
) AS v(key, section, sort_order, concept, prompt, passage, options, correct_index, difficulty, explanation, option_notes);


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- One row per section. Expected on every row:
--   questions 15 · easy 5 · medium 5 · hard 5 · labelled 15 · notes_ok true
--   max_answer_share <= 27%
-- and scoring_bank_untouched = 1500 on every row (the quiz bank never moves).

SELECT
  t.section::TEXT                                                   AS section,
  COUNT(*)                                                          AS questions,
  COUNT(*) FILTER (WHERE t.difficulty = 1)                          AS easy,
  COUNT(*) FILTER (WHERE t.difficulty = 2)                          AS medium,
  COUNT(*) FILTER (WHERE t.difficulty = 3)                          AS hard,
  COUNT(t.concept)                                                  AS labelled,
  bool_and(jsonb_array_length(t.option_notes) = 4
           AND NOT (t.option_notes::TEXT LIKE '%""%'))              AS notes_ok,
  ROUND(100.0 * MAX(pos.n) / COUNT(*)) || '%'                          AS max_answer_share,
  (SELECT COUNT(*) FROM questions)                                  AS scoring_bank_untouched
FROM training_questions t
JOIN LATERAL (
  SELECT COUNT(*) AS n FROM training_questions t2
  WHERE t2.section = t.section AND t2.correct_index = t.correct_index
) pos ON true
WHERE t.exam = 'hspt'
GROUP BY t.section
ORDER BY t.section;
