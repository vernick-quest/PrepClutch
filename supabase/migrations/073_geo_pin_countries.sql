-- 073 - Geography: Pin the map, find the country
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
--                                   af 110/1400 km, as 120/1500 km, eu 50/650 km, na 80/1000 km, sa 80/1000 km, oc 90/1200 km
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
  SELECT CASE WHEN p_ms BETWEEN 0 AND 3000 THEN 10 WHEN p_ms BETWEEN 0 AND 6000 THEN 5 ELSE 0 END
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
      FROM (VALUES ('af', 110::DOUBLE PRECISION, 1400::DOUBLE PRECISION), ('as', 120::DOUBLE PRECISION, 1500::DOUBLE PRECISION), ('eu', 50::DOUBLE PRECISION, 650::DOUBLE PRECISION), ('na', 80::DOUBLE PRECISION, 1000::DOUBLE PRECISION), ('sa', 80::DOUBLE PRECISION, 1000::DOUBLE PRECISION), ('oc', 90::DOUBLE PRECISION, 1200::DOUBLE PRECISION)) AS v(cont, bull, zero)
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
    SELECT c || ':' || l FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  cont := split_part(p_deck, ':', 1);
  IF jsonb_typeof(p_pins) IS DISTINCT FROM 'array' OR jsonb_array_length(p_pins) <> 10 THEN
    RAISE EXCEPTION 'a pin round has 10 places';
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

  IF places <> 10 THEN
    RAISE EXCEPTION 'a pin round needs 10 different places of its continent';
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

-- The tiny countries (lib/geo-pin.ts TINY_COUNTRIES: under 6000 km2 of
-- land on the map). A tap within 75 km of one's capital finds it,
-- unless the tap is inside another tiny country.
CREATE OR REPLACE FUNCTION geo_pin_tiny_isos()
RETURNS TEXT[]
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT ARRAY['AD', 'AG', 'BB', 'BH', 'BN', 'CV', 'DM', 'FM', 'GD', 'KI', 'KM', 'KN', 'LC', 'LI', 'LU', 'MC', 'MH', 'MT', 'MU', 'MV', 'NR', 'PW', 'SC', 'SG', 'SM', 'ST', 'TO', 'TT', 'TV', 'VC', 'WS']::TEXT[]
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
('crimea', 'Crimea', 'RU', ARRAY['RU', 'UA']::TEXT[], ARRAY[32.3, 45.2, 32.9, 45.95, 33.4, 46.25, 34.6, 46.2, 35.2, 45.7, 36.62, 45.6, 36.62, 44.9, 35, 44.3, 33.3, 44.3]::DOUBLE PRECISION[]),
('donbas', 'the Donbas', 'UA', ARRAY['RU', 'UA']::TEXT[], ARRAY[36.55, 47.6, 36.6, 48.3, 37, 49, 37.6, 49.2, 38, 49.9, 38.9, 50.15, 39.9, 49.7, 40.2, 49, 39.8, 47.85, 38.25, 47.1, 37.3, 46.95, 36.8, 47.1]::DOUBLE PRECISION[]),
('zaporizhzhia-kherson', 'Zaporizhzhia and Kherson', 'UA', ARRAY['RU', 'UA']::TEXT[], ARRAY[32, 46.4, 32.2, 47.2, 33.3, 47.6, 34.3, 47.85, 35.2, 48.1, 36.3, 47.9, 36.8, 47.1, 36.6, 46.7, 35.2, 46.2, 34.4, 46, 33.4, 46.05, 32.5, 46.1]::DOUBLE PRECISION[]),
('kurils', 'the southern Kuril Islands', 'RU', ARRAY['JP', 'RU']::TEXT[], ARRAY[145.3, 43.2, 149, 43.2, 149, 45.7, 145.3, 45.7]::DOUBLE PRECISION[]),
('golan', 'the Golan Heights', 'IL', ARRAY['IL', 'SY']::TEXT[], ARRAY[35.69, 33.33, 35.85, 33.33, 35.95, 32.9, 35.85, 32.7, 35.63, 32.7, 35.64, 32.85, 35.65, 33, 35.62, 33.1, 35.66, 33.25]::DOUBLE PRECISION[]),
('palestine', 'Palestine', 'PSX', ARRAY['IL']::TEXT[], NULL),
('kashmir-in', 'Kashmir', 'IN', ARRAY['IN', 'PK']::TEXT[], ARRAY[73.45, 33, 73.4, 34, 73.4, 34.45, 73.7, 34.6, 73.95, 34.85, 73.8, 35.3, 72.5, 35.9, 73.6, 36.9, 74.6, 37.1, 75.8, 36.9, 76.6, 36.4, 77.8, 35.9, 78.5, 36, 80.2, 35.9, 80.4, 35.2, 79.6, 34.3, 78.8, 33, 79.5, 32.5, 78.4, 32.4, 77.9, 32.8, 76.6, 33.1, 75.9, 32.6, 75.45, 32.3, 74.6, 32.7]::DOUBLE PRECISION[]),
('kashmir-pk', 'Kashmir', 'PK', ARRAY['IN', 'PK']::TEXT[], ARRAY[73.45, 33, 73.4, 34, 73.4, 34.45, 73.7, 34.6, 73.95, 34.85, 73.8, 35.3, 72.5, 35.9, 73.6, 36.9, 74.6, 37.1, 75.8, 36.9, 76.6, 36.4, 77.8, 35.9, 78.5, 36, 80.2, 35.9, 80.4, 35.2, 79.6, 34.3, 78.8, 33, 79.5, 32.5, 78.4, 32.4, 77.9, 32.8, 76.6, 33.1, 75.9, 32.6, 75.45, 32.3, 74.6, 32.7]::DOUBLE PRECISION[]),
('kashmir-siachen', 'Kashmir', 'KAS', ARRAY['IN', 'PK']::TEXT[], NULL),
('aksai-chin', 'Aksai Chin', 'CN', ARRAY['CN', 'IN']::TEXT[], ARRAY[73.45, 33, 73.4, 34, 73.4, 34.45, 73.7, 34.6, 73.95, 34.85, 73.8, 35.3, 72.5, 35.9, 73.6, 36.9, 74.6, 37.1, 75.8, 36.9, 76.6, 36.4, 77.8, 35.9, 78.5, 36, 80.2, 35.9, 80.4, 35.2, 79.6, 34.3, 78.8, 33, 79.5, 32.5, 78.4, 32.4, 77.9, 32.8, 76.6, 33.1, 75.9, 32.6, 75.45, 32.3, 74.6, 32.7]::DOUBLE PRECISION[]),
('arunachal', 'Arunachal Pradesh', 'IN', ARRAY['CN', 'IN']::TEXT[], ARRAY[91.55, 26.95, 92.6, 26.9, 93.8, 27.1, 94.6, 27.5, 95.4, 27.25, 96.2, 27.2, 97.5, 27.8, 97.5, 29.6, 91.55, 29.6]::DOUBLE PRECISION[]),
('taiwan', 'Taiwan', 'TWN', ARRAY['CN']::TEXT[], NULL),
('hong-kong', 'Hong Kong', 'HKG', ARRAY['CN']::TEXT[], NULL),
('kosovo', 'Kosovo', 'KOS', ARRAY['RS']::TEXT[], NULL),
('western-sahara', 'Western Sahara', 'SAH', ARRAY['MA']::TEXT[], NULL),
('essequibo', 'Essequibo', 'GY', ARRAY['GY', 'VE']::TEXT[], ARRAY[-61.4, 1.1, -58.55, 1.1, -58.55, 8.6, -61.4, 8.6]::DOUBLE PRECISION[]),
('abyei', 'Abyei', 'SD', ARRAY['SD', 'SS']::TEXT[], ARRAY[27.8, 9.3, 29, 9.3, 29, 10.1, 27.8, 10.1]::DOUBLE PRECISION[]),
('halaib', 'the Halaib Triangle', 'EG', ARRAY['EG', 'SD']::TEXT[], ARRAY[33.95, 22, 36.9, 22, 35.62, 23.15]::DOUBLE PRECISION[]),
('falklands', 'the Falkland Islands', 'FLK', ARRAY['AR', 'GB']::TEXT[], NULL),
('south-georgia', 'South Georgia', 'SGS', ARRAY['AR', 'GB']::TEXT[], NULL),
('chagos', 'the Chagos Islands', 'IOT', ARRAY['GB', 'MU']::TEXT[], NULL)
ON CONFLICT (area_key) DO UPDATE SET
  name = EXCLUDED.name, drawn = EXCLUDED.drawn, claimants = EXCLUDED.claimants, ring = EXCLUDED.ring;
DELETE FROM geo_disputed_areas WHERE area_key NOT IN ('crimea', 'donbas', 'zaporizhzhia-kherson', 'kurils', 'golan', 'palestine', 'kashmir-in', 'kashmir-pk', 'kashmir-siachen', 'aksai-chin', 'arunachal', 'taiwan', 'hong-kong', 'kosovo', 'western-sahara', 'essequibo', 'abyei', 'halaib', 'falklands', 'south-georgia', 'chagos');


-- 4. Recording a country round
--
-- p_pins: exactly 10 objects {iso, tap, lat, lon, ms}, one per
-- DIFFERENT country of the deck's continent (iso: a country with a capital
-- in geo_pin_places). tap is what the map has where the student tapped (a
-- UN member alpha-2, a neutral shape alpha-3, or null for the sea), lat and
-- lon where they tapped (all three null if they gave up), ms how long they
-- took. A pin finds the country when the tap is in it, OR the country is
-- tiny and the tap is within 75 km of its capital and not inside
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
    SELECT c || ':' || l || ':country' FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  cont := split_part(p_deck, ':', 1);
  IF jsonb_typeof(p_pins) IS DISTINCT FROM 'array' OR jsonb_array_length(p_pins) <> 10 THEN
    RAISE EXCEPTION 'a country round has 10 countries';
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
             OR (j.iso = ANY (tiny) AND (j.tap IS NULL OR NOT (j.tap = ANY (tiny))) AND j.km <= 75)
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

  IF n_iso <> 10 THEN
    RAISE EXCEPTION 'a country round needs 10 different countries of its continent';
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
    SELECT c || ':' || l || m FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l, unnest(ARRAY['', ':country']) AS m
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
   WHERE r.deck IN (SELECT c || ':' || l FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l)
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
-- Expected: new_functions 6, tiny_countries 31, disputed_areas 21,
--           capitals 193, place_rounds (any number, all rescored),
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
