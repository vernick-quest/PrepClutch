-- 057 — Section mastery tier 6: the full 300
--
-- Migration 029 built five tiers (50/100/150/200/250) when a section held 250
-- questions, so tier 5 was a genuine section-complete and its badge said so:
-- "All 250 verbal questions mastered."
--
-- Migrations 034-038 then grew every section to 300 and nobody revisited the
-- badges. Since then a student could earn a Mythic "you finished the section"
-- badge with 50 questions still to go.
--
-- This adds a sixth tier at 300 and rewords tier 5 so it stops claiming
-- completeness. Nothing is revoked: every badge already earned stays earned,
-- and tier 5 remains a real milestone — it just no longer says "all".
--
-- Additive and idempotent. Touches achievement_definitions and backfills
-- user_achievements only. No scoring column is read or written, so no student
-- can lose Clutch Points.


-- ── 1. Tier 5 is a waypoint, not the finish line ─────────────────────────────

UPDATE achievement_definitions
SET description = replace(description, 'All 250 ', '250 ')
WHERE key LIKE 'mastery_%_250'
  AND description LIKE 'All 250 %';

-- The tier-5 lore also claimed the whole bank had fallen. Rewritten so the
-- boast is about 250, and the last 50 are visibly still out there.
UPDATE achievement_definitions SET lore =
  'Two hundred and fifty verbal questions have been flexed into submission. ' ||
  'The bicep is visible from space. It has heard a rumour that fifty more ' ||
  'exist somewhere and has begun sharpening itself.'
WHERE key = 'mastery_verbal_250';

UPDATE achievement_definitions SET lore =
  'Two hundred and fifty sequences solved. The bicep now predicts the next ' ||
  'term before the question loads, which is impressive, though it has recently ' ||
  'noticed the pattern does not end where it thought it did.'
WHERE key = 'mastery_quantitative_250';

UPDATE achievement_definitions SET lore =
  'Two hundred and fifty passages read, understood, and flexed at. The bicep ' ||
  'is the largest thing in the library. It is currently staring at a shelf it ' ||
  'has not finished, and the shelf knows it.'
WHERE key = 'mastery_reading_250';

UPDATE achievement_definitions SET lore =
  'Two hundred and fifty math questions have fallen. The bicep has developed ' ||
  'opinions about proofs. Fifty more remain, and it has written their names ' ||
  'on a small list it keeps in its sleeve. It does not have sleeves.'
WHERE key = 'mastery_math_250';

UPDATE achievement_definitions SET lore =
  'Two hundred and fifty sentences corrected. The bicep has strong feelings ' ||
  'about the Oxford comma and the upper-body strength to enforce them. Fifty ' ||
  'stragglers remain, punctuating badly, unaware of what is coming.'
WHERE key = 'mastery_language_250';


-- ── 2. Tier 6 — every question in the section ────────────────────────────────
--
-- Rarity "Ascendant" sits above Mythic. The rarity column is unconstrained
-- text; the UI maps it to 7 stars and a cyan glow so it reads as a step beyond
-- Mythic rather than another shade of it.

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

('mastery_verbal_300', 'The Last Word', '💪', 'All 300 verbal questions mastered.', 'Ascendant', 'Bicep, Tier VI', 'Section Mastery',
 'Every verbal question in the entire bank. Not most. All of them. The bicep has run out of words to learn and has started inventing new ones, which it then also masters. Lexicographers have stopped returning calls. The bicep does not need them.', 300),

('mastery_quantitative_300', 'Sequence Singularity', '💪', 'All 300 quantitative questions mastered.', 'Ascendant', 'Bicep, Tier VI', 'Section Mastery',
 'Every pattern in the bank, complete. The bicep now sees the next term in everything: queues, traffic, the gaps between its own heartbeats. It has been asked politely to stop narrating them out loud. It will not.', 300),

('mastery_reading_300', 'Read the Whole Library', '💪', 'All 300 reading questions mastered.', 'Ascendant', 'Bicep, Tier VI', 'Section Mastery',
 'Every passage, every inference, every author''s sneaky little purpose. There is nothing left on the shelf. The bicep has begun re-reading things for fun, which is somehow more intimidating than when it was studying.', 300),

('mastery_math_300', 'Absolute Unit', '💪', 'All 300 mathematics questions mastered.', 'Ascendant', 'Bicep, Tier VI', 'Section Mastery',
 'Every math question in the bank has fallen. The bicep is now, by any reasonable measure, an absolute unit. Pythagoras has stopped visiting the dreams. He says it is not personal, he just needs some space.', 300),

('mastery_language_300', 'Grammar Final Form', '💪', 'All 300 language questions mastered.', 'Ascendant', 'Bicep, Tier VI', 'Section Mastery',
 'Every sentence in the bank, corrected. The bicep has achieved its final form and communicates exclusively in flawless prose. Its semicolons are load-bearing. Nobody has found an error in six weeks and several have looked very hard.', 300)

ON CONFLICT (key) DO UPDATE SET
  label       = EXCLUDED.label,
  description = EXCLUDED.description,
  rarity      = EXCLUDED.rarity,
  creature    = EXCLUDED.creature,
  category    = EXCLUDED.category,
  lore        = EXCLUDED.lore,
  threshold   = EXCLUDED.threshold;


-- ── 3. Backfill anyone already at 300 ────────────────────────────────────────
--
-- Same shape as 029's backfill: award the new tier to any student whose
-- CURRENT mastery already clears it, so nobody has to answer a question they
-- have already answered to collect a badge they have already earned.

-- The join to profiles is required, not cosmetic: user_achievements.user_id
-- has an FK to profiles(id), while user_question_history references
-- auth.users. A history row without a profile would abort the whole migration.
INSERT INTO user_achievements (user_id, achievement_key)
SELECT h.user_id, 'mastery_' || q.section::TEXT || '_300'
FROM user_question_history h
JOIN questions q ON q.id = h.question_id
JOIN profiles  p ON p.id = h.user_id
WHERE h.times_correct > 0
GROUP BY h.user_id, q.section
HAVING COUNT(*) >= 300
ON CONFLICT DO NOTHING;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected:
--   tier6_badges              5   one per section
--   tier5_still_claiming_all  0   no badge says "All 250" any more
--   sections_at_300               how many (student, section) pairs are done
--   sample                        the verbal tier-6 description

SELECT
  (SELECT COUNT(*) FROM achievement_definitions WHERE key LIKE 'mastery_%_300')      AS tier6_badges,
  (SELECT COUNT(*) FROM achievement_definitions WHERE description LIKE 'All 250 %')  AS tier5_still_claiming_all,
  (SELECT COUNT(*) FROM (
     SELECT h.user_id, q.section
     FROM user_question_history h JOIN questions q ON q.id = h.question_id
     WHERE h.times_correct > 0
     GROUP BY h.user_id, q.section HAVING COUNT(*) >= 300) t)                        AS sections_at_300,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Section Mastery')  AS section_mastery_total,
  (SELECT description FROM achievement_definitions WHERE key = 'mastery_verbal_250') AS tier5_verbal_now,
  (SELECT description FROM achievement_definitions WHERE key = 'mastery_verbal_300') AS tier6_verbal;
