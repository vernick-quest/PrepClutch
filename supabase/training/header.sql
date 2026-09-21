-- 060 — Training: concept labels + the full 75-question bank
--
-- 15 questions per section, 5 per difficulty, walked easiest first. Every
-- option carries its own note, so a student sees why EACH choice is right or
-- wrong — including a student who guessed correctly.
--
-- Generated from a validated source, not hand-typed. Before this file was
-- written, every question was checked for: exactly one correct answer, a
-- "Correct." note on that option and on no other, every math/quantitative
-- answer RECOMPUTED rather than trusted, balanced answer positions (the
-- original bank put the key on B 46% of the time, here no letter exceeds 27%),
-- no positional references like "Sentence B", and the notation conventions
-- from 053/055. The validator was itself proven by planting six known faults.
--
-- SAFE: `training_questions` has no dependents — nothing references it by
-- foreign key and no score reads it — so replacing its rows cannot touch any
-- student's data. (The same DELETE on `questions` would cascade into every
-- student's history, that is why this bank lives in its own table.)
-- The SQL editor runs this as one transaction: if any insert fails, the delete
-- rolls back with it and the pilot stays in place.


-- ── 1. Concept labels ────────────────────────────────────────────────────────
-- Heads each card with the pattern it teaches, e.g. "Analogies — degree", so a
-- student can say "I'm weak at inference" rather than "I'm bad at reading".

ALTER TABLE training_questions ADD COLUMN IF NOT EXISTS concept TEXT;


-- ── 2. Replace the 3-question pilot with the full bank ───────────────────────

DELETE FROM training_questions WHERE exam = 'hspt';

INSERT INTO training_questions
  (id, section, sort_order, concept, prompt, passage, options, correct_index, difficulty, explanation, option_notes)
SELECT md5(v.key)::UUID, v.section::section_type, v.sort_order, v.concept, v.prompt, v.passage,
       v.options, v.correct_index, v.difficulty, v.explanation, v.option_notes
FROM (VALUES
