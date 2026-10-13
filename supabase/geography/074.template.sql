-- __NUM__ - Geography: Pin the map masters cards
--
-- Needs 069-073. Every Geography game now feeds the same Explorer Points:
-- playing Pin the map masters cards, exactly as a quiz answer does. A
-- round's own score (stars, distance points, "better than X%", the per-map
-- best boards) stays what it was: round feedback, like a quiz round's
-- "7/10 correct".
--
--   geo_cards                 + __FIND__ 'find' cards ("Find Kenya on the map"),
--                             one per country Find the country asks (every
--                             UN member but __NOT_ASKED__), keyed 'find:ke'
--                             + __PIN__ 'pin' cards ("Pin Nairobi"), one per
--                             Pin the map place, keyed 'pin:' + the place key
--                             ('pin:cap:ke', 'pin:city:rio-de-janeiro').
--                             Both __POINTS__ Explorer Points, mastered within
--                             __SECS__ s. Inserted only: no other card is touched.
--                             The catalogue becomes __CARDS__ cards and
--                             __MAXPTS__ Explorer Points (was __OLD_CARDS__ and __OLD_MAXPTS__).
--   geo_pin_grade             a pin's verdict as a grade, the same thresholds
--                             as lib/geo-pin.ts pinVerdict: 2 = Bullseye or
--                             Great (within __GREAT_PCT__% of the continent's
--                             zero radius), 1 = Close (within __CLOSE_PCT__%),
--                             0 = the rest
--   geo_pin_master            writes a round's taps into geo_history with
--                             record_geo_answer's rules: a find, or a pin
--                             graded 2, within the card's target time (and
--                             at least 200 ms) masters it, fluent_at set
--                             once and never cleared. A slow find, or a
--                             Close pin, is right but not mastered. A miss,
--                             a give-up or an Off pin counts as wrong.
--                             Nothing is ever lowered. Not callable by clients.
--   record_geo_pin_round      073's functions: same signatures, same checks,
--   record_geo_country_round  same scoring and the same INT return, with two
--                             changes: the round row records mastery_at, and
--                             the same taps go through geo_pin_master in the
--                             same transaction.
--   geo_pin_rounds.mastery_at when a round's taps reached geo_history. NULL =
--                             not yet, which is how the backfill below finds
--                             the rounds saved before this migration (and why
--                             a second run changes nothing).
--   badges                    + Country Seeker (25 finds), Pathfinder (all
--                             __FIND__), Sharp Pin (25 pins), Grand Cartographer
--                             (all __PIN__). World Turtle and the continent
--                             ladders count every card, so find and pin
--                             cards now count toward them: the half rungs
--                             and the full continent badges get new
--                             thresholds. Everything a student has already
--                             earned is awarded FIRST, under the rules it was
--                             earned by, and badges are never removed.
--   award_geo_badges_for      072's, with the find and pin rungs and the new
--                             half thresholds. Still revoked from students.
--
-- Explorer Points (geo_leaderboard_view) and every page's points and "N of M
-- cards mastered" add up geo_cards, so they include the new cards with no
-- other change.
--
-- Re-running is harmless: cards and badges upsert, functions are replaced
-- with the same text, the backfill only takes rounds with no mastery_at, and
-- awards ignore duplicates.
--
-- Generated: do not edit by hand. Change lib/geo.ts, lib/geo-meta.ts,
-- lib/geo-pin.ts or supabase/geography/074.template.sql, then run
--   node supabase/geography/pin-mastery.mts
-- The generator copies the round functions from 073 and the award function
-- from 072 (changing only what is listed above), and refuses to write if any
-- string literal contains a semicolon, a dollar sign or a double dash (the
-- Supabase editor misparses those), or if the file is not pure ASCII.


-- 1. Award what students have already earned, under the rules they earned it by
--
-- The next steps add cards to the every-card and continent badges. Anything
-- a student qualifies for today is awarded first, so it can never slip out
-- of reach. (On a re-run this is the new function: also harmless.)

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT DISTINCT user_id FROM geo_history LOOP
    PERFORM award_geo_badges_for(r.user_id, FALSE);
  END LOOP;
END $$;


-- 2. The new cards
--
-- The WHERE below means a re-run can only ever update find and pin cards,
-- never an older card.

INSERT INTO geo_cards (card_key, iso, kind, continent, points, target_ms) VALUES
__ROWS__
ON CONFLICT (card_key) DO UPDATE SET
  iso = EXCLUDED.iso, kind = EXCLUDED.kind, continent = EXCLUDED.continent,
  points = EXCLUDED.points, target_ms = EXCLUDED.target_ms
  WHERE geo_cards.kind IN ('find', 'pin');


-- 3. When a round reached geo_history

ALTER TABLE geo_pin_rounds ADD COLUMN IF NOT EXISTS mastery_at TIMESTAMPTZ;


-- 4. Judging and writing
--
-- A place pin's grade: 2 for Bullseye or Great, 1 for Close, 0 for Off, Way
-- off, a give-up (NULL km) or an unknown continent. lib/geo-pin.ts
-- pinVerdict, same thresholds, same double arithmetic. Keep them in step.

CREATE OR REPLACE FUNCTION geo_pin_grade(p_cont TEXT, p_km DOUBLE PRECISION)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT COALESCE((
    SELECT CASE
             WHEN p_km IS NULL THEN 0
             WHEN p_km <= v.bull OR p_km <= v.zero * __GREAT_SHARE__::DOUBLE PRECISION THEN 2
             WHEN p_km <= v.zero * __CLOSE_SHARE__::DOUBLE PRECISION THEN 1
             ELSE 0
           END
      FROM (VALUES __ACCURACY__) AS v(cont, bull, zero)
     WHERE v.cont = p_cont
  ), 0)
$$;

-- One round's taps into geo_history, with record_geo_answer's rules (069):
-- right = a find, or a pin graded 1 or 2. Fast = a find or a grade-2 pin,
-- in at least 200 ms (under that is not a person) and within the card's
-- target_ms. times_correct or times_wrong goes up by one, best_ms only
-- improves, fluent_at is set the first time a card is fast and never
-- cleared. p_mode is 'country' (answers {i: iso, h: hit, ms}) or 'place'
-- (answers {i: place key, km, ms}), as the round functions store them.
-- p_at is when (now() for a new round, the round's own time in the
-- backfill). Taps on a card the catalogue lacks are skipped. Returns how
-- many cards this round mastered for the first time.

CREATE OR REPLACE FUNCTION geo_pin_master(p_user UUID, p_cont TEXT, p_mode TEXT, p_answers JSONB, p_at TIMESTAMPTZ)
RETURNS INT
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  n INT;
BEGIN
  IF p_user IS NULL OR p_mode IS NULL OR p_mode NOT IN ('country', 'place')
     OR jsonb_typeof(p_answers) IS DISTINCT FROM 'array' THEN
    RETURN 0;
  END IF;

  WITH a AS (
    SELECT DISTINCT ON (k.card_key) k.card_key, k.grade, k.ms
      FROM (
        SELECT e.ord,
               CASE WHEN p_mode = 'country' THEN 'find:' || lower(e.v ->> 'i') ELSE 'pin:' || lower(e.v ->> 'i') END AS card_key,
               CASE WHEN p_mode = 'country'
                    THEN CASE WHEN COALESCE((e.v ->> 'h')::BOOLEAN, FALSE) THEN 2 ELSE 0 END
                    ELSE geo_pin_grade(p_cont, (e.v ->> 'km')::DOUBLE PRECISION)
               END AS grade,
               (e.v ->> 'ms')::INT AS ms
          FROM jsonb_array_elements(p_answers) WITH ORDINALITY AS e(v, ord)
      ) k
     ORDER BY k.card_key, k.ord
  ),
  j AS (
    SELECT a.card_key, a.ms, a.grade > 0 AS correct,
           COALESCE(a.grade = 2 AND a.ms BETWEEN 200 AND c.target_ms, FALSE) AS fast
      FROM a
      JOIN geo_cards c ON c.card_key = a.card_key
                      AND c.kind = CASE WHEN p_mode = 'country' THEN 'find' ELSE 'pin' END
  ),
  up AS (
    INSERT INTO geo_history AS h
      (user_id, card_key, times_correct, times_wrong, best_ms, last_ms, fluent_at, last_answered_at)
    SELECT p_user, j.card_key,
           CASE WHEN j.correct THEN 1 ELSE 0 END,
           CASE WHEN j.correct THEN 0 ELSE 1 END,
           CASE WHEN j.correct AND j.ms >= 200 THEN j.ms END,
           j.ms,
           CASE WHEN j.fast THEN p_at END,
           p_at
      FROM j
    ON CONFLICT (user_id, card_key) DO UPDATE SET
      times_correct    = h.times_correct + EXCLUDED.times_correct,
      times_wrong      = h.times_wrong   + EXCLUDED.times_wrong,
      best_ms          = CASE WHEN EXCLUDED.best_ms IS NOT NULL
                           THEN LEAST(COALESCE(h.best_ms, EXCLUDED.best_ms), EXCLUDED.best_ms) ELSE h.best_ms END,
      last_ms          = EXCLUDED.last_ms,
      fluent_at        = COALESCE(h.fluent_at, EXCLUDED.fluent_at),
      last_answered_at = GREATEST(h.last_answered_at, EXCLUDED.last_answered_at)
    RETURNING h.card_key
  )
  -- Every part of one statement sees the table as it was before it, so this
  -- counts cards that were not mastered until this round.
  SELECT COUNT(*) INTO n
    FROM j
   WHERE j.fast
     AND NOT EXISTS (SELECT 1 FROM geo_history g
                      WHERE g.user_id = p_user AND g.card_key = j.card_key AND g.fluent_at IS NOT NULL);
  RETURN n;
END;
$$;

REVOKE ALL ON FUNCTION geo_pin_grade(TEXT, DOUBLE PRECISION) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION geo_pin_master(UUID, TEXT, TEXT, JSONB, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;


-- 5. The round functions: 073's, plus mastery
--
-- Copied from 073 by the generator. The only change in each is the line that
-- saves the round, which now also records mastery_at, and the call to
-- geo_pin_master after it. The score and the INT returned are as before.

__PLACE_FUNCTION__

__COUNTRY_FUNCTION__


-- 6. Badges

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

__BADGE_ROWS__

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;

-- The every-card and continent badges count the new cards too.
__RETOTAL__


-- 7. Awarding: 072's function, plus the find and pin rungs and the new halves

__AWARD_FUNCTION__

REVOKE ALL ON FUNCTION award_geo_badges_for(UUID, BOOLEAN) FROM PUBLIC, anon, authenticated;


-- 8. Backfill: every round saved before this migration masters its cards
--
-- Oldest first, each at its own time, through the same geo_pin_master the
-- round functions use, so a backfilled card is exactly what playing that
-- round today would have given. Places rounds saved before 073 stored whole
-- km, so a pin within half a km of a verdict line may be graded as the
-- other side of it. Only rounds with no mastery_at are taken, and each is
-- marked as it goes: a second run finds none.

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT id, user_id, deck, answers, completed_at FROM geo_pin_rounds
     WHERE mastery_at IS NULL
     ORDER BY completed_at, id
  LOOP
    IF r.deck IN (SELECT c || ':' || l || ':country' FROM unnest(ARRAY[__CONTINENTS__]) AS c, unnest(ARRAY['1', '2', '3']) AS l) THEN
      PERFORM geo_pin_master(r.user_id, split_part(r.deck, ':', 1), 'country', r.answers, r.completed_at);
    ELSIF r.deck IN (SELECT c || ':' || l FROM unnest(ARRAY[__CONTINENTS__]) AS c, unnest(ARRAY['1', '2', '3']) AS l) THEN
      PERFORM geo_pin_master(r.user_id, split_part(r.deck, ':', 1), 'place', r.answers, r.completed_at);
    END IF;
    UPDATE geo_pin_rounds SET mastery_at = now() WHERE id = r.id;
  END LOOP;
END $$;


-- 9. Award what the backfill earned

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT DISTINCT user_id FROM geo_history LOOP
    PERFORM award_geo_badges_for(r.user_id, FALSE);
  END LOOP;
END $$;


-- Verification
--
-- Expected: find_cards __FIND__, pin_cards __PIN__, cards __CARDS__, max_points __MAXPTS__,
--           pin_cards_without_place 0, places_without_pin_card 0,
--           orphan_history 0, geo_badges __BADGES__, unfed_rounds 0,
--           find_pin_history (any number: one row per student per find or
--           pin card ever played), find_pin_mastered (any number, at most
--           find_pin_history),
--           helpers_callable_by_students false, master_callable_by_anon false,
--           rounds_callable_by_anon false, rounds_callable_by_students true,
--           history_insert_by_students false.

SELECT
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'find')                    AS find_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'pin')                     AS pin_cards,
  (SELECT COUNT(*) FROM geo_cards)                                        AS cards,
  (SELECT SUM(points) FROM geo_cards)                                     AS max_points,
  (SELECT COUNT(*) FROM geo_cards c WHERE c.kind = 'pin'
    AND NOT EXISTS (SELECT 1 FROM geo_pin_places p WHERE 'pin:' || p.place_key = c.card_key)) AS pin_cards_without_place,
  (SELECT COUNT(*) FROM geo_pin_places p
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = 'pin:' || p.place_key)) AS places_without_pin_card,
  (SELECT COUNT(*) FROM geo_history h
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = h.card_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography') AS geo_badges,
  (SELECT COUNT(*) FROM geo_pin_rounds WHERE mastery_at IS NULL)          AS unfed_rounds,
  (SELECT COUNT(*) FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key
    WHERE c.kind IN ('find', 'pin'))                                      AS find_pin_history,
  (SELECT COUNT(*) FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key
    WHERE c.kind IN ('find', 'pin') AND h.fluent_at IS NOT NULL)          AS find_pin_mastered,
  has_function_privilege('authenticated', 'geo_pin_master(uuid, text, text, jsonb, timestamp with time zone)', 'EXECUTE')
    OR has_function_privilege('authenticated', 'geo_pin_grade(text, double precision)', 'EXECUTE')
    OR has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE') AS helpers_callable_by_students,
  has_function_privilege('anon', 'geo_pin_master(uuid, text, text, jsonb, timestamp with time zone)', 'EXECUTE')
    OR has_function_privilege('anon', 'geo_pin_grade(text, double precision)', 'EXECUTE') AS master_callable_by_anon,
  has_function_privilege('anon', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
    OR has_function_privilege('anon', 'record_geo_country_round(text, jsonb)', 'EXECUTE') AS rounds_callable_by_anon,
  has_function_privilege('authenticated', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
    AND has_function_privilege('authenticated', 'record_geo_country_round(text, jsonb)', 'EXECUTE') AS rounds_callable_by_students,
  has_table_privilege('authenticated', 'geo_history', 'INSERT')
    OR has_table_privilege('authenticated', 'geo_history', 'UPDATE')      AS history_insert_by_students;
