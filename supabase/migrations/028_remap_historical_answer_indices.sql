-- 028 — Denormalise historical answer text into quiz_attempts.answers
--
-- Migration 019 shuffled every question's `options` array and remapped
-- `questions.correct_index`, but the positional indices already stored in
-- `quiz_attempts.answers` were left pointing at the old order. Students'
-- history review therefore resolved `selected_index` against today's options
-- and showed an answer they never gave.
--
-- Remapping the indices would fix today and break again on the next reorder.
-- Instead this migration DENORMALISES the text: every answer element gains
--
--   selected_text  — the option the student actually chose (null on timeout)
--   correct_text   — the option that was correct at answer time
--
-- resolved against the option order AS IT WAS WHEN THE ATTEMPT WAS TAKEN.
-- Once the text lives on the answer, no future reorder can invalidate it.
--
-- SCORING SAFETY. This migration assigns to exactly one column of exactly one
-- table: `quiz_attempts.answers`. It never writes `quiz_attempts.score`,
-- `total_xp`, `user_id`, `section` or `completed_at`; it never writes anything
-- in `questions`; and it does not reference `user_question_history` — the
-- table Clutch Points are computed from — at all. It contains no DELETE, DROP
-- or TRUNCATE. Existing keys on each answer element are preserved by merging
-- with `||`, so `time_taken_ms`, `xp_earned`, `target_ms` and `section`
-- survive untouched.
--
-- IDEMPOTENT. An element that already carries both keys is skipped, so
-- re-running is a no-op rather than a re-derivation against whatever order is
-- current at that later moment.
--
-- Run this as a new query in the Supabase SQL editor, after 019.

BEGIN;

-- ── 1. The pre-019 option orders ─────────────────────────────────────────────
--
-- An exact snapshot of the question bank taken before 018 and 019 ran: every
-- row is (section, prompt, options-in-their-pre-019-order, the key that went
-- with that order).
--
-- `tier` records how the row can be identified safely. 019 only PERMUTED
-- options, so a live question's SORTED options equal its pre-019 sorted
-- options — that is the primary key for matching, and it survives the prompt
-- rewrites 018 made. For 178 of the 867 rows the option SET alone is not
-- unique within the section (many "What number comes next?" items share
-- the same four numerals), so those are tier 2 and additionally require the
-- prompt to match. No snapshot row is a true duplicate on (section, prompt,
-- option set), so all 867 are identifiable in principle.

CREATE TEMP TABLE _snapshot (
  tier              INT,
  section           TEXT,
  prompt            TEXT,
  old_options       JSONB,
  old_correct_index INT
) ON COMMIT DROP;

INSERT INTO _snapshot (tier, section, prompt, old_options, old_correct_index) VALUES
    (1, 'verbal', 'HAPPY most nearly means:', '["Sad", "Joyful", "Angry", "Tired"]', 1),
    (1, 'verbal', 'ANCIENT is the opposite of:', '["Old", "Large", "Modern", "Quiet"]', 2),
    (1, 'verbal', 'Paintbrush is to painter as scalpel is to:', '["Hospital", "Surgeon", "Nurse", "Patient"]', 1),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Hammer", "Wrench", "Screwdriver", "Paintbrush"]', 3),
    (1, 'verbal', 'ELOQUENT most nearly means:', '["Loud", "Articulate", "Confused", "Brief"]', 1),
    (1, 'verbal', 'Some musicians are teachers. All teachers are college graduates. Some musicians are college graduates — true, false, or uncertain?', '["True", "False", "Uncertain", "Cannot be determined"]', 0),
    (1, 'verbal', 'Sycophant is to flattery as martyr is to:', '["Religion", "Sacrifice", "Courage", "Victory"]', 1),
    (1, 'verbal', 'LOQUACIOUS most nearly means:', '["Silent", "Logical", "Talkative", "Lazy"]', 2),
    (1, 'verbal', 'BOLD most nearly means:', '["Timid", "Brave", "Quiet", "Tired"]', 1),
    (1, 'verbal', 'SWIFT most nearly means:', '["Slow", "Gentle", "Fast", "Bright"]', 2),
    (1, 'verbal', 'GLOOMY most nearly means:', '["Cheerful", "Dark", "Cloudy", "Sad"]', 3),
    (1, 'verbal', 'HUGE most nearly means:', '["Tiny", "Heavy", "Enormous", "Loud"]', 2),
    (1, 'verbal', 'WEARY most nearly means:', '["Alert", "Tired", "Worried", "Weak"]', 1),
    (1, 'verbal', 'FILTHY most nearly means:', '["Clean", "Messy", "Dirty", "Smelly"]', 2),
    (1, 'verbal', 'CHILLY most nearly means:', '["Hot", "Breezy", "Cold", "Wet"]', 2),
    (1, 'verbal', 'FURIOUS most nearly means:', '["Pleased", "Confused", "Very angry", "Frightened"]', 2),
    (1, 'verbal', 'DAMP most nearly means:', '["Dry", "Moist", "Frozen", "Warm"]', 1),
    (1, 'verbal', 'FOE most nearly means:', '["Friend", "Ally", "Enemy", "Partner"]', 2),
    (1, 'verbal', 'SLIM most nearly means:', '["Short", "Thin", "Small", "Weak"]', 1),
    (1, 'verbal', 'BRAVE most nearly means:', '["Reckless", "Courageous", "Strong", "Proud"]', 1),
    (1, 'verbal', 'GENEROUS is the opposite of:', '["Kind", "Wealthy", "Selfish", "Humble"]', 2),
    (1, 'verbal', 'NOISY is the opposite of:', '["Loud", "Busy", "Quiet", "Soft"]', 2),
    (1, 'verbal', 'DIFFICULT is the opposite of:', '["Hard", "Easy", "Painful", "Boring"]', 1),
    (1, 'verbal', 'VICTORY is the opposite of:', '["Battle", "Prize", "Defeat", "Struggle"]', 2),
    (1, 'verbal', 'FREEZE is the opposite of:', '["Cool", "Melt", "Harden", "Slow"]', 1),
    (1, 'verbal', 'POLITE is the opposite of:', '["Friendly", "Rude", "Shy", "Quiet"]', 1),
    (1, 'verbal', 'EXPAND is the opposite of:', '["Grow", "Open", "Shrink", "Spread"]', 2),
    (1, 'verbal', 'SHARP is the opposite of:', '["Bright", "Dull", "Hard", "Thin"]', 1),
    (1, 'verbal', 'ARRIVE is the opposite of:', '["Land", "Come", "Depart", "Enter"]', 2),
    (1, 'verbal', 'TAME is the opposite of:', '["Gentle", "Trained", "Wild", "Safe"]', 2),
    (1, 'verbal', 'THICK is the opposite of:', '["Wide", "Thin", "Large", "Heavy"]', 1),
    (1, 'verbal', 'COWARD is the opposite of:', '["Villain", "Warrior", "Hero", "Champion"]', 2),
    (1, 'verbal', 'Pen is to writer as brush is to:', '["Canvas", "Painter", "Paint", "Museum"]', 1),
    (1, 'verbal', 'Puppy is to dog as kitten is to:', '["Lion", "Fur", "Cat", "Paw"]', 2),
    (1, 'verbal', 'Glove is to hand as boot is to:', '["Leg", "Foot", "Shoe", "Sock"]', 1),
    (1, 'verbal', 'Fin is to fish as wing is to:', '["Sky", "Feather", "Bird", "Fly"]', 2),
    (1, 'verbal', 'Library is to books as museum is to:', '["History", "Artifacts", "Tickets", "Tours"]', 1),
    (1, 'verbal', 'Doctor is to hospital as chef is to:', '["Food", "Recipe", "Kitchen", "Restaurant"]', 3),
    (1, 'verbal', 'Cub is to bear as lamb is to:', '["Goat", "Wool", "Sheep", "Farm"]', 2),
    (1, 'verbal', 'Scissors is to cut as needle is to:', '["Thread", "Sew", "Knit", "Pin"]', 1),
    (1, 'verbal', 'Floor is to ceiling as ground is to:', '["Dirt", "Earth", "Sky", "Roof"]', 2),
    (1, 'verbal', 'Bark is to tree as skin is to:', '["Hair", "Body", "Animal", "Fur"]', 1),
    (1, 'verbal', 'Sad is to cry as funny is to:', '["Joke", "Smile", "Laugh", "Play"]', 2),
    (1, 'verbal', 'Chapter is to book as scene is to:', '["Actor", "Play", "Movie", "Stage"]', 2),
    (1, 'verbal', 'Mouth is to speak as ear is to:', '["Sound", "Head", "Hear", "Listen"]', 2),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Apple", "Banana", "Carrot", "Grape"]', 2),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Shirt", "Pants", "Hat", "Shoes"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Robin", "Sparrow", "Eagle", "Salmon"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Circle", "Square", "Triangle", "Cube"]', 3),
    (1, 'verbal', 'CANDID most nearly means:', '["Secret", "Honest", "Polite", "Careful"]', 1),
    (1, 'verbal', 'RESILIENT most nearly means:', '["Flexible", "Stubborn", "Able to recover", "Fragile"]', 2),
    (1, 'verbal', 'SCRUTINIZE most nearly means:', '["Ignore", "Examine carefully", "Clean thoroughly", "Criticize"]', 1),
    (1, 'verbal', 'VIVID most nearly means:', '["Dull", "Alive", "Bright and clear", "Colorful"]', 2),
    (1, 'verbal', 'NOVEL most nearly means:', '["Old", "Fictional", "New and original", "Long"]', 2),
    (1, 'verbal', 'DILIGENT most nearly means:', '["Lazy", "Hardworking", "Clever", "Loyal"]', 1),
    (1, 'verbal', 'DUBIOUS most nearly means:', '["Certain", "Doubtful", "Dangerous", "Clever"]', 1),
    (1, 'verbal', 'TRANQUIL most nearly means:', '["Noisy", "Boring", "Peaceful", "Slow"]', 2),
    (1, 'verbal', 'HINDER most nearly means:', '["Help", "Slow down", "Hide", "Follow"]', 1),
    (1, 'verbal', 'FRUGAL most nearly means:', '["Generous", "Wasteful", "Thrifty", "Greedy"]', 2),
    (1, 'verbal', 'AMIABLE most nearly means:', '["Hostile", "Friendly", "Capable", "Admirable"]', 1),
    (1, 'verbal', 'BENEVOLENT most nearly means:', '["Harmful", "Selfish", "Kind-hearted", "Powerful"]', 2),
    (1, 'verbal', 'PONDER most nearly means:', '["Wonder", "Think deeply about", "Disagree", "Measure"]', 1),
    (1, 'verbal', 'PLACID most nearly means:', '["Upset", "Flat", "Calm", "Pleased"]', 2),
    (1, 'verbal', 'METICULOUS most nearly means:', '["Careless", "Paying great attention to detail", "Slow", "Strict"]', 1),
    (1, 'verbal', 'ABUNDANT is the opposite of:', '["Plentiful", "Scarce", "Expensive", "Common"]', 1),
    (1, 'verbal', 'TRANSPARENT is the opposite of:', '["Clear", "Shiny", "Opaque", "Fragile"]', 2),
    (1, 'verbal', 'ARROGANT is the opposite of:', '["Proud", "Humble", "Rude", "Ignorant"]', 1),
    (1, 'verbal', 'COMPULSORY is the opposite of:', '["Required", "Forced", "Optional", "Strict"]', 2),
    (1, 'verbal', 'TRIVIAL is the opposite of:', '["Minor", "Important", "Boring", "Simple"]', 1),
    (1, 'verbal', 'CONCEAL is the opposite of:', '["Hide", "Cover", "Reveal", "Protect"]', 2),
    (1, 'verbal', 'TIMID is the opposite of:', '["Shy", "Bold", "Nervous", "Gentle"]', 1),
    (1, 'verbal', 'HUMBLE is the opposite of:', '["Modest", "Quiet", "Arrogant", "Simple"]', 2),
    (1, 'verbal', 'PROLONG is the opposite of:', '["Extend", "Shorten", "Delay", "Continue"]', 1),
    (1, 'verbal', 'HOSTILE is the opposite of:', '["Unfriendly", "Aggressive", "Welcoming", "Angry"]', 2),
    (1, 'verbal', 'PESSIMISTIC is the opposite of:', '["Gloomy", "Optimistic", "Realistic", "Negative"]', 1),
    (1, 'verbal', 'INFERIOR is the opposite of:', '["Lower", "Worse", "Superior", "Secondary"]', 2),
    (1, 'verbal', 'LENIENT is the opposite of:', '["Kind", "Mild", "Strict", "Permissive"]', 2),
    (1, 'verbal', 'CHAOS is the opposite of:', '["Disorder", "Confusion", "Order", "Noise"]', 2),
    (1, 'verbal', 'MEAGER is the opposite of:', '["Thin", "Scarce", "Abundant", "Weak"]', 2),
    (1, 'verbal', 'Warmth is to comfort as cold is to:', '["Snow", "Discomfort", "Winter", "Ice"]', 1),
    (1, 'verbal', 'Author is to novel as composer is to:', '["Piano", "Concert", "Symphony", "Musician"]', 2),
    (1, 'verbal', 'Drought is to water as famine is to:', '["Hunger", "Food", "Poverty", "Crops"]', 1),
    (1, 'verbal', 'Pedal is to bicycle as oar is to:', '["Water", "Boat", "Paddle", "Sail"]', 1),
    (1, 'verbal', 'Petal is to flower as feather is to:', '["Pillow", "Nest", "Wing", "Bird"]', 3),
    (1, 'verbal', 'General is to army as captain is to:', '["Soldier", "Ship", "Rank", "Battle"]', 1),
    (1, 'verbal', 'Rehearsal is to performance as practice is to:', '["Sport", "Game", "Training", "Skill"]', 1),
    (1, 'verbal', 'Degree is to temperature as pound is to:', '["Money", "Weight", "Force", "Volume"]', 1),
    (1, 'verbal', 'Architect is to blueprint as sculptor is to:', '["Clay", "Museum", "Sketch", "Chisel"]', 2),
    (1, 'verbal', 'Reckless is to cautious as rude is to:', '["Mean", "Polite", "Loud", "Selfish"]', 1),
    (1, 'verbal', 'Dull is to sharp as dim is to:', '["Dark", "Night", "Bright", "Blind"]', 2),
    (1, 'verbal', 'Microscope is to biologist as telescope is to:', '["Stars", "Astronomer", "Lens", "Scientist"]', 1),
    (1, 'verbal', 'Trunk is to elephant as shell is to:', '["Ocean", "Pearl", "Turtle", "Crab"]', 2),
    (1, 'verbal', 'Epidemic is to disease as avalanche is to:', '["Mountain", "Snow", "Storm", "Disaster"]', 1),
    (1, 'verbal', 'Prologue is to play as introduction is to:', '["Chapter", "Book", "Story", "Essay"]', 1),
    (1, 'verbal', 'Stingy is to generous as vague is to:', '["Uncertain", "Hidden", "Specific", "Confusing"]', 2),
    (1, 'verbal', 'Carpenter is to wood as blacksmith is to:', '["Anvil", "Fire", "Metal", "Horseshoe"]', 2),
    (1, 'verbal', 'Island is to ocean as oasis is to:', '["Water", "Desert", "Palm", "Sand"]', 1),
    (1, 'verbal', 'Cowardly is to lion as clumsy is to:', '["Bear", "Ballerina", "Turtle", "Elephant"]', 1),
    (1, 'verbal', 'Volume is to sound as speed is to:', '["Time", "Motion", "Distance", "Force"]', 1),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Sonnet", "Villanelle", "Haiku", "Ballad"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Memoir", "Biography", "Autobiography", "Novel"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Simile", "Metaphor", "Alliteration", "Paragraph"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Envy", "Greed", "Pride", "Courage"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Mercury", "Venus", "Moon", "Mars"]', 2),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Soliloquy", "Monologue", "Dialogue", "Oration"]', 2),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Granite", "Marble", "Limestone", "Bronze"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Theorem", "Hypothesis", "Axiom", "Stanza"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Infer", "Deduce", "Speculate", "Conclude"]', 2),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Senate", "Parliament", "Congress", "Judiciary"]', 3),
    (1, 'verbal', 'TRUCULENT most nearly means:', '["Timid", "Eager to argue or fight", "Reliable", "Wandering"]', 1),
    (1, 'verbal', 'OBSEQUIOUS most nearly means:', '["Stubborn", "Curious", "Excessively eager to please", "Loud"]', 2),
    (1, 'verbal', 'INVETERATE most nearly means:', '["Occasional", "Deeply habitual", "Stubborn", "Curable"]', 1),
    (1, 'verbal', 'PEDANTIC most nearly means:', '["Wise", "Overly focused on minor rules or details", "Childlike", "Patient"]', 1),
    (1, 'verbal', 'LACONIC most nearly means:', '["Wordy", "Logical", "Using very few words", "Lazy"]', 2),
    (1, 'verbal', 'INSIPID most nearly means:', '["Spicy", "Intelligent", "Lacking flavor or interest", "Offensive"]', 2),
    (1, 'verbal', 'PERFIDIOUS most nearly means:', '["Loyal", "Treacherous", "Fearless", "Dangerous"]', 1),
    (1, 'verbal', 'EQUIVOCAL most nearly means:', '["Fair", "Ambiguous", "Similar", "Balanced"]', 1),
    (1, 'verbal', 'MAGNANIMOUS most nearly means:', '["Powerful", "Generous and forgiving", "Proud", "Famous"]', 1),
    (1, 'verbal', 'MENDACIOUS most nearly means:', '["Accurate", "Threatening", "Dishonest", "Humble"]', 2),
    (1, 'verbal', 'EPHEMERAL most nearly means:', '["Eternal", "Delicate", "Lasting only a short time", "Mysterious"]', 2),
    (1, 'verbal', 'TACITURN most nearly means:', '["Rude", "Silent by nature", "Logical", "Secretive"]', 1),
    (1, 'verbal', 'GARRULOUS most nearly means:', '["Cheerful", "Excessively talkative", "Boastful", "Aggressive"]', 1),
    (1, 'verbal', 'RECONDITE most nearly means:', '["Recovered", "Hidden", "Obscure and little known", "Complex"]', 2),
    (1, 'verbal', 'INTREPID most nearly means:', '["Reckless", "Fearless", "Cautious", "Stubborn"]', 1),
    (1, 'verbal', 'CENSURE is the opposite of:', '["Criticize", "Punish", "Praise", "Condemn"]', 2),
    (1, 'verbal', 'VENERATE is the opposite of:', '["Worship", "Despise", "Honor", "Fear"]', 1),
    (1, 'verbal', 'VERBOSE is the opposite of:', '["Wordy", "Eloquent", "Terse", "Loud"]', 2),
    (1, 'verbal', 'TRACTABLE is the opposite of:', '["Manageable", "Gentle", "Obstinate", "Simple"]', 2),
    (1, 'verbal', 'CREDULOUS is the opposite of:', '["Naive", "Skeptical", "Trusting", "Ignorant"]', 1),
    (1, 'verbal', 'PENURY is the opposite of:', '["Misery", "Poverty", "Wealth", "Debt"]', 2),
    (1, 'verbal', 'CANDOR is the opposite of:', '["Honesty", "Deceit", "Kindness", "Openness"]', 1),
    (1, 'verbal', 'SERENE is the opposite of:', '["Peaceful", "Quiet", "Agitated", "Content"]', 2),
    (1, 'verbal', 'OPULENT is the opposite of:', '["Luxurious", "Rich", "Austere", "Expensive"]', 2),
    (1, 'verbal', 'ALACRITY is the opposite of:', '["Eagerness", "Speed", "Reluctance", "Energy"]', 2),
    (1, 'verbal', 'Herald is to announce as arbiter is to:', '["Judge", "Argue", "Negotiate", "Punish"]', 0),
    (1, 'verbal', 'Censure is to praise as condemn is to:', '["Blame", "Acquit", "Punish", "Accuse"]', 1),
    (1, 'verbal', 'Iconoclast is to tradition as rebel is to:', '["Revolution", "Order", "Freedom", "Change"]', 1),
    (1, 'verbal', 'Dilettante is to expertise as novice is to:', '["Skill", "Beginner", "Learning", "Mastery"]', 3),
    (1, 'verbal', 'Pariah is to society as exile is to:', '["Punishment", "Homeland", "Crime", "Prison"]', 1),
    (1, 'verbal', 'Perjury is to oath as forgery is to:', '["Signature", "Crime", "Document", "Money"]', 2),
    (1, 'verbal', 'Ascetic is to luxury as miser is to:', '["Money", "Generosity", "Poverty", "Saving"]', 1),
    (1, 'verbal', 'Platitude is to originality as cliché is to:', '["Speech", "Freshness", "Poetry", "Language"]', 1),
    (1, 'verbal', 'Impetuous is to restraint as profligate is to:', '["Wealth", "Extravagance", "Thrift", "Spending"]', 2),
    (1, 'verbal', 'Elegy is to mourning as ode is to:', '["Grief", "Celebration", "Rhythm", "Epic"]', 1),
    (1, 'verbal', 'Sophist is to deception as charlatan is to:', '["Magic", "Fraud", "Wisdom", "Performance"]', 1),
    (1, 'verbal', 'Solvent is to debt as immunity is to:', '["Medicine", "Vaccine", "Disease", "Health"]', 2),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Soliloquy", "Apostrophe", "Aside", "Allegory"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Stoic", "Epicurean", "Utilitarian", "Empiricist"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Anachronism", "Foreshadowing", "Flashback", "Euphony"]', 3),
    (1, 'verbal', 'Which word does NOT belong with the others?', '["Hubris", "Hamartia", "Catharsis", "Soliloquy"]', 3),
    (1, 'quantitative', 'What number comes next?  2, 4, 6, 8, ___', '["9", "10", "12", "11"]', 1),
    (1, 'quantitative', 'What number comes next?  100, 90, 80, 70, ___', '["55", "65", "60", "50"]', 2),
    (1, 'quantitative', 'What number comes next?  3, 6, 12, 24, ___', '["36", "42", "48", "30"]', 2),
    (1, 'quantitative', 'A number is divided by 5, then 8 is added, giving 12. What was the original number?', '["20", "25", "15", "30"]', 0),
    (1, 'quantitative', 'What number comes next?  1, 4, 9, 16, ___', '["20", "25", "21", "24"]', 1),
    (1, 'quantitative', 'The average of five consecutive even numbers is 18. What is the largest?', '["20", "22", "24", "26"]', 1),
    (1, 'quantitative', 'What number comes next?  5, 10, 15, 20, ___', '["22", "24", "25", "30"]', 2),
    (1, 'quantitative', 'What number comes next?  50, 45, 40, 35, ___', '["25", "28", "32", "30"]', 3),
    (1, 'quantitative', 'What number comes next?  10, 20, 30, 40, ___', '["45", "48", "50", "60"]', 2),
    (1, 'quantitative', 'What number comes next?  0, 5, 10, 15, ___', '["18", "20", "22", "25"]', 1),
    (1, 'quantitative', 'What number comes next?  2, 4, 8, 16, ___', '["18", "24", "32", "64"]', 2),
    (1, 'quantitative', 'What number comes next?  30, 25, 20, 15, ___', '["5", "8", "10", "12"]', 2),
    (1, 'quantitative', 'What number comes next?  7, 14, 21, 28, ___', '["32", "35", "36", "42"]', 1),
    (1, 'quantitative', 'What number comes next?  6, 12, 18, 24, ___', '["28", "30", "32", "36"]', 1),
    (1, 'quantitative', 'What number comes next?  40, 30, 20, 10, ___', '["0", "5", "2", "8"]', 0),
    (1, 'quantitative', 'What number comes next?  11, 22, 33, 44, ___', '["48", "50", "55", "66"]', 2),
    (1, 'quantitative', 'What number comes next?  8, 16, 24, 32, ___', '["36", "38", "40", "48"]', 2),
    (1, 'quantitative', 'A number is divided by 4 to give 5. What is the number?', '["16", "20", "24", "25"]', 1),
    (1, 'quantitative', 'A number divided by 9 gives 3. What is the number?', '["24", "27", "30", "33"]', 1),
    (1, 'quantitative', 'A number is cut in half to give 13. What is the number?', '["24", "25", "26", "28"]', 2),
    (1, 'quantitative', 'A number plus 21 equals 50. What is the number?', '["27", "28", "29", "30"]', 2),
    (1, 'quantitative', 'What number comes next?  2, 6, 18, 54, ___', '["108", "144", "162", "216"]', 2),
    (1, 'quantitative', 'What number comes next?  5, 15, 45, 135, ___', '["270", "375", "400", "405"]', 3),
    (1, 'quantitative', 'What number comes next?  2, 5, 10, 17, 26, ___', '["35", "36", "37", "38"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 3, 7, 15, 31, ___', '["47", "55", "62", "63"]', 3),
    (1, 'quantitative', 'What number comes next?  100, 50, 25, 12.5, ___', '["5", "6", "6.25", "7.5"]', 2),
    (1, 'quantitative', 'What number comes next?  3, 9, 27, 81, ___', '["162", "243", "270", "324"]', 1),
    (1, 'quantitative', 'What number comes next?  1, 5, 9, 13, 17, ___', '["19", "20", "21", "22"]', 2),
    (1, 'quantitative', 'What number comes next?  10, 7, 4, 1, ___', '["−1", "−2", "0", "−3"]', 1),
    (1, 'quantitative', 'What number comes next?  1, 2, 4, 8, 16, ___', '["24", "28", "32", "64"]', 2),
    (1, 'quantitative', 'What number comes next?  4, 9, 16, 25, 36, ___', '["42", "47", "49", "50"]', 2),
    (1, 'quantitative', 'What number comes next?  2, 6, 12, 20, 30, ___', '["38", "40", "42", "44"]', 2),
    (1, 'quantitative', 'What number comes next?  81, 27, 9, 3, ___', '["1", "0", "2", "3"]', 0),
    (1, 'quantitative', 'What number comes next?  1, 8, 27, 64, ___', '["100", "108", "121", "125"]', 3),
    (1, 'quantitative', 'What number comes next?  7, 10, 14, 19, 25, ___', '["30", "31", "32", "33"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 6, 11, 16, 21, ___', '["24", "25", "26", "27"]', 2),
    (1, 'quantitative', 'What number comes next?  3, 7, 15, 31, 63, ___', '["95", "121", "127", "128"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 2, 6, 24, ___', '["96", "100", "120", "144"]', 2),
    (1, 'quantitative', 'A number is divided by 6, then 4 is added, giving 9. What was the original number?', '["24", "30", "36", "42"]', 1),
    (1, 'quantitative', 'A number is divided by 3, then multiplied by 5, giving 25. What was the original number?', '["12", "13", "15", "18"]', 2),
    (1, 'quantitative', 'A number is divided by 4, then 9 is subtracted, giving 1. What was the original number?', '["36", "40", "44", "48"]', 1),
    (1, 'quantitative', 'A number is halved, then 3 is subtracted, giving 7. What was the original number?', '["18", "19", "20", "22"]', 2),
    (1, 'quantitative', 'What number comes next?  2, 1, 3, 4, 7, 11, ___', '["14", "15", "17", "18"]', 3),
    (1, 'quantitative', 'What number comes next?  1, 3, 6, 10, 15, 21, ___', '["25", "27", "28", "30"]', 2),
    (1, 'quantitative', 'What number comes next?  2, 5, 11, 23, 47, ___', '["89", "93", "95", "96"]', 2),
    (1, 'quantitative', 'What number comes next?  3, 5, 9, 17, 33, ___', '["55", "60", "65", "66"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 2, 5, 14, 42, ___', '["100", "118", "120", "132"]', 3),
    (1, 'quantitative', 'What number comes next?  4, 7, 13, 25, 49, ___', '["82", "90", "97", "100"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 2, 6, 24, 120, ___', '["480", "600", "720", "840"]', 2),
    (1, 'quantitative', 'What number comes next?  0, 1, 4, 9, 16, 25, ___', '["30", "35", "36", "49"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 5, 14, 30, 55, ___', '["77", "84", "91", "95"]', 2),
    (1, 'quantitative', 'What number comes next?  2, 8, 18, 32, 50, ___', '["68", "70", "72", "74"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 4, 13, 40, 121, ___', '["200", "300", "364", "400"]', 2),
    (1, 'quantitative', 'What number comes next?  6, 10, 16, 26, 42, ___', '["58", "62", "68", "74"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 3, 12, 60, 360, ___', '["720", "1440", "2160", "2520"]', 3),
    (1, 'quantitative', 'What number comes next?  1, 2, 3, 5, 8, 13, 21, 34, ___', '["45", "50", "55", "60"]', 2),
    (1, 'quantitative', 'What number comes next?  5, 12, 26, 54, 110, ___', '["185", "220", "222", "230"]', 2),
    (1, 'quantitative', 'What number comes next?  2, 3, 7, 13, 21, 31, ___', '["40", "41", "43", "45"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 3, 9, 27, 81, 243, ___', '["486", "729", "810", "972"]', 1),
    (1, 'quantitative', 'What number comes next?  2, 6, 12, 20, 30, 42, ___', '["52", "54", "56", "60"]', 2),
    (1, 'quantitative', 'What number comes next?  1, 3, 4, 7, 11, 18, ___', '["25", "28", "29", "30"]', 2),
    (1, 'quantitative', 'What number comes next?  0, 1, 8, 27, 64, 125, ___', '["196", "200", "210", "216"]', 3),
    (1, 'quantitative', 'A number is increased by 4, then multiplied by 3, then divided by 6, giving 7. What was the original number?', '["10", "12", "14", "16"]', 0),
    (1, 'quantitative', 'A number is decreased by 5, then doubled, then increased by 4, giving 30. What was the original number?', '["16", "18", "20", "22"]', 1),
    (1, 'quantitative', 'A number is divided by 4, then multiplied by 5, then reduced by 10, giving 15. What was the original number?', '["16", "18", "20", "24"]', 2),
    (1, 'quantitative', 'A number is divided by 5, then multiplied by 4, then 8 is added, giving 32. What was the original number?', '["25", "30", "35", "40"]', 1),
    (1, 'reading', 'According to the passage, where do monarch butterflies spend the winter?', '["Canada", "The United States", "The mountains of central Mexico", "South America"]', 2),
    (1, 'reading', 'How far can monarch butterflies travel during migration?', '["Up to 1,000 miles", "Up to 2,000 miles", "Up to 3,000 miles", "Up to 4,000 miles"]', 2),
    (1, 'reading', 'As used in the passage, ''navigate'' most nearly means:', '["Fly fast", "Find one''s way", "Avoid danger", "Rest and recover"]', 1),
    (1, 'reading', 'Before the railroad, approximately how long did it take to travel to California from the East Coast?', '["A few days", "About a week", "Several months", "About a year"]', 2),
    (1, 'reading', 'Which conclusion is best supported by the passage?', '["The railroad made the wagon industry more profitable.", "The railroad had mostly negative effects on American life.", "The railroad connected economic and geographic parts of the nation.", "The railroad caused most Americans to move to California."]', 2),
    (1, 'reading', 'As used in the passage, ''accelerated'' most nearly means:', '["Slowed", "Stopped", "Sped up", "Reversed"]', 2),
    (1, 'reading', 'What is the main idea of this passage?', '["The railroad was completed in 1869.", "Travel to California was once very slow.", "The Transcontinental Railroad greatly changed American society and economy.", "Thousands of families moved west after 1869."]', 2),
    (1, 'reading', 'Based on the passage, which of the following best describes why advertisers use cognitive dissonance principles?', '["To confuse audiences so they buy more products.", "To guide audiences toward resolving internal conflicts in a way that favors the advertiser.", "To introduce new psychological research to the public.", "To ensure audiences feel comfortable with their existing beliefs."]', 1),
    (1, 'reading', 'As used in the passage, ''simultaneously'' most nearly means:', '["Eventually", "Repeatedly", "At the same time", "Gradually"]', 2),
    (1, 'reading', 'The author most likely ends with the sentence about advertisers in order to:', '["Criticize the advertising industry.", "Show that the concept has practical, real-world applications beyond psychology.", "Prove that cognitive dissonance is harmful.", "Encourage readers to avoid advertisements."]', 1),
    (1, 'reading', 'What percentage of Earth''s surface do rain forests cover?', '["25%", "50%", "6%", "12%"]', 2),
    (1, 'reading', 'According to the passage, rain forests help regulate Earth''s climate by:', '["Producing large amounts of oxygen only.", "Absorbing large amounts of carbon dioxide.", "Covering half the Earth''s surface.", "Housing millions of animal species."]', 1),
    (1, 'reading', 'Which conclusion is most strongly supported by the passage?', '["Most species on Earth live in oceans.", "Destroying rain forests could have significant environmental consequences.", "Rain forests should be converted to farmland.", "Carbon dioxide is not harmful to the environment."]', 1),
    (1, 'reading', 'As used in the passage, ''regulating'' most nearly means:', '["Destroying", "Controlling", "Measuring", "Ignoring"]', 1),
    (1, 'reading', 'Which best describes the relationship between the two arguments presented in the passage?', '["They agree that virtue and prosperity are unrelated.", "They offer opposing views on which comes first — virtue or prosperity.", "They both argue that ancient Greeks were correct.", "They suggest that only wealthy people can be virtuous."]', 1),
    (1, 'reading', 'The phrase ''rarely have the luxury of ethical deliberation'' suggests that:', '["Ethics is only for wealthy people to study.", "People in desperate circumstances may not have the time or resources to focus on moral choices.", "Ancient Greeks were wrong about virtue.", "Ethical deliberation is not important."]', 1),
    (1, 'reading', 'What is the main idea of this passage?', '["Ancient Greeks were more virtuous than modern people.", "Prosperity and virtue have a debated, complex relationship.", "Material wealth always leads to moral development.", "Ethical deliberation is only possible for the wealthy."]', 1),
    (1, 'reading', 'As used in the passage, ''preceded'' most nearly means:', '["Followed", "Came before", "Replaced", "Caused"]', 1),
    (1, 'reading', 'Before the printing press, why were books rare?', '["Paper had not yet been invented.", "Books were copied by hand, making them slow and expensive to produce.", "Governments restricted book production.", "Most people did not know how to read."]', 1),
    (1, 'reading', 'The passage implies that the printing press contributed most directly to:', '["The invention of paper.", "A more informed and literate general population.", "Government censorship of ideas.", "A decrease in the quality of books."]', 1),
    (1, 'reading', 'Approximately when was the printing press invented?', '["1340", "1440", "1540", "1640"]', 1),
    (1, 'reading', 'As used in the passage, ''circulate'' most nearly means:', '["Stop", "Move around freely", "Be censored", "Be destroyed"]', 1),
    (1, 'reading', 'Based on the passage, which group likely benefited MOST from the printing press?', '["Wealthy nobles who could already afford hand-copied books.", "Church leaders who controlled book production.", "Common people who previously had little access to books.", "Scribes who copied books by hand."]', 2),
    (1, 'reading', 'What is the main idea of this passage?', '["Gutenberg was an important historical figure.", "Books were too expensive before 1440.", "The printing press transformed how information was shared in Europe.", "Literacy was rare in medieval Europe."]', 2),
    (1, 'reading', 'The author includes the detail about books being ''copied by hand'' primarily to:', '["Show that scribes were important workers.", "Provide contrast that highlights how significant the printing press was.", "Argue that handmade books were superior.", "Prove that literacy was impossible before Gutenberg."]', 1),
    (1, 'reading', 'What is the PRIMARY reason deep-sea creatures produce bioluminescence, according to the passage?', '["To help them see in the dark", "To serve multiple survival purposes such as luring prey and attracting mates", "To warm the cold ocean water around them", "To communicate with scientists on the surface"]', 1),
    (1, 'reading', 'What does the word "lure" mean as used in the passage about bioluminescence?', '["A type of glowing chemical", "Something used to attract or draw in an animal", "A deep-sea predator", "The process of producing light"]', 1),
    (1, 'reading', 'Which conclusion can be drawn from the fact that bioluminescence "evolved independently in dozens of different marine species"?', '["All deep-sea creatures share a common ancestor", "Producing light must provide a strong survival advantage", "Scientists invented bioluminescence through genetic engineering", "Only anglerfish are capable of producing light"]', 1),
    (1, 'reading', 'What is this passage mainly about?', '["The diet of the anglerfish", "How and why deep-sea creatures produce their own light", "Why the ocean depths are completely dark", "The history of marine biology research"]', 1),
    (1, 'reading', 'Why does the author mention the anglerfish specifically?', '["To show that anglerfish are the most dangerous ocean creatures", "To provide a specific, concrete example of bioluminescence used for hunting", "To explain how bioluminescence was first discovered", "To argue that all fish should be studied more carefully"]', 1),
    (1, 'reading', 'According to the passage, where did sign language first develop in an organized way?', '["Hartford, Connecticut", "Paris, France", "Throughout ancient Greece", "Washington, D.C."]', 1),
    (1, 'reading', 'What does the word "syntax" most likely mean as used in the passage about sign language?', '["A list of hand movements", "The rules for arranging words or signs into sentences", "A type of hearing device", "The historical study of language"]', 1),
    (1, 'reading', 'What inference can be made about ASL based on information in the passage?', '["ASL and French Sign Language share some historical roots", "ASL was invented entirely without any European influence", "ASL is simpler than spoken English", "ASL can only be understood by people who are completely deaf"]', 0),
    (1, 'reading', 'What is the main idea of this passage about sign language?', '["Laurent Clerc was the most important figure in the history of language", "Sign languages are real, complete languages with a formal history of development", "Deaf people communicate less effectively than hearing people", "All sign languages around the world are essentially the same"]', 1),
    (1, 'reading', 'According to the passage, what drives the water cycle?', '["The rotation of the Earth", "Energy from the sun", "The gravitational pull of the moon", "Wind patterns alone"]', 1),
    (1, 'reading', 'What does "condenses" mean as used in the passage about the water cycle?', '["Evaporates into the air", "Changes from gas back into liquid", "Freezes into ice crystals", "Sinks into the ground"]', 1),
    (1, 'reading', 'Which of the following would most likely happen if the sun''s energy reaching Earth were significantly reduced?', '["Rainfall would increase significantly", "The water cycle would slow down or weaken", "Clouds would form more quickly", "Rivers would flow faster"]', 1),
    (1, 'reading', 'What is the passage''s main purpose?', '["To argue that humans must protect the water supply", "To explain the continuous process by which water moves through Earth''s systems", "To describe how clouds are formed in detail", "To compare different forms of precipitation"]', 1),
    (1, 'reading', 'According to the passage, what was cuneiform first used to record?', '["Laws and royal decrees", "Religious ceremonies", "Economic records such as grain and livestock", "Epic poems and stories"]', 2),
    (1, 'reading', 'What does the word "decrees" most likely mean in this passage?', '["Ancient trade agreements", "Official orders or commands issued by a ruler", "Written prayers to the gods", "Historical maps of the region"]', 1),
    (1, 'reading', 'What does the development of cuneiform over centuries suggest about ancient Mesopotamian society?', '["Mesopotamian society stayed simple and unchanged", "Society grew more complex, with expanding needs for communication and record-keeping", "Only priests and kings were ever literate", "The economy collapsed after writing was invented"]', 1),
    (1, 'reading', 'What is the passage mainly about?', '["The plot of the Epic of Gilgamesh", "The geography of ancient Mesopotamia", "The origin and development of cuneiform writing", "Why ancient civilizations needed trade records"]', 2),
    (1, 'reading', 'According to the passage, where did the ancient Olympic Games originate?', '["Athens, Greece", "Sparta, Greece", "Olympia, Greece", "Rome, Italy"]', 2),
    (1, 'reading', 'Why was a truce declared during the ancient Olympic Games?', '["To honor the god Zeus with a period of peace", "To allow competitors to travel to Olympia without danger", "To give athletes time to rest before competing", "To prevent cheating during the events"]', 1),
    (1, 'reading', 'What can be inferred about the ancient Olympics from the fact that city-states across Greece sent athletes?', '["The Games were not very well known outside of Olympia", "The Games were a unifying event for otherwise separate Greek communities", "Only the wealthiest city-states participated", "Greek city-states were always at peace with one another"]', 1),
    (1, 'reading', 'What is this passage mainly about?', '["The athletic events included in the modern Olympics", "The religious beliefs of ancient Greeks", "The origins and development of the Olympic Games from ancient Greece to today", "Why ancient Greece was the center of world civilization"]', 2),
    (1, 'reading', 'According to the passage, how do vaccines teach the immune system to fight disease?', '["By introducing a full-strength dose of the disease", "By introducing a harmless form of the pathogen so the immune system learns to fight it", "By injecting antibodies directly from other people", "By strengthening the immune system through nutrition"]', 1),
    (1, 'reading', 'What does "immunological memory" mean as used in the passage?', '["A list of diseases a person has survived", "The immune system''s ability to recognize and quickly respond to a previously encountered pathogen", "The process by which vaccines are manufactured", "A type of protein that destroys viruses"]', 1),
    (1, 'reading', 'Why does the author describe antibodies as "proteins designed to neutralize that specific threat"?', '["To suggest that antibodies are man-made medications", "To emphasize that each antibody targets only one specific pathogen, not all germs", "To explain why vaccines must be refrigerated", "To describe the side effects of vaccination"]', 1),
    (1, 'reading', 'According to the passage, what would most likely happen if a vaccinated person were exposed to the real pathogen?', '["They would become very ill because vaccines weaken the immune system", "Their immune system would respond quickly and likely prevent the disease", "They would need to receive another vaccine immediately", "Their body would produce no antibodies at all"]', 1),
    (1, 'reading', 'According to the passage, why are bees essential to many ecosystems?', '["They produce honey that humans and animals eat", "They pollinate plants that produce food for many species", "They control insect populations by eating harmful pests", "They help spread seeds by carrying them in their legs"]', 1),
    (1, 'reading', 'What does "pollination" mean as described in the passage?', '["The process of bees making honey from nectar", "The transfer of pollen between flowers that allows plants to reproduce", "A method bees use to communicate danger", "The collection of nectar by bees for energy"]', 1),
    (1, 'reading', 'What would most likely happen to human food supplies if bee populations disappeared entirely?', '["Food supplies would be largely unaffected", "About one-third of human foods would be at risk", "Only honey production would decline", "Animals would lose food, but humans would be fine"]', 1),
    (1, 'reading', 'Why does the author mention habitat loss, pesticides, and disease in the final sentence?', '["To prove that bees are a nuisance to farmers", "To show that bees are thriving despite some minor challenges", "To highlight real threats to bee populations and underscore the seriousness of their decline", "To explain how new bee species are evolving"]', 2),
    (1, 'reading', 'According to the passage, what happens in the brain during sleep?', '["The brain shuts down to save energy", "The brain consolidates memories, clears waste, and processes emotions", "The brain produces growth hormones only during waking hours", "The brain replays the day''s experiences in order"]', 1),
    (1, 'reading', 'What does "consolidates" mean as used in the passage about sleep?', '["Erases memories that are no longer needed", "Strengthens and organizes memories for long-term storage", "Creates new dreams during deep sleep", "Transfers waste products out of the brain"]', 1),
    (1, 'reading', 'What can be inferred from the passage about the importance of sleep for students?', '["Students who sleep more than nine hours will have better grades", "Not getting enough sleep can hurt a student''s ability to remember and think clearly", "Dreams during REM sleep help students study better", "Teenagers need less sleep than adults"]', 1),
    (1, 'reading', 'What is the main idea of the passage about sleep?', '["Dreams are the most important part of sleep", "Sleep is an active and essential process for brain and body health", "Teenagers sleep too much and should spend more time studying", "The brain is less active at night than during the day"]', 1),
    (1, 'reading', 'According to the passage, where did jazz music first develop?', '["Chicago, Illinois", "New York City", "New Orleans, Louisiana", "Memphis, Tennessee"]', 2),
    (1, 'reading', 'What does "improvisational" most likely mean in the context of the passage about jazz?', '["Based on strict written musical rules", "Created spontaneously in the moment rather than planned in advance", "Influenced by European classical music", "Performed only for large audiences"]', 1),
    (1, 'reading', 'What can be inferred about the spread of jazz from New Orleans to Chicago and New York?', '["Jazz spread because musicians were paid to move to other cities", "Jazz traveled with people migrating along river and trade routes", "Radio broadcasts were the main cause of jazz''s spread", "Northern cities invented their own version of jazz independently"]', 1),
    (1, 'reading', 'What is the passage mainly about?', '["The life of a famous jazz musician", "The origins, influences, and spread of jazz as an American art form", "Why New Orleans is the best city for music", "The differences between blues and jazz music"]', 1),
    (1, 'reading', 'According to the passage, how does the eye detect different colors?', '["By measuring the brightness of incoming light", "Through three types of cone cells that each respond to a different wavelength of light", "Through rod cells that detect red, green, and blue light", "By measuring the speed at which light enters the eye"]', 1),
    (1, 'reading', 'What does "wavelength" suggest about light in the context of this passage?', '["Light travels in waves of different sizes, and color is related to those differences", "Light is a solid particle that bounces off objects", "Wavelength refers to the brightness of a color", "Only visible light has a wavelength"]', 0),
    (1, 'reading', 'What can be inferred about why colorblind people confuse certain colors?', '["Their brains are unable to process electrical signals", "Without a functioning cone type, their brain receives incomplete information about certain wavelengths", "They have too many cone cells, creating confusion", "They see the world in black and white only"]', 1),
    (1, 'reading', 'What is the main idea of this passage?', '["The eye is the most complex organ in the human body", "Color vision works through three types of specialized cells that detect light wavelengths", "Colorblindness is a very common condition that affects everyone slightly", "The brain produces color without any input from the eyes"]', 1),
    (1, 'reading', 'According to the passage, who is credited with inventing the telephone?', '["Thomas Watson", "A Scottish engineer in Glasgow", "Alexander Graham Bell", "An unnamed inventor who filed first"]', 2),
    (1, 'reading', 'What does "patent" mean as used in the passage about the telephone?', '["A financial prize for inventors", "An official legal document granting the inventor exclusive rights to their invention", "A scientific paper describing how the telephone works", "A government contract to build telephones"]', 1),
    (1, 'reading', 'What does the detail about Bell filing his patent "just hours before a competing inventor" suggest?', '["Bell stole his ideas from the competing inventor", "The invention of the telephone was not Bell''s idea at all", "Multiple inventors were close to the same breakthrough, and timing determined who got credit", "Bell was not a serious inventor and succeeded only by luck"]', 2),
    (1, 'reading', 'What is the passage mainly about?', '["The life story of Alexander Graham Bell", "Thomas Watson''s contributions to science", "The invention of the telephone and the story behind Bell''s patent", "How telephones have changed since 1876"]', 2),
    (1, 'reading', 'According to the passage, what causes earthquakes?', '["The cooling of Earth''s core", "The sudden release of energy when tectonic plates slip or grind", "Pressure from underground rivers and caves", "Volcanic eruptions that shake surrounding rock"]', 1),
    (1, 'reading', 'What does "tectonic" suggest about Earth''s plates, based on context?', '["They are temporary and dissolve over millions of years", "They relate to the large-scale structural movements of Earth''s outer layer", "They are found only beneath the oceans", "They are heated by the sun rather than Earth''s interior"]', 1),
    (1, 'reading', 'What can be inferred about why the "Ring of Fire" has so many earthquakes and volcanoes?', '["The Pacific Ocean is unusually warm, heating the plates beneath it", "Several tectonic plate boundaries meet around the Pacific Ocean", "The Ring of Fire is made of different rock than other regions", "Earthquakes in one region trigger earthquakes across the Pacific"]', 1),
    (1, 'reading', 'What is this passage primarily about?', '["How volcanoes form beneath the sea", "The composition of Earth''s inner core", "How tectonic plates move and cause earthquakes and volcanoes", "The history of earthquake measurement"]', 2),
    (1, 'reading', 'According to the passage, what is the final stage in the life of a massive star?', '["They slowly cool into a white dwarf", "They expand permanently into a red giant", "They collapse and explode in a supernova, possibly becoming a neutron star or black hole", "They break apart into smaller stars"]', 2),
    (1, 'reading', 'What does "nuclear fusion" most likely mean, based on how the term is used in the passage?', '["The process by which stars collect gas and dust from space", "A reaction in a star''s core that produces energy by combining atoms", "The explosion that ends a massive star''s life", "The cooling process that turns a star into a white dwarf"]', 1),
    (1, 'reading', 'What is the main idea of this passage about stars?', '["Black holes are the most dangerous objects in the universe", "Stars go through a predictable life cycle from birth to death", "Our sun will eventually explode in a supernova", "All stars end as white dwarfs"]', 1),
    (1, 'reading', 'Why does the author begin by saying stars are "not permanent fixtures in the sky"?', '["To argue that stars are less important than planets", "To correct a common assumption and set up the main topic of stars'' life cycles", "To frighten readers about the eventual death of our sun", "To explain why ancient people could not study stars"]', 1),
    (1, 'reading', 'According to the passage, what is an urban heat island?', '["A park in the center of a city that gets extra sunlight", "The tendency of cities to be warmer than surrounding rural areas due to human-made surfaces and activities", "A weather pattern that traps heat over tropical cities", "The heating of rivers and lakes caused by industrial waste"]', 1),
    (1, 'reading', 'What does "vulnerable populations" most likely mean as used in the passage?', '["City residents who live near factories", "Groups of people who are especially at risk of harm from heat", "Scientists who study urban weather", "People who cannot afford air conditioning"]', 1),
    (1, 'reading', 'Which of the following is most likely to reduce the urban heat island effect, based on the passage?', '["Building more parking lots and highways", "Replacing dark asphalt roads with lighter-colored or vegetated surfaces", "Increasing the number of air conditioners in buildings", "Constructing taller buildings to block sunlight"]', 1),
    (1, 'reading', 'What is this passage mainly about?', '["Why cities should plant more trees", "What causes the urban heat island effect and why it matters", "The history of city planning and road construction", "Why summer heat waves are becoming more frequent"]', 1),
    (1, 'reading', 'According to the passage, what was ARPANET?', '["The first personal computer sold to the public", "An early government-funded computer network that was the predecessor to the internet", "A software program for browsing websites", "The organization that manages the internet today"]', 1),
    (1, 'reading', 'What does "protocols" mean in the context of this passage?', '["High-speed cables that connect computers", "The rules or standards that govern how computers communicate with each other", "Programs that protect computers from viruses", "A type of hardware used in early computers"]', 1),
    (1, 'reading', 'Why did Tim Berners-Lee''s invention of the World Wide Web matter for ordinary people?', '["It made the internet faster for scientists at universities", "It made the internet accessible and easy to navigate for people outside research labs", "It replaced ARPANET with a more secure system", "It reduced the cost of computers so more families could buy them"]', 1),
    (1, 'reading', 'What is the main idea of this passage?', '["Tim Berners-Lee is the most important inventor in modern history", "The internet developed gradually from a small military research network into a global tool", "ARPANET was invented to help soldiers communicate during wartime", "The World Wide Web and the internet are exactly the same thing"]', 1),
    (1, 'reading', 'According to the passage, how do bats use echolocation to navigate?', '["By using their large eyes to see in very dim light", "By emitting sound pulses and interpreting the returning echoes", "By sensing vibrations through their wings", "By following the magnetic field of the Earth"]', 1),
    (1, 'reading', 'What does "nocturnal" mean as used in the passage about bats?', '["Active during daylight hours", "Active during the night", "Capable of seeing in the dark", "Able to survive without food for weeks"]', 1),
    (1, 'reading', 'What can be inferred from the fact that bats can catch moths in complete darkness?', '["Bats have better eyesight than most other animals", "Echolocation provides bats with extremely precise spatial information", "Moths are easy to catch because they fly slowly", "Bats can only hunt when conditions are perfectly quiet"]', 1),
    (1, 'reading', 'Why does the author mention sonar and radar technology at the end of the passage?', '["To suggest that bats are more intelligent than machines", "To show that studying bats has had real-world benefits for human technology", "To argue that ships and aircraft should use bats instead of sonar", "To explain why scientists prefer bats to other nocturnal animals"]', 1),
    (1, 'reading', 'According to the passage, how does the color of an object affect how we perceive it?', '["Objects produce their own color through internal chemistry", "Objects reflect certain wavelengths of light, which the brain interprets as color", "The brain ignores color and focuses on shape instead", "Color perception is the same for all people in all situations"]', 1),
    (1, 'reading', 'What does "context" mean as used in the passage about color perception?', '["The wavelength of light reflected by an object", "The surrounding environment that influences how something is perceived", "The part of the brain responsible for color vision", "The history of how humans learned about color"]', 1),
    (1, 'reading', 'What can be inferred about why marketers choose specific colors for products and advertisements?', '["They choose colors purely for artistic reasons", "They use color strategically to trigger specific emotional responses in consumers", "They always choose the brightest colors to attract attention", "They rely on customers'' favorite colors rather than psychological research"]', 1),
    (1, 'reading', 'What is the passage mainly about?', '["Why red is the most powerful color in marketing", "How the brain interprets color and how color can influence perception and behavior", "The physical properties of light and wavelengths", "Why all people perceive color differently"]', 1),
    (1, 'reading', 'According to the passage, what tools did Pacific Islander navigators use to find their way?', '["Compasses and early maps drawn on animal skins", "Stars, ocean swells, wave motion, water color, clouds, and birds", "Radio signals and ocean charts", "Magnetic rocks and tidal patterns"]', 1),
    (1, 'reading', 'What does "wayfinding" most likely mean in this passage?', '["Building boats strong enough to cross oceans", "The skill of navigating and finding one''s route using available information", "Reading weather patterns to predict storms", "Swimming from island to island"]', 1),
    (1, 'reading', 'What does the phrase "passed down through oral tradition" suggest about how this knowledge was preserved?', '["The knowledge was written in books stored in temples", "The knowledge was spoken and memorized, not written down", "The knowledge was kept secret and shared only with royalty", "The knowledge was learned from European sailors"]', 1),
    (1, 'reading', 'What is the passage mainly about?', '["Why the Pacific Ocean is the most difficult ocean to cross", "The sophisticated navigation methods used by indigenous Pacific Islander peoples", "The history of the compass and its importance to sailors", "How Polynesian peoples first discovered the Pacific Islands"]', 1),
    (1, 'reading', 'According to the passage, what happens to the price of a product when demand increases and supply stays the same?', '["Prices fall because sellers want to attract buyers", "Prices stay the same regardless of demand", "Prices rise because buyers are competing for a limited supply", "Prices become unpredictable and fluctuate randomly"]', 2),
    (1, 'reading', 'What does "equilibrium" most likely mean as used in the passage?', '["The highest price a product has ever sold for", "A point of balance where supply and demand are equal", "The price set by the government for a product", "The average price of all products in an economy"]', 1),
    (1, 'reading', 'What can be inferred about the effect of a new technology that makes production much cheaper?', '["It would cause demand to fall because buyers would not trust cheaper products", "It would likely increase supply and lower prices for consumers", "It would have no effect on prices if demand stays the same", "It would cause sellers to raise prices to make more profit"]', 1),
    (1, 'reading', 'What is the main idea of this passage?', '["Droughts and technology are the biggest threats to a healthy economy", "Sellers always have more power than buyers in setting prices", "Supply and demand are the forces that determine prices in a market economy", "The equilibrium price never changes once it is established"]', 2),
    (1, 'reading', 'According to the passage, which city is considered the birthplace of democracy?', '["Rome", "Sparta", "Athens", "Alexandria"]', 2),
    (1, 'reading', 'What does "direct democracy" mean as described in the passage?', '["Electing representatives to vote on laws on your behalf", "Citizens voting directly on laws and policies themselves", "A king ruling with the advice of citizens", "A council of nobles making decisions for the public"]', 1),
    (1, 'reading', 'Why does the author describe Athens'' democracy as having "flaws" in the final sentence?', '["To argue that Athens was not really a democracy at all", "To acknowledge that Athenian democracy excluded many people, even while praising its foundational ideas", "To show that Cleisthenes was a dishonest leader", "To suggest that ancient systems are not worth studying"]', 1),
    (1, 'reading', 'What is the passage mainly about?', '["The biography of Cleisthenes and his political career", "The origins of democracy in ancient Athens, including both its innovations and its limitations", "Why democracy failed in ancient Greece", "The differences between ancient and modern voting systems"]', 1),
    (1, 'reading', 'According to the passage, how do antibiotics fight bacterial infections?', '["By strengthening the immune system to fight infections faster", "By targeting features of bacteria that human cells lack, such as cell walls and protein production", "By killing all microorganisms in the body, including helpful bacteria", "By lowering body temperature to slow bacterial growth"]', 1),
    (1, 'reading', 'What does "antibiotic resistance" mean as described in the passage?', '["Patients refusing to take prescribed antibiotics", "Bacteria that have evolved to survive antibiotic drugs", "Antibiotics that no longer dissolve in the body", "A shortage of antibiotic medications in hospitals"]', 1),
    (1, 'reading', 'Why do doctors not prescribe antibiotics for colds or the flu?', '["Colds and flu are not serious enough to need medicine", "Colds and flu are caused by viruses, not bacteria, so antibiotics would not work", "Antibiotics are too expensive to use for minor illnesses", "Doctors prefer natural remedies for respiratory infections"]', 1),
    (1, 'reading', 'What might happen if antibiotics are overused, based on the passage?', '["Antibiotics would become more effective over time", "Bacteria would evolve resistance, making infections harder to treat", "Viruses would start responding to antibiotic treatment", "People would develop immunity to bacterial infections naturally"]', 1),
    (1, 'reading', 'According to the passage, what role do coral reefs play in the ocean?', '["They serve as feeding grounds exclusively for large ocean predators", "They support enormous biodiversity, protect coastlines, and sustain fishing economies", "They produce the oxygen that marine animals breathe", "They are found mainly in the deep ocean far from human populations"]', 1),
    (1, 'reading', 'What does "bleaching" suggest about coral reefs when ocean temperatures rise?', '["Corals turn brighter colors when they are healthy", "Corals lose their algae and energy source, which can cause them to die", "Warm water causes corals to grow faster", "Bleaching is a natural seasonal event that does not harm reefs"]', 1),
    (1, 'reading', 'What can be inferred about the relationship between corals and algae?', '["Algae compete with coral for space on the reef", "Coral cannot survive without the energy algae provide through photosynthesis", "Algae are harmful to corals and cause bleaching", "Algae and coral are the same type of organism"]', 1),
    (1, 'reading', 'What is the passage mainly about?', '["Why fishing near coral reefs should be banned", "The structure, importance, and threats facing coral reef ecosystems", "How algae reproduce in warm ocean water", "The history of scientific research on coral reefs"]', 1),
    (1, 'reading', 'According to the passage, how does sound travel from its source to your ears?', '["Sound travels as light waves that are converted into vibrations by the ear", "Sound travels as pressure waves created by vibrations, which cause the eardrum to vibrate", "Sound jumps directly from the source to the eardrum without a medium", "Sound travels through space and is slowed down when it enters the atmosphere"]', 1),
    (1, 'reading', 'What does "frequency" mean as used in the passage about sound?', '["The loudness or volume of a sound", "How many waves pass a point per second", "The distance a sound wave travels", "The material through which sound travels"]', 1),
    (1, 'reading', 'What would most likely happen to the pitch of a sound if its frequency doubled?', '["The pitch would get lower", "The pitch would stay the same", "The pitch would get higher", "The sound would stop traveling through air"]', 2),
    (1, 'reading', 'What is the main idea of this passage?', '["Why sound cannot travel in outer space", "How sound waves are produced, how they travel, and how their properties determine pitch", "The anatomy of the human ear and how it is protected", "Why some materials conduct electricity better than others"]', 1),
    (1, 'reading', 'According to the passage, what triggers many birds'' migration each year?', '["Dropping temperatures in autumn", "The start of rainfall in their habitat", "Changes in the length of daylight hours", "Decreasing food supply in summer"]', 2),
    (1, 'reading', 'What does "photoperiod" mean as used in the passage about bird migration?', '["The total amount of rainfall in a season", "The length of daylight in a given period", "A bird''s internal sense of direction", "The temperature difference between two seasons"]', 1),
    (1, 'reading', 'What can be inferred about birds that return to the same nesting grounds each year?', '["They never encounter any obstacles during migration", "They rely entirely on learned behavior from older birds", "They possess a reliable internal navigation system that stores location information", "They are guided to their nesting grounds by other animals"]', 2),
    (1, 'reading', 'What is the passage primarily about?', '["The threats that climate change poses to migrating birds", "What triggers bird migration and how birds navigate during their journeys", "Why some birds migrate while others do not", "The specific routes used by different bird species"]', 1),
    (1, 'reading', 'According to the passage, where are memories first formed?', '["The cerebral cortex", "The amygdala", "The hippocampus", "The nervous system outside the brain"]', 2),
    (1, 'reading', 'What does "consolidation" mean as used in the passage about memory?', '["The process of forgetting old memories to make room for new ones", "The gradual transfer and stabilization of memories into long-term storage", "The experience of recalling a memory under stress", "The destruction of memories during sleep"]', 1),
    (1, 'reading', 'Why do strong emotional experiences tend to create more lasting memories?', '["The hippocampus stores emotional memories in a different location", "The amygdala signals that emotional events are important, making them more strongly encoded", "People pay more attention to boring events than emotional ones", "Emotional memories skip the hippocampus and go directly to long-term storage"]', 1),
    (1, 'reading', 'What is the main idea of this passage?', '["The hippocampus is the only part of the brain that matters for learning", "The brain forms and stores memories through a multi-step process involving several regions", "Sleep is the most important factor in how smart a person is", "Emotions are stored separately from other types of memories"]', 1),
    (1, 'math', 'What is 15% of 200?', '["25", "30", "35", "40"]', 1),
    (1, 'math', 'What is 3² + 4²?', '["25", "49", "14", "7"]', 0),
    (1, 'math', 'A rectangle has length 12 and width 7. What is the area?', '["38", "74", "84", "19"]', 2),
    (1, 'math', 'Maria drives 60 mph. How long to drive 210 miles?', '["3 hours", "3.5 hours", "4 hours", "2.5 hours"]', 1),
    (1, 'math', 'A $120 jacket is 25% off. What is the sale price?', '["$85", "$90", "$95", "$80"]', 1),
    (1, 'math', 'The sum of two consecutive integers is 85. What is the larger integer?', '["41", "42", "43", "44"]', 2),
    (1, 'math', 'A right triangle has legs 5 and 12. What is the hypotenuse?', '["11", "13", "15", "17"]', 1),
    (1, 'math', 'Pump A fills a pool in 6 hours; Pump B in 4 hours. Together, how long?', '["2 hours", "2.4 hours", "3 hours", "5 hours"]', 1),
    (1, 'math', 'What is 8 × 7?', '["54", "56", "58", "64"]', 1),
    (1, 'math', 'What is the value of |−15|?', '["−15", "0", "15", "150"]', 2),
    (1, 'math', 'What is the GCF of 24 and 36?', '["6", "8", "9", "12"]', 3),
    (1, 'math', 'What is the LCM of 4 and 6?', '["10", "12", "18", "24"]', 1),
    (1, 'math', 'What is 2⁵?', '["10", "16", "25", "32"]', 3),
    (1, 'math', 'What is the remainder when 50 is divided by 8?', '["1", "2", "3", "4"]', 1),
    (1, 'math', 'What is |−8| + |3|?', '["−5", "5", "11", "−11"]', 2),
    (1, 'math', 'Evaluate: (6 + 2) × 3 − 4', '["14", "18", "20", "22"]', 2),
    (1, 'math', 'What is 4³?', '["12", "16", "48", "64"]', 3),
    (1, 'math', 'What is the LCM of 6 and 9?', '["3", "18", "27", "54"]', 1),
    (1, 'math', 'What is the remainder when 63 is divided by 9?', '["0", "3", "6", "9"]', 0),
    (1, 'math', 'Evaluate: 5² − 3 × 4 + 2', '["12", "15", "17", "27"]', 1),
    (1, 'math', 'What is √81?', '["7", "8", "9", "11"]', 2),
    (1, 'math', 'What is the GCF of 32 and 48?', '["8", "12", "16", "24"]', 2),
    (1, 'math', 'What is 1/2 + 1/4?', '["1/6", "2/6", "3/4", "1/3"]', 2),
    (1, 'math', 'What is 0.75 expressed as a fraction in lowest terms?', '["7/10", "3/4", "75/10", "15/20"]', 1),
    (1, 'math', 'What is 20% of 80?', '["12", "14", "16", "20"]', 2),
    (1, 'math', 'Which fraction is largest: 1/2, 2/5, 3/7?', '["1/2", "2/5", "3/7", "All equal"]', 0),
    (1, 'math', 'What is 3/4 of 60?', '["40", "42", "45", "48"]', 2),
    (1, 'math', 'What is 0.3 + 0.45?', '["0.48", "0.75", "0.73", "0.78"]', 1),
    (1, 'math', 'What percent of 50 is 10?', '["5%", "10%", "15%", "20%"]', 3),
    (1, 'math', 'What is 2/3 × 3/4?', '["5/7", "6/12", "1/2", "2/4"]', 2),
    (1, 'math', 'A store marks a $40 item up by 50%. What is the new price?', '["$50", "$55", "$60", "$65"]', 2),
    (1, 'math', 'What is 1/5 as a decimal?', '["0.1", "0.15", "0.2", "0.25"]', 2),
    (1, 'math', 'What is 5/8 − 1/4?', '["3/8", "4/8", "1/8", "2/8"]', 0),
    (1, 'math', 'Find the mode of: 2, 4, 4, 5, 6, 4, 7.', '["2", "4", "5", "7"]', 1),
    (1, 'math', 'Find the range of: 10, 3, 7, 15, 6.', '["9", "10", "12", "15"]', 2),
    (1, 'math', 'Find the mean of: 12, 16, 20, 8.', '["12", "14", "15", "16"]', 1),
    (1, 'math', 'What is the perimeter of a square with side 9?', '["18", "27", "36", "81"]', 2),
    (1, 'math', 'What is the area of a triangle with base 10 and height 6?', '["16", "30", "60", "48"]', 1),
    (1, 'math', 'What is the area of a circle with radius 3? (Use π ≈ 3.14)', '["9.42", "18.84", "28.26", "37.68"]', 2),
    (1, 'math', 'A rectangle has perimeter 30. Its width is 6. What is its length?', '["5", "7", "9", "12"]', 2),
    (1, 'math', 'Two angles of a triangle are 50° and 70°. What is the third angle?', '["50°", "60°", "70°", "80°"]', 1),
    (1, 'math', 'What is the circumference of a circle with diameter 10? (Use π ≈ 3.14)', '["15.7", "31.4", "62.8", "78.5"]', 1),
    (1, 'math', 'A rectangular room is 8 feet long and 5 feet wide. What is its area?', '["13", "26", "35", "40"]', 3),
    (1, 'math', 'What type of angle measures exactly 90°?', '["Acute", "Obtuse", "Right", "Straight"]', 2),
    (1, 'math', 'The sum of three consecutive even integers is 60. What is the largest?', '["18", "20", "22", "24"]', 2),
    (1, 'math', 'If x/4 = 9, what is x?', '["13", "27", "36", "40"]', 2),
    (1, 'math', 'Which value of x satisfies: 3x > 12?', '["x = 2", "x = 4", "x = 5", "x = 3"]', 2),
    (1, 'math', 'The sum of two consecutive odd integers is 36. What is the smaller integer?', '["15", "17", "19", "21"]', 1),
    (1, 'math', 'Which value satisfies 4x − 1 ≤ 11?', '["x = 4", "x = 3", "x = 5", "x = 6"]', 1),
    (1, 'math', 'The product of two consecutive integers is 56. What are the integers?', '["6 and 7", "7 and 8", "8 and 9", "5 and 6"]', 1),
    (1, 'math', 'If x/3 + 2 = 7, what is x?', '["9", "12", "15", "18"]', 2),
    (1, 'math', 'The sum of two numbers is 48. One number is 3 times the other. What is the larger number?', '["12", "24", "32", "36"]', 3),
    (1, 'math', 'Solve for x: 3x/4 = 9.', '["8", "10", "12", "15"]', 2),
    (1, 'math', 'The sum of two consecutive integers is 99. What is the larger?', '["48", "49", "50", "51"]', 2),
    (1, 'math', 'The sum of a number and twice its value is 27. What is the number?', '["7", "8", "9", "10"]', 2),
    (1, 'math', 'A triangle has angles in ratio 1:2:3. What is the largest angle?', '["60°", "80°", "90°", "100°"]', 2),
    (1, 'math', 'What is the area of a circle with radius 5? (Use π ≈ 3.14)', '["31.4", "62.8", "78.5", "157"]', 2),
    (1, 'math', 'A rectangular prism has length 5, width 4, and height 3. What is its volume?', '["40", "47", "60", "72"]', 2),
    (1, 'math', 'Two supplementary angles are in ratio 2:3. What is the measure of the larger angle?', '["72°", "90°", "108°", "120°"]', 2),
    (1, 'math', 'A right triangle has hypotenuse 10 and one leg 6. What is the other leg?', '["4", "6", "8", "9"]', 2),
    (1, 'math', 'What is the perimeter of a triangle with sides 7, 11, and 13?', '["28", "30", "31", "33"]', 2),
    (1, 'math', 'A square has an area of 64. What is its perimeter?', '["16", "24", "32", "36"]', 2),
    (1, 'math', 'The circumference of a circle is 62.8. What is the radius? (Use π ≈ 3.14)', '["5", "10", "15", "20"]', 1),
    (1, 'math', 'An angle measures 35°. What is the measure of its complement?', '["45°", "55°", "65°", "145°"]', 1),
    (1, 'math', 'A rectangular prism has length 10, width 3, and height 4. What is its volume?', '["100", "110", "120", "130"]', 2),
    (1, 'math', 'Two complementary angles are in ratio 1:4. What is the larger angle?', '["18°", "54°", "72°", "80°"]', 2),
    (1, 'math', 'What is the area of a triangle with base 14 and height 8?', '["44", "56", "78", "112"]', 1),
    (1, 'math', 'An angle measures 130°. What is the measure of its supplement?', '["40°", "50°", "60°", "70°"]', 1),
    (1, 'math', 'A right triangle has legs 8 and 15. What is the hypotenuse?', '["15", "16", "17", "18"]', 2),
    (1, 'math', 'What is the volume of a cube with side length 6?', '["36", "72", "180", "216"]', 3),
    (1, 'math', 'A train travels at 80 mph. How far does it travel in 2.5 hours?', '["180", "190", "200", "210"]', 2),
    (1, 'math', 'Carlos has twice as many cards as Diego. Together they have 90. How many does Carlos have?', '["30", "45", "60", "75"]', 2),
    (1, 'math', 'A car travels 150 miles in 3 hours. What is its average speed?', '["40 mph", "45 mph", "50 mph", "60 mph"]', 2),
    (1, 'math', 'Anna is 4 years older than Ben. The sum of their ages is 28. How old is Anna?', '["14", "16", "18", "20"]', 1),
    (1, 'math', 'A store buys shirts for $15 each and sells them for $25 each. What is the percent profit?', '["50%", "60%", "66%", "67%"]', 2),
    (1, 'math', 'A cyclist travels 12 miles in 48 minutes. How many miles per hour is this?', '["12", "15", "18", "20"]', 1),
    (1, 'math', 'Jake is twice as old as Lily. In 5 years Jake will be 29. How old is Lily now?', '["9", "10", "11", "12"]', 3),
    (1, 'math', 'A runner completes a 5-km race in 25 minutes. What is her speed in km per minute?', '["0.1", "0.2", "0.3", "0.5"]', 1),
    (1, 'math', 'Tom had $50. He spent $18 on lunch and $12 on a book. How much does he have left?', '["$18", "$20", "$22", "$30"]', 1),
    (1, 'math', 'A recipe calls for 2.5 cups of flour for 12 cookies. How much flour is needed for 36 cookies?', '["5 cups", "6.5 cups", "7 cups", "7.5 cups"]', 3),
    (1, 'math', 'Two friends split a bill of $64 equally. Each then gives a $5 tip. How much does each person pay in total?', '["$35", "$37", "$38", "$40"]', 1),
    (1, 'math', 'A pool holds 3,000 liters. A pump fills it at 60 liters per minute. How long to fill it?', '["40 min", "45 min", "50 min", "60 min"]', 2),
    (1, 'math', 'Maria earns $12 per hour. She worked 35 hours. She spent $200 on groceries. How much does she have left?', '["$200", "$220", "$230", "$240"]', 1),
    (1, 'math', 'A $200 TV is on sale for 15% off. What is the sale price?', '["$160", "$165", "$170", "$175"]', 2),
    (1, 'math', 'What is 2/3 ÷ 4?', '["1/4", "1/6", "2/12", "8/3"]', 1),
    (1, 'math', 'A test has 40 questions. A student answers 34 correctly. What percent is correct?', '["80%", "82%", "85%", "88%"]', 2),
    (1, 'math', 'What is 5/6 + 2/3?', '["7/9", "7/6", "3/2", "9/6"]', 2),
    (1, 'math', 'A price increased from $80 to $100. What is the percent increase?', '["20%", "22%", "25%", "30%"]', 2),
    (1, 'math', 'What is 3/8 as a decimal?', '["0.3", "0.35", "0.375", "0.38"]', 2),
    (1, 'math', 'A student got 18 out of 24 problems correct. What percent is this?', '["70%", "72%", "75%", "80%"]', 2),
    (1, 'math', 'What is 4/5 − 1/3?', '["3/2", "7/15", "4/15", "7/8"]', 1),
    (1, 'math', 'What is 40% of 150?', '["40", "55", "60", "75"]', 2),
    (1, 'math', 'A number is increased by 30% to get 91. What was the original number?', '["60", "65", "70", "75"]', 2),
    (1, 'math', 'Find the mean of: 5, 10, 15, 20, 25.', '["10", "13", "15", "20"]', 2),
    (1, 'math', 'Find the median of: 7, 3, 9, 1, 5, 11, 6.', '["5", "6", "7", "9"]', 1),
    (1, 'math', 'A data set has values: 4, 7, 7, 8, 9, 12. What is the mode?', '["4", "7", "8", "9"]', 1),
    (1, 'math', 'Find the range of: 14, 6, 22, 9, 18, 3.', '["16", "18", "19", "20"]', 2),
    (1, 'math', 'Five quiz scores are 72, 85, 90, 68, 80. What is the mean?', '["77", "79", "80", "83"]', 1),
    (1, 'math', 'What is the LCM of 12, 15, and 20?', '["30", "45", "60", "120"]', 2),
    (1, 'math', 'What is the GCF of 84, 126, and 210?', '["14", "21", "42", "63"]', 2),
    (1, 'math', 'Evaluate: |−14| − |−6| + |−3|', '["5", "11", "17", "23"]', 1),
    (1, 'math', 'Evaluate: 3³ × 2² − 4 × (6 − 2)', '["88", "92", "96", "100"]', 1),
    (1, 'math', 'What is the remainder when 253 is divided by 15?', '["7", "8", "10", "13"]', 3),
    (1, 'math', 'Evaluate: (2³ + 3²) × (4 − 1) ÷ 3', '["15", "17", "21", "51"]', 1),
    (1, 'math', 'What is the LCM of 8, 12, and 18?', '["36", "48", "72", "144"]', 2),
    (1, 'math', 'Evaluate: 5! ÷ 3! (where n! means n-factorial)', '["10", "15", "20", "25"]', 2),
    (1, 'math', 'Which of these is divisible by both 6 and 8?', '["42", "48", "54", "64"]', 1),
    (1, 'math', 'What is 2¹⁰?', '["256", "512", "1000", "1024"]', 3),
    (1, 'math', 'Evaluate: √(25 × 36)', '["25", "30", "36", "61"]', 1),
    (1, 'math', 'What is the remainder when 5¹⁰⁰ is divided by 4?', '["0", "1", "2", "3"]', 1),
    (1, 'math', 'Evaluate: 4 + 3 × [2 × (5 + 1) − 4]', '["22", "28", "32", "40"]', 1),
    (1, 'math', 'The sum of three consecutive integers is 102. What is the middle integer?', '["32", "33", "34", "35"]', 2),
    (1, 'math', 'If x² − 7x + 12 = 0, what are the values of x?', '["2 and 6", "3 and 4", "1 and 12", "4 and 6"]', 1),
    (1, 'math', 'A number is 5 less than twice another. Their sum is 22. What is the larger number?', '["9", "11", "13", "15"]', 2),
    (1, 'math', 'If x² + 5x + 6 = 0, what are the values of x?', '["−2 and −3", "2 and 3", "1 and 6", "−1 and −6"]', 0),
    (1, 'math', 'The sum of four consecutive integers is 74. What is the smallest?', '["16", "17", "18", "19"]', 1),
    (1, 'math', 'A father is 3 times as old as his son. In 12 years, he will be twice as old. How old is the son now?', '["10", "11", "12", "14"]', 2),
    (1, 'math', 'A right triangle has legs 7 and 24. What is the hypotenuse?', '["23", "25", "26", "31"]', 1),
    (1, 'math', 'A circle is inscribed in a square with side 10. What is the area of the circle? (Use π ≈ 3.14)', '["62.8", "78.5", "100", "314"]', 1),
    (1, 'math', 'A rectangular prism has volume 360 cm³. Its length is 10 and width is 6. What is its height?', '["4", "5", "6", "8"]', 2),
    (1, 'math', 'What is the area of a triangle with vertices at (0,0), (6,0), and (0,8)?', '["20", "24", "28", "48"]', 1),
    (1, 'math', 'A right triangle has hypotenuse 26 and one leg 10. What is the other leg?', '["16", "20", "24", "28"]', 2),
    (1, 'math', 'A circle has area 200.96 square cm. What is its radius? (Use π ≈ 3.14)', '["4", "6", "7", "8"]', 3),
    (1, 'math', 'A cylinder has radius 3 and height 10. What is its volume? (Use π ≈ 3.14)', '["94.2", "188.4", "282.6", "565.2"]', 2),
    (1, 'math', 'A square is inscribed in a circle with radius 5. What is the area of the square?', '["25", "50", "78.5", "100"]', 1),
    (1, 'math', 'A right triangle with legs 9 and 40 has what hypotenuse?', '["41", "42", "43", "49"]', 0),
    (1, 'math', 'Pipe X fills a tank in 8 hours; Pipe Y drains it in 12 hours. Both open together — how long to fill the tank?', '["16 hours", "20 hours", "24 hours", "32 hours"]', 2),
    (1, 'math', 'A jar has red and blue marbles in ratio 3:5. If there are 40 marbles total, how many are red?', '["12", "15", "16", "24"]', 1),
    (1, 'math', 'Two workers together finish a job in 6 hours. One alone takes 10 hours. How long does the other take alone?', '["12 hours", "15 hours", "18 hours", "20 hours"]', 1),
    (1, 'math', 'A 30-liter solution is 40% acid. How many liters of pure acid must be added to make it 50% acid?', '["4", "6", "8", "10"]', 1),
    (1, 'math', 'A boat travels 24 miles upstream in 3 hours and the same distance downstream in 2 hours. What is the speed of the current?', '["1 mph", "2 mph", "3 mph", "4 mph"]', 1),
    (1, 'math', 'Person A can paint a fence in 5 hours. Person B takes 7 hours. Working together, how long? (Round to nearest tenth)', '["2.5 hours", "2.9 hours", "3.1 hours", "3.5 hours"]', 1),
    (1, 'math', 'A mixture of nuts costs $6/lb. Cashews cost $8/lb and peanuts cost $4/lb. What fraction of the mix is cashews?', '["1/4", "1/3", "1/2", "2/3"]', 2),
    (1, 'math', 'A price dropped from $250 to $200. What is the percent decrease?', '["15%", "20%", "25%", "30%"]', 1),
    (1, 'math', 'After a 20% increase, a price is $156. What was the original price?', '["$120", "$125", "$130", "$140"]', 2),
    (1, 'math', 'What is 2/7 ÷ 4/21?', '["3/2", "3", "8/147", "7/6"]', 1),
    (1, 'math', 'A store offers successive discounts of 20% and 10%. What is the effective percent discount on the original price?', '["25%", "28%", "30%", "32%"]', 1),
    (1, 'math', 'What is 5/6 × 3/4 ÷ 5/8?', '["1/2", "1", "5/4", "3/2"]', 1),
    (1, 'math', 'After two successive 10% increases, what is the overall percent increase?', '["20%", "21%", "22%", "25%"]', 1),
    (1, 'math', 'Six test scores are 70, 75, 80, 85, 90, and x. The mean is 82. What is x?', '["92", "94", "96", "98"]', 0),
    (1, 'math', 'Four test scores are 72, 85, 90, and 78. The mean of all five scores is 82. What is the fifth score?', '["80", "83", "85", "88"]', 2),
    (1, 'math', 'A data set has five values: 12, 14, 15, 16, and 93. Which statement is true?', '["The mean equals the median.", "The mean is greater than the median.", "The median is greater than the mean.", "The mean and median are both 15."]', 1),
    (1, 'math', 'A student scored 68 on a test worth 40% of the grade and 88 on a test worth 60% of the grade. What is the weighted average?', '["76", "78", "80", "82"]', 2),
    (1, 'math', 'A set of five values has a range of 35. The largest value is 89. Four of the five values are 62, 71, 78, and 89. What must the fifth value be?', '["52", "54", "56", "58"]', 1),
    (1, 'math', 'A data set contains: 3, 5, 7, 3, 9, 5, 3, 7, 5, 9. What is the mode?', '["3 only", "5 only", "3 and 5", "7 and 9"]', 2),
    (1, 'math', 'A class of 20 students has a mean test score of 74. One absent student later takes a makeup test. After adding this score, the class mean rises to 75. What did the student score on the makeup test?', '["85", "90", "95", "100"]', 2),
    (1, 'math', 'Group A has 15 students with a mean score of 80. Group B has 10 students with a mean score of 70. What is the mean score of all 25 students combined?', '["74", "75", "76", "77"]', 2),
    (1, 'math', 'A data set of five values has a mean of 10, a median of 9, and a mode of 7. Which value must appear in the data set?', '["5", "7", "10", "15"]', 1),
    (1, 'math', 'A teacher calculated the mean of 10 quiz scores and got 82. She then discovered she had recorded one score as 90 when it should have been 60. What is the correct mean?', '["77", "78", "79", "80"]', 2),
    (1, 'math', 'A data set of 8 values has a mean of 50. A ninth value is added and the mean rises to 52. How much greater than the original mean is the ninth value?', '["Above by 14", "Above by 16", "Above by 18", "Above by 20"]', 2),
    (1, 'math', 'Point A is at (2, 6) and Point B is at (8, 2). What are the coordinates of the midpoint of segment AB?', '["(4, 4)", "(5, 4)", "(6, 4)", "(5, 5)"]', 1),
    (1, 'math', 'A triangle has vertices at (0, 0), (6, 0), and (0, 8). What is the perimeter?', '["20", "22", "24", "26"]', 2),
    (1, 'math', 'A circle has center (3, 3) and radius 5. Which of the following points lies INSIDE the circle?', '["(7, 3)", "(3, 9)", "(8, 3)", "(0, 7)"]', 0),
    (1, 'math', 'A square has a diagonal of 10 units and is inscribed in a circle (all four corners touch the circle). What is the approximate area of the region inside the circle but outside the square? (Use π ≈ 3.14)', '["24.5", "26.5", "28.5", "30.5"]', 2),
    (1, 'math', 'A circular ring is formed by two concentric circles. The outer radius is 8 and the inner radius is 5. What is the area of the ring? (Use π ≈ 3.14)', '["98.0", "110.0", "122.5", "150.7"]', 2),
    (1, 'math', 'A composite shape is made of a rectangle 12 units long and 6 units wide, with a semicircle attached to one of the shorter ends. The semicircle''s diameter equals the width of the rectangle. What is the total area? (Use π ≈ 3.14)', '["80.1", "83.1", "86.1", "90.1"]', 2),
    (1, 'math', 'A circle of radius 4 is cut out of a square with side 10. What is the area of the remaining square? (Use π ≈ 3.14)', '["45.8", "47.8", "49.8", "51.8"]', 2),
    (1, 'language', 'Which sentence uses punctuation correctly?', '["She went to the store, and bought milk.", "She went to the store and bought milk.", "She went to the store and, bought milk.", "She went, to the store and bought milk."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["We visited the grand canyon last Summer.", "we visited the Grand Canyon last summer.", "We visited the Grand Canyon last summer.", "We visited The Grand Canyon last summer."]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Recieve", "Recive", "Receive", "Receeve"]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Each of the students have completed their project.", "Each of the students has completed their project.", "Each of the students have completed his project.", "Each of the students has completed their projects."]', 1),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["The dog''s bone is buried in the yard''s.", "The dogs bone is buried in the yard.", "The dog''s bone is buried in the yard.", "The dogs'' bone is buried in the yard."]', 2),
    (1, 'language', 'Which sentence best fits as a topic sentence about exercise benefits?', '["Many people find exercise boring.", "Running shoes come in many styles.", "Regular exercise offers numerous physical and mental health benefits.", "Some athletes train many hours per day."]', 2),
    (1, 'language', 'Choose the correctly written sentence.', '["Between you and I, this is a great idea.", "Between you and me, this is a great idea.", "Between you and myself, this is a great idea.", "Between I and you, this is a great idea."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Neither the coach nor the players was ready.", "Neither the coach nor the players were ready.", "Neither the coach nor the players is ready.", "Neither the coach nor the players are ready."]', 1),
    (1, 'language', 'Which sentence uses the semicolon correctly?', '["She studied hard; but she failed.", "She studied hard; she passed with high marks.", "She studied; hard and passed.", "She; studied hard and passed."]', 1),
    (1, 'language', 'Which sentence contains a dangling modifier?', '["Running through the park, the dog chased the squirrel.", "Running through the park, the squirrel was chased by Sarah.", "Sarah chased the squirrel through the park.", "The squirrel ran as Sarah chased it."]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Accomodate", "Acommodate", "Accommodate", "Acomodate"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Embarass", "Embarrass", "Embarras", "Embaras"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Necesary", "Neccesary", "Neccessary", "Necessary"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Seperate", "Seprate", "Separate", "Separrate"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Occurance", "Occurence", "Occurrance", "Occurrence"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Exagerate", "Exaggerate", "Exaggarate", "Exaggerrate"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Privelege", "Priviledge", "Privilege", "Privilige"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Aquaint", "Acquaint", "Acqaint", "Acquiant"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Conscientous", "Consciencious", "Conscientious", "Consientious"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Liason", "Liaison", "Liasson", "Liasion"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Definately", "Definitly", "Definiteley", "Definitely"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Calender", "Calandar", "Calandr", "Calendar"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Grammer", "Gramer", "Grammir", "Grammar"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Restarant", "Restuarant", "Restaurant", "Restorant"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Beleive", "Beleve", "Believe", "Belive"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Wierd", "Wired", "Weird", "Weerd"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Arguement", "Arugment", "Arguemnt", "Argument"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Noticable", "Noticeable", "Notiseable", "Noticeble"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Writting", "Writing", "Writeing", "Writen"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Begining", "Begginning", "Beggining", "Beginning"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Febuary", "Feburary", "February", "Febrary"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Suprise", "Surprize", "Surprisse", "Surprise"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Nieghbor", "Neighbor", "Naighbor", "Nieghbour"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Knowlege", "Knowlegde", "Knowledg", "Knowledge"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Succedd", "Sucseed", "Succeed", "Suceed"]', 2),
    (1, 'language', 'Which word is spelled correctly?', '["Mispell", "Misspell", "Misspel", "Missppell"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Untill", "Unttil", "Untl", "Until"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Enviroment", "Enviornment", "Environement", "Environment"]', 3),
    (1, 'language', 'Which word is spelled correctly?', '["Minature", "Miniature", "Minuature", "Miniuture"]', 1),
    (1, 'language', 'Which word is spelled correctly?', '["Millenium", "Milennium", "Millennium", "Milenneum"]', 2),
    (1, 'language', 'Which sentence is correctly capitalized?', '["My favorite subject is Math.", "My favorite subject is math.", "my favorite subject is Math.", "My Favorite Subject is math."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["We drove across the mississippi river.", "We drove across the Mississippi River.", "We drove across the Mississippi river.", "We Drove Across The Mississippi River."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["She loves spring and Summer.", "She loves Spring and summer.", "She loves spring and summer.", "She Loves Spring And Summer."]', 2),
    (1, 'language', 'Which sentence is correctly capitalized?', '["I read a book by dr. seuss.", "I read a book by Dr. Seuss.", "I read a book by dr. Seuss.", "I read a book by Dr. seuss."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["The capital of France is paris.", "The capital of france is Paris.", "The Capital of France is Paris.", "The capital of France is Paris."]', 3),
    (1, 'language', 'Which sentence is correctly capitalized?', '["She shops at walmart every friday.", "She shops at Walmart every Friday.", "She shops at Walmart every friday.", "She shops at walmart every Friday."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["I visited aunt Maria last tuesday.", "I visited Aunt Maria last Tuesday.", "I visited aunt Maria last Tuesday.", "I visited Aunt maria last Tuesday."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["He moved to the west to find work.", "He moved to the West to find work.", "He Moved To The West To Find Work.", "He moved to the west To find work."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["The book is called the call of the wild.", "The book is called The Call of the Wild.", "The book is called The Call Of The Wild.", "The book is called the Call of the Wild."]', 1),
    (1, 'language', 'Which sentence is correctly capitalized?', '["My teacher is named mr. johnson.", "My teacher is named mr. Johnson.", "My teacher is named Mr. Johnson.", "My teacher is named Mr. johnson."]', 2),
    (1, 'language', 'Which sentence uses commas correctly?', '["I need eggs milk, and butter.", "I need eggs, milk and butter.", "I need eggs, milk, and butter.", "I need, eggs, milk, and butter."]', 2),
    (1, 'language', 'Which sentence uses the comma correctly?', '["After the game we went home.", "After the game, we went home.", "After, the game we went home.", "After the game we, went home."]', 1),
    (1, 'language', 'Which sentence uses commas correctly?', '["My brother, who lives in Denver loves skiing.", "My brother who lives in Denver, loves skiing.", "My brother, who lives in Denver, loves skiing.", "My brother who lives, in Denver loves skiing."]', 2),
    (1, 'language', 'Which sentence uses the comma correctly?', '["We can leave early, or stay for the whole show.", "We can leave early or, stay for the whole show.", "We can leave, early or stay for the whole show.", "We can leave early or stay for the whole show."]', 3),
    (1, 'language', 'Which sentence uses commas correctly?', '["Yes I agree with your decision.", "Yes, I agree with your decision.", "Yes I agree, with your decision.", "Yes, I agree, with your decision."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["Maria my best friend moved away last year.", "Maria, my best friend, moved away last year.", "Maria, my best friend moved away last year.", "Maria my best, friend moved away last year."]', 1),
    (1, 'language', 'Which sentence uses commas correctly?', '["The tall, dark, mysterious stranger walked in.", "The tall dark mysterious stranger walked in.", "The, tall dark mysterious stranger walked in.", "The tall, dark mysterious stranger walked in."]', 0),
    (1, 'language', 'Which sentence uses the comma correctly?', '["He was born on March, 15 2010.", "He was born on March 15, 2010.", "He was born on March 15 2010.", "He was born, on March 15, 2010."]', 1),
    (1, 'language', 'Which sentence uses commas correctly?', '["We visited Paris France on our trip.", "We visited Paris, France, on our trip.", "We visited Paris France, on our trip.", "We visited, Paris France on our trip."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["Although she was tired she kept studying.", "Although she was tired, she kept studying.", "Although, she was tired she kept studying.", "Although she was tired she kept, studying."]', 1),
    (1, 'language', 'Which sentence uses commas correctly?', '["I bought apples oranges and grapes at the market.", "I bought apples, oranges, and grapes at the market.", "I bought apples, oranges and, grapes at the market.", "I bought, apples, oranges, and grapes at the market."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["James please close the door.", "James please, close the door.", "James, please close the door.", "James please close, the door."]', 2),
    (1, 'language', 'Which sentence uses commas correctly with a compound sentence?', '["She finished her homework and then she watched TV.", "She finished her homework, and then she watched TV.", "She finished her homework and, then she watched TV.", "She finished her homework, and, then she watched TV."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["Running down the hall, the bell rang loudly.", "Running down the hall the student heard the bell.", "Running down the hall, the student heard the bell.", "Running down the hall the, student heard the bell."]', 2),
    (1, 'language', 'Which sentence uses commas correctly?', '["The results were however not what we expected.", "The results were, however not what we expected.", "The results were, however, not what we expected.", "The results were however, not what we expected."]', 2),
    (1, 'language', 'Which sentence uses the comma correctly?', '["She has three dogs a golden retriever a poodle and a beagle.", "She has three dogs, a golden retriever, a poodle, and a beagle.", "She has three dogs a golden retriever, a poodle, and a beagle.", "She has, three dogs a golden retriever a poodle and a beagle."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["The small, red car was parked outside.", "The small red, car was parked outside.", "The, small red car was parked outside.", "The small red car, was parked outside."]', 0),
    (1, 'language', 'Which sentence uses the comma correctly?', '["When it rains, I like to read indoors.", "When it rains I like to read, indoors.", "When, it rains I like to read indoors.", "When it rains I like, to read indoors."]', 0),
    (1, 'language', 'Which sentence uses the comma correctly?', '["He is, I believe a talented musician.", "He is I believe, a talented musician.", "He is, I believe, a talented musician.", "He is I believe a talented musician."]', 2),
    (1, 'language', 'Which sentence uses the comma correctly?', '["That is my dog Buddy the golden retriever.", "That is my dog, Buddy, the golden retriever.", "That is my dog Buddy, the golden retriever.", "That is my dog, Buddy the golden retriever."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["The teacher said that we should study every night.", "The teacher said, that we should study every night.", "The teacher, said that we should study every night.", "The teacher said that we should, study every night."]', 0),
    (1, 'language', 'Which sentence uses the comma correctly?', '["Students who study regularly tend to earn better grades.", "Students, who study regularly, tend to earn better grades.", "Students who, study regularly tend to earn better grades.", "Students who study, regularly tend to earn better grades."]', 0),
    (1, 'language', 'Which sentence uses commas correctly in a series of actions?', '["She walked into the room sat down and opened her book.", "She walked into the room, sat down, and opened her book.", "She walked, into the room, sat down and opened her book.", "She walked into the room sat, down, and opened her book."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["No I do not think that is a good idea.", "No, I do not think that is a good idea.", "No I, do not think that is a good idea.", "No I do not think, that is a good idea."]', 1),
    (1, 'language', 'Which sentence uses the comma correctly?', '["We drove through Dallas Texas and then headed north.", "We drove through Dallas, Texas, and then headed north.", "We drove through Dallas Texas, and then headed north.", "We drove through Dallas, Texas and then headed north."]', 1),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["Its time to leave for school.", "It''s time to leave for school.", "Its'' time to leave for school.", "It''ss time to leave for school."]', 1),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["The two boy''s bikes were stolen.", "The two boys bike''s were stolen.", "The two boys'' bikes were stolen.", "The two boys bikes'' were stolen."]', 2),
    (1, 'language', 'Which sentence uses the colon correctly?', '["She needed: eggs, milk, and flour.", "She needed eggs, milk: and flour.", "She needed eggs: milk and flour.", "She needed three things: eggs, milk, and flour."]', 3),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["The childrens'' playground was closed.", "The children''s playground was closed.", "The childrens playground was closed.", "The childrens''s playground was closed."]', 1),
    (1, 'language', 'Which sentence uses the semicolon correctly?', '["I enjoy hiking; but not in the rain.", "I enjoy hiking; however, I avoid muddy trails.", "I enjoy; hiking in the mountains.", "I enjoy hiking, however; I avoid muddy trails."]', 1),
    (1, 'language', 'Which sentence uses the colon correctly?', '["My three favorite sports are: soccer, basketball, and tennis.", "My three favorite sports: are soccer, basketball, and tennis.", "My three favorite sports are soccer, basketball: and tennis.", "My three favorite sports are soccer: basketball, and tennis."]', 0),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["That car is her''s.", "That car is hers''.", "That car is hers.", "That car is her''s''."]', 2),
    (1, 'language', 'Which sentence uses the semicolon correctly?', '["Marcus loves to cook; and he often bakes bread.", "Marcus loves to cook; in fact, he bakes his own bread.", "Marcus loves; to cook and bake bread.", "Marcus loves to; cook and bake bread."]', 1),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["Can''t you see I''m busy?", "Cant you see Im busy?", "Can''t you see Im busy?", "Cant you see I''m busy?"]', 0),
    (1, 'language', 'Which sentence uses the colon correctly?', '["The coach gave one piece of advice: practice daily.", "The coach gave: one piece of advice practice daily.", "The coach gave one piece of advice practice: daily.", "The coach: gave one piece of advice practice daily."]', 0),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["We''re going to the movies tonight.", "Were going to the movies tonight.", "We''r going to the movies tonight.", "We''re'' going to the movies tonight."]', 0),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["The boss''s office is on the third floor.", "The boss'' office is on the third floor.", "The bosses office is on the third floor.", "The bosses'' office is on the third floor."]', 0),
    (1, 'language', 'Which sentence uses the semicolon correctly?', '["The storm hit last night; causing widespread damage.", "The storm hit last night; the damage was widespread.", "The storm; hit last night causing widespread damage.", "The storm hit; last night causing widespread damage."]', 1),
    (1, 'language', 'Which sentence uses the colon correctly?', '["The reason is clear: she forgot to study.", "The reason: is clear she forgot to study.", "The reason is: clear she forgot to study.", "The reason is clear she: forgot to study."]', 0),
    (1, 'language', 'Which sentence uses the apostrophe correctly?', '["You''re shoes are untied.", "Your shoes are untied.", "Youre shoes are untied.", "Your'' shoes are untied."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The team are playing their best game.", "The team is playing its best game.", "The team is playing their best game.", "The team are playing its best game."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["He don''t know the answer.", "He doesn''t knows the answer.", "He doesn''t know the answer.", "He do not knows the answer."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She runs more faster than her brother.", "She runs fastest than her brother.", "She runs more fast than her brother.", "She runs faster than her brother."]', 3),
    (1, 'language', 'Choose the grammatically correct sentence.', '["I can''t hardly wait for the concert.", "I can''t wait hardly for the concert.", "I can hardly wait for the concert.", "I can''t hardly wait hardly for the concert."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The data shows that the experiment failed.", "The data show that the experiment failed.", "The data is showing that the experiment failed.", "The data were showing that the experiment failed."]', 1),
    (1, 'language', 'Choose the correctly written sentence.', '["Lay down and rest for a while.", "Lie down and rest for a while.", "Lay yourself down and rest for a while.", "Lays down and rest for a while."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Everyone have submitted their forms.", "Everyone has submitted their forms.", "Everyone have submitted his form.", "Everyone has submitted his or her forms."]', 1),
    (1, 'language', 'Choose the correctly written sentence.', '["I feel badly about missing the party.", "I feel bad about missing the party.", "I feel more bad about missing the party.", "I feel badder about missing the party."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Him and his friend went to the mall.", "He and his friend went to the mall.", "Him and his friend goed to the mall.", "He and his friend go to the mall yesterday."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The number of students are increasing.", "A number of students is signing up.", "The number of students is increasing.", "A number of students are is signing up."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She is more smarter than anyone in class.", "She is smarter than anyone else in class.", "She is the more smart than anyone in class.", "She is the most smartest in class."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Please give the package to whoever answers the door.", "Please give the package to whomever answers the door.", "Please give the package to who answers the door.", "Please give the package to whom answers the door."]', 0),
    (1, 'language', 'Choose the grammatically correct sentence.', '["They played good in the finals.", "They played goodly in the finals.", "They played well in the finals.", "They played more good in the finals."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["It was her who called last night.", "It was she who called last night.", "It was she whom called last night.", "It was her whom called last night."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The committee have reached their decision.", "The committee has reached their decision.", "The committee has reached its decision.", "The committee have reached its decision."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Neither of the answers are correct.", "Neither of the answers is correct.", "Neither answers are correct.", "Neither answers is correct."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["I use to wake up early every morning.", "I used to wake up early every morning.", "I use to waked up early every morning.", "I used to waking up early every morning."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Less students attended today than yesterday.", "Fewer students attend today than yesterday.", "Fewer students attended today than yesterday.", "Less students attend today than yesterday."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She is the tallest of the two sisters.", "She is the taller of the two sisters.", "She is more taller of the two sisters.", "She is tallest between the two sisters."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The coach talked to Maria and I after practice.", "The coach talked to Maria and me after practice.", "The coach talked to Maria and myself after practice.", "The coach talked to I and Maria after practice."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She looked at the mirror and combed her hairs.", "She looked at the mirror and combed her hair.", "She looked to the mirror and combed her hair.", "She looked the mirror and combed her hair."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Can you borrow me your pencil?", "Can you lend me your pencil?", "Can I lend your pencil?", "Can you borrow your pencil to me?"]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["I am taller then my father.", "I am more tall than my father.", "I am taller than my father.", "I am most taller than my father."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She don''t never miss practice.", "She doesn''t never miss practice.", "She never misses practice.", "She don''t miss never practice."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Its'' a beautiful morning outside.", "It''s a beautiful morning outside.", "It is'' a beautiful morning outside.", "Its a beautiful morning outside."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The principle of the school made an announcement.", "The principal of the school make an announcement.", "The principal of the school made an announcement.", "The principle of the school make an announcement."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She was laying on the couch all afternoon.", "She was lying on the couch all afternoon.", "She was lain on the couch all afternoon.", "She was lied on the couch all afternoon."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The affect of the medicine was immediate.", "The effect of the medicine was immediate.", "The effect of the medicine were immediate.", "The affect of the medicine were immediate."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["He could of won if he had practiced.", "He could have won if he had practiced.", "He could of win if he had practiced.", "He could''ve of won if he had practiced."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She types more quicker than anyone on the team.", "She types quicklier than anyone on the team.", "She types more quickly than anyone on the team.", "She types more quick than anyone on the team."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Between the three options, I like the first best.", "Among the three options, I like the first best.", "Among the three options, I like the first better.", "Between the three options, I like the first better."]', 1),
    (1, 'language', 'Which sentence best serves as a concluding sentence for a paragraph about recycling?', '["Plastics are a major source of pollution.", "Clearly, recycling plays a vital role in protecting our planet for future generations.", "Many people do not recycle at their workplaces.", "Glass can be recycled many times without losing quality."]', 1),
    (1, 'language', 'Which version best combines these two sentences: ''The movie was long. The movie was interesting.''?', '["The movie was long, interesting.", "Although the movie was long, it was interesting.", "The movie was long and interesting both.", "The movie was long it was interesting."]', 1),
    (1, 'language', 'Which sentence is a run-on?', '["The sun set; the stars appeared.", "The sun set, and the stars appeared.", "The sun set the stars appeared.", "After the sun set, the stars appeared."]', 2),
    (1, 'language', 'Which sentence is the most concise revision of ''Due to the fact that it was raining, we decided to postpone the game''?', '["Because it was raining we decided to postpone the game.", "Because it was raining, we postponed the game.", "It was raining, so we decided we would postpone the game at that time.", "We postponed the game, and the reason is that it was raining outside."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She is one of the students who has excelled.", "She is one of the students who have excelled.", "She is one of the students whom has excelled.", "She is one of the students whom have excelled."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Whomever arrives first should sign in.", "Whoever arrives first should sign in.", "Whomever arrives first should signs in.", "Who arrives first should sign in."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The committee approved the proposal that it deemed most worthy.", "The committee approved the proposal what it deemed most worthy.", "The committee approved the proposal which they deemed most worthy.", "The committee approved the proposal whom it deemed most worthy."]', 0),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Having finished the exam, the questions seemed easy.", "Having finished the exam, the students thought the questions were easy.", "The questions, having finished the exam, seemed easy.", "Having finished the exam and the questions seemed easy."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Neither the teacher nor the students was prepared.", "Neither the students nor the teacher was prepared.", "Neither the students nor the teacher were prepared.", "Neither the teacher nor the students is prepared."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The man who I spoke to was very helpful.", "The man to whom I spoke was very helpful.", "The man whom I spoke was very helpful.", "The man which I spoke to was very helpful."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Walking along the pier, the sunset was breathtaking.", "Walking along the pier, we found the sunset breathtaking.", "The sunset, walking along the pier, was breathtaking.", "We found the sunset breathtaking, walking along the pier."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["It is important that he attends the meeting.", "It is important that he attend the meeting.", "It is important that he attended the meeting.", "It is important that he attending the meeting."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["If I was you, I would apologize immediately.", "If I were you, I would apologize immediately.", "If I am you, I would apologize immediately.", "If I be you, I would apologize immediately."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The reason she succeeded is because she practiced.", "The reason she succeeded is that she practiced.", "The reason she succeeded is due to she practiced.", "The reason she succeeded is for she practiced."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Scarcely had the game begun when it started to rain.", "Scarcely had the game begun than it started to rain.", "Scarcely had the game begun and it started to rain.", "Scarcely had the game began when it started to rain."]', 0),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The winners were him and her.", "The winners were he and she.", "The winners was him and her.", "The winners was he and she."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She wants to quickly and accurately complete the form.", "She wants to complete the form quickly and accurately.", "She wants quickly and accurately to complete the form.", "Quickly and accurately, she wants to complete the form."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["I wish I would have studied harder for the test.", "I wish I had studied harder for the test.", "I wish I studied harder for the test.", "I wish I was studied harder for the test."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She is taller than me by three inches.", "She is taller than I by three inches.", "She is taller than myself by three inches.", "She is taller than I am by three inches."]', 3),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The news are disturbing.", "Mathematics are difficult.", "The news is disturbing.", "Physics are taught here."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Hardly no one came to the event.", "Scarcely anyone came to the event.", "Barely nobody came to the event.", "Almost no one didn''t come to the event."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["He is the kind of student who works hard and that gets results.", "He is the kind of student who works hard and who gets results.", "He is the kind of student which works hard and that gets results.", "He is the kind of student that works hard and which gets results."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She not only cleaned her room but also organized her closet.", "She not only cleaned her room but organized also her closet.", "She not only cleaned her room, but also she organized her closet.", "Not only she cleaned her room but also organized her closet."]', 0),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The professor, along with her students, are presenting today.", "The professor, along with her students, is presenting today.", "The professor along with her students is presenting today.", "The professor along with her students are presenting today."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["I resent him leaving without saying goodbye.", "I resent him leave without saying goodbye.", "I resent his leaving without saying goodbye.", "I resent his leave without saying goodbye."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Neither her talent nor her dedication have gone unnoticed.", "Neither her talent nor her dedication has gone unnoticed.", "Neither her talent or her dedication has gone unnoticed.", "Neither her talent or her dedication have gone unnoticed."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["To finish the project on time, extra shifts were worked by the team.", "To finish the project on time, the team worked extra shifts.", "The project, to finish on time, the team worked extra shifts.", "Extra shifts were worked to finish, the project on time, by the team."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["He speaks English fluent and writes it good.", "He speaks English fluently and writes it well.", "He speaks English fluently and writes it good.", "He speaks English fluent and writes it well."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The book that I was told about it is excellent.", "The book that I was told about is excellent.", "The book which I was told about it is excellent.", "The book about which I was told it is excellent."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["Irregardless of the outcome, we should try our best.", "Regardless of the outcome, we should try our best.", "Irregardless the outcome, we should try our best.", "Regardless the outcome, we should try our best."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She bought less groceries than planned.", "She bought fewer groceries than planned.", "She bought less grocery than planned.", "She bought fewer grocery than planned."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["You look as if you could use a rest.", "You look as though you could use a rest.", "Both A and B are correct.", "You look like you need a rest right now."]', 2),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The suspect insisted that he had laid in bed all morning.", "The suspect insisted that he had lain in bed all morning.", "The suspect insisted that he had lied in bed all morning.", "The suspect insisted that he had lay in bed all morning."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["I am anxious to start the new job next week.", "I am eager to start the new job next week.", "I am eager starting the new job next week.", "I am anxious starting the new job next week."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["The jury have reached their verdict.", "The jury has reached its verdict.", "The jury have reached its verdict.", "The jury has reached their verdict."]', 1),
    (1, 'language', 'Choose the grammatically correct sentence.', '["She is the smartest of all her siblings.", "She is the most smart of all her siblings.", "She is the smarter of all her siblings.", "She is more smarter than all her siblings."]', 0),
    (1, 'language', 'Which sentence uses the dash correctly?', '["She had only one dream — to become a doctor.", "She had — only one dream to become a doctor.", "She had only — one dream to become a doctor.", "She had only one — dream — to become a doctor."]', 0),
    (1, 'language', 'Which sentence uses the colon correctly?', '["He arrived late: and missed the opening act.", "The instructions were simple: read, write, and submit.", "The instructions: were simple to read write and submit.", "Read write and submit: were the simple instructions."]', 1),
    (1, 'language', 'Which sentence uses semicolons correctly in a complex list?', '["The guests were from Austin, Texas; Miami, Florida; and Portland, Oregon.", "The guests were from Austin Texas, Miami Florida, and Portland Oregon.", "The guests were from Austin, Texas, Miami, Florida, and Portland, Oregon.", "The guests were from Austin Texas; Miami Florida; Portland Oregon."]', 0),
    (1, 'language', 'Which sentence uses punctuation correctly with dialogue?', '["\"Where are you going?\" she asked.", "\"Where are you going\"? she asked.", "\"Where are you going?\" She asked.", "\"Where are you going\"? She asked."]', 0),
    (1, 'language', 'Which sentence uses the hyphen correctly?', '["She is a well known scientist.", "She is a well-known scientist.", "She is a well-known-scientist.", "She is a well known-scientist."]', 1),
    (1, 'language', 'Which sentence uses punctuation correctly with a quotation?', '["He said, \"I will be there by noon\".", "He said, \"I will be there by noon.\"", "He said \"I will be there by noon.\"", "He said, ''I will be there by noon.''"]', 1),
    (1, 'language', 'Which sentence uses parentheses correctly?', '["The president (who was elected in 2020), announced a new policy.", "The policy (announced in January) took effect immediately.", "The policy, (announced in January) took effect immediately.", "The policy took effect (immediately, in January)."]', 1),
    (1, 'language', 'Which sentence uses the ellipsis correctly to show a pause?', '["She paused and said, \"I... I don''t know what to say.\"", "She paused and said, \"I . . I don''t know what to say.\"", "She paused and said, \"I..I don''t know what to say.\"", "She paused and said, \"I .... I don''t know what to say.\""]', 0),
    (1, 'language', 'Which sentence best revises this fragment: ''Although the team practiced hard''?', '["Although the team practiced hard every day.", "Although the team practiced hard, they lost the championship.", "The team practiced hard, although.", "Although, the team practiced hard and lost."]', 1),
    (1, 'language', 'Which sentence has faulty parallel structure?', '["She enjoys reading, writing, and to paint.", "She enjoys reading, writing, and painting.", "She enjoys to read, to write, and to paint.", "She enjoys reading books, writing stories, and painting portraits."]', 0),
    (1, 'language', 'Which sentence has faulty parallel structure?', '["The manager told us to arrive early, work efficiently, and being professional.", "The manager told us to arrive early, work efficiently, and be professional.", "The manager told us to be early, efficient, and professional.", "The manager told us: arrive early, work efficiently, be professional."]', 0),
    (1, 'language', 'Which transition word best fills the blank? ''She studied all night; _____, she passed the exam.''', '["however", "consequently", "meanwhile", "nevertheless"]', 1),
    (1, 'language', 'Which sentence best corrects this run-on: ''I wanted to go to the game it was sold out''?', '["I wanted to go to the game, however it was sold out.", "I wanted to go to the game; it was sold out.", "I wanted to go, to the game, it was sold out.", "I wanted to go to the game and it was, sold out."]', 1),
    (1, 'language', 'Which revision of the following sentence is most concise? ''The reason why he left early was due to the fact that he was feeling sick.''', '["The reason he left early was because he felt sick.", "He left early because he was feeling sick.", "He left early due to the fact of his sickness.", "The reason why he left was that he was sick."]', 1),
    (1, 'language', 'Which sentence contains a misplaced modifier?', '["She only eats vegetables on Mondays.", "She eats only vegetables on Mondays.", "Only on Mondays does she eat vegetables.", "On Mondays, she eats only vegetables."]', 0),
    (1, 'language', 'Which sentence best serves as a topic sentence for a paragraph about the dangers of social media?', '["Millions of teenagers use social media every day.", "Some people post vacation photos online.", "While social media connects people, its unchecked use poses significant risks to adolescent mental health.", "Social media companies make a lot of money from advertising."]', 2),
    (1, 'language', 'Which sentence best revises this wordy passage: ''At this point in time, it is absolutely necessary that all students make a decision about their future career plans''?', '["At this time, it is necessary for students to make a decision about careers.", "Now, all students must decide on a career.", "Students are required to make necessary decisions about careers at this point.", "It is now absolutely necessary that all students decide on a future career plan."]', 1),
    (1, 'language', 'Which sentence contains a comma splice?', '["She ran the race, and she won.", "She ran the race; she won.", "She ran the race, she won.", "She ran the race — and she won."]', 2),
    (1, 'language', 'Which revision best improves this sentence? "She was absent due to the fact that she was ill."', '["She was absent, due to the fact that, she was ill.", "She was absent because she was ill.", "Due to the fact that she was ill, she was absent.", "She was absent, due to her illness, which she had."]', 1),
    (1, 'language', 'Which revision best improves this sentence? "At this point in time, we are unable to make a decision."', '["At this point in time now, we are unable to decide.", "Currently, we are unable to make a decision.", "At this point, in time, we cannot make a decision.", "At this point in time, a decision cannot be made by us."]', 1),
    (1, 'language', 'Which revision best improves this sentence? "In spite of the fact that it rained, the game continued."', '["In spite of the fact that it rained, the game went on continuing.", "Despite it rained, the game continued.", "Although it rained, the game continued.", "In spite of the rain fact, the game continued."]', 2),
    (1, 'language', 'Which revision best improves this sentence? "The reason why she failed is because she did not study."', '["The reason why she failed is that she did not study.", "She failed is because she did not study.", "She failed because she did not study.", "The reason she failed is due to the fact that she did not study."]', 2),
    (1, 'language', 'Which revision best improves this sentence? "We need to review each and every application carefully."', '["We need to review every each application carefully.", "We need to carefully review each application.", "Each and every application must be reviewed by us carefully.", "We need to review each and every application with care and attention."]', 1),
    (1, 'language', 'Sentences 1–4 appear in scrambled order. Which arrangement makes the most logical paragraph? 1. Attach the roof pieces at an angle so rainwater runs off. 2. Gather your wood, nails, and a hammer before you begin. 3. Finally, hang the finished birdhouse from a tree branch at least six feet off the ground. 4. Nail the four walls together, making sure the front piece has a small round entrance hole.', '["1, 2, 3, 4", "2, 4, 1, 3", "3, 1, 4, 2", "4, 2, 1, 3"]', 1),
    (1, 'language', 'Sentences 1–4 appear in scrambled order. Which arrangement makes the most logical paragraph? 1. This gravitational pull causes water on the side of Earth nearest the Moon to bulge outward. 2. Because of Earth''s rotation, most coastal locations experience two high tides and two low tides each day. 3. Tides are the periodic rise and fall of sea levels caused mainly by the Moon''s gravity. 4. At the same time, the opposite side of Earth bulges outward due to inertia, creating a second high tide.', '["1, 3, 4, 2", "3, 4, 1, 2", "3, 1, 4, 2", "2, 3, 1, 4"]', 2),
    (1, 'language', 'Sentences 1–4 appear in scrambled order. Which arrangement makes the most logical paragraph? 1. Next, identify expenses you can reduce, such as dining out or subscription services. 2. With consistent effort, even small savings add up to a significant amount over time. 3. The first step to saving money is tracking exactly how much you spend each month. 4. Once you have cut costs, deposit the extra money into a dedicated savings account each payday.', '["1, 3, 2, 4", "3, 2, 1, 4", "2, 4, 3, 1", "3, 1, 4, 2"]', 3),
    (1, 'language', 'Sentences 1–4 appear in scrambled order. Which arrangement makes the most logical paragraph? 1. Over centuries, it was extended and reinforced by successive dynasties, eventually stretching thousands of miles. 2. However, historians now believe it was never a single continuous wall but a series of connected fortifications. 3. The Great Wall of China was originally constructed to defend Chinese territory against northern invasions. 4. Despite its fame, the wall was not always effective — raiders frequently found ways around or through it.', '["3, 1, 2, 4", "1, 3, 4, 2", "3, 2, 4, 1", "2, 3, 1, 4"]', 0),
    (1, 'language', 'Sentences 1–4 appear in scrambled order. Which arrangement makes the most logical paragraph? 1. As warm, moist air rises, it cools, causing water vapor to condense into clouds. 2. Water on Earth''s surface evaporates when heated by the sun, turning from liquid into vapor. 3. This cycle of evaporation, condensation, and precipitation keeps Earth''s water supply constantly moving. 4. When enough water collects in clouds, it falls back to Earth as rain, snow, or sleet.', '["1, 4, 2, 3", "2, 1, 4, 3", "3, 2, 1, 4", "4, 1, 2, 3"]', 1),
    (1, 'language', 'Which transition word or phrase best completes this sentence? "Mia trained for months; _____, she qualified for the state championship."', '["however", "nevertheless", "consequently", "in contrast"]', 2),
    (1, 'language', 'Which transition word or phrase best completes this sentence? "The original data appeared flawed; _____, the team collected new samples before publishing."', '["consequently", "however", "in addition", "meanwhile"]', 0),
    (1, 'language', 'Which transition word or phrase best completes this sentence? "The candidate had strong qualifications; _____, she had never managed a team of more than five people."', '["therefore", "furthermore", "however", "in addition"]', 2),
    (1, 'language', 'Which transition word or phrase best completes this sentence? "Regular exercise improves cardiovascular health; _____, it reduces the risk of type 2 diabetes."', '["nevertheless", "moreover", "although", "consequently"]', 1),
    (1, 'language', 'Which transition word or phrase best completes this sentence? "_____ the weather forecast predicted clear skies, the hiking group packed rain gear just in case."', '["Therefore", "Furthermore", "Although", "As a result"]', 2),
    (2, 'verbal', 'All cats are animals. All animals need food. All cats need food — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'No reptiles are warm-blooded. Some egg-layers are warm-blooded. Some egg-layers are reptiles — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 2),
    (2, 'verbal', 'All birds have wings. A penguin is a bird. A penguin has wings — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 0),
    (2, 'verbal', 'All squares are rectangles. Shape X is a square. Shape X is a rectangle — true, false, or uncertain?', '["True", "False", "Uncertain", "Maybe"]', 0),
    (2, 'verbal', 'No fish can climb trees. Goldie is a fish. Goldie can climb trees — true, false, or uncertain?', '["True", "False", "Uncertain", "Maybe"]', 1),
    (2, 'verbal', 'All dogs bark. Rex is a dog. Rex barks — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'Some students like math. Maria is a student. Maria likes math — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 2),
    (2, 'verbal', 'All roses are flowers. All flowers need water. All roses need water — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 0),
    (2, 'verbal', 'All mammals are warm-blooded. Whales are mammals. Whales are warm-blooded — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'No vegetables are sweet. Carrots are vegetables. Carrots are not sweet — true, false, or uncertain?', '["True", "False", "Uncertain", "Depends"]', 0),
    (2, 'verbal', 'All athletes exercise daily. Some students are athletes. Some students exercise daily — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 0),
    (2, 'verbal', 'All planets orbit a star. Some moons orbit planets. Some moons orbit stars — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 2),
    (2, 'verbal', 'No honest person lies. Jordan is honest. Jordan does not lie — true, false, or uncertain?', '["True", "False", "Uncertain", "Maybe"]', 0),
    (2, 'verbal', 'Some painters are left-handed. All left-handed people write with their left hand. Some painters write with their left hand — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'All chefs can cook. Some chefs cannot bake. Some people who can cook cannot bake — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 0),
    (2, 'verbal', 'All rivers flow to the sea. The Amazon is a river. The Amazon flows to the sea — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'Some doctors are scientists. All scientists publish research. Some doctors publish research — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 0),
    (2, 'verbal', 'No nocturnal animal is active during the day. Owls are nocturnal. Owls are not active during the day — true, false, or uncertain?', '["True", "False", "Uncertain", "Depends"]', 0),
    (2, 'verbal', 'All computers need electricity. Some tablets are computers. Some tablets need electricity — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'All virtuous acts are selfless. No selfish act is virtuous. Alex''s act was selfish. Alex''s act was virtuous — true, false, or uncertain?', '["True", "False", "Uncertain", "Impossible"]', 1),
    (2, 'verbal', 'All philosophers question assumptions. Some scientists question assumptions. Some scientists are philosophers — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 2),
    (2, 'verbal', 'No coward has ever been awarded the Medal of Honor. Captain Rivera was awarded the Medal of Honor. Captain Rivera is a coward — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 1),
    (2, 'verbal', 'All primary colors can mix to form secondary colors. Green is a secondary color. Green can be formed from primary colors — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 0),
    (2, 'verbal', 'Some poems rhyme. All haiku are poems. Some haiku rhyme — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 2),
    (2, 'verbal', 'No democracy allows one-person rule. Country X allows one-person rule. Country X is a democracy — true, false, or uncertain?', '["True", "False", "Uncertain", "Neither"]', 1),
    (2, 'quantitative', 'A number multiplied by 3 gives 21. What is the number?', '["6", "9", "7", "8"]', 2),
    (2, 'quantitative', 'Examine: (A) 3/4  vs.  (B) 7/10. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'What number comes next?  2, 3, 5, 8, 13, ___', '["18", "19", "21", "20"]', 2),
    (2, 'quantitative', 'Examine: (A) 5² − 3²  vs.  (B) (5−3)². Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'What number comes next?  1, 2, 3, 4, ___', '["5", "6", "7", "8"]', 0),
    (2, 'quantitative', 'What number comes next?  3, 6, 9, 12, ___', '["14", "15", "16", "18"]', 1),
    (2, 'quantitative', 'What number comes next?  20, 18, 16, 14, ___', '["10", "11", "12", "13"]', 2),
    (2, 'quantitative', 'What number comes next?  1, 3, 5, 7, ___', '["8", "9", "10", "11"]', 1),
    (2, 'quantitative', 'What number comes next?  4, 8, 12, 16, ___', '["18", "20", "22", "24"]', 1),
    (2, 'quantitative', 'What number comes next?  1, 1, 2, 3, ___', '["4", "5", "6", "7"]', 1),
    (2, 'quantitative', 'What number comes next?  9, 8, 7, 6, ___', '["4", "5", "3", "6"]', 1),
    (2, 'quantitative', 'What number comes next?  0, 2, 4, 6, ___', '["7", "8", "9", "10"]', 1),
    (2, 'quantitative', 'What number comes next?  1, 4, 7, 10, ___', '["11", "12", "13", "14"]', 2),
    (2, 'quantitative', 'A number is increased by 7 to give 15. What is the number?', '["6", "7", "8", "9"]', 2),
    (2, 'quantitative', 'A number is doubled to give 18. What is the number?', '["7", "8", "9", "10"]', 2),
    (2, 'quantitative', 'A number is reduced by 12 to give 8. What is the number?', '["18", "20", "22", "24"]', 1),
    (2, 'quantitative', 'A number multiplied by 6 gives 42. What is the number?', '["5", "6", "7", "8"]', 2),
    (2, 'quantitative', 'A number is tripled to give 27. What is the number?', '["7", "8", "9", "10"]', 2),
    (2, 'quantitative', 'A number plus 15 equals 30. What is the number?', '["12", "13", "14", "15"]', 3),
    (2, 'quantitative', 'A number multiplied by 4 gives 36. What is the number?', '["7", "8", "9", "10"]', 2),
    (2, 'quantitative', 'A number is decreased by 5 to give 11. What is the number?', '["14", "15", "16", "17"]', 2),
    (2, 'quantitative', 'A number multiplied by 8 gives 56. What is the number?', '["5", "6", "7", "8"]', 2),
    (2, 'quantitative', 'A number multiplied by 7 gives 49. What is the number?', '["5", "6", "7", "8"]', 2),
    (2, 'quantitative', 'Examine: (A) 1/2  vs.  (B) 1/3. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) 8 × 3  vs.  (B) 6 × 4. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) 15 − 6  vs.  (B) 4 + 5. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) 2/5  vs.  (B) 3/10. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) 20 ÷ 4  vs.  (B) 3 × 2. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 7 + 4  vs.  (B) 3 × 4. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 3/4  vs.  (B) 6/8. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a rectangle with length 6 and width 4. Shape B: a rectangle with length 5 and width 5. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a rectangle with length 8 and width 3. Shape B: a rectangle with length 6 and width 4. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a rectangle with length 5 and width 3. Shape B: a rectangle with length 4 and width 4. Which has the greater perimeter?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a rectangle with length 10 and width 2. Shape B: a rectangle with length 7 and width 3. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a square with side 4. Shape B: a rectangle with length 6 and width 3. Which has the greater perimeter?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a rectangle with length 9 and width 2. Shape B: a rectangle with length 3 and width 6. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'What number comes next?  1, 2, 4, 7, 11, ___', '["14", "15", "16", "18"]', 2),
    (2, 'quantitative', 'What number comes next?  2, 3, 5, 7, 11, ___', '["12", "13", "14", "15"]', 1),
    (2, 'quantitative', 'What number comes next?  5, 6, 8, 11, 15, ___', '["18", "19", "20", "21"]', 2),
    (2, 'quantitative', 'What number comes next?  2, 4, 6, 8, 10, ___', '["11", "12", "13", "14"]', 1),
    (2, 'quantitative', 'What number comes next?  0, 1, 3, 6, 10, ___', '["13", "14", "15", "16"]', 2),
    (2, 'quantitative', 'What number comes next?  2, 4, 3, 6, 5, 10, ___', '["7", "8", "9", "11"]', 2),
    (2, 'quantitative', 'A number is multiplied by 3, then 5 is subtracted, giving 19. What was the original number?', '["6", "7", "8", "9"]', 2),
    (2, 'quantitative', 'A number is increased by 4, then doubled, giving 22. What was the original number?', '["7", "8", "9", "11"]', 0),
    (2, 'quantitative', 'A number is halved, then 6 is added, giving 14. What was the original number?', '["14", "16", "18", "20"]', 1),
    (2, 'quantitative', 'A number is multiplied by 4, then divided by 2, giving 10. What was the original number?', '["3", "4", "5", "6"]', 2),
    (2, 'quantitative', 'A number is decreased by 8, then multiplied by 3, giving 21. What was the original number?', '["13", "14", "15", "16"]', 2),
    (2, 'quantitative', 'A number is multiplied by 5, then 10 is subtracted, giving 40. What was the original number?', '["8", "9", "10", "11"]', 2),
    (2, 'quantitative', 'A number is doubled, then 7 is added, giving 29. What was the original number?', '["10", "11", "12", "13"]', 1),
    (2, 'quantitative', 'A number is increased by 9, then divided by 4, giving 6. What was the original number?', '["13", "14", "15", "16"]', 2),
    (2, 'quantitative', 'A number is tripled, then 12 is subtracted, giving 24. What was the original number?', '["10", "11", "12", "13"]', 2),
    (2, 'quantitative', 'A number is decreased by 3, then multiplied by 7, giving 35. What was the original number?', '["7", "8", "9", "10"]', 1),
    (2, 'quantitative', 'A number is multiplied by 2, then divided by 8, giving 3. What was the original number?', '["10", "11", "12", "13"]', 2),
    (2, 'quantitative', 'A number is increased by 6, then halved, giving 11. What was the original number?', '["14", "15", "16", "17"]', 2),
    (2, 'quantitative', 'A number is multiplied by 6, then 6 is added, giving 42. What was the original number?', '["5", "6", "7", "8"]', 1),
    (2, 'quantitative', 'A number is multiplied by 9, then divided by 3, giving 21. What was the original number?', '["5", "6", "7", "8"]', 2),
    (2, 'quantitative', 'A number is increased by 11, then tripled, giving 48. What was the original number?', '["4", "5", "6", "7"]', 1),
    (2, 'quantitative', 'Examine: (A) 2³  vs.  (B) 3². Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 5 × 7  vs.  (B) 4 × 9. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 2/3  vs.  (B) 5/8. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) 7² − 4²  vs.  (B) (7−4)² × 5. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) √64  vs.  (B) 2³. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) 3/5 + 1/4  vs.  (B) 9/10. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 40% of 80  vs.  (B) 30% of 100. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) 6²  vs.  (B) 4³. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 25% of 60  vs.  (B) 20% of 75. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) 4/7  vs.  (B) 7/12. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 50% of 50  vs.  (B) 25% of 100. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) √36 + √16  vs.  (B) √100. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) 8 × 9  vs.  (B) 6 × 12. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) 3/8  vs.  (B) 2/5. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 10² ÷ 4  vs.  (B) 5 × 5. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a right triangle with legs 6 and 8. Shape B: a rectangle with length 5 and width 4. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a triangle with base 10 and height 6. Shape B: a rectangle with length 4 and width 8. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a rectangle with length 7 and width 6. Shape B: a triangle with base 12 and height 8. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a square with side 6. Shape B: a triangle with base 9 and height 8. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a rectangle with length 9 and width 4. Shape B: a rectangle with length 6 and width 6. Which has the greater perimeter?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a rectangle with length 12 and width 3. Shape B: a square with side 5. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a triangle with base 14 and height 6. Shape B: a square with side 6. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a rectangle with length 8 and width 5. Shape B: a triangle with base 16 and height 5. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a right triangle with legs 5 and 12. Shape B: a rectangle with length 4 and width 7. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a square with side 7. Shape B: a rectangle with length 11 and width 4. Which has the greater perimeter?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a rectangle with length 10 and width 6. Shape B: a triangle with base 20 and height 6. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Shape A: a square with side 8. Shape B: a rectangle with length 10 and width 6. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a triangle with base 10 and height 10. Shape B: a rectangle with length 4 and width 12. Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a rectangle with length 15 and width 2. Shape B: a square with side 5. Which has the greater perimeter?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'What number comes next?  1, 1, 2, 3, 5, 8, 13, ___', '["18", "19", "20", "21"]', 3),
    (2, 'quantitative', 'A number is multiplied by 4, then 8 is subtracted, then the result is divided by 2, giving 10. What was the original number?', '["5", "6", "7", "8"]', 2),
    (2, 'quantitative', 'A number is doubled, then 9 is subtracted, then the result is multiplied by 3, giving 21. What was the original number?', '["6", "7", "8", "9"]', 2),
    (2, 'quantitative', 'A number is multiplied by 2, then 7 is subtracted, then the result is divided by 3, giving 5. What was the original number?', '["10", "11", "12", "13"]', 1),
    (2, 'quantitative', 'A number is tripled, then 6 is added, then the result is halved, giving 15. What was the original number?', '["6", "7", "8", "9"]', 2),
    (2, 'quantitative', 'A number is increased by 10, then divided by 3, then multiplied by 2, giving 20. What was the original number?', '["18", "20", "22", "24"]', 1),
    (2, 'quantitative', 'Half of a number is increased by 6, then the result is tripled, giving 45. What was the original number?', '["14", "16", "18", "20"]', 2),
    (2, 'quantitative', 'A number is multiplied by 6, then 18 is subtracted, then the result is divided by 3, giving 8. What was the original number?', '["5", "6", "7", "8"]', 2),
    (2, 'quantitative', 'A number is increased by 3, then squared, then 5 is subtracted, giving 59. What was the original number?', '["5", "6", "7", "8"]', 0),
    (2, 'quantitative', 'Examine: (A) 3⁴  vs.  (B) 4³. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) √144 + √25  vs.  (B) √(144 + 25). Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) 2⁵ + 3²  vs.  (B) 6² − 2². Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) 75% of 120  vs.  (B) 80% of 110. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Examine: (A) (2/3)²  vs.  (B) 2/3 × 3/2 − 1/2. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Examine: (A) 5! ÷ 4!  vs.  (B) 6! ÷ 5! − 1. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 2),
    (2, 'quantitative', 'Examine: (A) √200  vs.  (B) 3√20. Which is greater?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a circle with radius 5. Shape B: a square with side 9. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a circle with radius 4. Shape B: a rectangle with length 12 and width 4. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a circle with radius 6. Shape B: a square with side 10. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a rectangle with length 2k and width k. Shape B: a square with side k+3 (assume k = 6). Which has the greater area?', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a circle with diameter 10. Shape B: a right triangle with legs 13 and 12. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a circle with radius 7. Shape B: a rectangle with length 16 and width 9. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a circle with radius 4. Shape B: a square with side 7. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a circle with radius 3. Shape B: a rectangle with length 9 and width 3. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'quantitative', 'Shape A: a circle with radius 5. Shape B: a rectangle with length 10 and width 8. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 1),
    (2, 'quantitative', 'Shape A: a circle with radius 2. Shape B: a rectangle with length 6 and width 2. Which has the greater area? (Use π ≈ 3.14)', '["A is greater", "B is greater", "Equal", "Cannot determine"]', 0),
    (2, 'math', 'What is the remainder when 47 is divided by 6?', '["4", "5", "6", "3"]', 1),
    (2, 'math', 'If 4x − 5 = 19, what is x?', '["5", "6", "7", "8"]', 1),
    (2, 'math', 'Evaluate: 3 + 4 × 2 − 1', '["10", "12", "13", "14"]', 0),
    (2, 'math', 'What is the GCF of 18 and 30?', '["3", "6", "9", "12"]', 1),
    (2, 'math', 'Find the mean of: 4, 8, 6, 10, 2.', '["5", "6", "7", "8"]', 1),
    (2, 'math', 'Find the median of: 3, 7, 2, 9, 5.', '["5", "7", "3", "9"]', 0),
    (2, 'math', 'If 3x + 7 = 22, what is x?', '["4", "5", "6", "7"]', 1),
    (2, 'math', 'If 2x − 3 = 9, what is x?', '["3", "4", "5", "6"]', 3),
    (2, 'math', 'If 5x + 2 = 3x + 10, what is x?', '["2", "3", "4", "5"]', 2),
    (2, 'math', 'If 7 − 2x = 1, what is x?', '["2", "3", "4", "5"]', 1),
    (2, 'math', 'If 2(x + 3) = 14, what is x?', '["4", "5", "6", "7"]', 0),
    (2, 'math', 'If 9x − 4 = 5x + 8, what is x?', '["2", "3", "4", "5"]', 1),
    (2, 'math', 'If x + y = 10 and x − y = 4, what is x?', '["3", "5", "7", "9"]', 2),
    (2, 'math', 'If 2x + y = 11 and x = 3, what is y?', '["3", "4", "5", "6"]', 2),
    (2, 'math', 'If 3x + 2y = 16 and y = 2, what is x?', '["3", "4", "5", "6"]', 1),
    (2, 'math', 'Solve for x: 6 − x = 2x − 3.', '["2", "3", "4", "5"]', 1),
    (2, 'math', 'If 5(x − 2) = 15, what is x?', '["3", "4", "5", "7"]', 2),
    (2, 'math', 'If 2x + 3y = 18 and x = 3, what is y?', '["3", "4", "5", "6"]', 1),
    (2, 'math', 'If n − 8 > 5, which value of n is a solution?', '["12", "13", "14", "10"]', 2),
    (2, 'math', 'Solve the system: x + y = 8 and x − y = 2. What is y?', '["2", "3", "4", "5"]', 1),
    (2, 'math', 'If 4(2x − 1) = 28, what is x?', '["3", "4", "5", "6"]', 1),
    (2, 'math', 'A number multiplied by 6 then decreased by 5 equals 31. What is the number?', '["5", "6", "7", "8"]', 1),
    (2, 'math', 'Solve for x: x² = 49.', '["6", "7", "8", "9"]', 1),
    (2, 'math', 'If 2x + 5 > 13, which value of x satisfies the inequality?', '["3", "4", "5", "2"]', 2),
    (2, 'math', 'A circle has circumference 18.84. What is its diameter? (Use π ≈ 3.14)', '["3", "6", "9", "12"]', 1),
    (2, 'math', 'A rectangle has area 72 and length 9. What is the width?', '["6", "7", "8", "9"]', 2),
    (2, 'math', 'A box holds 24 apples. How many boxes are needed to hold 180 apples?', '["6", "7", "8", "9"]', 2),
    (2, 'math', 'A car uses 1 gallon of gas every 30 miles. How many gallons are needed for a 210-mile trip?', '["5", "6", "7", "8"]', 2),
    (2, 'math', 'Evaluate: 2 + 3 × (4² − 6) ÷ 5', '["6", "7", "8", "9"]', 2),
    (2, 'math', 'Solve the system: 3x + 2y = 20 and x − y = 5. What is x?', '["5", "6", "7", "8"]', 1),
    (2, 'math', 'Solve the system: x + 2y = 11 and 3x − y = 5. What is y?', '["2", "3", "4", "5"]', 2),
    (2, 'math', 'Solve the system: 3x + 2y = 18 and x − y = 1. What is x?', '["3", "4", "5", "6"]', 1),
    (2, 'math', 'Solve the system: 2x − y = 3 and x + 2y = 14. What is y?', '["4", "5", "6", "7"]', 1),
    (2, 'math', 'Two angles of a triangle are 48° and 67°. What is the exterior angle at the third vertex?', '["65°", "90°", "115°", "180°"]', 2),
    (2, 'math', 'Two parallel lines are cut by a transversal. One co-interior angle is 65°. What is the other co-interior angle?', '["65°", "90°", "115°", "180°"]', 2),
    (2, 'math', 'What is the distance between the points (1, 1) and (4, 5)?', '["3", "4", "5", "7"]', 2),
    (2, 'language', 'Read the following paragraph. Which sentence does NOT belong? (1) Honeybees live in highly organized colonies that can contain up to 60,000 workers. (2) Each worker bee has a specific role — some gather nectar, others protect the hive, and some feed the young. (3) Wasps, unlike bees, do not produce honey and can sting multiple times. (4) The queen bee''s sole function is to lay eggs, sometimes thousands per day.', '["Sentence 1", "Sentence 2", "Sentence 3", "Sentence 4"]', 2),
    (2, 'language', 'Read the following paragraph. Which sentence does NOT belong? (1) Thomas Edison held over a thousand patents, making him one of the most prolific inventors in history. (2) His invention of the phonograph allowed recorded sound to be played back for the first time. (3) Alexander Graham Bell, Edison''s contemporary, invented the telephone in 1876. (4) Edison also developed a practical electric light bulb and systems to distribute electricity to homes.', '["Sentence 1", "Sentence 2", "Sentence 3", "Sentence 4"]', 2),
    (2, 'language', 'Read the following paragraph. Which sentence does NOT belong? (1) Photosynthesis is the process by which plants use sunlight to convert carbon dioxide and water into glucose. (2) This glucose provides plants with the energy they need to grow, flower, and reproduce. (3) Most plants grow better in well-drained soil with a neutral pH level. (4) As a byproduct of photosynthesis, plants release oxygen, which animals and humans need to breathe.', '["Sentence 1", "Sentence 2", "Sentence 3", "Sentence 4"]', 2),
    (2, 'language', 'Read the following paragraph. Which sentence does NOT belong? (1) The Amazon rainforest covers over 5.5 million square kilometers and is home to extraordinary biodiversity. (2) Scientists estimate that one in ten known species on Earth lives in the Amazon. (3) The Congo Basin in Africa is the world''s second-largest tropical rainforest. (4) Deforestation threatens this biodiversity, as thousands of acres of Amazon forest are lost each year.', '["Sentence 1", "Sentence 2", "Sentence 3", "Sentence 4"]', 2),
    (2, 'language', 'Read the following paragraph. Which sentence does NOT belong? (1) The immune system is the body''s defense network against viruses, bacteria, and other harmful invaders. (2) White blood cells identify foreign substances and launch attacks to neutralize them. (3) The digestive system processes food into nutrients the body can absorb. (4) After an infection, the immune system retains a memory of the invader, making future responses faster.', '["Sentence 1", "Sentence 2", "Sentence 3", "Sentence 4"]', 2);


-- ── 2. Match snapshot rows to live question ids ──────────────────────────────
--
-- Two passes, both requiring the match to be unambiguous on BOTH sides — a
-- wrong match would show a student text they never saw, which is the exact
-- bug being fixed, so no match is always preferred to a doubtful one.
--
-- The join deliberately misses questions whose option CONTENT 018 rewrote
-- (~39 rows): their sorted options no longer agree, the choices the student
-- saw no longer exist, and no honest text is recoverable. Those answers are
-- left untouched and the review UI keeps suppressing their option text.

CREATE TEMP TABLE _qmap (
  question_id       UUID PRIMARY KEY,
  old_options       JSONB,
  old_correct_index INT
) ON COMMIT DROP;

CREATE TEMP TABLE _live ON COMMIT DROP AS
SELECT
  q.id,
  q.section,
  q.prompt,
  (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(q.options) v) AS opt_sig
FROM questions q
WHERE jsonb_typeof(q.options) = 'array';

CREATE TEMP TABLE _snap ON COMMIT DROP AS
SELECT
  s.tier,
  s.section,
  s.prompt,
  s.old_options,
  s.old_correct_index,
  (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(s.old_options) v) AS opt_sig
FROM _snapshot s;

-- Pass 1 — option set alone is unique on both sides. Prompt-independent, so
-- it still matches the rows whose prompt 018 rewrote.
INSERT INTO _qmap (question_id, old_options, old_correct_index)
SELECT lu.id, su.old_options, su.old_correct_index
FROM (
  SELECT id, section, opt_sig
  FROM (SELECT l.*, COUNT(*) OVER (PARTITION BY section, opt_sig) AS n FROM _live l) x
  WHERE n = 1
) lu
JOIN (
  SELECT section, old_options, old_correct_index, opt_sig
  FROM (SELECT s.*, COUNT(*) OVER (PARTITION BY section, opt_sig) AS n FROM _snap s) y
  WHERE n = 1 AND tier = 1
) su
  ON su.section = lu.section
 AND su.opt_sig = lu.opt_sig
ON CONFLICT (question_id) DO NOTHING;

-- Pass 2 — option set repeats within the section, so the prompt disambiguates.
-- Requires (section, prompt, option set) to be unique on both sides.
INSERT INTO _qmap (question_id, old_options, old_correct_index)
SELECT lu.id, su.old_options, su.old_correct_index
FROM (
  SELECT id, section, prompt, opt_sig
  FROM (
    SELECT l.*, COUNT(*) OVER (PARTITION BY section, prompt, opt_sig) AS n FROM _live l
  ) x
  WHERE n = 1
) lu
JOIN (
  SELECT section, prompt, old_options, old_correct_index, opt_sig
  FROM (
    SELECT s.*, COUNT(*) OVER (PARTITION BY section, prompt, opt_sig) AS n FROM _snap s
  ) y
  WHERE n = 1 AND tier = 2
) su
  ON su.section = lu.section
 AND su.prompt  = lu.prompt
 AND su.opt_sig = lu.opt_sig
WHERE NOT EXISTS (SELECT 1 FROM _qmap m WHERE m.question_id = lu.id)
ON CONFLICT (question_id) DO NOTHING;


-- ── 3. Decide which option order each attempt was recorded against ───────────
--
-- Attempts taken AFTER the shuffle store indices in today's order; resolving
-- those against the pre-019 snapshot would write the very error this
-- migration exists to remove. The two eras must therefore be told apart — and
-- that is done FROM THE DATA, never from a clock. Nothing inside the database
-- records when 019 was actually applied by hand, and a guessed cutoff would
-- mislabel attempts silently, in exactly the direction that corrupts them.
--
-- The signal is `correct_index`, which is stored ON the answer and so
-- describes the same ordering as the `selected_index` beside it:
--
--   * if ANY element disagrees with its question's CURRENT correct_index,
--     the ordering has changed since — the attempt is PRE-shuffle
--   * if EVERY element agrees, the attempt is treated as POST-shuffle
--
-- An attempt is a single point in time, so the verdict is per ATTEMPT and all
-- its elements share it.
--
-- A pre-shuffle attempt is misread only if every one of its questions kept
-- its correct_index through a random shuffle — (1/4)^n, about one in a
-- million for a 10-question quiz. Even then the output stays correct: a
-- question whose key did not move is one whose stored index resolves to the
-- same text in either order. Section 5 makes that guarantee unconditional.

CREATE TEMP TABLE _attempt_era ON COMMIT DROP AS
SELECT
  a.id,
  COALESCE(bool_or(
    idx.cor IS NOT NULL
    AND cq.correct_index IS NOT NULL
    AND idx.cor <> cq.correct_index
  ), FALSE) AS pre_shuffle
FROM quiz_attempts a
CROSS JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(a.answers) = 'array' THEN a.answers ELSE '[]'::JSONB END
) AS e(elem)
LEFT JOIN LATERAL (
  SELECT CASE WHEN e.elem ->> 'correct_index' ~ '^-?[0-9]+$'
              THEN (e.elem ->> 'correct_index')::INT END AS cor
) idx ON TRUE
-- Compared as lowercase text so a malformed id can never reach a UUID cast.
LEFT JOIN questions cq
  ON cq.id::TEXT = lower(e.elem ->> 'question_id')
GROUP BY a.id;


-- ── 4. Record the pre-update shape, so the rewrite can be proved lossless ────
--
-- Per attempt: how many answer elements it holds, and how many keys those
-- elements carry in total. Section 6 re-measures and compares. This catches a
-- rebuild that dropped an element or a key without assuming anything about
-- what legacy answers happen to contain.

CREATE TEMP TABLE _before ON COMMIT DROP AS
SELECT
  a.id,
  COUNT(e.elem)                                                      AS n_elems,
  COALESCE(SUM((SELECT COUNT(*) FROM jsonb_object_keys(e.elem))), 0) AS n_keys
FROM quiz_attempts a
LEFT JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(a.answers) = 'array' THEN a.answers ELSE '[]'::JSONB END
) AS e(elem) ON TRUE
GROUP BY a.id;


-- ── 5. Rewrite the answers ───────────────────────────────────────────────────
--
-- Every element is rebuilt in place with WITH ORDINALITY preserving array
-- order, and merged with `||` so no existing key is lost.
--
-- SELF-VALIDATING WRITE. The era decided in section 3 selects a candidate
-- order, but the write does not trust it: the element's own stored
-- `correct_index` must EQUAL the correct_index belonging to that order. If the
-- two disagree they are describing different orderings, and the element is
-- left untouched rather than stamped with a guess. A misclassification
-- therefore cannot become wrong text — the worst it can do is decline to
-- recover some.
--
-- An element is left BYTE-IDENTICAL when:
--   * it already carries both text keys (idempotent re-run)
--   * `question_id` is absent or not a UUID (legacy ids like 'bio-q1' exist)
--   * the question could not be matched, or its row is gone
--   * either stored index is missing, non-numeric, or out of range
--   * the stored correct_index contradicts the chosen order
-- The review UI already suppresses option text for exactly these answers and
-- shows the student an explanatory note, so nothing regresses.
--
-- `selected_index = -1` means the student ran out of time; that is a real
-- state, not a bad index, and yields a JSON null `selected_text`.

UPDATE quiz_attempts qa
SET answers = rebuilt.answers
FROM (
  SELECT
    a.id,
    jsonb_agg(
      CASE
        WHEN jsonb_exists(e.elem, 'selected_text')
         AND jsonb_exists(e.elem, 'correct_text')                     THEN e.elem
        WHEN src.opts IS NULL OR src.key IS NULL                      THEN e.elem
        WHEN idx.sel IS NULL OR idx.cor IS NULL                       THEN e.elem
        -- the write validates itself against the order it chose
        WHEN idx.cor <> src.key                                       THEN e.elem
        WHEN src.key < 0 OR src.key >= jsonb_array_length(src.opts)   THEN e.elem
        WHEN idx.sel <> -1
         AND (idx.sel < 0 OR idx.sel >= jsonb_array_length(src.opts)) THEN e.elem
        ELSE e.elem || jsonb_build_object(
               'selected_text',
               CASE WHEN idx.sel = -1 THEN 'null'::JSONB ELSE src.opts -> idx.sel END,
               'correct_text',
               src.opts -> idx.cor
             )
      END
      ORDER BY e.ord
    ) AS answers
  FROM quiz_attempts a
  JOIN _attempt_era era ON era.id = a.id
  CROSS JOIN LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(a.answers) = 'array' THEN a.answers ELSE '[]'::JSONB END
  ) WITH ORDINALITY AS e(elem, ord)
  -- Stored indices are text in JSON; a non-numeric value yields NULL, not an error.
  LEFT JOIN LATERAL (
    SELECT
      CASE WHEN e.elem ->> 'selected_index' ~ '^-?[0-9]+$'
           THEN (e.elem ->> 'selected_index')::INT END AS sel,
      CASE WHEN e.elem ->> 'correct_index'  ~ '^-?[0-9]+$'
           THEN (e.elem ->> 'correct_index')::INT END  AS cor
  ) idx ON TRUE
  LEFT JOIN _qmap m
    ON m.question_id::TEXT = lower(e.elem ->> 'question_id')
  LEFT JOIN questions cq
    ON cq.id::TEXT = lower(e.elem ->> 'question_id')
   AND jsonb_typeof(cq.options) = 'array'
  LEFT JOIN LATERAL (
    SELECT
      CASE WHEN era.pre_shuffle THEN m.old_options       ELSE cq.options       END AS opts,
      CASE WHEN era.pre_shuffle THEN m.old_correct_index ELSE cq.correct_index END AS key
  ) src ON TRUE
  GROUP BY a.id
) rebuilt
WHERE qa.id = rebuilt.id
  AND qa.answers IS DISTINCT FROM rebuilt.answers;


-- ── 6. Safety net ────────────────────────────────────────────────────────────
--
-- Losing an answer element or a key would silently corrupt every affected
-- student's history, so fail loudly and roll the whole thing back instead.
-- The rewrite may only ADD keys (two per eligible element) and must never
-- change how many elements an attempt holds.

DO $$
DECLARE bad INT;
BEGIN
  SELECT COUNT(*) INTO bad
  FROM quiz_attempts
  WHERE answers IS NOT NULL
    AND jsonb_typeof(answers) NOT IN ('array', 'null');

  IF bad > 0 THEN
    RAISE EXCEPTION '% attempts no longer hold a JSON array — rolled back', bad;
  END IF;

  WITH after AS (
    SELECT
      a.id,
      COUNT(e.elem)                                                      AS n_elems,
      COALESCE(SUM((SELECT COUNT(*) FROM jsonb_object_keys(e.elem))), 0) AS n_keys
    FROM quiz_attempts a
    LEFT JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(a.answers) = 'array' THEN a.answers ELSE '[]'::JSONB END
    ) AS e(elem) ON TRUE
    GROUP BY a.id
  )
  SELECT COUNT(*) INTO bad
  FROM _before b
  JOIN after f ON f.id = b.id
  WHERE f.n_elems <> b.n_elems
     OR f.n_keys  <  b.n_keys;

  IF bad > 0 THEN
    RAISE EXCEPTION '% attempts lost an answer element or a key — rolled back', bad;
  END IF;

  SELECT COUNT(*) INTO bad FROM _before b
  WHERE NOT EXISTS (SELECT 1 FROM quiz_attempts a WHERE a.id = b.id);

  IF bad > 0 THEN
    RAISE EXCEPTION '% attempts disappeared — rolled back', bad;
  END IF;
END $$;

COMMIT;


-- ── Verification ─────────────────────────────────────────────────────────────
-- How many stored answers now carry recoverable text, and how many remain
-- suppressed (018 rewrote their choices, or the stored index contradicted the
-- order chosen). The UI shows an explanatory note for the remainder.

SELECT
  COUNT(*)                                                          AS answer_elements,
  COUNT(*) FILTER (WHERE jsonb_exists(elem, 'correct_text'))        AS with_text,
  COUNT(*) FILTER (WHERE NOT jsonb_exists(elem, 'correct_text'))    AS unrecoverable,
  ROUND(100.0 * COUNT(*) FILTER (WHERE jsonb_exists(elem, 'correct_text'))
        / NULLIF(COUNT(*), 0))                                      AS pct_recovered
FROM quiz_attempts a
CROSS JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(a.answers) = 'array' THEN a.answers ELSE '[]'::JSONB END
) AS e(elem);
