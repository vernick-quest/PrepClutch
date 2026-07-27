-- 015 — Strip double-escaped quotes from question options
--
-- Three Language questions about dialogue punctuation were seeded with their
-- quotation marks escaped twice, so the stored option text literally contains
-- a backslash:
--
--   shown to students:  \"Where are you going?\" she asked.
--   should be:          "Where are you going?" she asked.
--
-- The questions are about correct quotation punctuation, so the stray
-- backslashes make them impossible to answer as intended.
--
-- Rewrites any option element containing a literal backslash-quote, so this
-- repairs the defect wherever it occurs rather than hardcoding three rows.
-- Idempotent: once the backslashes are gone the WHERE clause matches nothing.
--
-- Run this as a new query in the Supabase SQL editor.

-- ── Before ───────────────────────────────────────────────────────────────────
-- Inspect what will change (safe to run on its own first):
--
--   SELECT id, prompt, options FROM questions
--   WHERE EXISTS (
--     SELECT 1 FROM jsonb_array_elements_text(options) e WHERE strpos(e, '\"') > 0
--   );

-- ── Fix ──────────────────────────────────────────────────────────────────────

UPDATE questions q
SET options = (
  SELECT jsonb_agg(replace(e, '\"', '"') ORDER BY ord)
  FROM jsonb_array_elements_text(q.options) WITH ORDINALITY AS t(e, ord)
)
WHERE EXISTS (
  SELECT 1 FROM jsonb_array_elements_text(q.options) e WHERE strpos(e, '\"') > 0
);

-- ── Verification ─────────────────────────────────────────────────────────────
-- Expect 0 remaining, and the three repaired rows rendering clean quotes.

SELECT 'rows still double-escaped (expect 0)' AS check, COUNT(*)::TEXT AS value
FROM questions
WHERE EXISTS (
  SELECT 1 FROM jsonb_array_elements_text(options) e WHERE strpos(e, '\"') > 0
)
UNION ALL
SELECT 'repaired sample', string_agg(o, '  |  ')
FROM (
  SELECT jsonb_array_elements_text(options) AS o
  FROM questions
  WHERE prompt = 'Which sentence uses punctuation correctly with dialogue?'
) s;
