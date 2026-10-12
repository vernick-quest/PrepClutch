-- 062 — Math Facts: fact history, Fact Points, leaderboard
--
-- A separate track at prepclutch.com/math. Its own table, its own points, its
-- own leaderboard. Nothing here reads or writes questions,
-- user_question_history or leaderboard_view, so Clutch Points cannot move.
--
-- Cards are generated, not stored: multiplication and division with factors
-- 1-12, each in three forms (classic, missing first number, missing second).
-- math_fact_cards lists all 864 and is the source of truth for what a card is
-- worth and how fast it must be answered. lib/math-facts.ts mirrors it.
--
-- A card is mastered (fluent_at set) the first time it is answered correctly
-- within its target time. fluent_at is never cleared, so a later slow or wrong
-- answer can never take Fact Points away.
--
-- SAFE: purely additive. Re-running is harmless.


-- ── 1. The card catalogue ────────────────────────────────────────────────────

CREATE OR REPLACE VIEW math_fact_cards AS
SELECT
  o.op || ':' || a.n || ':' || b.n || ':' || f.form   AS fact_key,
  o.op, a.n AS a, b.n AS b, f.form,
  CASE WHEN f.form = 'c' THEN 10   ELSE 15   END      AS points,
  CASE WHEN f.form = 'c' THEN 3000 ELSE 5000 END      AS target_ms
FROM unnest(ARRAY['mul', 'div'])   AS o(op)
CROSS JOIN generate_series(1, 12)  AS a(n)
CROSS JOIN generate_series(1, 12)  AS b(n)
CROSS JOIN unnest(ARRAY['c', 'l', 'r']) AS f(form);

GRANT SELECT ON math_fact_cards TO authenticated;


-- ── 2. Per-student history ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS fact_history (
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fact_key         TEXT        NOT NULL,
  times_correct    INT         NOT NULL DEFAULT 0,
  times_wrong      INT         NOT NULL DEFAULT 0,
  best_ms          INT,
  last_ms          INT,
  fluent_at        TIMESTAMPTZ,
  last_answered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, fact_key)
);

ALTER TABLE fact_history ENABLE ROW LEVEL SECURITY;

-- Students read their own rows. There are no insert or update policies: every
-- write goes through record_fact_answer, which is what guarantees fluent_at
-- is only ever set, never cleared.
DROP POLICY IF EXISTS "fact_history_select_own" ON fact_history;
CREATE POLICY "fact_history_select_own"
  ON fact_history FOR SELECT
  USING (auth.uid() = user_id);


-- ── 3. Recording an answer ───────────────────────────────────────────────────
--
-- Returns TRUE when this answer mastered the card for the first time, so the
-- client can report newly earned Fact Points without trusting its own clock
-- for the threshold. Unknown keys are refused.

CREATE OR REPLACE FUNCTION record_fact_answer(
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
    RAISE EXCEPTION 'record_fact_answer requires a signed-in user';
  END IF;

  SELECT c.target_ms INTO target FROM math_fact_cards c WHERE c.fact_key = p_key;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'unknown fact key %', p_key;
  END IF;

  -- Under 200ms is not a human reading a card.
  fast := p_correct AND p_ms IS NOT NULL AND p_ms BETWEEN 200 AND target;

  SELECT h.fluent_at IS NOT NULL INTO was_fluent
    FROM fact_history h WHERE h.user_id = uid AND h.fact_key = p_key;

  INSERT INTO fact_history AS h
    (user_id, fact_key, times_correct, times_wrong, best_ms, last_ms, fluent_at, last_answered_at)
  VALUES
    (uid, p_key,
     CASE WHEN p_correct THEN 1 ELSE 0 END,
     CASE WHEN p_correct THEN 0 ELSE 1 END,
     CASE WHEN p_correct AND p_ms >= 200 THEN p_ms END,
     p_ms,
     CASE WHEN fast THEN now() END,
     now())
  ON CONFLICT (user_id, fact_key) DO UPDATE SET
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

REVOKE ALL ON FUNCTION record_fact_answer(TEXT, BOOLEAN, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION record_fact_answer(TEXT, BOOLEAN, INT) TO authenticated;


-- ── 4. Leaderboard ───────────────────────────────────────────────────────────
--
-- Same shape as leaderboard_view (one row per profile) so the dashboard
-- patterns carry over. Aggregates only: no individual answers are exposed.

CREATE OR REPLACE VIEW math_leaderboard_view AS
SELECT
  p.id AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  COALESCE(SUM(c.points) FILTER (WHERE h.fluent_at IS NOT NULL), 0)::INT                   AS points,
  COALESCE(SUM(c.points) FILTER (WHERE h.fluent_at IS NOT NULL AND c.op = 'mul'), 0)::INT AS mul_points,
  COALESCE(SUM(c.points) FILTER (WHERE h.fluent_at IS NOT NULL AND c.op = 'div'), 0)::INT AS div_points,
  COUNT(h.fluent_at)::INT                                                                  AS fluent
FROM profiles p
LEFT JOIN fact_history    h ON h.user_id  = p.id
LEFT JOIN math_fact_cards c ON c.fact_key = h.fact_key
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code;

GRANT SELECT ON math_leaderboard_view TO authenticated;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected: cards 864, unique_keys 864, max_points 11520, history_table 1,
--           leaderboard_rows = number of profiles, points_total 0 on first run.

SELECT
  (SELECT COUNT(*) FROM math_fact_cards)                     AS cards,
  (SELECT COUNT(DISTINCT fact_key) FROM math_fact_cards)     AS unique_keys,
  (SELECT SUM(points) FROM math_fact_cards)                  AS max_points,
  (SELECT COUNT(*) FROM information_schema.tables
    WHERE table_name = 'fact_history')                       AS history_table,
  (SELECT COUNT(*) FROM math_leaderboard_view)               AS leaderboard_rows,
  (SELECT COUNT(*) FROM profiles)                            AS profiles,
  (SELECT SUM(points) FROM math_leaderboard_view)            AS points_total;
