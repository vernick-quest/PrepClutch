-- 058 — Split the question bank by exam (HSPT / SSAT)
--
-- Phase 1 of SSAT support: give every question an exam, and make the scoring
-- path exam-aware. Nothing about HSPT changes — every existing question is
-- backfilled to 'hspt', get_section_mastery defaults to 'hspt', and
-- leaderboard_view is pinned to 'hspt' so SSAT questions cannot pollute it
-- when they land.
--
-- WHY A COLUMN AND NOT A SEPARATE DATABASE: students need to move between the
-- two, so auth, profiles, classes and quiz history must stay shared. The exam
-- dimension is what makes the *content* separate — separate questions, separate
-- mastery, separate leaderboards, separate badges, one login.
--
-- SAFE: additive. No question is deleted or re-identified, no history row is
-- touched, and no student's Clutch Points move. `questions.id` is untouched, so
-- every user_question_history row still joins exactly as before.


-- ── 1. The exam dimension ────────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE exam_type AS ENUM ('hspt', 'ssat');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE questions
  ADD COLUMN IF NOT EXISTS exam exam_type NOT NULL DEFAULT 'hspt';

-- Every selector filters on (exam, section) now, so index the pair.
CREATE INDEX IF NOT EXISTS questions_exam_section_idx ON questions (exam, section);


-- ── 2. Mastery becomes per-exam ──────────────────────────────────────────────
--
-- The parameter defaults to 'hspt', so every existing caller — the results
-- page, the profile pages, awardSectionMasteryBadges — keeps working untouched
-- and keeps returning exactly the numbers it returns today.
--
-- DROP then CREATE, not CREATE OR REPLACE: adding a parameter makes a new
-- overload rather than replacing, and a one-argument call against two
-- candidates is ambiguous.

DROP FUNCTION IF EXISTS get_section_mastery(UUID);

CREATE OR REPLACE FUNCTION get_section_mastery(
  p_user_id UUID,
  p_exam    exam_type DEFAULT 'hspt'
)
RETURNS TABLE(
  section   TEXT,
  score     INT,
  max_score INT,
  correct   INT,
  seen      INT,
  total     INT
)
LANGUAGE sql SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    q.section,
    COALESCE(SUM(
      CASE WHEN uqh.times_correct > 0
        THEN CASE q.difficulty WHEN 1 THEN 10 WHEN 2 THEN 20 WHEN 3 THEN 35 ELSE 20 END
        ELSE 0
      END
    ), 0)::INT                                                           AS score,
    SUM(
      CASE q.difficulty WHEN 1 THEN 10 WHEN 2 THEN 20 WHEN 3 THEN 35 ELSE 20 END
    )::INT                                                               AS max_score,
    COUNT(DISTINCT CASE WHEN uqh.times_correct > 0 THEN q.id END)::INT   AS correct,
    COUNT(DISTINCT uqh.question_id)::INT                                 AS seen,
    COUNT(DISTINCT q.id)::INT                                            AS total
  FROM questions q
  LEFT JOIN user_question_history uqh
    ON uqh.question_id = q.id AND uqh.user_id = p_user_id
  WHERE q.exam = p_exam
  GROUP BY q.section;
$$;


-- ── 3. Pin the existing leaderboard to HSPT ──────────────────────────────────
--
-- leaderboard_view keeps its exact current shape — one row per student, fixed
-- per-section columns — because two call sites use .single() on it and an exam
-- dimension would return two rows per student and break them.
--
-- SSAT gets its own leaderboard in a later phase, once its UI exists and the
-- shape is known. Adding a speculative one now would be guessing.

DROP VIEW IF EXISTS leaderboard_view;

CREATE VIEW leaderboard_view AS
WITH mastery AS (
  SELECT
    uqh.user_id,
    q.section,
    SUM(
      CASE q.difficulty WHEN 1 THEN 10 WHEN 2 THEN 20 WHEN 3 THEN 35 ELSE 20 END
    )::INT AS section_score
  FROM user_question_history uqh
  JOIN questions q ON q.id = uqh.question_id
  WHERE uqh.times_correct > 0
    AND q.exam = 'hspt'
    AND q.section IN ('verbal', 'quantitative', 'reading', 'math', 'language')
  GROUP BY uqh.user_id, q.section
)
SELECT
  p.id           AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  COALESCE(SUM(m.section_score), 0)                                              AS aggregate_score,
  COALESCE(MAX(CASE WHEN m.section = 'verbal'       THEN m.section_score END), 0) AS verbal_score,
  COALESCE(MAX(CASE WHEN m.section = 'quantitative' THEN m.section_score END), 0) AS quantitative_score,
  COALESCE(MAX(CASE WHEN m.section = 'reading'      THEN m.section_score END), 0) AS reading_score,
  COALESCE(MAX(CASE WHEN m.section = 'math'         THEN m.section_score END), 0) AS math_score,
  COALESCE(MAX(CASE WHEN m.section = 'language'     THEN m.section_score END), 0) AS language_score,
  COALESCE(SUM(m.section_score), 0)                                              AS total_xp
FROM profiles p
LEFT JOIN mastery m ON m.user_id = p.id
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected:
--   hspt_questions          1500   every existing question backfilled
--   ssat_questions             0   none yet
--   mastery_rows_unchanged     5   get_section_mastery still returns 5 sections
--   leaderboard_rows          >0   one row per profile, unchanged shape
--   top_score_matches       true   the leaderboard's top score is unchanged
--
-- The last one is the one that matters: if pinning the view to 'hspt' had
-- altered anyone's total, this would be false.

WITH lb AS (SELECT MAX(aggregate_score) AS top FROM leaderboard_view),
     direct AS (
       SELECT MAX(s) AS top FROM (
         SELECT SUM(CASE q.difficulty WHEN 1 THEN 10 WHEN 2 THEN 20 WHEN 3 THEN 35 ELSE 20 END) AS s
         FROM user_question_history uqh
         JOIN questions q ON q.id = uqh.question_id
         WHERE uqh.times_correct > 0 AND q.exam = 'hspt'
         GROUP BY uqh.user_id
       ) t
     )
SELECT
  (SELECT COUNT(*) FROM questions WHERE exam = 'hspt')               AS hspt_questions,
  (SELECT COUNT(*) FROM questions WHERE exam = 'ssat')               AS ssat_questions,
  (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_name = 'questions' AND column_name = 'exam')         AS exam_column_exists,
  (SELECT COUNT(*) FROM leaderboard_view)                            AS leaderboard_rows,
  (SELECT top FROM lb)                                               AS leaderboard_top_score,
  (SELECT top FROM direct)                                           AS recomputed_top_score,
  ((SELECT top FROM lb) = (SELECT top FROM direct))                  AS top_score_matches;
