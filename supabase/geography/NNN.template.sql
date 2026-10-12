-- NNN — Geography: country cards, Explorer Points, badges, round history
--
-- A separate track at prepclutch.com/geo, built the same way as Math Facts
-- (062-068) but in its own tables. Nothing here reads or writes questions,
-- Clutch Points, fact_history or any math table.
--
--   geo_cards             the __CARDS__ cards: 193 UN member states x 7 kinds
--                         (capital, capital to country, flag, pick the flag,
--                         currency, language, continent), loaded from
--                         lib/geo.ts, with points and target times
--   geo_history           one row per student per card. A card is mastered
--                         (fluent_at set) the first time it is answered right
--                         within its target time. fluent_at is never cleared,
--                         so no later answer can take Explorer Points away.
--   record_geo_answer     the only way to write geo_history
--   geo_leaderboard_view  Explorer Points per profile, for class and global boards
--   geo_rounds            one row per finished round, display only
--   __BADGES__ badges        category Geography, awarded in SQL from geo_history
--                         (only the perfect round is reported by the client),
--                         backfilled at the end
--
-- Admins (profiles.is_admin) can read every student's geo_history and
-- geo_rounds. Students read only their own.
--
-- Additive. Re-running is harmless: the catalogue and badge definitions
-- upsert, awards ignore duplicates, nothing is ever deleted.
-- Generated: do not edit by hand. Change lib/geo.ts or
-- supabase/geography/NNN.template.sql, then run
--   node supabase/geography/cards.mts
-- The generator refuses to write if any string literal contains a semicolon,
-- a dollar sign or a double dash (the Supabase editor misparses those).


-- ── 1. The catalogue ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS geo_cards (
  card_key  TEXT PRIMARY KEY,
  iso       TEXT NOT NULL,
  kind      TEXT NOT NULL,
  continent TEXT NOT NULL,
  points    INT  NOT NULL,
  target_ms INT  NOT NULL
);

ALTER TABLE geo_cards ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "geo_cards_readable" ON geo_cards;
CREATE POLICY "geo_cards_readable" ON geo_cards FOR SELECT USING (TRUE);
-- Supabase grants every new table to anon and authenticated by default. Only
-- reading is wanted.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_cards FROM anon, authenticated;
GRANT SELECT ON geo_cards TO anon, authenticated;

INSERT INTO geo_cards (card_key, iso, kind, continent, points, target_ms) VALUES
__ROWS__
ON CONFLICT (card_key) DO UPDATE SET
  iso = EXCLUDED.iso, kind = EXCLUDED.kind, continent = EXCLUDED.continent,
  points = EXCLUDED.points, target_ms = EXCLUDED.target_ms;


-- ── 2. Per-student history ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS geo_history (
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  card_key         TEXT        NOT NULL,
  times_correct    INT         NOT NULL DEFAULT 0,
  times_wrong      INT         NOT NULL DEFAULT 0,
  best_ms          INT,
  last_ms          INT,
  fluent_at        TIMESTAMPTZ,
  last_answered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, card_key)
);

ALTER TABLE geo_history ENABLE ROW LEVEL SECURITY;

-- Read policies only. Every write goes through record_geo_answer, which is
-- what guarantees fluent_at is only ever set, never cleared.
DROP POLICY IF EXISTS "geo_history_select_own" ON geo_history;
CREATE POLICY "geo_history_select_own" ON geo_history FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "geo_history_select_admin" ON geo_history;
CREATE POLICY "geo_history_select_admin" ON geo_history FOR SELECT
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin));

REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_history FROM anon, authenticated;
REVOKE ALL ON geo_history FROM anon;
GRANT SELECT ON geo_history TO authenticated;


-- ── 3. Recording an answer ───────────────────────────────────────────────────
--
-- Returns TRUE when this answer mastered the card for the first time, so the
-- client can show newly earned Explorer Points without deciding the threshold
-- itself. Unknown keys are refused.

CREATE OR REPLACE FUNCTION record_geo_answer(
  p_key     TEXT,
  p_correct BOOLEAN,
  p_ms      INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid        UUID := auth.uid();
  target     INT;
  fast       BOOLEAN;
  was_fluent BOOLEAN;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'record_geo_answer requires a signed-in user';
  END IF;

  SELECT c.target_ms INTO target FROM geo_cards c WHERE c.card_key = p_key;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'unknown geography card %', p_key;
  END IF;

  -- Under 200ms is not a human reading a card.
  fast := COALESCE(p_correct AND p_ms IS NOT NULL AND p_ms BETWEEN 200 AND target, FALSE);

  SELECT h.fluent_at IS NOT NULL INTO was_fluent
    FROM geo_history h WHERE h.user_id = uid AND h.card_key = p_key;

  INSERT INTO geo_history AS h
    (user_id, card_key, times_correct, times_wrong, best_ms, last_ms, fluent_at, last_answered_at)
  VALUES
    (uid, p_key,
     CASE WHEN p_correct THEN 1 ELSE 0 END,
     CASE WHEN p_correct THEN 0 ELSE 1 END,
     CASE WHEN p_correct AND p_ms >= 200 THEN p_ms END,
     p_ms,
     CASE WHEN fast THEN now() END,
     now())
  ON CONFLICT (user_id, card_key) DO UPDATE SET
    times_correct    = h.times_correct + CASE WHEN p_correct THEN 1 ELSE 0 END,
    times_wrong      = h.times_wrong   + CASE WHEN p_correct THEN 0 ELSE 1 END,
    best_ms          = CASE WHEN p_correct AND p_ms >= 200
                         THEN LEAST(COALESCE(h.best_ms, p_ms), p_ms) ELSE h.best_ms END,
    last_ms          = p_ms,
    fluent_at        = COALESCE(h.fluent_at, CASE WHEN fast THEN now() END),
    last_answered_at = now();

  RETURN fast AND NOT COALESCE(was_fluent, FALSE);
END;
$$;

-- Supabase grants new functions to anon by default, so PUBLIC alone is not enough.
REVOKE ALL ON FUNCTION record_geo_answer(TEXT, BOOLEAN, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_geo_answer(TEXT, BOOLEAN, INT) TO authenticated;


-- ── 4. Leaderboard ───────────────────────────────────────────────────────────
--
-- One row per profile, like math_leaderboard_view. Aggregates only, no
-- individual answers.

CREATE OR REPLACE VIEW geo_leaderboard_view AS
SELECT
  p.id AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  COALESCE(SUM(c.points) FILTER (WHERE h.fluent_at IS NOT NULL), 0)::INT AS points,
  COUNT(h.fluent_at)::INT                                                AS fluent,
  COUNT(h.fluent_at) FILTER (WHERE c.kind IN ('cap', 'capr'))::INT       AS capitals,
  COUNT(h.fluent_at) FILTER (WHERE c.kind IN ('flag', 'flagr'))::INT     AS flags
FROM profiles p
LEFT JOIN geo_history h ON h.user_id  = p.id
LEFT JOIN geo_cards   c ON c.card_key = h.card_key
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code;

REVOKE ALL ON geo_leaderboard_view FROM anon;
GRANT SELECT ON geo_leaderboard_view TO authenticated;


-- ── 5. Round history ─────────────────────────────────────────────────────────
--
-- Display only: points and badges come from geo_history, so nothing here can
-- move anyone's Explorer Points.

CREATE TABLE IF NOT EXISTS geo_rounds (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deck         TEXT        NOT NULL,
  cards        INT         NOT NULL,
  correct      INT         NOT NULL,
  fast         INT         NOT NULL,
  points       INT         NOT NULL,
  answers      JSONB       NOT NULL,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS geo_rounds_user_time_idx ON geo_rounds (user_id, completed_at DESC);

ALTER TABLE geo_rounds ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "geo_rounds_select" ON geo_rounds;
CREATE POLICY "geo_rounds_select" ON geo_rounds FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin)
  );

DROP POLICY IF EXISTS "geo_rounds_insert_own" ON geo_rounds;
CREATE POLICY "geo_rounds_insert_own" ON geo_rounds FOR INSERT
  WITH CHECK (auth.uid() = user_id);

REVOKE ALL ON geo_rounds FROM anon;
REVOKE UPDATE, DELETE, TRUNCATE ON geo_rounds FROM authenticated;
GRANT SELECT, INSERT ON geo_rounds TO authenticated;


-- ── 6. Badge definitions ─────────────────────────────────────────────────────

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

__BADGE_ROWS__

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;


-- ── 7. Awarding ──────────────────────────────────────────────────────────────
--
-- award_geo_badges_for does the work for any student and is NOT callable by
-- students (revoked below), or anyone could award badges to anyone. Students
-- call award_geo_badges, which only ever acts on themselves. Returns the keys
-- newly awarded by this call. Badges are only ever inserted, never removed.

CREATE OR REPLACE FUNCTION award_geo_badges_for(p_user UUID, p_perfect_round BOOLEAN DEFAULT FALSE)
RETURNS SETOF TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH g AS (
    SELECT c.kind, c.continent, (h.fluent_at IS NOT NULL) AS fluent
    FROM geo_cards c
    LEFT JOIN geo_history h ON h.card_key = c.card_key AND h.user_id = p_user
  ),
  earned(key) AS (
    SELECT 'geo_mastered_' || t FROM unnest(ARRAY[__LADDER__]) AS t
     WHERE (SELECT COUNT(*) FROM g WHERE fluent) >= t
    UNION ALL
    SELECT 'geo_mastered_all'
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE NOT fluent)
    UNION ALL
    SELECT 'geo_continent_' || ct FROM unnest(ARRAY[__CONTINENTS__]) AS ct
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE continent = ct AND NOT fluent)
    UNION ALL
    SELECT 'geo_' || r.grp || '_' || r.t
      FROM (VALUES __GROUP_STEPS__) AS r(grp, kinds, t)
     WHERE (SELECT COUNT(*) FROM g WHERE kind = ANY (r.kinds) AND fluent) >= r.t
    UNION ALL
    SELECT 'geo_' || r.grp || '_all'
      FROM (VALUES __GROUP_ALL__) AS r(grp, kinds)
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE kind = ANY (r.kinds) AND NOT fluent)
    UNION ALL
    SELECT 'geo_perfect_round' WHERE p_perfect_round
  )
  INSERT INTO user_achievements (user_id, achievement_key)
  SELECT p_user, e.key
    FROM earned e
    JOIN achievement_definitions d ON d.key = e.key
   WHERE EXISTS (SELECT 1 FROM profiles p WHERE p.id = p_user)
  ON CONFLICT (user_id, achievement_key) DO NOTHING
  RETURNING achievement_key;
$$;

REVOKE ALL ON FUNCTION award_geo_badges_for(UUID, BOOLEAN) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION award_geo_badges(p_perfect_round BOOLEAN DEFAULT FALSE)
RETURNS SETOF TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'award_geo_badges requires a signed-in user';
  END IF;
  RETURN QUERY SELECT k FROM award_geo_badges_for(auth.uid(), p_perfect_round) AS k;
END;
$$;

REVOKE ALL ON FUNCTION award_geo_badges(BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION award_geo_badges(BOOLEAN) TO authenticated;


-- ── 8. Award what students have already earned ───────────────────────────────

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT DISTINCT user_id FROM geo_history LOOP
    PERFORM award_geo_badges_for(r.user_id, FALSE);
  END LOOP;
END $$;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected: cards __CARDS__, countries 193, max_points __MAXPTS__,
--           orphan_history 0, geo_badges __BADGES__, rounds_table 1,
--           helper_callable_by_students false, record_callable_by_anon false,
--           leaderboard_rows = number of profiles.

SELECT
  (SELECT COUNT(*) FROM geo_cards)                                        AS cards,
  (SELECT COUNT(DISTINCT iso) FROM geo_cards)                             AS countries,
  (SELECT SUM(points) FROM geo_cards)                                     AS max_points,
  (SELECT COUNT(*) FROM geo_history h
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = h.card_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography') AS geo_badges,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'geo_rounds') AS rounds_table,
  has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE')
                                                                           AS helper_callable_by_students,
  has_function_privilege('anon', 'record_geo_answer(text, boolean, integer)', 'EXECUTE')
                                                                           AS record_callable_by_anon,
  (SELECT COUNT(*) FROM geo_leaderboard_view)                             AS leaderboard_rows;
