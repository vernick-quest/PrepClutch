-- 032 — Reword reading questions that depend on a sentence's position
--
-- Four questions ask why the author says something "in the final sentence" or
-- "at the end of the passage". That phrasing pins the question to the passage's
-- current length, so appending a paragraph silently breaks the stem — the
-- sentence is no longer last, and the question asks about something that is not
-- true any more.
--
-- This blocked lengthening four passages that are far shorter than a real HSPT
-- passage (83-116 words against a 200-250 word norm), including one carrying
-- 5 questions.
--
-- Each key answers WHY the author included the material, not WHERE it sits, so
-- deleting the positional phrase leaves every answer exactly as correct as it
-- was. Options and correct_index are untouched; only `prompt` (and one
-- `explanation` that echoed "final sentence") change.
--
-- SCORING: prompt and explanation do not feed any score. Points come from
-- user_question_history joined to questions on id, valued by difficulty. None
-- of those are touched here, so no student can gain or lose a point.
--
-- Run this as a new query in the Supabase SQL editor.

-- ── 1. Cognitive dissonance — advertisers ────────────────────────────────────
UPDATE questions SET
  prompt      = 'The author most likely mentions advertisers in order to:',
  explanation = 'The sentence about advertisers extends the psychological concept into a real-world application, showing its practical relevance — not to criticize advertisers, but to broaden the concept''s scope.'
WHERE section = 'reading'
  AND prompt = 'The author most likely ends with the sentence about advertisers in order to:';

-- ── 2. Bees — habitat loss, pesticides, disease ──────────────────────────────
UPDATE questions SET
  prompt = 'Why does the author mention habitat loss, pesticides, and disease?'
WHERE section = 'reading'
  AND prompt = 'Why does the author mention habitat loss, pesticides, and disease in the final sentence?';

-- ── 3. Bats — sonar and radar ────────────────────────────────────────────────
UPDATE questions SET
  prompt = 'Why does the author mention sonar and radar technology?'
WHERE section = 'reading'
  AND prompt = 'Why does the author mention sonar and radar technology at the end of the passage?';

-- ── 4. Athenian democracy — "flaws" ──────────────────────────────────────────
UPDATE questions SET
  prompt = 'Why does the author describe Athens'' democracy as having "flaws"?'
WHERE section = 'reading'
  AND prompt = 'Why does the author describe Athens'' democracy as having "flaws" in the final sentence?';


-- ── Verification ─────────────────────────────────────────────────────────────
-- Expect 0 remaining position-dependent stems, and 4 reworded questions present.

SELECT 'reading questions still pinned to a position (expect 0)' AS check,
       COUNT(*)::TEXT AS value
  FROM questions
 WHERE section = 'reading'
   AND (prompt ILIKE '%final sentence%'
     OR prompt ILIKE '%end of the passage%'
     OR prompt ILIKE '%ends with%'
     OR prompt ILIKE '%last sentence%')
UNION ALL
SELECT 'reworded questions found (expect 4)', COUNT(*)::TEXT
  FROM questions
 WHERE section = 'reading'
   AND prompt IN (
     'The author most likely mentions advertisers in order to:',
     'Why does the author mention habitat loss, pesticides, and disease?',
     'Why does the author mention sonar and radar technology?',
     'Why does the author describe Athens'' democracy as having "flaws"?'
   );
