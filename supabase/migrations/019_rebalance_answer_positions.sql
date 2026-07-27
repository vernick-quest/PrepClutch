-- 019 — Rebalance answer positions across the question bank
--
-- The audit found the correct answer clustered hard on option B. Across 867
-- live questions the key sat at A/B/C/D in 89/397/322/59 rows, so a student
-- who always guessed B scored 46% — and 76% on reading, where D was never
-- correct once in 126 questions. "Pick the longest option" won 63% of the
-- time. Both beat the 25% a four-option guess should earn.
--
-- Two harms follow. Scores stop measuring knowledge, and mastery gets
-- recorded for questions that were pattern-matched rather than answered. Worse,
-- the real HSPT balances its answer positions, so a student trained here walks
-- in with a habit that fails exactly when it counts.
--
-- This shuffles each question's options and remaps correct_index to follow.
-- The shuffle runs in SQL against live rows, so it composes with any earlier
-- migration that rewrote options (018) without needing a fixed snapshot.
--
-- Run this AFTER 018, as a new query in the Supabase SQL editor.

-- ── 1. Shuffle ───────────────────────────────────────────────────────────────
--
-- For each question: pair every option with its 1-based ordinal, order the
-- pairs randomly, rebuild the array in that order, then find where the
-- originally-correct ordinal landed. ARRAY_POSITION returns a 1-based index,
-- so subtract 1 to get back to the 0-based correct_index the app expects.
--
-- jsonb_agg and array_agg share the same ORDER BY inside a group, so the
-- rebuilt option array and the ordinal array stay aligned.
--
-- EXCLUDED: questions whose option text refers to another option by letter
-- (e.g. "Both A and B are correct"). Shuffling those changes their meaning.

UPDATE questions q
SET options       = s.new_options,
    correct_index = s.new_correct_index
FROM (
  SELECT
    t.id,
    jsonb_agg(t.opt ORDER BY t.rnd)                                       AS new_options,
    ARRAY_POSITION(ARRAY_AGG(t.ord ORDER BY t.rnd), t.correct_ord) - 1    AS new_correct_index
  FROM (
    SELECT
      q2.id,
      e.opt,
      e.ord,
      q2.correct_index + 1 AS correct_ord,
      random()             AS rnd
    FROM questions q2
    CROSS JOIN LATERAL jsonb_array_elements(q2.options) WITH ORDINALITY AS e(opt, ord)
    WHERE NOT EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(q2.options) o
      WHERE o ~* '(both\s+[a-d]\s+and|all of the above|none of the above|answers?\s+[a-d]\b)'
    )
  ) t
  GROUP BY t.id, t.correct_ord
) s
WHERE q.id = s.id;


-- ── 2. Safety net ────────────────────────────────────────────────────────────
--
-- The remap is arithmetic on aggregates, so a mistake would be silent and
-- catastrophic: every affected question keyed to the wrong answer. Fail loudly
-- instead if any row ended up out of range or lost an option.

DO $$
DECLARE bad INT;
BEGIN
  SELECT COUNT(*) INTO bad
  FROM questions
  WHERE correct_index IS NULL
     OR correct_index < 0
     OR correct_index > 3
     OR jsonb_array_length(options) <> 4;

  IF bad > 0 THEN
    RAISE EXCEPTION 'Shuffle produced % invalid rows — transaction rolled back', bad;
  END IF;
END $$;


-- ── Verification ─────────────────────────────────────────────────────────────
-- Expect each position near 25%, and "always guess B" back down to chance.

SELECT
  section,
  COUNT(*)                                                        AS questions,
  ROUND(100.0 * COUNT(*) FILTER (WHERE correct_index = 0) / COUNT(*)) AS pct_a,
  ROUND(100.0 * COUNT(*) FILTER (WHERE correct_index = 1) / COUNT(*)) AS pct_b,
  ROUND(100.0 * COUNT(*) FILTER (WHERE correct_index = 2) / COUNT(*)) AS pct_c,
  ROUND(100.0 * COUNT(*) FILTER (WHERE correct_index = 3) / COUNT(*)) AS pct_d
FROM questions
GROUP BY section
ORDER BY section;
