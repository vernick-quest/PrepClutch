-- 030 — Real titles for reading passages
--
-- Reading questions duplicate their passage text across every question that
-- shares it, and the table has no title column, so the UI derived a header
-- from the passage's opening words. That rendered as a sentence fragment.
--
-- Adds a nullable `passage_title` and sets a real, hand-written title on every
-- row of each of the 50 distinct reading passages. Titles are 2-5 words,
-- topical, and deliberately avoid restating any question's correct answer.
--
-- Matching is done on a distinctive substring of each passage; every fragment
-- below was verified to match exactly one distinct passage across the whole
-- corpus (seed_questions.sql + migrations 014 and 020), and no fragment
-- overlaps the passage text edited by migration 018.
--
-- Nothing else is touched: no id, section, difficulty, options, correct_index,
-- and no row in user_question_history. Re-running is a no-op.

ALTER TABLE questions ADD COLUMN IF NOT EXISTS passage_title TEXT;

-- ── Titles ──────────────────────────────────────────────────────────────────

-- 58 words · 3 questions
UPDATE questions SET passage_title = 'Monarch Butterfly Migration'
 WHERE section = 'reading'
   AND passage LIKE '%longest migrations of any insect%'
   AND passage_title IS DISTINCT FROM 'Monarch Butterfly Migration';

-- 64 words · 4 questions
UPDATE questions SET passage_title = 'The Transcontinental Railroad'
 WHERE section = 'reading'
   AND passage LIKE '%Transcontinental Railroad transformed American life%'
   AND passage_title IS DISTINCT FROM 'The Transcontinental Railroad';

-- 83 words · 3 questions
UPDATE questions SET passage_title = 'Cognitive Dissonance Explained'
 WHERE section = 'reading'
   AND passage LIKE '%introduced by psychologist Leon Festinger%'
   AND passage_title IS DISTINCT FROM 'Cognitive Dissonance Explained';

-- 41 words · 4 questions
UPDATE questions SET passage_title = 'Why Rain Forests Matter'
 WHERE section = 'reading'
   AND passage LIKE '%home to more than half of the world%'
   AND passage_title IS DISTINCT FROM 'Why Rain Forests Matter';

-- 57 words · 4 questions
UPDATE questions SET passage_title = 'Debating Wealth and Virtue'
 WHERE section = 'reading'
   AND passage LIKE '%whether prosperity causes virtue%'
   AND passage_title IS DISTINCT FROM 'Debating Wealth and Virtue';

-- 54 words · 7 questions
UPDATE questions SET passage_title = 'Gutenberg and the Printing Press'
 WHERE section = 'reading'
   AND passage LIKE '%invented by Johannes Gutenberg around 1440%'
   AND passage_title IS DISTINCT FROM 'Gutenberg and the Printing Press';

-- 89 words · 5 questions
UPDATE questions SET passage_title = 'Light in the Ocean Depths'
 WHERE section = 'reading'
   AND passage LIKE '%In the pitch-black depths of the ocean%'
   AND passage_title IS DISTINCT FROM 'Light in the Ocean Depths';

-- 105 words · 4 questions
UPDATE questions SET passage_title = 'The History of Sign Language'
 WHERE section = 'reading'
   AND passage LIKE '%first formal sign language school%'
   AND passage_title IS DISTINCT FROM 'The History of Sign Language';

-- 102 words · 4 questions
UPDATE questions SET passage_title = 'How the Water Cycle Works'
 WHERE section = 'reading'
   AND passage LIKE '%never-ending process called the water cycle%'
   AND passage_title IS DISTINCT FROM 'How the Water Cycle Works';

-- 106 words · 4 questions
UPDATE questions SET passage_title = 'Writing in Ancient Mesopotamia'
 WHERE section = 'reading'
   AND passage LIKE '%wedge-shaped reed stylus%'
   AND passage_title IS DISTINCT FROM 'Writing in Ancient Mesopotamia';

-- 107 words · 4 questions
UPDATE questions SET passage_title = 'The Olympic Games Through Time'
 WHERE section = 'reading'
   AND passage LIKE '%took place in 776 BCE%'
   AND passage_title IS DISTINCT FROM 'The Olympic Games Through Time';

-- 108 words · 4 questions
UPDATE questions SET passage_title = 'How Vaccines Work'
 WHERE section = 'reading'
   AND passage LIKE '%called immunological memory%'
   AND passage_title IS DISTINCT FROM 'How Vaccines Work';

-- 106 words · 4 questions
UPDATE questions SET passage_title = 'Bees and Pollination'
 WHERE section = 'reading'
   AND passage LIKE '%not because of their honey%'
   AND passage_title IS DISTINCT FROM 'Bees and Pollination';

-- 106 words · 4 questions
UPDATE questions SET passage_title = 'The Brain During Sleep'
 WHERE section = 'reading'
   AND passage LIKE '%clears out waste products that build up%'
   AND passage_title IS DISTINCT FROM 'The Brain During Sleep';

-- 105 words · 4 questions
UPDATE questions SET passage_title = 'The Roots of Jazz'
 WHERE section = 'reading'
   AND passage LIKE '%juke joints%'
   AND passage_title IS DISTINCT FROM 'The Roots of Jazz';

-- 115 words · 4 questions
UPDATE questions SET passage_title = 'How the Eye Sees Color'
 WHERE section = 'reading'
   AND passage LIKE '%specialized cells called cones%'
   AND passage_title IS DISTINCT FROM 'How the Eye Sees Color';

-- 108 words · 4 questions
UPDATE questions SET passage_title = 'Bell and the Telephone'
 WHERE section = 'reading'
   AND passage LIKE '%filed his patent just hours before%'
   AND passage_title IS DISTINCT FROM 'Bell and the Telephone';

-- 119 words · 4 questions
UPDATE questions SET passage_title = 'Tectonic Plates and Earthquakes'
 WHERE section = 'reading'
   AND passage LIKE '%patchwork of giant rocky slabs%'
   AND passage_title IS DISTINCT FROM 'Tectonic Plates and Earthquakes';

-- 127 words · 4 questions
UPDATE questions SET passage_title = 'The Life Cycle of Stars'
 WHERE section = 'reading'
   AND passage LIKE '%cloud of gas and dust called a nebula%'
   AND passage_title IS DISTINCT FROM 'The Life Cycle of Stars';

-- 109 words · 4 questions
UPDATE questions SET passage_title = 'The Urban Heat Island'
 WHERE section = 'reading'
   AND passage LIKE '%urban heat island effect%'
   AND passage_title IS DISTINCT FROM 'The Urban Heat Island';

-- 107 words · 4 questions
UPDATE questions SET passage_title = 'From ARPANET to the Web'
 WHERE section = 'reading'
   AND passage LIKE '%smaller network created in 1969%'
   AND passage_title IS DISTINCT FROM 'From ARPANET to the Web';

-- 116 words · 4 questions
UPDATE questions SET passage_title = 'How Bats Use Echolocation'
 WHERE section = 'reading'
   AND passage LIKE '%biological sonar system called echolocation%'
   AND passage_title IS DISTINCT FROM 'How Bats Use Echolocation';

-- 116 words · 4 questions
UPDATE questions SET passage_title = 'How the Brain Reads Color'
 WHERE section = 'reading'
   AND passage LIKE '%gray square looks darker%'
   AND passage_title IS DISTINCT FROM 'How the Brain Reads Color';

-- 118 words · 4 questions
UPDATE questions SET passage_title = 'Wayfinding Across the Pacific'
 WHERE section = 'reading'
   AND passage LIKE '%indigenous navigators of the Pacific Islands%'
   AND passage_title IS DISTINCT FROM 'Wayfinding Across the Pacific';

-- 114 words · 4 questions
UPDATE questions SET passage_title = 'Supply, Demand, and Prices'
 WHERE section = 'reading'
   AND passage LIKE '%called the equilibrium price%'
   AND passage_title IS DISTINCT FROM 'Supply, Demand, and Prices';

-- 107 words · 4 questions
UPDATE questions SET passage_title = 'Democracy in Ancient Athens'
 WHERE section = 'reading'
   AND passage LIKE '%Athenian statesman Cleisthenes%'
   AND passage_title IS DISTINCT FROM 'Democracy in Ancient Athens';

-- 108 words · 4 questions
UPDATE questions SET passage_title = 'How Antibiotics Fight Bacteria'
 WHERE section = 'reading'
   AND passage LIKE '%targeting features of bacteria that human cells do not have%'
   AND passage_title IS DISTINCT FROM 'How Antibiotics Fight Bacteria';

-- 114 words · 4 questions
UPDATE questions SET passage_title = 'Life on Coral Reefs'
 WHERE section = 'reading'
   AND passage LIKE '%rainforests of the sea%'
   AND passage_title IS DISTINCT FROM 'Life on Coral Reefs';

-- 121 words · 4 questions
UPDATE questions SET passage_title = 'How Sound Travels'
 WHERE section = 'reading'
   AND passage LIKE '%areas of compression and expansion%'
   AND passage_title IS DISTINCT FROM 'How Sound Travels';

-- 115 words · 4 questions
UPDATE questions SET passage_title = 'Why Birds Migrate'
 WHERE section = 'reading'
   AND passage LIKE '%called photoperiod%'
   AND passage_title IS DISTINCT FROM 'Why Birds Migrate';

-- 119 words · 4 questions
UPDATE questions SET passage_title = 'How Memories Are Formed'
 WHERE section = 'reading'
   AND passage LIKE '%region called the hippocampus%'
   AND passage_title IS DISTINCT FROM 'How Memories Are Formed';

-- 237 words · 4 questions
UPDATE questions SET passage_title = 'Reading Antarctic Ice Cores'
 WHERE section = 'reading'
   AND passage LIKE '%Deep beneath the Antarctic surface%'
   AND passage_title IS DISTINCT FROM 'Reading Antarctic Ice Cores';

-- 218 words · 4 questions
UPDATE questions SET passage_title = 'Tardigrades and Extreme Survival'
 WHERE section = 'reading'
   AND passage LIKE '%nickname water bear%'
   AND passage_title IS DISTINCT FROM 'Tardigrades and Extreme Survival';

-- 224 words · 4 questions
UPDATE questions SET passage_title = 'Fungal Networks Beneath Forests'
 WHERE section = 'reading'
   AND passage LIKE '%partnership that biologists call mycorrhiza%'
   AND passage_title IS DISTINCT FROM 'Fungal Networks Beneath Forests';

-- 220 words · 4 questions
UPDATE questions SET passage_title = 'Why Leaves Change Color'
 WHERE section = 'reading'
   AND passage LIKE '%yellows and oranges of autumn leaves%'
   AND passage_title IS DISTINCT FROM 'Why Leaves Change Color';

-- 222 words · 4 questions
UPDATE questions SET passage_title = 'Taking Salt Out of Seawater'
 WHERE section = 'reading'
   AND passage LIKE '%More than nine-tenths of the water on Earth%'
   AND passage_title IS DISTINCT FROM 'Taking Salt Out of Seawater';

-- 219 words · 4 questions
UPDATE questions SET passage_title = 'Measuring the Solar System'
 WHERE section = 'reading'
   AND passage LIKE '%Edmond Halley proposed a method%'
   AND passage_title IS DISTINCT FROM 'Measuring the Solar System';

-- 223 words · 4 questions
UPDATE questions SET passage_title = 'Caravan Routes Across Asia'
 WHERE section = 'reading'
   AND passage LIKE '%The Silk Road was never a road%'
   AND passage_title IS DISTINCT FROM 'Caravan Routes Across Asia';

-- 222 words · 4 questions
UPDATE questions SET passage_title = 'Building the Erie Canal'
 WHERE section = 'reading'
   AND passage LIKE '%digging a ditch four feet deep%'
   AND passage_title IS DISTINCT FROM 'Building the Erie Canal';

-- 222 words · 4 questions
UPDATE questions SET passage_title = 'The Seneca Falls Convention'
 WHERE section = 'reading'
   AND passage LIKE '%gathered in a chapel in Seneca Falls%'
   AND passage_title IS DISTINCT FROM 'The Seneca Falls Convention';

-- 229 words · 4 questions
UPDATE questions SET passage_title = 'The Great Migration North'
 WHERE section = 'reading'
   AND passage LIKE '%Historians call this movement the Great Migration%'
   AND passage_title IS DISTINCT FROM 'The Great Migration North';

-- 229 words · 4 questions
UPDATE questions SET passage_title = 'Carnegie''s Public Libraries'
 WHERE section = 'reading'
   AND passage LIKE '%the steel manufacturer Andrew Carnegie%'
   AND passage_title IS DISTINCT FROM 'Carnegie''s Public Libraries';

-- 225 words · 4 questions
UPDATE questions SET passage_title = 'Trade and Books in Timbuktu'
 WHERE section = 'reading'
   AND passage LIKE '%the name Timbuktu is used to mean anywhere impossibly far away%'
   AND passage_title IS DISTINCT FROM 'Trade and Books in Timbuktu';

-- 229 words · 4 questions
UPDATE questions SET passage_title = 'The Invention of Perspective'
 WHERE section = 'reading'
   AND passage LIKE '%demonstrated in Florence by the architect Filippo Brunelleschi%'
   AND passage_title IS DISTINCT FROM 'The Invention of Perspective';

-- 222 words · 4 questions
UPDATE questions SET passage_title = 'How Haiku Works'
 WHERE section = 'reading'
   AND passage LIKE '%built from seventeen sound units%'
   AND passage_title IS DISTINCT FROM 'How Haiku Works';

-- 226 words · 4 questions
UPDATE questions SET passage_title = 'Inside the Globe Theatre'
 WHERE section = 'reading'
   AND passage LIKE '%The Globe Theatre, where many of Shakespeare%'
   AND passage_title IS DISTINCT FROM 'Inside the Globe Theatre';

-- 221 words · 4 questions
UPDATE questions SET passage_title = 'How Museums Became Public'
 WHERE section = 'reading'
   AND passage LIKE '%The first museums were not public%'
   AND passage_title IS DISTINCT FROM 'How Museums Became Public';

-- 222 words · 3 questions
UPDATE questions SET passage_title = 'Life in the Deep Sea'
 WHERE section = 'reading'
   AND passage LIKE '%specialized cells known as photophores%'
   AND passage_title IS DISTINCT FROM 'Life in the Deep Sea';

-- 251 words · 4 questions
UPDATE questions SET passage_title = 'The Silk Road Network'
 WHERE section = 'reading'
   AND passage LIKE '%coined by German geographer Ferdinand von Richthofen%'
   AND passage_title IS DISTINCT FROM 'The Silk Road Network';

-- 216 words · 3 questions
UPDATE questions SET passage_title = 'Learning to Observe Nature'
 WHERE section = 'reading'
   AND passage LIKE '%The naturalist who wishes to truly understand the world%'
   AND passage_title IS DISTINCT FROM 'Learning to Observe Nature';

-- ── Verification ────────────────────────────────────────────────────────────
-- Expect: 50 titled passages, 0 untitled, and no repeated title.

WITH p AS (
  SELECT DISTINCT passage, passage_title
  FROM questions
  WHERE section = 'reading' AND passage IS NOT NULL
)
SELECT 'distinct passages with a title' AS check,
       COUNT(*)::TEXT AS value
FROM p WHERE passage_title IS NOT NULL
UNION ALL
SELECT 'distinct passages still NULL (expect 0)',
       COUNT(*)::TEXT
FROM p WHERE passage_title IS NULL
UNION ALL
SELECT 'titles used by more than one passage (expect none)',
       COALESCE(string_agg(passage_title, ', '), 'none')
FROM (
  SELECT passage_title FROM p
  WHERE passage_title IS NOT NULL
  GROUP BY passage_title HAVING COUNT(*) > 1
) dup;
