-- ── Migration 007: Cumulative mastery scoring ────────────────────────────────
--
-- Clutch Points are now cumulative: every unique question a student answers
-- correctly adds its base points (Easy=10, Medium=20, Hard=35) to their total.
-- Answering the same question correctly again does not double-count.
--
-- This replaces the old MAX(total_xp per quiz run) approach.
--
-- Run this as a new query in the Supabase SQL editor.

-- ── 1. New RPC: per-section mastery score + max possible score ────────────────
--
-- Returns one row per section with:
--   score     = sum of base points for questions this user has mastered (times_correct > 0)
--   max_score = sum of base points for ALL questions in that section (same for every user)
--   correct   = count of questions mastered
--   seen      = count of questions attempted at least once
--   total     = total questions in section

CREATE OR REPLACE FUNCTION get_section_mastery(p_user_id UUID)
RETURNS TABLE(
  section   TEXT,
  score     INT,
  max_score INT,
  correct   INT,
  seen      INT,
  total     INT
)
LANGUAGE sql SECURITY DEFINER AS $$
  SELECT
    q.section,
    COALESCE(SUM(
      CASE WHEN uqh.times_correct > 0
        THEN CASE q.difficulty WHEN 1 THEN 10 WHEN 2 THEN 20 WHEN 3 THEN 35 ELSE 20 END
        ELSE 0
      END
    ), 0)::INT                                                              AS score,
    SUM(
      CASE q.difficulty WHEN 1 THEN 10 WHEN 2 THEN 20 WHEN 3 THEN 35 ELSE 20 END
    )::INT                                                                  AS max_score,
    COUNT(DISTINCT CASE WHEN uqh.times_correct > 0 THEN q.id END)::INT     AS correct,
    COUNT(DISTINCT uqh.question_id)::INT                                    AS seen,
    COUNT(DISTINCT q.id)::INT                                               AS total
  FROM questions q
  LEFT JOIN user_question_history uqh
    ON uqh.question_id = q.id AND uqh.user_id = p_user_id
  GROUP BY q.section;
$$;

-- ── 2. Rebuild leaderboard_view using cumulative mastery ──────────────────────
--
-- aggregate_score  = total base points across all mastered questions (all sections)
-- verbal_score     = mastery score for verbal section only
-- … etc.

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
    AND q.section IN ('verbal', 'quantitative', 'reading', 'math', 'language')
  GROUP BY uqh.user_id, q.section
)
SELECT
  p.id           AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  COALESCE(SUM(m.section_score), 0)                                          AS aggregate_score,
  COALESCE(MAX(CASE WHEN m.section = 'verbal'       THEN m.section_score END), 0) AS verbal_score,
  COALESCE(MAX(CASE WHEN m.section = 'quantitative' THEN m.section_score END), 0) AS quantitative_score,
  COALESCE(MAX(CASE WHEN m.section = 'reading'      THEN m.section_score END), 0) AS reading_score,
  COALESCE(MAX(CASE WHEN m.section = 'math'         THEN m.section_score END), 0) AS math_score,
  COALESCE(MAX(CASE WHEN m.section = 'language'     THEN m.section_score END), 0) AS language_score,
  COALESCE(SUM(m.section_score), 0)                                          AS total_xp
FROM profiles p
LEFT JOIN mastery m ON m.user_id = p.id
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code;
