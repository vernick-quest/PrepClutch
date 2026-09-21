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
-- original bank put the key on B 46% of the time; here no letter exceeds 27%),
-- no positional references like "Sentence B", and the notation conventions
-- from 053/055. The validator was itself proven by planting six known faults.
--
-- SAFE: `training_questions` has no dependents — nothing references it by
-- foreign key and no score reads it — so replacing its rows cannot touch any
-- student's data. (The same DELETE on `questions` would cascade into every
-- student's history; that is why this bank lives in its own table.)
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
('train-hspt-verbal-01', 'verbal', 1, 'Synonyms',
 'ABUNDANT most nearly means:',
 NULL,
 '["plentiful", "costly", "hidden", "recent"]'::JSONB, 0, 1,
 'Abundant describes having a great deal of something — more than enough. Think of an abundant harvest: the barns are full. The word is about quantity, so the answer has to be a quantity word.',
 '["Correct. Plentiful and abundant both mean there is a large supply of something.", "Costly is about PRICE, not amount. Something abundant is often cheap precisely because there is so much of it — the opposite pull.", "Hidden is about whether you can SEE something. An abundant thing is usually the easiest thing to find.", "Recent is about TIME. A harvest can be recent and tiny, or abundant and years old. Different measure entirely."]'::JSONB),

('train-hspt-verbal-02', 'verbal', 2, 'Antonyms',
 'FRAGILE is the opposite of:',
 NULL,
 '["delicate", "broken", "sturdy", "small"]'::JSONB, 2, 1,
 'Fragile means easily broken. For an opposite, first put the word in your own words, then flip it: easily broken becomes hard to break. Only then look at the choices — the test nearly always includes a synonym to catch readers who forget they want the opposite.',
 '["Delicate is a SYNONYM of fragile — both mean easily damaged. Opposite questions almost always plant the word''s twin as a trap.", "Broken is what can happen to something fragile, not its opposite. Watch for choices that are merely related.", "Correct. Sturdy means strong and hard to break — exactly the reverse of fragile.", "Size has nothing to do with it. A glass sculpture can be enormous and still fragile."]'::JSONB),

('train-hspt-verbal-03', 'verbal', 3, 'Analogies — part to whole',
 'Petal is to flower as page is to:',
 NULL,
 '["ink", "book", "writer", "library"]'::JSONB, 1, 1,
 'Turn the first pair into a sentence: a petal is one part of a flower. Now swap in the second word: a page is one part of a ___. Only book fits the same sentence. Building the sentence first stops you from picking a word that is merely connected.',
 '["Ink is printed ON a page — it is not what a page belongs to. It flips the relationship.", "Correct. A petal is one part of a flower; a page is one part of a book. Same part-to-whole link.", "A writer creates a book, but a page is not part of a writer. Creator is a different relationship from whole.", "A library holds books, so it is two steps away from a page. The pattern needs the thing a page is directly part of."]'::JSONB),

('train-hspt-verbal-04', 'verbal', 4, 'Classification — which does not belong',
 'Which word does NOT belong with the others?',
 NULL,
 '["carrot", "turnip", "apple", "potato"]'::JSONB, 2, 1,
 'Find a rule that fits three words and breaks for exactly one. Three of these are dug out of the ground; one is picked from a tree. When you can name a rule that includes three and excludes one — and a second rule agrees — you can be confident.',
 '["Carrots grow underground, like turnips and potatoes, so they belong to the group.", "Turnips grow underground too — part of the group.", "Correct. Apples grow on trees above the ground; the other three grow in the soil. They are also the only fruit here, so two different rules point to the same answer.", "Potatoes grow underground as well, so they fit. The shared rule is where they grow, not their shape or color."]'::JSONB),

('train-hspt-verbal-05', 'verbal', 5, 'Logic — putting things in order',
 'Maria is taller than Jon.
Jon is taller than Lee.
Maria is taller than Lee.
If the first two statements are true, the third statement is:',
 NULL,
 '["True", "False", "Uncertain", "Neither"]'::JSONB, 0, 1,
 'Line them up with the tallest on the left: Maria, then Jon, then Lee. Once the first two statements are placed on one line, you can read the third straight off it. Ordering questions almost always come down to drawing that line.',
 '["Correct. Maria is above Jon and Jon is above Lee, so Maria must be above Lee. The order passes straight down the chain.", "False would mean Lee is at least as tall as Maria — impossible when Maria outranks Jon and Jon outranks Lee.", "Uncertain is for when the facts allow more than one outcome. Here the chain leaves only one, so nothing is uncertain.", "The real HSPT gives only three verdicts on these — true, false, or uncertain. Neither is never the answer; it is only here to fill the fourth slot."]'::JSONB),

('train-hspt-verbal-06', 'verbal', 6, 'Synonyms',
 'CANDID most nearly means:',
 NULL,
 '["secretive", "frank", "sweet", "careful"]'::JSONB, 1, 2,
 'Candid means honest and straightforward. A candid photo is taken without posing — it shows things as they really are. When a word looks like one you know (candid, candy), check that the MEANING actually connects before trusting the resemblance.',
 '["Secretive is close to the OPPOSITE — a candid person hides nothing.", "Correct. Frank and candid both mean honest and direct, even when the truth is uncomfortable.", "Sweet is the trap for anyone thinking of candy. Similar spelling, unrelated meaning.", "Careful describes caution. A candid remark is often the opposite of careful — it says the blunt thing."]'::JSONB),

('train-hspt-verbal-07', 'verbal', 7, 'Analogies — tool and what it measures',
 'Thermometer is to temperature as scale is to:',
 NULL,
 '["weight", "kitchen", "number", "heat"]'::JSONB, 0, 2,
 'Say the relationship aloud: a thermometer is used to measure temperature. Then test it: a scale is used to measure ___. Weight is the only fit. Analogy traps often reuse a word from the first pair, like heat here, so be wary of a choice that feels familiar only because you just read it.',
 '["Correct. A thermometer measures temperature; a scale measures weight.", "A kitchen is where you might find a scale. Location is a different relationship from what it measures.", "A scale shows a number, but so does a thermometer. The pattern asks WHAT is measured, and number is too general.", "Heat belongs with the thermometer, not the scale. It borrows from the first pair to catch a rushed reader."]'::JSONB),

('train-hspt-verbal-08', 'verbal', 8, 'Antonyms',
 'DILIGENT is the opposite of:',
 NULL,
 '["hardworking", "clever", "honest", "lazy"]'::JSONB, 3, 2,
 'Diligent describes someone who works steadily and carefully. Flip that — avoids effort — and lazy is the match. Notice two other choices are also positive traits: an opposite must be opposite in the SAME quality, not just something different.',
 '["Hardworking is a SYNONYM of diligent. On an opposite question, the synonym is the most common trap.", "Clever is about intelligence, not effort. A clever person can be lazy or diligent.", "Honest is about truthfulness — a different quality entirely.", "Correct. Diligent means putting in steady, careful effort; lazy means avoiding effort."]'::JSONB),

('train-hspt-verbal-09', 'verbal', 9, 'Analogies — degree',
 'Warm is to hot as cool is to:',
 NULL,
 '["breezy", "cold", "mild", "damp"]'::JSONB, 1, 2,
 'This is a degree analogy: the second word is a more intense version of the first. Warm to hot turns the heat up; cool to cold turns the chill up. When two words differ only in strength, find the choice that makes the same jump in the same direction.',
 '["Breezy describes wind, not how cold something is.", "Correct. Hot is a stronger version of warm; cold is a stronger version of cool. The same step up in intensity.", "Mild is WEAKER than cool, not stronger — it moves in the wrong direction.", "Damp is about moisture, a different scale entirely."]'::JSONB),

('train-hspt-verbal-10', 'verbal', 10, 'Logic — putting things in order',
 'Box A weighs more than Box B.
Box C weighs less than Box B.
Box C weighs more than Box A.
If the first two statements are true, the third statement is:',
 NULL,
 '["True", "False", "Uncertain", "Neither"]'::JSONB, 1, 2,
 'Place all three on one line, heaviest first. A is heavier than B: A, B. C is lighter than B: A, B, C. The third statement claims C beats A, and the line shows the reverse. Tip: rewrite any ''less than'' sentence so every comparison points the same direction before you compare.',
 '["True would put C above A. But A is heavier than B, and B is heavier than C, so C is at the bottom.", "Correct. From heaviest to lightest the order is A, then B, then C. C cannot outweigh A.", "Uncertain applies when the facts leave room for either answer. Here they fix the order completely.", "The real HSPT gives only three verdicts on these — true, false, or uncertain. Neither is never the answer; it is only here to fill the fourth slot."]'::JSONB),

('train-hspt-verbal-11', 'verbal', 11, 'Synonyms',
 'EPHEMERAL most nearly means:',
 NULL,
 '["mysterious", "ancient", "fleeting", "beautiful"]'::JSONB, 2, 3,
 'Ephemeral means lasting only a very short time — a soap bubble, a rainbow, a fad. If you do not know a hard word, think about what it usually describes. Then be careful: a choice that describes the KIND of thing the word is used about is not the same as what the word means.',
 '["Ephemeral things can seem mysterious, but the word is about how LONG something lasts, not how puzzling it is.", "Ancient means very old — close to the opposite of something that barely lasts.", "Correct. Ephemeral means lasting a very short time, just as fleeting does.", "The word is often used about beautiful things, like a sunset, which makes this tempting. But it means short-lived, not beautiful."]'::JSONB),

('train-hspt-verbal-12', 'verbal', 12, 'Analogies — word parts',
 'Illegible is to read as inaudible is to:',
 NULL,
 '["speak", "see", "write", "hear"]'::JSONB, 3, 3,
 'Both words are built the same way: il- or in- means NOT, and -ible means able to be. Illegible is not able to be read; inaudible is not able to be heard. When the words in an analogy share a prefix and suffix, take them apart — the pattern is usually hiding in the pieces.',
 '["Speaking PRODUCES sound, but inaudible is about receiving it. The pattern is about what cannot be done TO the thing.", "Seeing pairs with invisible, not inaudible. Close, but the wrong sense.", "Write is borrowed from the reading side of the analogy. It matches illegible''s topic, not inaudible''s.", "Correct. Illegible writing cannot be read; an inaudible sound cannot be heard."]'::JSONB),

('train-hspt-verbal-13', 'verbal', 13, 'Logic — overlapping groups',
 'All violinists are musicians.
Some musicians are composers.
Some violinists are composers.
If the first two statements are true, the third statement is:',
 NULL,
 '["True", "False", "Uncertain", "Neither"]'::JSONB, 2, 3,
 'Draw two circles. Violinists sit entirely inside musicians. Composers overlap musicians somewhere — but nothing tells you where. The overlap could include violinists, or it could land entirely on pianists and drummers. When the statements allow the conclusion but do not force it, the answer is uncertain.',
 '["True would require the composers to definitely include some violinists. Nothing says they do — the composers could all be drummers.", "False would require the composers to include NO violinists. Nothing says that either. True and False both claim to know something the statements never give you.", "Correct. The first two statements allow the third but do not force it, and that gap is exactly what uncertain means.", "The real HSPT gives only three verdicts on these — true, false, or uncertain. Neither is never the answer; it is only here to fill the fourth slot."]'::JSONB),

('train-hspt-verbal-14', 'verbal', 14, 'Antonyms',
 'VERBOSE is the opposite of:',
 NULL,
 '["concise", "loud", "truthful", "rapid"]'::JSONB, 0, 3,
 'Verbose comes from the Latin verbum, meaning word — a verbose person uses too many words. The opposite must also be about the NUMBER of words: concise. When a hard word contains a root you recognize, the root often tells you which quality is being measured.',
 '["Correct. Verbose means using more words than needed; concise means saying it in as few as possible.", "Loud is about volume. A verbose speaker can whisper.", "Truthful is about honesty. Wordiness says nothing about whether the words are true.", "Rapid is about speed. Someone can be verbose slowly or quickly."]'::JSONB),

('train-hspt-verbal-15', 'verbal', 15, 'Classification — which does not belong',
 'Which word does NOT belong with the others?',
 NULL,
 '["rejoice", "exult", "celebrate", "lament"]'::JSONB, 3, 3,
 'Three of these mean showing happiness; one means showing grief. The trap is the unfamiliar word — students often pick exult just because they do not know it. Before choosing the strangest-looking word, check whether your rule actually excludes it.',
 '["Rejoice means to feel or show great joy, so it fits the group.", "Exult means to show triumphant joy. It is the least familiar word here, which makes it tempting — but it belongs.", "Celebrate fits: it is a joyful action.", "Correct. Lament means to express sorrow; the other three all express joy."]'::JSONB),

('train-hspt-quantitative-01', 'quantitative', 1, 'Number series — adding',
 'Look at this series: 3, 6, 9, 12, ... What number should come next?',
 NULL,
 '["13", "14", "15", "18"]'::JSONB, 2, 1,
 'Find the gap between neighbors: 6 − 3 = 3, 9 − 6 = 3, 12 − 9 = 3. When every gap is the same, keep adding it: 12 + 3 = 15. Always check at least two gaps before trusting a pattern.',
 '["13 adds only 1. The series adds 3 every time.", "14 adds 2. Check the gap between each pair — it is always 3.", "Correct. Each number is 3 more than the one before: 12 + 3 = 15.", "18 adds 6, doubling the step. The step never changes in this series."]'::JSONB),

('train-hspt-quantitative-02', 'quantitative', 2, 'Number series — subtracting',
 'Look at this series: 20, 17, 14, 11, ... What number should come next?',
 NULL,
 '["8", "9", "7", "10"]'::JSONB, 0, 1,
 'The numbers go down, so find how much they drop: 20 − 17 = 3, 17 − 14 = 3, 14 − 11 = 3. Keep subtracting 3: 11 − 3 = 8. A falling series works exactly like a rising one — you just subtract the gap.',
 '["Correct. Each number is 3 less than the one before: 11 − 3 = 8.", "9 subtracts only 2. The series drops by 3 each time.", "7 subtracts 4 — one more than the real step.", "10 subtracts just 1."]'::JSONB),

('train-hspt-quantitative-03', 'quantitative', 3, 'Number series — multiplying',
 'Look at this series: 2, 4, 8, 16, ... What number should come next?',
 NULL,
 '["18", "20", "24", "32"]'::JSONB, 3, 1,
 'The gaps are 2, 4, 8 — not constant, so this is not an adding series. Try dividing instead: 4 ÷ 2 = 2, 8 ÷ 4 = 2, 16 ÷ 8 = 2. Each term is double the last, so 16 × 2 = 32. When the gaps grow fast, test multiplication.',
 '["18 adds 2. But the gaps here keep growing — 2, 4, 8 — so adding a fixed amount cannot work.", "20 adds 4, repeating an earlier gap. The gaps double each time, so the next one is 16.", "24 adds 8, repeating the previous gap. The gaps themselves are growing.", "Correct. Each number is twice the one before: 16 × 2 = 32."]'::JSONB),

('train-hspt-quantitative-04', 'quantitative', 4, 'Number manipulation',
 'What number is 4 less than 3 × 5?',
 NULL,
 '["3", "11", "19", "15"]'::JSONB, 1, 1,
 'Work from the inside out. The phrase ''4 less than 3 × 5'' is built on 3 × 5, so find that first: 15. Then ''4 less than'' means subtract 4: 11. The words ''less than'' tell you to take away from the number that comes after them.',
 '["3 comes from subtracting first: 3 × (5 − 4). But ''4 less than 3 × 5'' means find 3 × 5 before anything else.", "Correct. 3 × 5 = 15, and 4 less than 15 is 11.", "19 adds 4 instead of subtracting it. ''Less than'' means take away.", "15 is 3 × 5 — the right starting point, but you still need to take away 4."]'::JSONB),

('train-hspt-quantitative-05', 'quantitative', 5, 'Comparisons — are they equal?',
 'Examine (a), (b), and (c) and find the best answer.
(a) 1/2 of 10
(b) 5
(c) 10 ÷ 2',
 NULL,
 '["(a) is greater than (b)", "(a), (b), and (c) are equal", "(c) is greater than (a)", "(b) is less than (c)"]'::JSONB, 1, 1,
 'Turn every item into a plain number before comparing: (a) half of 10 is 5, (b) is 5, (c) 10 ÷ 2 is 5. Only then read the choices. Comparison questions look complicated but reward one habit: compute everything first, compare second.',
 '["Half of 10 is 5, the same as (b). Neither is greater.", "Correct. Half of 10 is 5, (b) is 5, and 10 ÷ 2 is 5. All three are the same value.", "10 ÷ 2 and half of 10 are two ways of writing the same thing — both equal 5.", "(b) is 5 and (c) is 5, so neither is less."]'::JSONB),

('train-hspt-quantitative-06', 'quantitative', 6, 'Number series — square numbers',
 'Look at this series: 1, 4, 9, 16, 25, ... What number should come next?',
 NULL,
 '["30", "34", "36", "49"]'::JSONB, 2, 2,
 'The gaps are 3, 5, 7, 9 — growing by 2 each step — so the next gap is 11: 25 + 11 = 36. Or spot the shortcut: each term is a number times itself, 1², 2², 3², 4², 5², so the sixth is 6² = 36. Recognizing square numbers on sight saves real time.',
 '["30 adds 5, but the gaps are growing: 3, 5, 7, 9. The next gap is 11.", "34 adds 9, repeating the last gap. The gaps grow by 2 every time.", "Correct. These are square numbers — 1², 2², 3², 4², 5² — so the next is 6² = 36.", "49 is 7². It skips over 6²."]'::JSONB),

('train-hspt-quantitative-07', 'quantitative', 7, 'Number series — two steps taking turns',
 'Look at this series: 5, 10, 8, 16, 14, ... What number should come next?',
 NULL,
 '["12", "28", "16", "20"]'::JSONB, 1, 2,
 'The numbers go up, down, up, down — a sign that two steps are taking turns. Write each one: 5 to 10 is × 2, 10 to 8 is − 2, 8 to 16 is × 2, 16 to 14 is − 2. The next step is × 2: 14 × 2 = 28.',
 '["12 subtracts 2. But the steps alternate — the last step subtracted, so this one multiplies.", "Correct. The pattern alternates × 2 then − 2. The last step was − 2 (16 to 14), so now multiply: 14 × 2 = 28.", "16 adds 2. Neither step in this pattern adds.", "20 adds 6. Look at the steps, not just the size of the numbers."]'::JSONB),

('train-hspt-quantitative-08', 'quantitative', 8, 'Number manipulation',
 'What number is 5 more than 1/3 of 27?',
 NULL,
 '["22", "9", "32", "14"]'::JSONB, 3, 2,
 'Break the sentence at the word ''than'': ''5 more than'' ... ''1/3 of 27''. Do the second part first, because the first part depends on it: 27 ÷ 3 = 9. Then add 5: 14. Most mistakes come from using the whole 27 instead of the third.',
 '["22 is 27 − 5. It skips the ''one third of'' step and subtracts instead of adding.", "9 is one third of 27 — the right first step — but you still need 5 more.", "32 adds 5 to 27 and never takes a third.", "Correct. One third of 27 is 9, and 5 more than 9 is 14."]'::JSONB),

('train-hspt-quantitative-09', 'quantitative', 9, 'Comparisons — percents, fractions, decimals',
 'Examine (a), (b), and (c) and find the best answer.
(a) 25% of 80
(b) 1/5 of 100
(c) 0.3 × 60',
 NULL,
 '["(a) and (b) are equal, and both are greater than (c)", "(a), (b), and (c) are equal", "(c) is greater than (a)", "(b) is greater than (a)"]'::JSONB, 0, 2,
 'Convert each to a plain number. 25% is one quarter, and a quarter of 80 is 20. One fifth of 100 is 20. For 0.3 × 60, find 3 × 60 = 180, then move the decimal one place: 18. With everything as a plain number, the comparison is easy.',
 '["Correct. (a) 25% of 80 = 20, (b) 1/5 of 100 = 20, (c) 0.3 × 60 = 18. The first two tie, and both beat 18.", "(c) is 18, not 20 — close enough to fool a quick estimate, but not equal.", "(c) is 18 and (a) is 20, so (c) is smaller.", "(a) and (b) are both exactly 20."]'::JSONB),

('train-hspt-quantitative-10', 'quantitative', 10, 'Comparisons — exponents and roots',
 'Examine (a), (b), and (c) and find the best answer.
(a) 3²
(b) 2³
(c) √64',
 NULL,
 '["(a), (b), and (c) are equal", "(a) is less than (c)", "(b) is greater than (c)", "(b) and (c) are equal, and both are less than (a)"]'::JSONB, 3, 2,
 'The small raised number tells you how many times to multiply the base by itself: 3² = 3 × 3 = 9, but 2³ = 2 × 2 × 2 = 8. The √ sign asks which number times itself makes 64: 8. Write the multiplication out rather than guessing — 3² and 2³ look alike but are not equal.',
 '["3² is 9, not 8. Many students mix up 3² and 2³ because the same digits appear.", "(a) is 9 and (c) is 8, so (a) is the larger one.", "2³ = 8 and √64 = 8 — they are equal.", "Correct. 3² = 3 × 3 = 9, 2³ = 2 × 2 × 2 = 8, and √64 = 8, since 8 × 8 = 64."]'::JSONB),

('train-hspt-quantitative-11', 'quantitative', 11, 'Number series — growing gaps',
 'Look at this series: 2, 3, 5, 8, 12, 17, ... What number should come next?',
 NULL,
 '["22", "23", "24", "25"]'::JSONB, 1, 3,
 'The start — 2, 3, 5, 8 — looks as if each term is the sum of the two before it. But 5 + 8 = 13, not 12, so that rule breaks. Check the gaps instead: 1, 2, 3, 4, 5. They grow by one each time, so the next gap is 6: 17 + 6 = 23. Always test a pattern against every term, not just the first few.',
 '["22 adds 5, repeating the last gap. The gaps are increasing by 1 each time.", "Correct. The gaps are 1, 2, 3, 4, 5, so the next gap is 6: 17 + 6 = 23.", "24 adds 7 — one step too far.", "25 adds the two previous numbers (8 + 17). That rule breaks earlier in the series: 5 + 8 = 13, not 12."]'::JSONB),

('train-hspt-quantitative-12', 'quantitative', 12, 'Number series — two operations',
 'Look at this series: 3, 5, 9, 17, 33, ... What number should come next?',
 NULL,
 '["49", "64", "65", "66"]'::JSONB, 2, 3,
 'The gaps are 2, 4, 8, 16 — they double, so the next gap is 32: 33 + 32 = 65. The same pattern written as a rule: double the term and subtract 1 (5 × 2 − 1 = 9, 9 × 2 − 1 = 17). When the gaps themselves form a pattern, follow the gaps.',
 '["49 adds 16, repeating the last gap. The gaps double — 2, 4, 8, 16 — so the next is 32.", "64 is one short. Doubling 33 gives 66, and the rule subtracts 1, not 2.", "Correct. Each term is double the one before, minus 1: 33 × 2 − 1 = 65.", "66 doubles 33 but forgets to subtract 1."]'::JSONB),

('train-hspt-quantitative-13', 'quantitative', 13, 'Number series — two steps taking turns',
 'Look at this series: 80, 40, 44, 22, 26, ... What number should come next?',
 NULL,
 '["13", "30", "52", "11"]'::JSONB, 0, 3,
 'The series falls and rises, so two steps are alternating. Label them: 80 to 40 is ÷ 2, 40 to 44 is + 4, 44 to 22 is ÷ 2, 22 to 26 is + 4. The next step is ÷ 2, applied to the last term: 26 ÷ 2 = 13.',
 '["Correct. The steps alternate ÷ 2 then + 4. The last step was + 4 (22 to 26), so now halve: 26 ÷ 2 = 13.", "30 adds 4 again, but the steps take turns — after + 4 comes ÷ 2.", "52 doubles 26. This pattern halves; it never doubles.", "11 is 22 ÷ 2 — the right operation on the wrong number. Apply the next step to the LAST term, 26."]'::JSONB),

('train-hspt-quantitative-14', 'quantitative', 14, 'Number manipulation — working backward',
 'When a number is doubled and then decreased by 7, the result is 15. What is the number?',
 NULL,
 '["11", "4", "22", "37"]'::JSONB, 0, 3,
 'Work backward, undoing the LAST step first. The last thing done was ''decreased by 7'', so add 7: 15 + 7 = 22. Before that it was doubled, so halve: 22 ÷ 2 = 11. Always check by running it forward: 11 × 2 = 22, and 22 − 7 = 15.',
 '["Correct. Undo each step in reverse: 15 + 7 = 22, then 22 ÷ 2 = 11. Check: 11 × 2 − 7 = 15.", "4 comes from subtracting 7 instead of adding it back. To undo ''decreased by 7'', you add 7.", "22 undoes the subtraction but not the doubling. Divide by 2 to finish.", "37 runs the operations forward on 15 (15 × 2 + 7) instead of undoing them."]'::JSONB),

('train-hspt-quantitative-15', 'quantitative', 15, 'Comparisons — ordering three values',
 'Examine (a), (b), and (c) and find the best answer.
(a) 2/3
(b) 0.6
(c) 65%',
 NULL,
 '["(c) is greater than (a)", "(a) and (c) are equal", "(a) is greater than (c), and (c) is greater than (b)", "(b) is greater than (c)"]'::JSONB, 2, 3,
 'Put all three in the same form; decimals are easiest. 2/3 = 0.666..., 65% = 0.65, and 0.6 = 0.60. Writing 0.60 with two places makes it obvious that it sits below 0.65. When values are close, add zeros so the decimals have the same length before you compare.',
 '["65% is 0.65, but 2/3 is about 0.667 — just barely larger.", "They are close but not equal: about 0.667 versus 0.65.", "Correct. As decimals: (a) 2/3 ≈ 0.667, (c) 65% = 0.65, (b) 0.6. The order is a, then c, then b.", "0.6 is less than 0.65 — write it as 0.60 to see it."]'::JSONB),

('train-hspt-reading-01', 'reading', 1, 'Vocabulary — word in a phrase',
 'Choose the word that means the same as the capitalized word.
a RAPID river',
 NULL,
 '["slow", "fast", "deep", "cold"]'::JSONB, 1, 1,
 'The short phrase gives context, but notice that several choices fit a river — rivers can be deep, cold, or fast. Only one matches the meaning of rapid itself. Do not pick a word just because it fits the noun; pick the one that means the same as the capitalized word.',
 '["Slow is the OPPOSITE of rapid — the classic trap on a same-meaning question.", "Correct. Rapid means moving quickly.", "Deep describes a river, but it has nothing to do with speed.", "Cold describes a river too, but not how fast it moves."]'::JSONB),

('train-hspt-reading-02', 'reading', 2, 'Reading — finding a detail',
 'According to the passage, what does the LENGTH of the bee''s straight run tell the other bees?',
 'When a honeybee finds a good patch of flowers, she does not keep it to herself. She flies back to the hive and performs a dance on the wall of the honeycomb. In this "waggle dance," the bee runs in a straight line while shaking her body from side to side, then circles back and repeats the run.

The dance is a set of directions. The angle of the straight run tells the other bees which way to fly compared to the direction of the sun. The length of the run tells them how far away the flowers are: the longer the bee waggles, the farther the trip. Scientists who studied the dance were amazed that an insect could share such precise information without making a single sound.',
 '["which flowers smell the best", "how many bees should go", "which way the sun is moving", "how far away the flowers are"]'::JSONB, 3, 1,
 'Detail questions are answered by one specific sentence, so go find it. Search for the word ''length'': the second paragraph says the length of the run tells them how far away the flowers are. Match your choice to the text — do not answer from what merely sounds reasonable.',
 '["The passage never mentions smell. The dance is about location, not which flowers are best.", "The passage says nothing about how many bees go. It describes only direction and distance.", "The sun appears as a reference point for DIRECTION, and direction comes from the angle of the run, not its length.", "Correct. The passage says: the longer the bee waggles, the farther the trip."]'::JSONB),

('train-hspt-reading-03', 'reading', 3, 'Reading — finding a detail',
 'According to the passage, the Erie Canal connected the Hudson River to',
 'In 1817, the state of New York began digging a canal that many people thought was foolish. Critics called it "Clinton''s Ditch," after Governor DeWitt Clinton, who championed the plan. The canal would stretch 363 miles, connecting the Hudson River at Albany to Lake Erie at Buffalo.

When the Erie Canal opened in 1825, the critics were proved wrong. Before the canal, moving goods overland from Buffalo to New York City could take weeks and cost a fortune. By boat, the trip became much faster, and the cost of shipping dropped by roughly ninety percent. Farm goods from the Midwest poured east, and New York City grew into the busiest port in the nation.',
 '["the Atlantic Ocean", "New York City", "Lake Erie", "the Mississippi River"]'::JSONB, 2, 1,
 'Find the sentence that answers it directly: the canal would connect the Hudson River at Albany to Lake Erie at Buffalo. New York City is a trap — it is in the passage and it matters to the story, but it is not what the canal connected to.',
 '["The Atlantic is never mentioned. The canal ran inland, west from the Hudson.", "New York City benefited from the canal, but the canal''s western end was at Lake Erie.", "Correct. The passage says it connected the Hudson River at Albany to Lake Erie at Buffalo.", "The Mississippi does not appear in the passage at all."]'::JSONB),

('train-hspt-reading-04', 'reading', 4, 'Reading — finding a detail',
 'According to the passage, trees cool the air because',
 'Every city should plant more trees along its streets. On a summer afternoon, a shaded sidewalk can be many degrees cooler than one in full sun, and trees cool the air around them as water evaporates from their leaves. That matters to anyone waiting for a bus in July.

Trees also soak up rainwater that would otherwise rush into storm drains and flood low streets. Some people argue that trees are too expensive to plant and care for. But a young tree costs far less than repairing a flooded road, and it keeps working for decades. A city that plants trees today is not spending money; it is saving it.',
 '["their shade blocks the wind", "water evaporates from their leaves", "they soak up rainwater", "they grow taller in summer"]'::JSONB, 1, 1,
 'The trickiest wrong answers are TRUE statements from a different part of the passage. Soaking up rainwater really is in the text — but it answers a different question. Always check that your choice answers the question asked, not just that it appears somewhere.',
 '["Shade blocks sunlight, not wind, and the passage never mentions wind.", "Correct. The passage says trees cool the air around them as water evaporates from their leaves.", "Soaking up rain is a real benefit in the passage, but it explains flood control, not cooling.", "Growth is never mentioned."]'::JSONB),

('train-hspt-reading-05', 'reading', 5, 'Reading — finding a detail',
 'According to the passage, what are chromatophores?',
 'An octopus can change color in less than a second. Its skin holds thousands of tiny sacs of pigment called chromatophores, and each sac is ringed by muscles. When the muscles pull, the sac stretches wide and its color spreads across a patch of skin; when they relax, the sac shrinks to a dot too small to see.

Because these muscles are controlled by nerves, an octopus can reshape the patterns on its body almost instantly. It uses this skill to vanish against a rocky seafloor, to startle a predator with a sudden flash of dark color, or to signal to other octopuses. The same animal that can squeeze through a gap the size of a coin can also disappear in plain sight.',
 '["tiny sacs of pigment in the skin", "muscles that move the octopus''s arms", "nerves that control breathing", "patterns on the seafloor"]'::JSONB, 0, 1,
 'When a passage introduces a technical word, it almost always defines it in the same sentence — look for ''called'' or a comma right after the new word. Here: tiny sacs of pigment called chromatophores. The other choices borrow real words from the passage but attach them to the wrong thing.',
 '["Correct. The passage defines them as tiny sacs of pigment in the octopus''s skin.", "The muscles in the passage surround the pigment sacs; they do not move the arms.", "Nerves are mentioned, but they control the muscles around the sacs, not breathing.", "The seafloor is where an octopus hides, not what a chromatophore is."]'::JSONB),

('train-hspt-reading-06', 'reading', 6, 'Vocabulary — word in a phrase',
 'Choose the word that means the same as the capitalized word.
a CAUTIOUS driver',
 NULL,
 '["careful", "speedy", "skilled", "nervous"]'::JSONB, 0, 2,
 'Cautious means careful to avoid danger. The hard part is the near-miss: nervous people are often cautious, so it feels close. But the question asks what the word MEANS, not who tends to act that way. A calm driver can be cautious, and a nervous one can be reckless.',
 '["Correct. A cautious driver takes care to avoid danger.", "Speedy is nearly the opposite — caution usually means slowing down.", "A driver can be skilled without being cautious. Skill is ability; caution is attitude.", "Nervous describes a feeling. A cautious driver may be perfectly calm — caution is about choices, not worry."]'::JSONB),

('train-hspt-reading-07', 'reading', 7, 'Reading — main idea',
 'Which title best fits this passage?',
 'When a honeybee finds a good patch of flowers, she does not keep it to herself. She flies back to the hive and performs a dance on the wall of the honeycomb. In this "waggle dance," the bee runs in a straight line while shaking her body from side to side, then circles back and repeats the run.

The dance is a set of directions. The angle of the straight run tells the other bees which way to fly compared to the direction of the sun. The length of the run tells them how far away the flowers are: the longer the bee waggles, the farther the trip. Scientists who studied the dance were amazed that an insect could share such precise information without making a single sound.',
 '["How Bees Make Honey", "A Dance That Gives Directions", "Why Bees Fly Toward the Sun", "The Scientists Who Studied Insects"]'::JSONB, 1, 2,
 'A good title covers the WHOLE passage, not one sentence of it. Ask what both paragraphs are about: the first describes the dance, the second explains what it communicates. Titles that fit only a single sentence — or no sentence — are too narrow or simply wrong.',
 '["Honey-making is never described. A title must cover what the passage is actually about.", "Correct. Both paragraphs build toward one idea: the waggle dance tells other bees where the flowers are.", "Bees do not fly toward the sun in the passage; the sun is only a reference for direction. This title misreads a detail.", "Scientists appear in one closing sentence. A title built on a small detail is too narrow."]'::JSONB),

('train-hspt-reading-08', 'reading', 8, 'Reading — word in context',
 'In the passage, the word "championed" most nearly means',
 'In 1817, the state of New York began digging a canal that many people thought was foolish. Critics called it "Clinton''s Ditch," after Governor DeWitt Clinton, who championed the plan. The canal would stretch 363 miles, connecting the Hudson River at Albany to Lake Erie at Buffalo.

When the Erie Canal opened in 1825, the critics were proved wrong. Before the canal, moving goods overland from Buffalo to New York City could take weeks and cost a fortune. By boat, the trip became much faster, and the cost of shipping dropped by roughly ninety percent. Farm goods from the Midwest poured east, and New York City grew into the busiest port in the nation.',
 '["defeated", "won a contest for", "questioned", "strongly supported"]'::JSONB, 3, 2,
 'When a familiar word appears in an unusual role, trust the sentence over your first association. Champion usually means a winner, but here it is something a governor does to a plan. The critics attached his name to the canal, so he must have been its leading supporter. Try each choice in the sentence and keep the one that makes sense.',
 '["Defeating a plan is the opposite of what Clinton did — the canal was nicknamed after him because he backed it.", "This is the everyday meaning of champion, a sports winner. In this sentence the word is an action someone takes toward a plan.", "Questioning the plan is what the critics did, not Clinton.", "Correct. Clinton championed the plan, meaning he argued for it — which is why critics tied his name to it."]'::JSONB),

('train-hspt-reading-09', 'reading', 9, 'Reading — main idea',
 'What is the author''s main point?',
 'Every city should plant more trees along its streets. On a summer afternoon, a shaded sidewalk can be many degrees cooler than one in full sun, and trees cool the air around them as water evaporates from their leaves. That matters to anyone waiting for a bus in July.

Trees also soak up rainwater that would otherwise rush into storm drains and flood low streets. Some people argue that trees are too expensive to plant and care for. But a young tree costs far less than repairing a flooded road, and it keeps working for decades. A city that plants trees today is not spending money; it is saving it.',
 '["Trees are too expensive for most cities to care for.", "Waiting for a bus in summer is unpleasant.", "Cities should plant more street trees because they pay for themselves.", "Storm drains in most cities are poorly built."]'::JSONB, 2, 2,
 'In a persuasive passage, the main point is the claim everything else supports — usually stated in the first or last sentence. Here the first says cities should plant more trees, and the last explains why it saves money. Be careful with opposing views: an author often mentions one only to answer it.',
 '["This is the objection the author raises in order to reject it. Mentioning an opposing view is not agreeing with it.", "The bus stop is one example of why shade matters, not the point of the passage.", "Correct. The first sentence states the claim, and every paragraph supports it, ending with ''it is saving it.''", "Storm drains appear only as part of the flooding argument."]'::JSONB),

('train-hspt-reading-10', 'reading', 10, 'Reading — cause and effect',
 'According to the passage, why can an octopus change its patterns so quickly?',
 'An octopus can change color in less than a second. Its skin holds thousands of tiny sacs of pigment called chromatophores, and each sac is ringed by muscles. When the muscles pull, the sac stretches wide and its color spreads across a patch of skin; when they relax, the sac shrinks to a dot too small to see.

Because these muscles are controlled by nerves, an octopus can reshape the patterns on its body almost instantly. It uses this skill to vanish against a rocky seafloor, to startle a predator with a sudden flash of dark color, or to signal to other octopuses. The same animal that can squeeze through a gap the size of a coin can also disappear in plain sight.',
 '["Its skin is extremely thin.", "It can see every color around it.", "It lives on rocky seafloors.", "The muscles around its pigment sacs are controlled by nerves."]'::JSONB, 3, 2,
 'Cause-and-effect questions often have a signal word in the passage — because, so, as a result. Search for it: ''Because these muscles are controlled by nerves, an octopus can reshape the patterns on its body almost instantly.'' The word ''because'' points straight at the cause.',
 '["The thickness of the skin is never mentioned.", "The passage says nothing about the octopus''s eyesight.", "The seafloor is where it hides, not what makes the change fast.", "Correct. The passage says: because these muscles are controlled by nerves, an octopus can reshape its patterns almost instantly."]'::JSONB),

('train-hspt-reading-11', 'reading', 11, 'Vocabulary — word in a phrase',
 'Choose the word that means the same as the capitalized word.
an AUSTERE room',
 NULL,
 '["luxurious", "crowded", "plain and bare", "brightly lit"]'::JSONB, 2, 3,
 'Austere means severely simple — no decoration, no luxury. If you do not know it, notice that it sounds stern; words describing strictness often describe plainness too. Then eliminate what you can: luxurious is the opposite, and crowded and brightly lit describe other qualities of a room entirely.',
 '["Luxurious is the opposite — rich and comfortable. Austere means without comforts.", "Austere describes how a room is furnished, not how many people are in it.", "Correct. An austere room is simple and undecorated, with nothing extra.", "Lighting is not part of the word''s meaning."]'::JSONB),

('train-hspt-reading-12', 'reading', 12, 'Reading — inference',
 'The passage suggests that the scientists were surprised mainly because',
 'When a honeybee finds a good patch of flowers, she does not keep it to herself. She flies back to the hive and performs a dance on the wall of the honeycomb. In this "waggle dance," the bee runs in a straight line while shaking her body from side to side, then circles back and repeats the run.

The dance is a set of directions. The angle of the straight run tells the other bees which way to fly compared to the direction of the sun. The length of the run tells them how far away the flowers are: the longer the bee waggles, the farther the trip. Scientists who studied the dance were amazed that an insect could share such precise information without making a single sound.',
 '["bees can see the sun from inside the hive", "the bees'' message was precise yet completely silent", "bees live together in large groups", "flowers tend to grow in patches"]'::JSONB, 1, 3,
 'Inference questions ask what the passage implies, but the proof is still in the text. The final sentence gives two reasons for the amazement: the information was precise, and it was shared without sound. The right answer must hold both ideas. Choices that are simply true about bees do not explain why the scientists were surprised.',
 '["The passage never raises whether bees can see the sun as the surprising part.", "Correct. The last sentence says they were amazed an insect could share such precise information without a single sound — precise and silent together.", "Living in hives is never presented as surprising.", "Flowers growing in patches is background, not a discovery."]'::JSONB),

('train-hspt-reading-13', 'reading', 13, 'Reading — author''s purpose',
 'The author mentions the nickname "Clinton''s Ditch" mainly to',
 'In 1817, the state of New York began digging a canal that many people thought was foolish. Critics called it "Clinton''s Ditch," after Governor DeWitt Clinton, who championed the plan. The canal would stretch 363 miles, connecting the Hudson River at Albany to Lake Erie at Buffalo.

When the Erie Canal opened in 1825, the critics were proved wrong. Before the canal, moving goods overland from Buffalo to New York City could take weeks and cost a fortune. By boat, the trip became much faster, and the cost of shipping dropped by roughly ninety percent. Farm goods from the Midwest poured east, and New York City grew into the busiest port in the nation.',
 '["explain how the canal got its official name", "prove that the governor was unpopular", "describe how the canal was dug", "show that many people doubted the project at first"]'::JSONB, 3, 3,
 'Purpose questions ask WHY the author included something. Look at what comes next: when the canal opened in 1825, the critics were proved wrong. The nickname sets up a doubt that the passage then overturns. Be suspicious of choices with strong words like ''prove'' — authors rarely prove anything with one detail.',
 '["The official name was the Erie Canal. The nickname was an insult, not a title.", "The nickname mocked the plan, not necessarily the man — and ''prove'' is far too strong for a single nickname.", "The nickname says nothing about how it was built.", "Correct. Calling it a ditch mocked the project, and the next paragraph says the critics were proved wrong — the author sets up the doubt so the success lands harder."]'::JSONB),

('train-hspt-reading-14', 'reading', 14, 'Reading — how an author argues',
 'How does the author respond to the argument that trees are too expensive?',
 'Every city should plant more trees along its streets. On a summer afternoon, a shaded sidewalk can be many degrees cooler than one in full sun, and trees cool the air around them as water evaporates from their leaves. That matters to anyone waiting for a bus in July.

Trees also soak up rainwater that would otherwise rush into storm drains and flood low streets. Some people argue that trees are too expensive to plant and care for. But a young tree costs far less than repairing a flooded road, and it keeps working for decades. A city that plants trees today is not spending money; it is saving it.',
 '["by comparing the cost of a tree to the cost of flood damage", "by agreeing that most cities cannot afford them", "by listing the prices of different kinds of trees", "by saying the argument is not worth discussing"]'::JSONB, 0, 3,
 'When an author writes ''Some people argue...'', watch for the ''But'' that follows — that is where the author answers. Here the answer compares two costs: a tree now against flood repairs later. These questions test whether you can name the author''s MOVE — compare, concede, or dismiss — not just repeat what was said.',
 '["Correct. The author answers one cost with a bigger one: a young tree costs far less than repairing a flooded road.", "The author mentions the objection only to answer it — the very next word is ''But.''", "No prices appear anywhere in the passage.", "The author does discuss it, with a direct counter-argument."]'::JSONB),

('train-hspt-reading-15', 'reading', 15, 'Reading — drawing a conclusion',
 'Which conclusion is best supported by the passage?',
 'An octopus can change color in less than a second. Its skin holds thousands of tiny sacs of pigment called chromatophores, and each sac is ringed by muscles. When the muscles pull, the sac stretches wide and its color spreads across a patch of skin; when they relax, the sac shrinks to a dot too small to see.

Because these muscles are controlled by nerves, an octopus can reshape the patterns on its body almost instantly. It uses this skill to vanish against a rocky seafloor, to startle a predator with a sudden flash of dark color, or to signal to other octopuses. The same animal that can squeeze through a gap the size of a coin can also disappear in plain sight.',
 '["Octopuses change color only when they are frightened.", "All sea animals can change color quickly.", "An octopus''s color changes serve more than one purpose.", "Octopuses cannot see their predators."]'::JSONB, 2, 3,
 'Supported conclusions stay close to the text. Absolute words — only, all, never — are red flags, because one counter-example breaks them. The passage names three different reasons for changing color, which supports ''more than one purpose'' and breaks ''only when frightened.''',
 '["''Only'' is too strong. The passage also lists hiding and signaling to other octopuses.", "The passage is about octopuses alone; ''all sea animals'' goes far beyond it.", "Correct. The passage lists three uses: hiding against the seafloor, startling a predator, and signaling to other octopuses.", "Nothing about octopus eyesight appears in the passage."]'::JSONB),

('train-hspt-math-01', 'math', 1, 'Order of operations',
 'What is 6 + 4 × 3?',
 NULL,
 '["30", "18", "13", "22"]'::JSONB, 1, 1,
 'Multiplication and division come before addition and subtraction, unless parentheses say otherwise. So 4 × 3 = 12 first, then 6 + 12 = 18. Reading left to right and adding 6 + 4 first is the single most common mistake on these.',
 '["30 adds first: (6 + 4) × 3. Without parentheses, multiplication comes before addition.", "Correct. Multiply first: 4 × 3 = 12. Then add: 6 + 12 = 18.", "13 adds all three numbers. The × sign means multiply.", "22 multiplies 6 × 3 and then adds 4 — the operations are attached to the wrong numbers."]'::JSONB),

('train-hspt-math-02', 'math', 2, 'Adding fractions',
 'What is 1/2 + 1/4?',
 NULL,
 '["2/6", "1/8", "3/4", "2/4"]'::JSONB, 2, 1,
 'You can only add fractions whose bottoms (denominators) match. Rewrite 1/2 as 2/4, so both are in fourths. Then add the tops: 2/4 + 1/4 = 3/4. Never add the denominators — one fourth plus one fourth is two fourths, not two eighths.',
 '["2/6 adds the tops and the bottoms separately. Fractions need a common denominator before you add.", "1/8 is 1/2 × 1/4 — that multiplies instead of adding.", "Correct. 1/2 is the same as 2/4, and 2/4 + 1/4 = 3/4.", "2/4 is just 1/2 rewritten. You still need to add the 1/4."]'::JSONB),

('train-hspt-math-03', 'math', 3, 'Percents',
 'What is 10% of 250?',
 NULL,
 '["2.5", "240", "10", "25"]'::JSONB, 3, 1,
 '10% is one tenth, so divide by 10 — which just moves the decimal point one place left: 250 becomes 25.0. Knowing 10% instantly lets you build others: 20% is double (50), and 5% is half (12.5).',
 '["2.5 is 1% of 250 — the decimal moved one place too far.", "240 subtracts 10 from 250. A percent means a part out of 100, not a number to subtract.", "10 is the percent itself, not 10% of 250.", "Correct. 10% means one tenth: 250 ÷ 10 = 25."]'::JSONB),

('train-hspt-math-04', 'math', 4, 'Perimeter',
 'A rectangle is 7 inches long and 3 inches wide. What is its perimeter?',
 NULL,
 '["20 inches", "21 inches", "10 inches", "17 inches"]'::JSONB, 0, 1,
 'Perimeter means the distance around the outside. A rectangle has two lengths and two widths: 7 + 7 + 3 + 3 = 20. The quick way is 2 × (7 + 3). If you multiplied 7 × 3, you found the area — a completely different measurement.',
 '["Correct. Perimeter is the distance all the way around: 7 + 3 + 7 + 3 = 20.", "21 is 7 × 3, which is the AREA. Perimeter adds the sides; area multiplies them.", "10 adds one length and one width — only halfway around.", "17 counts only three sides: 7 + 7 + 3."]'::JSONB),

('train-hspt-math-05', 'math', 5, 'Word problems — multiplying',
 'Notebooks cost $2.50 each. How much do 3 notebooks cost?',
 NULL,
 '["$5.00", "$5.50", "$6.50", "$7.50"]'::JSONB, 3, 1,
 'The word ''each'' signals multiplication: price per item times the number of items. For 3 × $2.50, split dollars from cents: 3 × 2 = 6 and 3 × 0.50 = 1.50, so 6 + 1.50 = $7.50. Splitting like this makes money math easy to do in your head.',
 '["$5.00 is the cost of 2 notebooks, not 3.", "$5.50 adds $3 to $2.50 — it adds the count instead of multiplying by it.", "$6.50 is a dollar short. Check by adding $2.50 three times: $2.50, $5.00, $7.50.", "Correct. 3 × $2.50 = $7.50."]'::JSONB),

('train-hspt-math-06', 'math', 6, 'Order of operations',
 'What is (8 − 3)² − 4 × 2?',
 NULL,
 '["42", "47", "17", "2"]'::JSONB, 2, 2,
 'The order is Parentheses, Exponents, Multiplication and Division, then Addition and Subtraction. (8 − 3) = 5; 5² = 25; 4 × 2 = 8; 25 − 8 = 17. The exponent sits outside the parentheses, so it squares the result, 5 — not the 8 and the 3 separately.',
 '["42 subtracts 4 from 25 before multiplying. The multiplication, 4 × 2, must come first.", "47 squares 8 and 3 separately (64 − 9 − 8). The exponent applies to the whole parentheses, which equal 5.", "Correct. Parentheses first: 8 − 3 = 5. Exponent: 5² = 25. Multiply: 4 × 2 = 8. Subtract: 25 − 8 = 17.", "2 treats the small 2 as × 2: 5 × 2 = 10, then 10 − 8. The ² means multiply 5 by ITSELF."]'::JSONB),

('train-hspt-math-07', 'math', 7, 'Fractions of a number',
 'What is 2/3 of 45?',
 NULL,
 '["15", "30", "22.5", "67.5"]'::JSONB, 1, 2,
 '''Of'' means multiply. The easy way: divide by the bottom number, multiply by the top. 45 ÷ 3 = 15, then 15 × 2 = 30. A quick sanity check: 2/3 is less than 1, so the answer must be less than 45.',
 '["15 is one third of 45. Two thirds is twice that.", "Correct. One third of 45 is 15, so two thirds is 30.", "22.5 is one half of 45. Two thirds is more than a half.", "67.5 flips the fraction (45 × 3/2). Taking 2/3 of a number makes it smaller, not bigger."]'::JSONB),

('train-hspt-math-08', 'math', 8, 'Solving equations',
 'If 3x + 5 = 20, what is x?',
 NULL,
 '["15", "25/3", "5", "45"]'::JSONB, 2, 2,
 'Undo the operations in reverse order, doing the same thing to both sides. The + 5 happened last, so remove it first: 3x = 15. Then undo the × 3 by dividing: x = 5. Always plug your answer back in to check it.',
 '["15 is 3x — one step short. Divide by 3 to find x itself.", "25/3 comes from adding 5 instead of subtracting it. To undo + 5, subtract 5.", "Correct. Subtract 5 from both sides: 3x = 15. Divide by 3: x = 5. Check: 3 × 5 + 5 = 20.", "45 multiplies 15 by 3 instead of dividing."]'::JSONB),

('train-hspt-math-09', 'math', 9, 'Area',
 'A triangle has a base of 10 cm and a height of 6 cm. What is its area?',
 NULL,
 '["16 cm²", "60 cm²", "30 cm²", "8 cm²"]'::JSONB, 2, 2,
 'A triangle is exactly half of a rectangle with the same base and height. So find base × height (10 × 6 = 60) and halve it: 30. The units are squared — cm² — because you multiplied two lengths together.',
 '["16 adds the base and the height. Area multiplies them.", "60 is base × height — the area of a RECTANGLE. A triangle is half of that.", "Correct. Area = ½ × base × height = ½ × 10 × 6 = 30 cm².", "8 halves the sum of base and height instead of their product."]'::JSONB),

('train-hspt-math-10', 'math', 10, 'Percent discounts',
 'A shirt costs $40. It is on sale for 25% off. What is the sale price?',
 NULL,
 '["$30", "$10", "$15", "$50"]'::JSONB, 0, 2,
 'Two steps: find the discount, then subtract it. 25% is one quarter, and a quarter of $40 is $10. The sale price is $40 − $10 = $30. Shortcut: 25% off means you pay 75%, and 75% of $40 is $30.',
 '["Correct. 25% of $40 is $10, and $40 − $10 = $30.", "$10 is the amount you SAVE, 25% of $40. The sale price is what is left to pay.", "$15 subtracts 25 dollars, treating the percent as if it were money.", "$50 adds the discount. A sale lowers the price."]'::JSONB),

('train-hspt-math-11', 'math', 11, 'Ratios',
 'The ratio of boys to girls in a class is 3 to 5. If there are 40 students in the class, how many are girls?',
 NULL,
 '["15", "25", "24", "5"]'::JSONB, 1, 3,
 'A ratio of 3 to 5 splits the class into 3 + 5 = 8 equal parts. Find one part: 40 ÷ 8 = 5 students. The girls are 5 parts, so 25. Check with the boys: 3 parts is 15, and 15 + 25 = 40.',
 '["15 is the number of BOYS (3 parts of 5 students each). The question asks for girls.", "Correct. 3 + 5 = 8 equal parts, and 40 ÷ 8 = 5 students per part. Girls get 5 parts: 5 × 5 = 25.", "24 takes 3/5 of the whole class. But the ratio compares boys to girls, not boys to all 40 students.", "5 is the size of ONE part. The girls are five parts."]'::JSONB),

('train-hspt-math-12', 'math', 12, 'Solving equations — x on both sides',
 'If 2(x − 3) = x + 4, what is x?',
 NULL,
 '["7", "−2", "10/3", "10"]'::JSONB, 3, 3,
 'First clear the parentheses by multiplying the 2 by BOTH terms inside: 2x − 6. Then gather the x''s on one side by subtracting x from both sides: x − 6 = 4. Undo the − 6 by adding 6: x = 10. Check in the original: 2(10 − 3) = 14, and 10 + 4 = 14.',
 '["7 forgets to multiply the 3 by 2. 2(x − 3) is 2x − 6, not 2x − 3.", "−2 subtracts 6 when moving it across. To undo − 6, add 6.", "10/3 adds x to both sides, giving 3x = 10. To gather the x''s on one side, subtract x.", "Correct. Distribute: 2x − 6 = x + 4. Subtract x from both sides: x − 6 = 4. Add 6: x = 10."]'::JSONB),

('train-hspt-math-13', 'math', 13, 'Circles',
 'A circle has a diameter of 10 inches. What is its area? (Use π ≈ 3.14)',
 NULL,
 '["314 square inches", "78.5 square inches", "31.4 square inches", "15.7 square inches"]'::JSONB, 1, 3,
 'Area of a circle = π × r², where r is the radius. The problem gives the diameter, so halve it first: r = 5. Then 5² = 25, and 3.14 × 25 = 78.5. The two classic traps are using the diameter instead of the radius, and confusing area with circumference, which is π × d.',
 '["314 uses the diameter as the radius: 3.14 × 10². The radius is half the diameter.", "Correct. The radius is 10 ÷ 2 = 5. Area = π × r² = 3.14 × 25 = 78.5 square inches.", "31.4 is the CIRCUMFERENCE (π × diameter) — the distance around, not the space inside.", "15.7 is π × 5. It multiplies by the radius once instead of squaring it."]'::JSONB),

('train-hspt-math-14', 'math', 14, 'Averages — finding a missing score',
 'Jada''s first three test scores are 80, 85, and 90. What score does she need on the fourth test to have an average of 86?',
 NULL,
 '["85", "86", "91", "89"]'::JSONB, 3, 3,
 'Work with totals, not averages. To average 86 over 4 tests, the four scores must add up to 4 × 86 = 344. She already has 255. The difference is what she needs: 344 − 255 = 89. Check: (80 + 85 + 90 + 89) ÷ 4 = 344 ÷ 4 = 86.',
 '["85 is her CURRENT average (255 ÷ 3). The question asks what she needs next.", "Scoring exactly 86 would only lift her average to 85.25, because her first three tests average below 86.", "91 overshoots: (255 + 91) ÷ 4 = 86.5.", "Correct. An average of 86 over 4 tests needs a total of 4 × 86 = 344. She has 80 + 85 + 90 = 255, so she needs 344 − 255 = 89."]'::JSONB),

('train-hspt-math-15', 'math', 15, 'Rates',
 'A car travels 180 miles in 3 hours. At the same rate, how far will it travel in 5 hours?',
 NULL,
 '["300 miles", "108 miles", "900 miles", "360 miles"]'::JSONB, 0, 3,
 'Find the unit rate first — miles in ONE hour: 180 ÷ 3 = 60. Then scale up: 60 × 5 = 300. Sanity check: 5 hours is longer than 3, so the answer must be more than 180, and less than 360, since 5 hours is less than double 3.',
 '["Correct. 180 ÷ 3 = 60 miles per hour, and 60 × 5 = 300 miles.", "108 flips the rate (180 × 3 ÷ 5). A longer trip at the same speed must cover MORE distance, not less.", "900 multiplies the whole 3-hour distance by 5, as if every hour covered 180 miles.", "360 doubles the distance, which would take 6 hours, not 5."]'::JSONB),

('train-hspt-language-01', 'language', 1, 'Capitalization — starting a sentence',
 'Look for errors in capitalization. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["My cousin lives in Denver.", "we visited the museum on Saturday.", "The Pacific Ocean is very deep.", "No mistakes"]'::JSONB, 1, 1,
 'Check every sentence against the two basic rules: capitalize the first word of a sentence, and capitalize the names of specific people, places, and things. The museum sentence starts with a lowercase ''we.'' Check the first letter of each sentence first — it is the easiest error to miss, because your eyes jump to the middle.',
 '["Denver is a city, so it is capitalized correctly.", "Correct. The first word of every sentence needs a capital letter: We visited the museum.", "Pacific Ocean is the name of a specific ocean, so both words are capitalized correctly.", "The museum sentence starts with a lowercase letter, so there is a mistake."]'::JSONB),

('train-hspt-language-02', 'language', 2, 'Commas in a list',
 'Look for errors in punctuation. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["I bought apples bananas, and grapes.", "Our team won the game.", "Where did you put the keys?", "No mistakes"]'::JSONB, 0, 1,
 'When three or more items are listed, separate each one with a comma. ''Apples bananas'' runs two items together with nothing between them. Read lists slowly and check that every item is separated from the next.',
 '["Correct. Items in a list need commas between them: apples, bananas, and grapes. Here there is no comma between the first two.", "A complete statement that ends with a period — correct.", "A question that ends with a question mark — correct.", "The fruit sentence is missing a comma, so there is a mistake."]'::JSONB),

('train-hspt-language-03', 'language', 3, 'Subject–verb agreement',
 'Look for errors in usage. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["She walks to school every day.", "They are going to the park.", "The dogs barks at the mail carrier.", "No mistakes"]'::JSONB, 2, 1,
 'A singular subject takes a singular verb, and a plural subject takes a plural verb. The confusing part: in English the singular VERB is the one ending in -s (she walks), while the plural NOUN ends in -s (dogs). So it is ''the dogs bark'' but ''the dog barks.'' Find the subject, decide whether it is one or many, then check the verb.',
 '["''She'' is one person, and ''walks'' is the singular verb, so they agree.", "''They'' is plural, and ''are'' is the plural verb, so they agree.", "Correct. ''Dogs'' is plural, so the verb must be ''bark,'' not ''barks.''", "The sentence about the dogs has an agreement error."]'::JSONB),

('train-hspt-language-04', 'language', 4, 'Spelling — ie or ei',
 'Look for errors in spelling. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["I will recieve the package tomorrow.", "My neighbor has a vegetable garden.", "I believe you.", "No mistakes"]'::JSONB, 0, 1,
 'The rhyme ''i before e, except after c'' covers receive: right after the c, it is e-i. Words like neighbor and weigh follow a different pattern — when the sound is ''ay,'' it is e-i. Slow down on any word with ie or ei and say it to yourself.',
 '["Correct. The word is spelled ''receive'' — after c, it is e before i.", "''Neighbor'' is spelled correctly. It is one of the words where e comes before i because it sounds like ''ay.''", "''Believe'' is correct: i before e.", "The package sentence has a misspelling."]'::JSONB),

('train-hspt-language-05', 'language', 5, 'When there is no mistake',
 'Look for errors in capitalization, punctuation, or usage. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["My sister plays the violin.", "Is the library open on Sunday?", "We ate lunch at noon.", "No mistakes"]'::JSONB, 3, 1,
 '''No mistakes'' is a real answer, and it will be right on some questions. Do not force an error that is not there. Check each sentence against the rules you know — capitals, end marks, agreement — and if all three pass, trust your work.',
 '["Capital first letter, a verb that agrees, and a period at the end — no error.", "A question that correctly ends with a question mark, with Sunday capitalized as a day of the week.", "Nothing is wrong here. ''Noon'' is not capitalized because it is not a name.", "Correct. All three sentences are written properly. Sometimes there really is no mistake."]'::JSONB),

('train-hspt-language-06', 'language', 6, 'Apostrophes — its or it''s',
 'Look for errors in punctuation. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["It''s going to rain today.", "The cat licked it''s paw.", "The company changed its name.", "No mistakes"]'::JSONB, 1, 2,
 'Test every ''it''s'' by expanding it to ''it is.'' If the sentence still makes sense, the apostrophe is right. If it does not, you need ''its.'' This is one of the few words where the possessive has NO apostrophe — just like his and hers.',
 '["''It''s'' means ''it is,'' and ''It is going to rain today'' makes sense. Correct.", "Correct. ''It''s'' means ''it is,'' and ''the cat licked it is paw'' makes no sense. The possessive is ''its,'' with no apostrophe.", "''Its name'' shows ownership, and the possessive ''its'' has no apostrophe. Correct.", "The sentence about the cat misuses ''it''s.''"]'::JSONB),

('train-hspt-language-07', 'language', 7, 'Pronouns — I or me',
 'Look for errors in usage. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["The coach gave the award to Sara and me.", "Sara and I finished the project.", "Me and Sara went to the store.", "No mistakes"]'::JSONB, 2, 2,
 'Cover up the other person and read the sentence with just the pronoun. ''Me went'' is wrong, so the store sentence needs ''I.'' ''Gave the award to me'' is right, so the award sentence keeps ''me.'' Many students think ''Sara and I'' is always the more correct choice. It is not — it depends on where the words sit in the sentence.',
 '["''Gave the award to me'' sounds right, so ''to Sara and me'' is correct.", "''I finished the project'' works, so ''Sara and I'' is correct.", "Correct. Take away ''and Sara'': ''Me went to the store'' is wrong. The subject form is ''I'': Sara and I went to the store.", "The store sentence uses ''me'' where ''I'' is needed."]'::JSONB),

('train-hspt-language-08', 'language', 8, 'Commas — joining two sentences',
 'Look for errors in punctuation. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["After dinner, we played a game.", "I wanted to go to the beach, but it was raining.", "I finished my homework, I went outside.", "No mistakes"]'::JSONB, 2, 2,
 'A comma alone cannot join two complete sentences. Test it: can each side stand on its own? ''I finished my homework'' and ''I went outside'' both can, so they need a period, a semicolon, or a comma PLUS a joining word like and, but, or so. The beach sentence has ''but''; the homework sentence does not.',
 '["A comma after an introductory phrase like ''After dinner'' is correct.", "Two complete sentences joined by a comma plus ''but'' — correct.", "Correct. Two complete sentences are joined by only a comma, which is called a comma splice. Add a joining word (''and then'') or use a period.", "The homework sentence is a comma splice."]'::JSONB),

('train-hspt-language-09', 'language', 9, 'Capitalization — names and titles',
 'Look for errors in capitalization. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["We read about the Declaration of independence.", "My uncle is a doctor.", "Grandma made pancakes this morning.", "No mistakes"]'::JSONB, 0, 2,
 'The names of specific things — documents, holidays, events — capitalize every important word, while small words like ''of'' stay lowercase. Job titles and family words stay lowercase unless they are used AS a name: ''my grandma made pancakes,'' but ''Grandma made pancakes.''',
 '["Correct. Every important word in the name of a document is capitalized: Declaration of Independence.", "''Doctor'' is a job, not a name, so it stays lowercase. Correct as written.", "''Grandma'' is used as her name here, so it is capitalized. Correct.", "The Declaration sentence has a capitalization error."]'::JSONB),

('train-hspt-language-10', 'language', 10, 'Composition — transition words',
 'Choose the word or phrase that best completes the second sentence.
Maya studied every night for two weeks.
______, she earned the highest score in her class.',
 NULL,
 '["However", "For example", "Meanwhile", "As a result"]'::JSONB, 3, 2,
 'Transition words show how two ideas connect. Ask what the second sentence is to the first: a contrast, an example, a result, or something happening at the same time? Studying led to the high score, so the link is cause and effect: As a result.',
 '["''However'' signals a contrast, but the high score is the expected payoff of studying, not a surprise.", "''For example'' introduces an illustration of a general point. The second sentence is an outcome, not an example.", "''Meanwhile'' means at the same time, but the score came AFTER the studying.", "Correct. The high score happened because she studied — a cause and its effect."]'::JSONB),

('train-hspt-language-11', 'language', 11, 'Verb tense',
 'Look for errors in usage. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["Tomorrow she will visit her aunt.", "Yesterday we walk to the park and saw a parade.", "Every morning he runs two miles.", "No mistakes"]'::JSONB, 1, 3,
 'Look for time clues — yesterday, tomorrow, every day — and make every verb agree with them. In the parade sentence, ''yesterday'' and ''saw'' are both past, but ''walk'' is present. Tense errors hide in sentences with two verbs, where one is right and the other quietly is not.',
 '["''Tomorrow'' with ''will visit'' — the future tense matches.", "Correct. ''Yesterday'' puts the sentence in the past, and ''saw'' is past tense, so ''walk'' must be ''walked.''", "''Every morning'' describes a habit, and ''runs'' is the present tense used for habits. Correct.", "The parade sentence switches tense partway through."]'::JSONB),

('train-hspt-language-12', 'language', 12, 'Pronouns — who or whom',
 'Look for errors in usage. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["To who did you give the book?", "Whom should I invite to the party?", "Who is knocking at the door?", "No mistakes"]'::JSONB, 0, 3,
 'Answer the question with he or him. If the answer uses HE, choose who; if it uses HIM, choose whom — him and whom both end in m. ''You gave the book to HIM,'' so it is ''to whom.'' Words like to, for, and with are a strong clue that whom is coming.',
 '["Correct. After a word like ''to,'' use ''whom'': To whom did you give the book?", "Answer it: ''I should invite HIM.'' Him ends in m, so ''whom'' is correct.", "Answer it: ''HE is knocking.'' He does not end in m, so ''who'' is correct.", "The book sentence uses ''who'' where ''whom'' is needed."]'::JSONB),

('train-hspt-language-13', 'language', 13, 'Semicolons',
 'Look for errors in punctuation. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["I love to read; my brother prefers sports.", "The storm was fierce; however, no one was hurt.", "Because it was late; we went home.", "No mistakes"]'::JSONB, 2, 3,
 'A semicolon works like a soft period: both sides must be complete sentences. Test each side on its own. ''My brother prefers sports'' stands alone; ''Because it was late'' does not — it leaves you waiting for the rest. Clauses that start with because, when, or although need a comma, not a semicolon.',
 '["Both sides are complete sentences, so the semicolon joins them correctly.", "A semicolon before ''however'' joins two complete sentences, with a comma after it. Correct.", "Correct. ''Because it was late'' cannot stand alone as a sentence, so it cannot sit before a semicolon. Use a comma: Because it was late, we went home.", "The sentence about it being late misuses a semicolon."]'::JSONB),

('train-hspt-language-14', 'language', 14, 'Composition — topic sentences',
 'Which sentence would best begin a paragraph about the benefits of learning a second language?',
 NULL,
 '["Many people around the world speak more than one language.", "Spanish is spoken in many different countries.", "My friend is learning French this year.", "Learning a second language can open doors in school, travel, and work."]'::JSONB, 3, 3,
 'A topic sentence tells the reader what the whole paragraph will be about. It should be broad enough to cover every sentence that follows, yet specific enough to make a point. Facts and personal examples are supporting details — they belong later in the paragraph.',
 '["True, but it states a fact without saying why learning a language helps. It does not point toward benefits.", "This is a detail about one language — too narrow to introduce the whole topic.", "A personal example works in the middle of a paragraph, not as the sentence that sets up the main idea.", "Correct. It names the topic and previews the benefits the paragraph will explain."]'::JSONB),

('train-hspt-language-15', 'language', 15, 'Spelling — double letters',
 'Look for errors in spelling. Choose the sentence that has an error, or choose No mistakes.',
 NULL,
 '["The hotel can accommodate a large group.", "It is neccessary to bring a pencil.", "We celebrate on special occasions.", "No mistakes"]'::JSONB, 1, 3,
 'Words with double letters are among the most misspelled on the test. Memory tricks help: necessary has one Collar and two Sleeves — one c, two s''s. Accommodate is big enough to hold two c''s and two m''s. When a word looks almost right, check which letter is doubled.',
 '["''Accommodate'' is correct — it has a double c AND a double m.", "Correct. ''Necessary'' has one c and two s''s. The misspelling doubles the wrong letter.", "''Occasions'' is correct: double c, single s.", "The pencil sentence has a misspelling."]'::JSONB)
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
  (SELECT COUNT(*) FROM questions)                                  AS scoring_bank_untouched,
  -- Hash of every prompt, option, note and explanation as STORED, compared to
  -- the hash of the validated source. Catches anything corrupted between the
  -- generator and the database — a slipped character in a copy and paste
  -- passes every count above but fails here.
  (SELECT md5(string_agg(concat_ws('|', c.concept, c.prompt, COALESCE(c.passage, ''),
                                     c.options::TEXT, c.option_notes::TEXT, c.explanation,
                                     c.correct_index::TEXT, c.difficulty::TEXT),
                           '#' ORDER BY c.section::TEXT, c.sort_order))
     FROM training_questions AS c
    WHERE c.exam = 'hspt') = 'd3b78e485f58e4f16abc39ed109aa40e'                            AS content_intact
FROM training_questions t
JOIN LATERAL (
  SELECT COUNT(*) AS n FROM training_questions t2
  WHERE t2.section = t.section AND t2.correct_index = t.correct_index
) pos ON true
WHERE t.exam = 'hspt'
GROUP BY t.section
ORDER BY t.section;
