-- 055 — Multiplication and division as symbols
--
-- Finishes what 053 started. Comparison lists still mix "0.25 x 80" with
-- "3 × 2" and spell out "divided by", so a row of three items reads in three
-- different notations.
--
--   (a) 0.25 x 80            (a) 0.25 × 80
--   (b) 80 divided by 4  ->  (b) 80 ÷ 4
--   (c) 1/5 of 80            (c) 1/5 of 80
--
-- THE RISK, and why this is safe:
--
-- `x` is also the algebra variable. The rewrite requires a digit or closing
-- paren, then whitespace, then `x`, then whitespace, then a digit or opening
-- paren. A variable is never written that way -- it appears as "3x", "x + 2",
-- "solve for x", "the value of x" -- so none of those can match. The
-- verification at the foot reports every row that still contains a variable-x
-- so the assumption is checked against real rows rather than asserted.
--
-- The lookahead matters. Without it, "2 x 3 x 4" consumes the 3 as the right
-- operand of the first match and the second `x` survives -- a partial apply
-- that looks like success. `(?=...)` leaves the operand for the next match.
--
-- Computed from the live rows, idempotent, and text-only: no INSERT, no
-- DELETE, and no change to id, options, correct_index, section or difficulty,
-- so no student's mastery, points or history can move.


-- ── Multiplication ───────────────────────────────────────────────────────────

UPDATE questions
SET prompt = regexp_replace(prompt, '([0-9)])\s+x\s+(?=[0-9(])', '\1 × ', 'g'),
    explanation = CASE WHEN explanation IS NULL THEN NULL ELSE
                    regexp_replace(explanation, '([0-9)])\s+x\s+(?=[0-9(])', '\1 × ', 'g')
                  END
WHERE prompt      ~ '[0-9)]\s+x\s+[0-9(]'
   OR explanation ~ '[0-9)]\s+x\s+[0-9(]';


-- ── Division ─────────────────────────────────────────────────────────────────
--
-- Prose survives: "the total divided by the number of items" has a word after
-- "by", not a digit, so the lookahead rejects it.

UPDATE questions
SET prompt = regexp_replace(prompt, '([0-9)])\s+divided by\s+(?=[0-9(])', '\1 ÷ ', 'g'),
    explanation = CASE WHEN explanation IS NULL THEN NULL ELSE
                    regexp_replace(explanation, '([0-9)])\s+divided by\s+(?=[0-9(])', '\1 ÷ ', 'g')
                  END
WHERE prompt      ~ '[0-9)]\s+divided by\s+[0-9(]'
   OR explanation ~ '[0-9)]\s+divided by\s+[0-9(]';


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected:
--   mult_left            0   <- nothing matchable survived (the chain check)
--   div_left             0
--   prompts_with_times  >0
--   prompts_with_obelus >0
--   variable_x_rows          rows still using x as a variable. These must NOT
--                            contain a stray × next to the variable -- eyeball
--                            variable_x_sample if it is non-zero.
--   upper_x_left             " X " between digits, which this migration does
--                            NOT convert. Expected 0. If not, report back.

SELECT
  (SELECT COUNT(*) FROM questions
    WHERE prompt ~ '[0-9)]\s+x\s+[0-9(]' OR explanation ~ '[0-9)]\s+x\s+[0-9(]')       AS mult_left,
  (SELECT COUNT(*) FROM questions
    WHERE prompt ~ '[0-9)]\s+divided by\s+[0-9(]'
       OR explanation ~ '[0-9)]\s+divided by\s+[0-9(]')                                AS div_left,
  (SELECT COUNT(*) FROM questions WHERE prompt LIKE '%×%')                             AS prompts_with_times,
  (SELECT COUNT(*) FROM questions WHERE prompt LIKE '%÷%')                             AS prompts_with_obelus,
  (SELECT COUNT(*) FROM questions
    WHERE prompt ~ '[0-9]x\b|\bx\s*[-+=]|\bfor x\b|\bvalue of x\b')                    AS variable_x_rows,
  (SELECT COUNT(*) FROM questions
    WHERE prompt ~ '[0-9)]\s+X\s+[0-9(]' OR explanation ~ '[0-9)]\s+X\s+[0-9(]')       AS upper_x_left,
  (SELECT prompt FROM questions
    WHERE prompt ~ '[0-9]x\b|\bx\s*[-+=]|\bfor x\b|\bvalue of x\b'
    ORDER BY prompt LIMIT 1)                                                           AS variable_x_sample,
  (SELECT prompt FROM questions
    WHERE prompt LIKE '%÷%' ORDER BY prompt LIMIT 1)                                   AS sample_prompt;
