-- ============================================================
-- 006_engine_refactor.sql
-- Four-pillar engine refactor:
--   1. passage_id on questions (reading passage batching)
--   2. user_question_history table (deduplication)
--   3. upsert_question_history RPC (atomic increment)
--   4. get_section_coverage RPC (dashboard coverage bars)
--   5. leaderboard_view recreated on raw XP totals
-- ============================================================

-- ── 1. passage_id ────────────────────────────────────────────
ALTER TABLE questions
  ADD COLUMN IF NOT EXISTS passage_id UUID;

-- Back-fill: assign a shared UUID to all rows with identical passage text
DO $$
DECLARE
  rec    RECORD;
  new_id UUID;
BEGIN
  FOR rec IN
    SELECT DISTINCT passage FROM questions WHERE passage IS NOT NULL
  LOOP
    new_id := gen_random_uuid();
    UPDATE questions SET passage_id = new_id WHERE passage = rec.passage;
  END LOOP;
END $$;

CREATE INDEX IF NOT EXISTS idx_questions_passage_id ON questions(passage_id);
CREATE INDEX IF NOT EXISTS idx_questions_section    ON questions(section);

-- ── 2. user_question_history ─────────────────────────────────
CREATE TABLE IF NOT EXISTS user_question_history (
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id      UUID        NOT NULL REFERENCES questions(id)  ON DELETE CASCADE,
  last_answered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  times_seen       INT         NOT NULL DEFAULT 1,
  times_correct    INT         NOT NULL DEFAULT 0,
  times_wrong      INT         NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, question_id)
);

ALTER TABLE user_question_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "uqh_select_own" ON user_question_history;
DROP POLICY IF EXISTS "uqh_insert_own" ON user_question_history;
DROP POLICY IF EXISTS "uqh_update_own" ON user_question_history;

CREATE POLICY "uqh_select_own"
  ON user_question_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "uqh_insert_own"
  ON user_question_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "uqh_update_own"
  ON user_question_history FOR UPDATE
  USING (auth.uid() = user_id);

-- ── 3. upsert_question_history RPC ───────────────────────────
CREATE OR REPLACE FUNCTION upsert_question_history(
  p_user_id     UUID,
  p_question_id UUID,
  p_correct     BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO user_question_history
    (user_id, question_id, last_answered_at, times_seen, times_correct, times_wrong)
  VALUES
    (p_user_id, p_question_id, now(), 1,
      CASE WHEN p_correct THEN 1 ELSE 0 END,
      CASE WHEN NOT p_correct THEN 1 ELSE 0 END)
  ON CONFLICT (user_id, question_id) DO UPDATE SET
    last_answered_at = now(),
    times_seen       = user_question_history.times_seen + 1,
    times_correct    = user_question_history.times_correct
                       + CASE WHEN p_correct THEN 1 ELSE 0 END,
    times_wrong      = user_question_history.times_wrong
                       + CASE WHEN NOT p_correct THEN 1 ELSE 0 END;
END;
$$;

GRANT EXECUTE ON FUNCTION upsert_question_history(UUID, UUID, BOOLEAN)
  TO authenticated;

-- ── 4. get_section_coverage RPC ──────────────────────────────
CREATE OR REPLACE FUNCTION get_section_coverage(p_user_id UUID)
RETURNS TABLE(section TEXT, seen INT, total INT)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    q.section::TEXT,
    COUNT(DISTINCT uqh.question_id)::INT AS seen,
    COUNT(DISTINCT q.id)::INT            AS total
  FROM questions q
  LEFT JOIN user_question_history uqh
    ON uqh.question_id = q.id AND uqh.user_id = p_user_id
  GROUP BY q.section;
$$;

GRANT EXECUTE ON FUNCTION get_section_coverage(UUID)
  TO authenticated;

-- ── 5. leaderboard_view (raw XP, not percentages) ────────────
DROP VIEW IF EXISTS leaderboard_view;

CREATE VIEW leaderboard_view AS
WITH best AS (
  SELECT
    user_id,
    section,
    MAX(total_xp) AS best_xp
  FROM quiz_attempts
  WHERE completed_at IS NOT NULL
    AND section != 'full'
  GROUP BY user_id, section
)
SELECT
  p.id                                                                  AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  COALESCE(SUM(b.best_xp), 0)                                          AS aggregate_score,
  COALESCE(MAX(CASE WHEN b.section = 'verbal'       THEN b.best_xp END), 0) AS verbal_score,
  COALESCE(MAX(CASE WHEN b.section = 'quantitative' THEN b.best_xp END), 0) AS quantitative_score,
  COALESCE(MAX(CASE WHEN b.section = 'reading'      THEN b.best_xp END), 0) AS reading_score,
  COALESCE(MAX(CASE WHEN b.section = 'math'         THEN b.best_xp END), 0) AS math_score,
  COALESCE(MAX(CASE WHEN b.section = 'language'     THEN b.best_xp END), 0) AS language_score,
  COALESCE((
    SELECT SUM(total_xp)
    FROM quiz_attempts
    WHERE user_id = p.id AND completed_at IS NOT NULL
  ), 0)                                                                 AS total_xp
FROM profiles p
LEFT JOIN best b ON b.user_id = p.id
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code;

GRANT SELECT ON leaderboard_view TO authenticated;
