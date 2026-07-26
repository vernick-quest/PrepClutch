-- ── Migration 008 — Backfill question history from past attempts ─────────────
--
-- BUG: ReadingQuizClient (passage-based reading flow) wrote to quiz_attempts
-- but never called upsert_question_history. Because get_section_mastery and
-- leaderboard_view both compute totals from user_question_history JOIN questions,
-- reading points showed on the results page but never reached the section total.
--
-- The code fix makes reading record history going forward. This migration
-- credits every question users have ALREADY answered by replaying
-- quiz_attempts.answers (the complete record of every answer ever submitted)
-- into user_question_history.
--
-- Idempotent: safe to run more than once. times_correct/times_wrong use
-- GREATEST so a re-run never regresses an existing mastery.
--
-- NOTE: answers whose question_id is not a UUID present in `questions` are
-- skipped. That excludes the 10 hardcoded questions from the retired
-- lib/reading-passages.ts sample set, which never existed in the question bank.
--
-- Run this as a new query in the Supabase SQL editor.

-- ── 1. Repair passage_id for any questions seeded after migration 006 ────────
--
-- 006 back-filled passage_id for the rows that existed then. Passage content
-- seeded afterwards has passage_id NULL, which would scatter one passage into
-- several single-question passages in the reading quiz. Group by passage text,
-- reusing the id already assigned to that text where one exists.

DO $$
DECLARE
  rec    RECORD;
  new_id UUID;
BEGIN
  FOR rec IN
    SELECT DISTINCT passage
    FROM questions
    WHERE passage IS NOT NULL AND passage_id IS NULL
  LOOP
    SELECT passage_id INTO new_id
    FROM questions
    WHERE passage = rec.passage AND passage_id IS NOT NULL
    LIMIT 1;

    IF new_id IS NULL THEN
      new_id := gen_random_uuid();
    END IF;

    UPDATE questions
    SET passage_id = new_id
    WHERE passage = rec.passage AND passage_id IS NULL;
  END LOOP;
END $$;


-- ── 2. Credit every question already answered ────────────────────────────────

INSERT INTO user_question_history AS uqh
  (user_id, question_id, last_answered_at, times_seen, times_correct, times_wrong)
SELECT
  qa.user_id,
  (ans->>'question_id')::UUID                                        AS question_id,
  MAX(COALESCE(qa.completed_at, qa.started_at))                      AS last_answered_at,
  COUNT(*)::INT                                                      AS times_seen,
  COUNT(*) FILTER (
    WHERE (ans->>'selected_index')::INT = (ans->>'correct_index')::INT
  )::INT                                                             AS times_correct,
  COUNT(*) FILTER (
    WHERE (ans->>'selected_index')::INT IS DISTINCT FROM (ans->>'correct_index')::INT
  )::INT                                                             AS times_wrong
FROM quiz_attempts qa
-- The array guard must live INSIDE the LATERAL: jsonb_array_elements is
-- evaluated before the WHERE clause, so a single row whose `answers` is not a
-- JSON array (null, object, malformed) would abort the entire backfill.
CROSS JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(qa.answers) = 'array' THEN qa.answers ELSE '[]'::JSONB END
) AS ans
WHERE ans->>'question_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  -- Numeric guards, not just NOT NULL: a non-integer value would fail the ::INT
  -- cast during aggregation and abort the backfill.
  AND ans->>'selected_index' ~ '^-?[0-9]+$'
  AND ans->>'correct_index'  ~ '^-?[0-9]+$'
  AND EXISTS (
    SELECT 1 FROM questions q WHERE q.id = (ans->>'question_id')::UUID
  )
GROUP BY qa.user_id, (ans->>'question_id')::UUID
ON CONFLICT (user_id, question_id) DO UPDATE SET
  times_seen       = GREATEST(uqh.times_seen,       EXCLUDED.times_seen),
  times_correct    = GREATEST(uqh.times_correct,    EXCLUDED.times_correct),
  times_wrong      = GREATEST(uqh.times_wrong,      EXCLUDED.times_wrong),
  last_answered_at = GREATEST(uqh.last_answered_at, EXCLUDED.last_answered_at);


-- ── Verification ──────────────────────────────────────────────────────────────
-- Per-user reading mastery after the backfill. Reading score should now be > 0
-- for anyone who has completed a reading quiz.
--
--   SELECT p.display_name, m.section, m.score, m.max_score, m.correct, m.total
--   FROM profiles p
--   CROSS JOIN LATERAL get_section_mastery(p.id) m
--   WHERE m.section = 'reading'
--   ORDER BY m.score DESC;
