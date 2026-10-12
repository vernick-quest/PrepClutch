-- __NUM__ — Geography map: Name that country, famous cities, Pin the map
--
-- Phase 2 of Geography (069 is phase 1 and must be applied first). Additive:
-- nothing here changes or removes an existing card, history row or award.
--
--   geo_cards                 + __SHAPES__ "Name that country" cards, kind
--                             'shape', one per UN member, __SHAPE_POINTS__ Explorer
--                             Points each, mastered within __SHAPE_SECS__ s
--                             + __CITIES__ "Which country is Rio de Janeiro in?"
--                             cards, kind 'city', one per famous city (not
--                             capitals, lib/geo-cities.ts), __CITY_POINTS__ points,
--                             mastered within __CITY_SECS__ s. Inserted only: the
--                             069 cards are not touched.
--   badges                    + Shape Spotter (25 shapes), Map Master (all
--                             __SHAPES__), City Hopper (25 cities), Globetrotter
--                             (all __CITIES__)
--   award_geo_badges_for      069's function copied exactly, with the shapes
--                             and cities rungs added to its two card-type
--                             lists. Still revoked from students.
--   badge descriptions        World Turtle and the six continent badges count
--                             every card, so they now include shape and city
--                             cards: their descriptions and thresholds are
--                             updated to the new totals. Nobody loses a badge.
--   geo_pin_places            the __PINS__ places Pin the map can ask (__PIN_CAPITALS__
--                             capitals, __PIN_CITIES__ cities), keyed 'cap:ke' or
--                             'city:rio-de-janeiro', with their coordinates and
--                             level (read-only)
--   geo_pin_rounds            one row per Pin the map round. Written ONLY by
--                             record_geo_pin_round, which scores the taps
--                             itself from geo_pin_places
--   geo_pin_leaderboard_view  best score per student per continent and level
--
-- Pin the map never touches geo_history or Explorer Points.
-- Admins (profiles.is_admin) can read every student's pin rounds. Students
-- read only their own.
--
-- Re-running is harmless: catalogues and badge definitions upsert, the award
-- function is replaced with the same text, nothing is deleted.
-- Generated: do not edit by hand. Change lib/geo.ts, lib/geo-pin.ts or
-- supabase/geography/NNN.template.sql, then run
--   node supabase/geography/map-cards.mts [--number 070]
-- The generator refuses to write if any string literal contains a semicolon,
-- a dollar sign or a double dash (the Supabase editor misparses those).


-- ── 1. The new cards: Name that country (shape) and famous cities (city) ─────
--
-- City cards are keyed by the city ('city:rio-de-janeiro'); iso and
-- continent are its country's. The WHERE below means a re-run can only ever
-- update cards of the new kinds, never a 069 card.

INSERT INTO geo_cards (card_key, iso, kind, continent, points, target_ms) VALUES
__ROWS__
ON CONFLICT (card_key) DO UPDATE SET
  iso = EXCLUDED.iso, kind = EXCLUDED.kind, continent = EXCLUDED.continent,
  points = EXCLUDED.points, target_ms = EXCLUDED.target_ms
  WHERE geo_cards.kind IN (__NEW_KINDS__);


-- ── 2. Badge definitions ─────────────────────────────────────────────────────

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

__BADGE_ROWS__

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;

-- Every-card badges now count the shape and city cards too.
__RETOTAL__


-- ── 3. Awarding: 069's function, plus the shapes and cities rungs ────────────

__AWARD_FUNCTION__


-- ── 4. Pin the map: the places ───────────────────────────────────────────────

-- A capital ('cap:ke', the asked capital of Kenya) or a famous city
-- ('city:rio-de-janeiro'). iso and continent are the country's. tier is the
-- Pin the map level the place belongs to (lib/geo.ts pinPlaces).

CREATE TABLE IF NOT EXISTS geo_pin_places (
  place_key TEXT PRIMARY KEY,
  kind      TEXT NOT NULL CHECK (kind IN ('capital', 'city')),
  name      TEXT NOT NULL,
  iso       TEXT NOT NULL,
  continent TEXT NOT NULL,
  tier      INT  NOT NULL CHECK (tier BETWEEN 1 AND 3),
  lat       DOUBLE PRECISION NOT NULL CHECK (lat BETWEEN -90 AND 90),
  lon       DOUBLE PRECISION NOT NULL CHECK (lon BETWEEN -180 AND 180)
);

ALTER TABLE geo_pin_places ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "geo_pin_places_readable" ON geo_pin_places;
CREATE POLICY "geo_pin_places_readable" ON geo_pin_places FOR SELECT USING (TRUE);
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_pin_places FROM anon, authenticated;
GRANT SELECT ON geo_pin_places TO anon, authenticated;

INSERT INTO geo_pin_places (place_key, kind, name, iso, continent, tier, lat, lon) VALUES
__PIN_ROWS__
ON CONFLICT (place_key) DO UPDATE SET
  kind = EXCLUDED.kind, name = EXCLUDED.name, iso = EXCLUDED.iso, continent = EXCLUDED.continent,
  tier = EXCLUDED.tier, lat = EXCLUDED.lat, lon = EXCLUDED.lon;


-- ── 5. Pin the map: rounds ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS geo_pin_rounds (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deck         TEXT        NOT NULL,
  score        INT         NOT NULL CHECK (score BETWEEN 0 AND __MAX_PIN__),
  answers      JSONB       NOT NULL,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS geo_pin_rounds_user_time_idx ON geo_pin_rounds (user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS geo_pin_rounds_deck_score_idx ON geo_pin_rounds (deck, score DESC);

ALTER TABLE geo_pin_rounds ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "geo_pin_rounds_select" ON geo_pin_rounds;
CREATE POLICY "geo_pin_rounds_select" ON geo_pin_rounds FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin)
  );

-- No insert policy and no insert grant: a round is written only by
-- record_geo_pin_round, which works out the score itself.
REVOKE ALL ON geo_pin_rounds FROM anon;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_pin_rounds FROM authenticated;
GRANT SELECT ON geo_pin_rounds TO authenticated;


-- ── 6. Recording a round ─────────────────────────────────────────────────────
--
-- p_pins: exactly __ROUND__ objects {i, lat, lon, ms}, one per DIFFERENT place of
-- the deck's continent: i is its place_key ('cap:ke', 'city:mombasa'). lat
-- and lon are where the student tapped (null if they gave up), ms how long
-- they took. Distance is great-circle km to the place in geo_pin_places,
-- scored by the rings of lib/geo-pin.ts:
-- __RINGS_COMMENT__, plus __SPEED_COMMENT__
-- on any scoring pin. Returns the round's score.

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
  ringed AS (
    SELECT d.*, CASE __RING_CASE__ ELSE 0 END AS ring FROM dist d
  ),
  pts AS (
    SELECT r.*, r.ring + CASE WHEN r.ring > 0 THEN (CASE __SPEED_CASE__ ELSE 0 END) ELSE 0 END AS points FROM ringed r
  )
  SELECT COUNT(DISTINCT place), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', place, 'km', round(km::NUMERIC), 'ms', ms, 'p', points) ORDER BY ord)
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


-- ── 7. Pin the map leaderboard ───────────────────────────────────────────────
--
-- Best score per profile per deck ("eu:1" is Europe, level 1). Aggregates
-- only, no individual pins.

CREATE OR REPLACE VIEW geo_pin_leaderboard_view AS
SELECT
  p.id AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  r.deck,
  MAX(r.score)::INT AS best,
  COUNT(*)::INT     AS rounds
FROM geo_pin_rounds r
JOIN profiles p ON p.id = r.user_id
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code, r.deck;

REVOKE ALL ON geo_pin_leaderboard_view FROM anon;
GRANT SELECT ON geo_pin_leaderboard_view TO authenticated;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected: cards __CARDS__, shape_cards __SHAPES__, city_cards __CITIES__,
--           phase1_cards __P1CARDS__, phase1_points __P1POINTS__, max_points __MAXPTS__,
--           orphan_history 0, geo_badges __BADGES__, pin_places __PINS__,
--           pin_cities __PIN_CITIES__, pin_rounds_table 1,
--           helper_callable_by_students false,
--           pin_record_callable_by_anon false, pin_insert_by_students false.

SELECT
  (SELECT COUNT(*) FROM geo_cards)                                        AS cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'shape')                   AS shape_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'city')                    AS city_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind NOT IN (__NEW_KINDS__))      AS phase1_cards,
  (SELECT SUM(points) FROM geo_cards WHERE kind NOT IN (__NEW_KINDS__))   AS phase1_points,
  (SELECT SUM(points) FROM geo_cards)                                     AS max_points,
  (SELECT COUNT(*) FROM geo_history h
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = h.card_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography') AS geo_badges,
  (SELECT COUNT(*) FROM geo_pin_places)                                   AS pin_places,
  (SELECT COUNT(*) FROM geo_pin_places WHERE kind = 'city')               AS pin_cities,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'geo_pin_rounds') AS pin_rounds_table,
  has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE')
                                                                           AS helper_callable_by_students,
  has_function_privilege('anon', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
                                                                           AS pin_record_callable_by_anon,
  has_table_privilege('authenticated', 'geo_pin_rounds', 'INSERT')        AS pin_insert_by_students;
