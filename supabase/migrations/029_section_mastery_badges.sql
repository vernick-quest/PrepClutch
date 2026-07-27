-- 029 — Section mastery badges
--
-- 25 new badges: 5 sections x 5 tiers (50 / 100 / 150 / 200 / 250 questions
-- mastered). "Mastered" = user_question_history.times_correct > 0, exactly what
-- get_section_mastery(p_user_id).correct already returns. Every section holds
-- 250 questions, so tier 5 is a genuine section-complete.
--
-- The joke is that every badge is the SAME bicep emoji; the UI renders it at an
-- escalating size and glow per tier, so the arm visibly inflates as a student
-- grinds a section. No new art needed.
--
-- This migration is additive only: it inserts achievement_definitions rows and
-- backfills already-earned milestones into user_achievements. It never touches
-- user_question_history, questions, or any scoring column, so no student
-- can lose Clutch Points as a result of running it. Safe to re-run.

-- ── 1. Badge definitions ─────────────────────────────────────────────────────

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

-- VERBAL
('mastery_verbal_50',  'Word Nibbler',        '💪', '50 verbal questions mastered.',  'Uncommon',  'Bicep, Tier I',   'Section Mastery', 'It begins. One small bicep, one small vocabulary. The bicep has learned the word "flex" and considers this a full workout.', 50),
('mastery_verbal_100', 'Synonym Slinger',     '💪', '100 verbal questions mastered.', 'Rare',      'Bicep, Tier II',  'Section Mastery', 'The bicep now knows four words for "big" and uses all of them to describe itself. Nobody asked. It is telling you anyway.', 100),
('mastery_verbal_150', 'Thesaurus Thrasher',  '💪', '150 verbal questions mastered.', 'Epic',      'Bicep, Tier III', 'Section Mastery', 'Sleeves are now a theoretical concept. The bicep has read the thesaurus cover to cover and rated it "adequate, robust, sufficient, and ample."', 150),
('mastery_verbal_200', 'Vocab Vandal',        '💪', '200 verbal questions mastered.', 'Legendary', 'Bicep, Tier IV',  'Section Mastery', 'The bicep can no longer fit through standard doorways. It solves analogies by intimidation. Antonyms flee on sight.', 200),
('mastery_verbal_250', 'Dictionary Destroyer','💪', 'All 250 verbal questions mastered.', 'Mythic', 'Bicep, Tier V',  'Section Mastery', 'Every verbal question in the entire bank has been flexed into submission. The bicep is now visible from space. Lexicographers have stopped returning calls.', 250),

-- QUANTITATIVE
('mastery_quantitative_50',  'Pattern Poker',      '💪', '50 quantitative questions mastered.',  'Uncommon',  'Bicep, Tier I',   'Section Mastery', 'A small bicep pokes at a number sequence. The sequence continues. The bicep considers this a personal victory.', 50),
('mastery_quantitative_100', 'Sequence Squeezer',  '💪', '100 quantitative questions mastered.', 'Rare',      'Bicep, Tier II',  'Section Mastery', 'The bicep has started squeezing sequences until the next term falls out. This should not work. It keeps working.', 100),
('mastery_quantitative_150', 'Number Cruncher',    '💪', '150 quantitative questions mastered.', 'Epic',      'Bicep, Tier III', 'Section Mastery', 'Crunching is now literal. You can hear the numbers. It is deeply unsettling and extremely effective.', 150),
('mastery_quantitative_200', 'Series Slayer',      '💪', '200 quantitative questions mastered.', 'Legendary', 'Bicep, Tier IV',  'Section Mastery', 'Fibonacci himself would take one look at this arm and quietly close his notebook. The bicep has its own growth pattern. It is exponential.', 200),
('mastery_quantitative_250', 'Pattern Overlord',   '💪', 'All 250 quantitative questions mastered.', 'Mythic', 'Bicep, Tier V', 'Section Mastery', 'Every sequence in the bank has been solved. The bicep now predicts the next term before the question loads. Mathematicians describe it as "large."', 250),

-- READING
('mastery_reading_50',  'Page Curler',        '💪', '50 reading questions mastered.',  'Uncommon',  'Bicep, Tier I',   'Section Mastery', 'A modest bicep turns a page. It got the main idea. It would like a snack now.', 50),
('mastery_reading_100', 'Spine Cracker',      '💪', '100 reading questions mastered.', 'Rare',      'Bicep, Tier II',  'Section Mastery', 'The bicep opens paperbacks a little too enthusiastically. Every book it finishes now lies permanently flat. Librarians have noticed.', 100),
('mastery_reading_150', 'Shelf Wrecker',      '💪', '150 reading questions mastered.', 'Epic',      'Bicep, Tier III', 'Section Mastery', 'The bicep no longer reads books so much as absorbs them. An entire shelf collapsed today. Inferences were drawn. The shelf is not coming back.', 150),
('mastery_reading_200', 'Library Menace',     '💪', '200 reading questions mastered.', 'Legendary', 'Bicep, Tier IV',  'Section Mastery', 'Banned from three reading rooms for excessive comprehension. The bicep can identify an author purpose from across the building.', 200),
('mastery_reading_250', 'Final Boss of Books','💪', 'All 250 reading questions mastered.', 'Mythic', 'Bicep, Tier V',  'Section Mastery', 'Every passage in the bank has been read, understood, and flexed at. The bicep is now the largest thing in the library, including the library.', 250),

-- MATH
('mastery_math_50',  'Equation Elbow',        '💪', '50 mathematics questions mastered.',  'Uncommon',  'Bicep, Tier I',   'Section Mastery', 'A humble bicep solves for x. X was 7. The bicep grew approximately one millimeter and is thrilled about it.', 50),
('mastery_math_100', 'Algebra Arm',           '💪', '100 mathematics questions mastered.', 'Rare',      'Bicep, Tier II',  'Section Mastery', 'The bicep has begun carrying the one without being asked. Variables isolate themselves out of respect.', 100),
('mastery_math_150', 'Formula Flexer',        '💪', '150 mathematics questions mastered.', 'Epic',      'Bicep, Tier III', 'Section Mastery', 'The bicep now has a bicep. Word problems introduce themselves politely before being solved.', 150),
('mastery_math_200', 'Theorem Thrower',       '💪', '200 mathematics questions mastered.', 'Legendary', 'Bicep, Tier IV',  'Section Mastery', 'Pythagoras appeared in a dream and asked the bicep to take it easy. The bicep did not take it easy.', 200),
('mastery_math_250', 'Certified Math Colossus','💪','All 250 mathematics questions mastered.', 'Mythic', 'Bicep, Tier V', 'Section Mastery', 'Every math question in the bank has fallen. The bicep has its own gravitational field. Small equations orbit it. This is fine.', 250),

-- LANGUAGE
('mastery_language_50',  'Comma Curler',            '💪', '50 language questions mastered.',  'Uncommon',  'Bicep, Tier I',   'Section Mastery', 'A tiny bicep does curls with a comma. The comma is not heavy. The bicep is still out of breath.', 50),
('mastery_language_100', 'Semicolon Snapper',       '💪', '100 language questions mastered.', 'Rare',      'Bicep, Tier II',  'Section Mastery', 'The bicep can now snap two independent clauses together with one hand; it does this constantly; nobody can stop it.', 100),
('mastery_language_150', 'Grammar Grappler',        '💪', '150 language questions mastered.', 'Epic',      'Bicep, Tier III', 'Section Mastery', 'Run-on sentences are wrestled to the ground and made to apologize. The bicep has never lost a match to a misplaced modifier.', 150),
('mastery_language_200', 'Punctuation Powerlifter', '💪', '200 language questions mastered.', 'Legendary', 'Bicep, Tier IV',  'Section Mastery', 'The bicep deadlifts an entire paragraph, corrects its capitalization mid-air, and sets it down gently. The crowd is silent. The crowd is also correct now.', 200),
('mastery_language_250', 'Supreme Sentence Slammer','💪', 'All 250 language questions mastered.', 'Mythic', 'Bicep, Tier V',  'Section Mastery', 'Every language question in the bank has been mastered. The bicep is enormous, flawlessly punctuated, and has never once used a comma splice. It never will.', 250)

ON CONFLICT (key) DO NOTHING;

-- ── 2. Backfill milestones students have already earned ──────────────────────
--
-- Students have been mastering questions since long before these badges
-- existed. Without this, a student sitting on 98 reading questions would see an
-- empty Section Mastery row until their next quiz. Read-only against mastery
-- data: get_section_mastery() is a SELECT, and the only write is the INSERT
-- into user_achievements below.

WITH tiers(section, threshold) AS (
  VALUES
    ('verbal', 50), ('verbal', 100), ('verbal', 150), ('verbal', 200), ('verbal', 250),
    ('quantitative', 50), ('quantitative', 100), ('quantitative', 150), ('quantitative', 200), ('quantitative', 250),
    ('reading', 50), ('reading', 100), ('reading', 150), ('reading', 200), ('reading', 250),
    ('math', 50), ('math', 100), ('math', 150), ('math', 200), ('math', 250),
    ('language', 50), ('language', 100), ('language', 150), ('language', 200), ('language', 250)
)
INSERT INTO user_achievements (user_id, achievement_key)
SELECT p.id, 'mastery_' || t.section || '_' || t.threshold
FROM profiles p
CROSS JOIN LATERAL get_section_mastery(p.id) m
JOIN tiers t ON t.section = m.section AND m.correct >= t.threshold
ON CONFLICT (user_id, achievement_key) DO NOTHING;

-- ── 3. Verification ──────────────────────────────────────────────────────────
-- Expect definitions = 25.

SELECT
  (SELECT count(*) FROM achievement_definitions WHERE category = 'Section Mastery') AS definitions_expect_25,
  (SELECT count(*) FROM user_achievements ua
     JOIN achievement_definitions ad ON ad.key = ua.achievement_key
    WHERE ad.category = 'Section Mastery')                                          AS backfilled_awards,
  (SELECT count(DISTINCT ua.user_id) FROM user_achievements ua
     JOIN achievement_definitions ad ON ad.key = ua.achievement_key
    WHERE ad.category = 'Section Mastery')                                          AS students_with_awards;
