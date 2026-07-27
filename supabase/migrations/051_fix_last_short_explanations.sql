-- 051 — Rewrite the last short explanations
--
-- Six rows still carry their original terse seed explanation. Five are reading
-- rows that migration 047 deliberately skipped: their rationales described a
-- passage's FINAL sentence, and migrations 031 and 033 appended paragraphs, so
-- that sentence is no longer final. One is a verbal row whose match guard in
-- 046 used the pre-018 option set (Hat), while 018 had already replaced Hat
-- with Jacket, so nothing matched.
--
-- Every explanation below was written against the CURRENT passage text (the
-- post-031/033 version) and refers to CONTENT only -- never to a sentence's
-- position, and never to an option's position, since 019 shuffled every
-- pre-019 options array.
--
-- Updates ONE column: explanation. No prompt, options, correct_index,
-- difficulty, section or id is assigned, so no student score can move.
-- UPDATE statements only: nothing is inserted, deleted or restructured, and
-- user_question_history is never read or written.
--
-- ORDER-INDEPENDENT OPTIONS GUARD. Because 019 permuted every pre-019 options
-- array, comparing options to a literal array in the authored order matches
-- nothing (the defect that made 042 and 046 miss these rows). 019 only
-- PERMUTED the options, so a live row's option SET is unchanged. Each WHERE
-- therefore sorts both sides with the same expression inside the same query
-- and compares the sorted aggregates, exactly as 044-048 do.
--
-- Prompts are not unique in this bank and neither are option sets, so both are
-- required. Verified against the reconstructed live bank: section + prompt +
-- sorted option set matches exactly one row for every statement below.
--
-- Setting the same text twice is a no-op, so this file is idempotent.
--
-- Run this as a new query in the Supabase SQL editor.

-- Reading 1 of 5 - rain forests and climate
UPDATE questions SET explanation = 'The passage ties climate to carbon directly: rain forests help regulate Earth''s climate by soaking up large amounts of carbon dioxide, and it adds that burning cleared trees releases the carbon they had stored. Housing millions of animal species is true of rain forests, but the passage offers that as a measure of their variety of life, not as the climate mechanism this question asks about.'
  WHERE section = 'reading' AND prompt = 'According to the passage, rain forests help regulate Earth''s climate by:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Producing large amounts of oxygen only.", "Absorbing large amounts of carbon dioxide.", "Covering half the Earth''s surface.", "Housing millions of animal species."]'::JSONB) v);

-- Reading 2 of 5 - the Olympic Games
UPDATE questions SET explanation = 'The passage begins with the first recorded Games at Olympia in 776 BCE, follows the events and the truce that grew around them, then moves to the 1896 revival in Athens and the changes since then. That whole span from ancient beginnings to the modern competition is the subject. The athletic events of the modern Olympics is too narrow, since those events are one detail along the way.'
  WHERE section = 'reading' AND prompt = 'What is this passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The athletic events included in the modern Olympics", "The religious beliefs of ancient Greeks", "The origins and development of the Olympic Games from ancient Greece to today", "Why ancient Greece was the center of world civilization"]'::JSONB) v);

-- Reading 3 of 5 - how the eye detects color
UPDATE questions SET explanation = 'Color vision starts with cone cells in the retina, and the passage says there are three types, each most sensitive to a different wavelength: one to red light, one to green, one to blue. The brain combines their signals. Rod cells are the trap. The passage does describe rods, but as the cells used in dim light, and it states that they cannot distinguish wavelengths at all.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how does the eye detect different colors?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["By measuring the brightness of incoming light", "Through three types of cone cells that each respond to a different wavelength of light", "Through rod cells that detect red, green, and blue light", "By measuring the speed at which light enters the eye"]'::JSONB) v);

-- Reading 4 of 5 - how the internet grew
UPDATE questions SET explanation = 'The passage traces one long line of growth: a defense-funded network joining a handful of labs in 1969, then standardized protocols, then the World Wide Web in 1991, then open software and billions of users. That gradual change from a small research network into a worldwide tool is the point. Calling Tim Berners-Lee the most important inventor in modern history is praise the passage never offers about anyone.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Tim Berners-Lee is the most important inventor in modern history", "The internet developed gradually from a small military research network into a global tool", "ARPANET was invented to help soldiers communicate during wartime", "The World Wide Web and the internet are exactly the same thing"]'::JSONB) v);

-- Reading 5 of 5 - what antibiotic resistance means
UPDATE questions SET explanation = 'The passage defines the term as bacteria evolving to survive the drugs that once killed them, and explains the mechanism: a few cells in a huge population carry a mutation, careless use of antibiotics kills the rest, and the survivors pass the trait to their descendants. The passage even says it is the bacteria that change, not the patient, so patients refusing their medicine cannot be the meaning.'
  WHERE section = 'reading' AND prompt = 'What does "antibiotic resistance" mean as described in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Patients refusing to take prescribed antibiotics", "Bacteria that have evolved to survive antibiotic drugs", "Antibiotics that no longer dissolve in the body", "A shortage of antibiotic medications in hospitals"]'::JSONB) v);

-- Verbal 1 of 1 - odd one out: Shirt, Pants, Jacket, Shoes
-- 046 guarded on the pre-018 option set (Hat), so this row was never updated.
UPDATE questions SET explanation = 'All four are things you put on, so look for the tighter group. A shirt, pants, and a jacket are cloth garments worn on the body. Shoes are footwear, built with a stiff sole to carry you over the ground, which is what sets them apart. Jacket can feel like the outsider because you wear it over the rest, but it is still cloth clothing.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Shirt", "Pants", "Jacket", "Shoes"]'::JSONB) v);

-- Verification: no section should still hold a short explanation, except math
-- until 050 has been run.
SELECT section, COUNT(*)
FROM questions
WHERE LENGTH(explanation) <= 150
GROUP BY section;
