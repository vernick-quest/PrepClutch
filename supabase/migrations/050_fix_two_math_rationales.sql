-- 050 — Rewrite the last two short math explanations
--
-- Migration 044 skipped these two rows. Their options had been rewritten by
-- migration 018 (both offered a distractor equal in value to the key), and the
-- snapshot 044 was generated from still carried the pre-018 options, so 044's
-- order-independent options guard matched nothing for them.
--
-- Both prompts are unique within the math section, so matching on prompt alone
-- is safe here and sidesteps needing to know the current option order.
--
-- Only `explanation` is assigned — no score can move.

UPDATE questions SET explanation =
  'Fractions can only be added when the pieces are the same size. Rewrite 1/2 as 2/4 so both halves and quarters are in quarters, then 2/4 + 1/4 = 3/4. Adding the tops and bottoms straight across gives 2/6, which is the most common slip and is smaller than either fraction you started with.'
WHERE section = 'math' AND prompt = 'What is 1/2 + 1/4?';

UPDATE questions SET explanation =
  'Give both fractions the same denominator before adding. Sixths and thirds both fit into sixths, so 2/3 becomes 4/6, and 5/6 + 4/6 = 9/6, which reduces to 3/2. Notice the total is greater than 1, since 5/6 alone is nearly a whole. Answering 7/9 comes from adding the tops and the bottoms separately.'
WHERE section = 'math' AND prompt = 'What is 5/6 + 2/3?';

-- ── Verification ─────────────────────────────────────────────────────────────
SELECT 'math questions still on a short explanation (expect 0)' AS check,
       COUNT(*)::TEXT AS value
  FROM questions WHERE section = 'math' AND LENGTH(explanation) <= 150;
