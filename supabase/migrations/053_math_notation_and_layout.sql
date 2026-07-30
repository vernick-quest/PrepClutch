-- 053 — Show math as math: exponents, radicals, one item per line
--
-- Two readability changes, no change to what any question asks:
--
-- 1. Comparison questions list (a), (b) and (c) on one wrapped line, so on a
--    phone the third item rolls off mid-expression and they cannot be scanned
--    in order. Each item moves to its own line. The app renders prompts with
--    `whitespace-pre-line` as of dba992c, so the newlines below are what
--    produce the layout.
--
-- 2. "3 cubed" and "the square root of 0.25" are spelled out in words where
--    the exam shows notation. They become 3³ and √0.25.
--
-- Both rewrites are computed FROM THE LIVE ROWS with regexp_replace, not from
-- a snapshot, so nothing here depends on the bank looking the way it did when
-- this was written. Both are idempotent — re-running is a no-op.
--
-- SAFETY: no INSERT, no DELETE, no change to id, section, difficulty, options
-- or correct_index. Only `prompt` and `explanation` text changes, so no
-- student's mastery, points or answer history can move.


-- ── 1. One comparison item per line ──────────────────────────────────────────
--
-- All 30 comparison questions share one lead-in and sit in quantitative.
-- The lead-in sentence ITSELF contains "(a), (b), and (c)", so it is split off
-- first and only the item list is rewritten — otherwise the markers inside the
-- lead-in would be broken onto their own lines too.
--
-- Item text carrying its own parentheses, such as "(2 + 3) x 4", is safe: the
-- pattern requires the literal marker (b) or (c).

UPDATE questions
SET prompt =
      'Examine (a), (b), and (c) and find the best answer.'
      || E'\n'
      || regexp_replace(
           substring(prompt from '^Examine \(a\), \(b\), and \(c\) and find the best answer\.\s*(.*)$'),
           '\s*\((b|c)\)\s*',
           E'\n(\\1) ',
           'g')
WHERE prompt ~ '^Examine \(a\), \(b\), and \(c\) and find the best answer\.'
  AND position(E'\n' in prompt) = 0;


-- ── 2. Exponents and radicals ────────────────────────────────────────────────
--
-- Only NUMBER-preceded occurrences convert. The bank also contains prose --
-- "the radius squared", "once it has been squared", "a number that is then
-- squared" -- across 24 explanations. Those keep their words, because
-- "radius²" is not what a student would write, and the sentences read as
-- English rather than as expressions.
--
-- Requiring a digit or a closing paren before the word is what separates the
-- two cases: "0.5 squared" and "(2/3) squared" convert, "is squared" does not.
--
-- "the square root of N" is handled before the bare form so the article goes
-- with it, leaving "√25" rather than "the √25".

UPDATE questions
SET prompt = regexp_replace(
               regexp_replace(
                 regexp_replace(
                   regexp_replace(prompt,
                     'the square root of ([0-9]+(?:\.[0-9]+)?)', '√\1', 'gi'),
                   'square root of ([0-9]+(?:\.[0-9]+)?)',       '√\1', 'gi'),
                 '([0-9)])\s+squared', '\1²', 'g'),
               '([0-9)])\s+cubed',   '\1³', 'g'),
    explanation = regexp_replace(
               regexp_replace(
                 regexp_replace(
                   regexp_replace(COALESCE(explanation, ''),
                     'the square root of ([0-9]+(?:\.[0-9]+)?)', '√\1', 'gi'),
                   'square root of ([0-9]+(?:\.[0-9]+)?)',       '√\1', 'gi'),
                 '([0-9)])\s+squared', '\1²', 'g'),
               '([0-9)])\s+cubed',   '\1³', 'g')
WHERE prompt      ~* '([0-9)])\s+(squared|cubed)|square root of [0-9]'
   OR explanation ~* '([0-9)])\s+(squared|cubed)|square root of [0-9]';


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected, stated as the FULL population so a partial apply is visible:
--
--   comparison_total          30
--   comparison_on_own_lines   30   <- must equal comparison_total
--   numeric_words_left         0
--   root_words_left            0
--   prose_squared_kept        24   <- unchanged on purpose ("radius squared")
--
-- sample_prompt should show the lead-in and three items on four lines.

SELECT
  (SELECT COUNT(*) FROM questions
    WHERE prompt LIKE 'Examine (a), (b), and (c)%')                    AS comparison_total,
  (SELECT COUNT(*) FROM questions
    WHERE prompt LIKE 'Examine (a), (b), and (c)%'
      AND position(E'\n' in prompt) > 0)                               AS comparison_on_own_lines,
  (SELECT COUNT(*) FROM questions
    WHERE prompt      ~ '[0-9)]\s+(squared|cubed)'
       OR explanation ~ '[0-9)]\s+(squared|cubed)')                    AS numeric_words_left,
  (SELECT COUNT(*) FROM questions
    WHERE prompt      ~ 'square root of [0-9]'
       OR explanation ~ 'square root of [0-9]')                        AS root_words_left,
  (SELECT COUNT(*) FROM questions
    WHERE explanation ~ '[a-z]\s+(squared|cubed)')                     AS prose_squared_kept,
  (SELECT COUNT(*) FROM questions
    WHERE prompt LIKE '%²%' OR prompt LIKE '%³%' OR prompt LIKE '%√%') AS prompts_with_notation,
  (SELECT prompt FROM questions
    WHERE prompt LIKE 'Examine (a), (b), and (c)%'
    ORDER BY prompt LIMIT 1)                                           AS sample_prompt;
