-- 068 — Math Facts round history, and admin read access to Math Facts
--
-- 1. fact_rounds: one row per finished round, so students can look back at
--    their results the way HSPT quiz history works. Display only: scoring
--    and badges still come from fact_history, so nothing here can move
--    anyone's Fact Points.
--
-- 2. Admins can read every student's rounds and fact_history, so a student's
--    profile can show an admin their Math Facts progress. Students still see
--    only their own.
--
-- Additive and re-runnable.

CREATE TABLE IF NOT EXISTS fact_rounds (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deck         TEXT        NOT NULL,     -- mul, div, equiv, fdp, or mul:7 for one table
  cards        INT         NOT NULL,
  correct      INT         NOT NULL,
  fast         INT         NOT NULL,
  points       INT         NOT NULL,     -- Fact Points newly earned this round
  answers      JSONB       NOT NULL,     -- [{k, g, c, ms}] key, given, correct, time
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS fact_rounds_user_time_idx ON fact_rounds (user_id, completed_at DESC);

ALTER TABLE fact_rounds ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "fact_rounds_select" ON fact_rounds;
CREATE POLICY "fact_rounds_select" ON fact_rounds FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin)
  );

DROP POLICY IF EXISTS "fact_rounds_insert_own" ON fact_rounds;
CREATE POLICY "fact_rounds_insert_own" ON fact_rounds FOR INSERT
  WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT ON fact_rounds TO authenticated;

-- Admins read everyone's fact history. Writes still go only through
-- record_fact_answer.
DROP POLICY IF EXISTS "fact_history_select_admin" ON fact_history;
CREATE POLICY "fact_history_select_admin" ON fact_history FOR SELECT
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin));

-- Expected: rounds_table 1, round_policies 2, admin_history_policy 1
SELECT
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'fact_rounds')        AS rounds_table,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'fact_rounds')                       AS round_policies,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'fact_history'
     AND policyname = 'fact_history_select_admin')                                           AS admin_history_policy;
