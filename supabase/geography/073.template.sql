-- __NUM__ - Geography: Pin the map, find the country
--
-- Needs 070 (geo_pin_places, geo_pin_rounds, record_geo_pin_round). Pin the
-- map only: nothing here reads or writes geo_cards, geo_history, Explorer
-- Points, card mastery or badges.
--
--   geo_pin_speed, geo_pin_points   the scoring, as small IMMUTABLE helpers so
--                                   the round functions and the rescore below
--                                   share one formula. Not callable by clients.
--   record_geo_pin_round            replaced, same signature and the same
--                                   checks. Places now score by distance
--                                   SCALED TO THE CONTINENT'S MAP instead of
--                                   070's rings (the same on every continent):
--                                   100 within the bullseye radius, then a
--                                   square curve down to 0 at the zero radius
--                                   (lib/geo-pin.ts PIN_ACCURACY):
--                                   __ACC_COMMENT__
--                                   plus 10 for 3 s or 5 for 6 s on any
--                                   scoring pin. Still 1,100 at most.
--   geo_in_ring, geo_pin_tiny_isos  helpers for the country rules. Not
--   geo_disputed_areas              callable or readable by clients.
--   record_geo_country_round        "Find the country" rounds, decks like
--                                   'af:1:country'. Re-checks every tap.
--   geo_pin_percentile              how a score compares with every round
--                                   on a deck: two numbers, no rows.
--   rescore                         every places round saved under 070's
--                                   rings is rescored with the new rule
--                                   (Robert approved, 2026-10-12). Scores can
--                                   go down as well as up. Country rounds
--                                   and everything outside Pin the map are
--                                   untouched.
--
-- Re-running is harmless: functions are replaced with the same text, the
-- disputed areas upsert, and the rescore recomputes the same points (it
-- changes nothing the second time).
--
-- Generated: do not edit by hand. Change lib/geo-pin.ts or
-- supabase/geography/073.template.sql, then run
--   node supabase/geography/pin-countries.mts
-- The generator refuses to write if any string literal contains a semicolon,
-- a dollar sign or a double dash (the Supabase editor misparses those), or
-- if the file is not pure ASCII.


-- 1. Scoring helpers

-- The speed bonus on a scoring pin. lib/geo-pin.ts PIN_SPEED.
CREATE OR REPLACE FUNCTION geo_pin_speed(p_ms INT)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE __SPEED_CASE__ ELSE 0 END
$$;

-- A place pin's points: distance points on the continent's scale, plus the
-- speed bonus when they are above 0. A NULL km (gave up) or an unknown
-- continent is 0. Same arithmetic, in the same order, as lib/geo-pin.ts
-- distancePoints, so the two give the same integer. Keep them in step.
CREATE OR REPLACE FUNCTION geo_pin_points(p_cont TEXT, p_km DOUBLE PRECISION, p_ms INT)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$
  WITH a AS (
    SELECT v.bull, v.zero
      FROM (VALUES __ACCURACY__) AS v(cont, bull, zero)
     WHERE v.cont = p_cont
  ),
  d AS (
    SELECT CASE
             WHEN p_km IS NULL THEN 0
             WHEN p_km <= a.bull THEN 100
             WHEN p_km >= a.zero THEN 0
             ELSE floor(100 * ((a.zero - p_km) / (a.zero - a.bull)) * ((a.zero - p_km) / (a.zero - a.bull)) + 0.5)::INT
           END AS pts
      FROM a
  )
  SELECT COALESCE((SELECT pts + CASE WHEN pts > 0 THEN geo_pin_speed(p_ms) ELSE 0 END FROM d), 0)
$$;

REVOKE ALL ON FUNCTION geo_pin_speed(INT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION geo_pin_points(TEXT, DOUBLE PRECISION, INT) FROM PUBLIC, anon, authenticated;


-- 2. Places: record_geo_pin_round, rescaled
--
-- 070's function (same arguments, same checks) with the ring CASE replaced
-- by geo_pin_points, and one change to what it stores: each pin's km is
-- kept unrounded, so the rescore below, run again later, recomputes exactly
-- the points this function gave (from a whole km it could be a point off).

CREATE OR REPLACE FUNCTION record_geo_pin_round(p_deck TEXT, p_pins JSONB)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid    UUID := auth.uid();
  cont   TEXT;
  places INT;
  bad    INT;
  total  INT;
  scored JSONB;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'record_geo_pin_round requires a signed-in user';
  END IF;
  IF p_deck IS NULL OR p_deck NOT IN (
    SELECT c || ':' || l FROM unnest(ARRAY[__CONTINENTS__]) AS c, unnest(ARRAY['1', '2', '3']) AS l
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  cont := split_part(p_deck, ':', 1);
  IF jsonb_typeof(p_pins) IS DISTINCT FROM 'array' OR jsonb_array_length(p_pins) <> __ROUND__ THEN
    RAISE EXCEPTION 'a pin round has __ROUND__ places';
  END IF;

  WITH pins AS (
    SELECT e.ord,
           e.v ->> 'i'                AS place,
           (e.v ->> 'lat')::DOUBLE PRECISION AS lat,
           (e.v ->> 'lon')::DOUBLE PRECISION AS lon,
           (e.v ->> 'ms')::INT        AS ms
      FROM jsonb_array_elements(p_pins) WITH ORDINALITY AS e(v, ord)
  ),
  dist AS (
    SELECT p.ord, p.place, p.ms,
           CASE WHEN p.lat IS NULL OR p.lon IS NULL THEN NULL
                ELSE 2 * 6371 * asin(least(1, sqrt(
                       power(sin(radians(p.lat - g.lat) / 2), 2)
                       + cos(radians(g.lat)) * cos(radians(p.lat)) * power(sin(radians(p.lon - g.lon) / 2), 2))))
           END AS km,
           (p.lat IS NOT NULL AND NOT p.lat BETWEEN -90 AND 90)
             OR (p.lon IS NOT NULL AND NOT p.lon BETWEEN -180 AND 180)
             OR ((p.lat IS NULL) <> (p.lon IS NULL)) AS out_of_range
      FROM pins p
      JOIN geo_pin_places g ON g.place_key = p.place AND g.continent = cont
  ),
  pts AS (
    SELECT d.*, geo_pin_points(cont, d.km, d.ms) AS points FROM dist d
  )
  SELECT COUNT(DISTINCT place), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', place, 'km', km, 'ms', ms, 'p', points) ORDER BY ord)
    INTO places, bad, total, scored
    FROM pts;

  IF places <> __ROUND__ THEN
    RAISE EXCEPTION 'a pin round needs __ROUND__ different places of its continent';
  END IF;
  IF bad > 0 THEN
    RAISE EXCEPTION 'pin outside the map';
  END IF;

  INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES (uid, p_deck, total, scored);
  RETURN total;
END;
$$;

REVOKE ALL ON FUNCTION record_geo_pin_round(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_geo_pin_round(TEXT, JSONB) TO authenticated;


-- 3. Countries: the tiny-country and disputed-land rules

-- Even-odd point in one ring of [lon, lat, lon, lat, ...]. lib/geo-pin.ts
-- inFlatRing, same test.
CREATE OR REPLACE FUNCTION geo_in_ring(p_lon DOUBLE PRECISION, p_lat DOUBLE PRECISION, p_ring DOUBLE PRECISION[])
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  n      INT := COALESCE(array_length(p_ring, 1), 0);
  inside BOOLEAN := FALSE;
  i      INT := 1;
  j      INT;
  xi DOUBLE PRECISION; yi DOUBLE PRECISION; xj DOUBLE PRECISION; yj DOUBLE PRECISION;
BEGIN
  IF n < 6 OR p_lon IS NULL OR p_lat IS NULL THEN
    RETURN FALSE;
  END IF;
  j := n - 1;
  WHILE i < n LOOP
    xi := p_ring[i]; yi := p_ring[i + 1]; xj := p_ring[j]; yj := p_ring[j + 1];
    IF ((yi > p_lat) <> (yj > p_lat)) AND p_lon < ((xj - xi) * (p_lat - yi)) / (yj - yi) + xi THEN
      inside := NOT inside;
    END IF;
    j := i;
    i := i + 2;
  END LOOP;
  RETURN inside;
END;
$$;

-- The tiny countries (lib/geo-pin.ts TINY_COUNTRIES: under __TINY_KM2__ km2 of
-- land on the map). A tap within __RING_KM__ km of one's capital finds it,
-- unless the tap is inside another tiny country.
CREATE OR REPLACE FUNCTION geo_pin_tiny_isos()
RETURNS TEXT[]
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT ARRAY[__TINY__]::TEXT[]
$$;

REVOKE ALL ON FUNCTION geo_in_ring(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION[]) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION geo_pin_tiny_isos() FROM PUBLIC, anon, authenticated;

-- Disputed land as the map draws it (lib/geo-pin.ts DISPUTED_AREAS, where
-- each one is explained). A tap reported on `drawn` (a UN member alpha-2,
-- or a neutral shape alpha-3) and inside `ring` (all of it when NULL) is
-- right for every country in `claimants`.
CREATE TABLE IF NOT EXISTS geo_disputed_areas (
  area_key  TEXT PRIMARY KEY,
  name      TEXT NOT NULL,
  drawn     TEXT NOT NULL,
  claimants TEXT[] NOT NULL,
  ring      DOUBLE PRECISION[]
);

ALTER TABLE geo_disputed_areas ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON geo_disputed_areas FROM anon, authenticated;

INSERT INTO geo_disputed_areas (area_key, name, drawn, claimants, ring) VALUES
__AREA_ROWS__
ON CONFLICT (area_key) DO UPDATE SET
  name = EXCLUDED.name, drawn = EXCLUDED.drawn, claimants = EXCLUDED.claimants, ring = EXCLUDED.ring;
DELETE FROM geo_disputed_areas WHERE area_key NOT IN (__AREA_KEYS__);


-- 4. Recording a country round
--
-- p_pins: exactly __ROUND__ objects {iso, tap, lat, lon, ms}, one per
-- DIFFERENT country of the deck's continent (iso: a country with a capital
-- in geo_pin_places). tap is what the map has where the student tapped (a
-- UN member alpha-2, a neutral shape alpha-3, or null for the sea), lat and
-- lon where they tapped (all three null if they gave up), ms how long they
-- took. A pin finds the country when the tap is in it, OR the country is
-- tiny and the tap is within __RING_KM__ km of its capital and not inside
-- another tiny country, OR the tap is on disputed land the country is a
-- party to. A find scores 100 plus the speed bonus. Returns the score.

CREATE OR REPLACE FUNCTION record_geo_country_round(p_deck TEXT, p_pins JSONB)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid    UUID := auth.uid();
  cont   TEXT;
  n_iso  INT;
  bad    INT;
  total  INT;
  scored JSONB;
  tiny   TEXT[] := geo_pin_tiny_isos();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'record_geo_country_round requires a signed-in user';
  END IF;
  IF p_deck IS NULL OR p_deck NOT IN (
    SELECT c || ':' || l || ':country' FROM unnest(ARRAY[__CONTINENTS__]) AS c, unnest(ARRAY['1', '2', '3']) AS l
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  cont := split_part(p_deck, ':', 1);
  IF jsonb_typeof(p_pins) IS DISTINCT FROM 'array' OR jsonb_array_length(p_pins) <> __ROUND__ THEN
    RAISE EXCEPTION 'a country round has __ROUND__ countries';
  END IF;

  WITH pins AS (
    SELECT e.ord,
           e.v ->> 'iso'              AS iso,
           e.v ->> 'tap'              AS tap,
           (e.v ->> 'lat')::DOUBLE PRECISION AS lat,
           (e.v ->> 'lon')::DOUBLE PRECISION AS lon,
           (e.v ->> 'ms')::INT        AS ms
      FROM jsonb_array_elements(p_pins) WITH ORDINALITY AS e(v, ord)
  ),
  judged AS (
    SELECT p.*,
           CASE WHEN p.lat IS NULL OR p.lon IS NULL THEN NULL
                ELSE 2 * 6371 * asin(least(1, sqrt(
                       power(sin(radians(p.lat - g.lat) / 2), 2)
                       + cos(radians(g.lat)) * cos(radians(p.lat)) * power(sin(radians(p.lon - g.lon) / 2), 2))))
           END AS km,
           (p.lat IS NOT NULL AND NOT p.lat BETWEEN -90 AND 90)
             OR (p.lon IS NOT NULL AND NOT p.lon BETWEEN -180 AND 180)
             OR ((p.lat IS NULL) <> (p.lon IS NULL))
             OR (p.tap IS NOT NULL AND p.lat IS NULL)
             OR (p.tap IS NOT NULL AND (length(p.tap) NOT BETWEEN 2 AND 3 OR p.tap ~ '[^A-Z]')) AS out_of_range
      FROM pins p
      JOIN geo_pin_places g ON g.kind = 'capital' AND g.iso = p.iso AND g.continent = cont
  ),
  hits AS (
    SELECT j.*,
           COALESCE(j.lat IS NOT NULL AND (
             j.tap = j.iso
             OR (j.iso = ANY (tiny) AND (j.tap IS NULL OR NOT (j.tap = ANY (tiny))) AND j.km <= __RING_KM__)
             OR EXISTS (SELECT 1 FROM geo_disputed_areas a
                         WHERE a.drawn = j.tap AND j.iso = ANY (a.claimants)
                           AND (a.ring IS NULL OR geo_in_ring(j.lon, j.lat, a.ring)))
           ), FALSE) AS hit
      FROM judged j
  ),
  pts AS (
    SELECT h.*, CASE WHEN h.hit THEN 100 + geo_pin_speed(h.ms) ELSE 0 END AS points FROM hits h
  )
  SELECT COUNT(DISTINCT iso), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', iso, 't', tap, 'h', hit, 'ms', ms, 'p', points) ORDER BY ord)
    INTO n_iso, bad, total, scored
    FROM pts;

  IF n_iso <> __ROUND__ THEN
    RAISE EXCEPTION 'a country round needs __ROUND__ different countries of its continent';
  END IF;
  IF bad > 0 THEN
    RAISE EXCEPTION 'tap outside the map';
  END IF;

  INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES (uid, p_deck, total, scored);
  RETURN total;
END;
$$;

REVOKE ALL ON FUNCTION record_geo_country_round(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_geo_country_round(TEXT, JSONB) TO authenticated;


-- 5. How a score compares
--
-- Of every round on the deck (all students) other than the caller's most
-- recent one there (the round just saved), how many, and what percentage
-- scored below p_score. Two numbers, never a row or a name. The end screen
-- shows it from 10 rounds.

CREATE OR REPLACE FUNCTION geo_pin_percentile(p_deck TEXT, p_score INT)
RETURNS JSON
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid    UUID := auth.uid();
  latest UUID;
  n      INT;
  below  INT;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'geo_pin_percentile requires a signed-in user';
  END IF;
  IF p_deck IS NULL OR p_deck NOT IN (
    SELECT c || ':' || l || m FROM unnest(ARRAY[__CONTINENTS__]) AS c, unnest(ARRAY['1', '2', '3']) AS l, unnest(ARRAY['', ':country']) AS m
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  SELECT id INTO latest FROM geo_pin_rounds
   WHERE user_id = uid AND deck = p_deck ORDER BY completed_at DESC LIMIT 1;
  SELECT COUNT(*), COUNT(*) FILTER (WHERE score < p_score) INTO n, below
    FROM geo_pin_rounds WHERE deck = p_deck AND id IS DISTINCT FROM latest;
  RETURN json_build_object('rounds', n, 'better_than_pct', CASE WHEN n = 0 THEN 0 ELSE floor(100.0 * below / n)::INT END);
END;
$$;

REVOKE ALL ON FUNCTION geo_pin_percentile(TEXT, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION geo_pin_percentile(TEXT, INT) TO authenticated;


-- 6. Rescore the places rounds saved under 070's rings
--
-- Each stored pin keeps its place, km and ms; only its points (p) and the
-- round's score change, by the same geo_pin_points the new function uses.
-- Stored km is whole kilometres, so a rescored pin can differ by at most a
-- point from scoring the raw tap again. Rows already on the new rule are
-- left alone, so a second run changes nothing. Country rounds are not
-- touched (their decks end in ':country').

WITH el AS (
  SELECT r.id, e.ord, e.v,
         geo_pin_points(split_part(r.deck, ':', 1), (e.v ->> 'km')::DOUBLE PRECISION, (e.v ->> 'ms')::INT) AS p
    FROM geo_pin_rounds r
    CROSS JOIN LATERAL jsonb_array_elements(r.answers) WITH ORDINALITY AS e(v, ord)
   WHERE r.deck IN (SELECT c || ':' || l FROM unnest(ARRAY[__CONTINENTS__]) AS c, unnest(ARRAY['1', '2', '3']) AS l)
),
re AS (
  SELECT id, jsonb_agg(v || jsonb_build_object('p', p) ORDER BY ord) AS answers, SUM(p)::INT AS score
    FROM el GROUP BY id
)
UPDATE geo_pin_rounds r
   SET answers = re.answers, score = re.score
  FROM re
 WHERE r.id = re.id AND (r.answers IS DISTINCT FROM re.answers OR r.score IS DISTINCT FROM re.score);


-- Verification
--
-- Expected: new_functions 6, tiny_countries __TINY_COUNT__, disputed_areas __AREA_COUNT__,
--           capitals __CAPITALS__, place_rounds (any number, all rescored),
--           stale_place_pins 0, score_mismatches 0,
--           country_callable_by_anon false, country_callable_by_students true,
--           percentile_callable_by_anon false, helpers_callable_by_students false,
--           areas_readable_by_students false, pin_insert_by_students false.

SELECT
  (SELECT COUNT(*) FROM pg_proc WHERE proname IN ('geo_pin_speed', 'geo_pin_points', 'geo_in_ring',
     'geo_pin_tiny_isos', 'record_geo_country_round', 'geo_pin_percentile'))              AS new_functions,
  cardinality(geo_pin_tiny_isos())                                                          AS tiny_countries,
  (SELECT COUNT(*) FROM geo_disputed_areas)                                                 AS disputed_areas,
  (SELECT COUNT(*) FROM geo_pin_places WHERE kind = 'capital')                              AS capitals,
  (SELECT COUNT(*) FROM geo_pin_rounds WHERE deck NOT LIKE '%:country')                     AS place_rounds,
  (SELECT COUNT(*) FROM geo_pin_rounds r CROSS JOIN LATERAL jsonb_array_elements(r.answers) e
    WHERE r.deck NOT LIKE '%:country'
      AND (e ->> 'p')::INT IS DISTINCT FROM
          geo_pin_points(split_part(r.deck, ':', 1), (e ->> 'km')::DOUBLE PRECISION, (e ->> 'ms')::INT)) AS stale_place_pins,
  (SELECT COUNT(*) FROM geo_pin_rounds r
    WHERE r.score IS DISTINCT FROM (SELECT COALESCE(SUM((e ->> 'p')::INT), 0) FROM jsonb_array_elements(r.answers) e)) AS score_mismatches,
  has_function_privilege('anon', 'record_geo_country_round(text, jsonb)', 'EXECUTE')       AS country_callable_by_anon,
  has_function_privilege('authenticated', 'record_geo_country_round(text, jsonb)', 'EXECUTE') AS country_callable_by_students,
  has_function_privilege('anon', 'geo_pin_percentile(text, integer)', 'EXECUTE')           AS percentile_callable_by_anon,
  has_function_privilege('authenticated', 'geo_pin_points(text, double precision, integer)', 'EXECUTE')
    OR has_function_privilege('authenticated', 'geo_in_ring(double precision, double precision, double precision[])', 'EXECUTE')
    OR has_function_privilege('authenticated', 'geo_pin_tiny_isos()', 'EXECUTE')          AS helpers_callable_by_students,
  has_table_privilege('authenticated', 'geo_disputed_areas', 'SELECT')                      AS areas_readable_by_students,
  has_table_privilege('authenticated', 'geo_pin_rounds', 'INSERT')                          AS pin_insert_by_students;
