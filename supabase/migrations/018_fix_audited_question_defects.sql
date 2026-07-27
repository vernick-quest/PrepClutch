-- 018 — Fix defects found by the question-bank audit
--
-- Every finding marked `critical` (18) plus the `major` findings whose fix is
-- unambiguous (a distractor that is genuinely also correct, or a keyed answer that
-- is genuinely wrong). Style-preference and bank-wide-rebalance findings, and all
-- `minor` findings, are deliberately left alone.
--
-- SCORING SAFETY: Clutch Points are earned per mastered question and scale with
-- `difficulty`, joined to `questions.id`. This migration assigns only to
-- prompt / options / correct_index / explanation / passage, plus one upward
-- `difficulty` correction (language #101, 2 -> 3, which can only add points).
-- It never writes `section` or `id`, contains no DELETE / DROP, and does not touch
-- `user_question_history` at all: a student who was told the old (wrong) key was
-- correct keeps that mastery and those points. Findings that would require deleting
-- a row or moving it between sections are DEFERRED, not applied:
--   * math #138 (5^100 mod 4, "above HSPT scope")      — kept, difficulty 3 is right
--   * verbal #172, #174 (undergraduate-level classification) — kept, not retired
--   * quantitative #9 ("belongs in the math section")   — kept in quantitative
--
-- Rows are matched on (section, prompt), plus the exact pre-migration options array
-- wherever that prompt text repeats inside its section, so each statement touches
-- exactly one row. Re-running this migration is a no-op: the WHERE clauses no longer
-- match once the fix is applied.

BEGIN;

-- ==========================================================================
-- MATHEMATICS
-- ==========================================================================

-- [math #170] CRITICAL wrong key: 2/7 ÷ 4/21 = 2/7 × 21/4 = 42/28 = 3/2, not 3 — students who computed 3/2 were marked wrong
UPDATE questions SET
  correct_index = 0,
  explanation   = '2/7 ÷ 4/21 = 2/7 × 21/4 = 42/28 = 3/2.'
  WHERE section = 'math'
    AND prompt = 'What is 2/7 ÷ 4/21?';

-- [math #33] CRITICAL ambiguous: '6/12', '1/2' and '2/4' were all the same value (1/2); only the reduced form was keyed
UPDATE questions SET
  options       = '["5/7", "1/3", "1/2", "2/3"]'::JSONB,
  correct_index = 2,
  explanation   = '(2 × 3)/(3 × 4) = 6/12 = 1/2.'
  WHERE section = 'math'
    AND prompt = 'What is 2/3 × 3/4?';

-- [math #112] CRITICAL ambiguous: distractor '2/12' equalled the keyed '1/6'; replaced with 1/12 (dividing 1/3, not 2/3, by 4)
UPDATE questions SET
  options       = '["1/4", "1/6", "1/12", "8/3"]'::JSONB,
  correct_index = 1,
  explanation   = '2/3 ÷ 4 = 2/3 × 1/4 = 2/12 = 1/6.'
  WHERE section = 'math'
    AND prompt = 'What is 2/3 ÷ 4?';

-- [math #114] CRITICAL ambiguous: distractor '9/6' equalled the keyed '3/2'; replaced with 11/6 (from rewriting 2/3 as 6/6)
UPDATE questions SET
  options       = '["7/9", "7/6", "3/2", "11/6"]'::JSONB,
  correct_index = 2,
  explanation   = '2/3 = 4/6; 5/6 + 4/6 = 9/6 = 3/2.'
  WHERE section = 'math'
    AND prompt = 'What is 5/6 + 2/3?';

-- [math #100] CRITICAL ambiguous: 10/15 = 66.7% but both '66%' (keyed) and '67%' were offered — same value split by a rounding choice
UPDATE questions SET
  options       = '["40%", "50%", "66 2/3%", "75%"]'::JSONB,
  correct_index = 2,
  explanation   = 'Profit = $25 − $15 = $10 on a cost of $15; 10/15 × 100 = 66 2/3%.'
  WHERE section = 'math'
    AND prompt = 'A store buys shirts for $15 each and sells them for $25 each. What is the percent profit?';

-- [math #26] MAJOR: distractors '2/6' and '1/3' were the same value; '2/6' replaced with 1/2 (a student who adds only the halves)
UPDATE questions SET
  options       = '["1/6", "1/3", "3/4", "1/2"]'::JSONB,
  correct_index = 2,
  explanation   = '1/2 = 2/4; 2/4 + 1/4 = 3/4.'
  WHERE section = 'math'
    AND prompt = 'What is 1/2 + 1/4?';

-- [math #27] MAJOR: distractor '15/20' equalled the keyed '3/4'; replaced with 4/5 (a plausible 0.75 → 4/5 slip)
UPDATE questions SET
  options       = '["7/10", "3/4", "75/10", "4/5"]'::JSONB,
  correct_index = 1,
  explanation   = '0.75 = 75/100 = 3/4.'
  WHERE section = 'math'
    AND prompt = 'What is 0.75 expressed as a fraction in lowest terms?';

-- ==========================================================================
-- QUANTITATIVE
-- ==========================================================================

-- [quantitative #78] CRITICAL multiple rules: 2, 4, 3, 6, 5, 10 also fits an interleaved prime/double reading (→7) and a +1,+2,+3 reading (→8), both offered as options; series rebased so only the ×2, −1 alternation fits, and the leaked drafting note removed from the explanation
UPDATE questions SET
  prompt        = 'What number comes next?  3, 6, 5, 10, 9, 18, ___',
  options       = '["16", "17", "19", "36"]'::JSONB,
  correct_index = 1,
  explanation   = 'The pattern alternates: multiply by 2, then subtract 1. 18 − 1 = 17.'
  WHERE section = 'quantitative'
    AND prompt = 'What number comes next?  2, 4, 3, 6, 5, 10, ___';

-- [quantitative #144] CRITICAL wrong answer: differences of 2, 3, 7, 13, 21, 31 are 1, 4, 6, 8, 10 — no rule fits all six terms, so the keyed 43 was unreachable; first term corrected to 1 (n² − n + 1), giving differences 2, 4, 6, 8, 10
UPDATE questions SET
  prompt        = 'What number comes next?  1, 3, 7, 13, 21, 31, ___',
  explanation   = 'Differences: 2, 4, 6, 8, 10 — even differences increasing by 2. Next difference = 12: 31 + 12 = 43.'
  WHERE section = 'quantitative'
    AND prompt = 'What number comes next?  2, 3, 7, 13, 21, 31, ___';

-- [quantitative #133] MAJOR unreachable: 1, 2, 5, 14, 42 are the Catalan numbers — only memorization yields 132; replaced with a discoverable ×3 − 1 series
UPDATE questions SET
  prompt        = 'What number comes next?  1, 2, 5, 14, 41, ___',
  options       = '["82", "122", "123", "132"]'::JSONB,
  correct_index = 1,
  explanation   = 'Each term is the previous term times 3, minus 1: 41 × 3 − 1 = 122.'
  WHERE section = 'quantitative'
    AND prompt = 'What number comes next?  1, 2, 5, 14, 42, ___';

-- ==========================================================================
-- READING
-- ==========================================================================

-- [reading #54-57] CRITICAL factual error in the shared sleep passage: teenagers need
-- 8-10 hours (AAP/AASM/CDC); "seven to nine hours" is the ADULT figure, taught to
-- 7th/8th graders as fact. No answer key depends on the number.
UPDATE questions SET
  passage = REPLACE(passage, 'typically seven to nine hours for teenagers', 'typically eight to ten hours for teenagers')
  WHERE section = 'reading'
    AND passage LIKE '%typically seven to nine hours for teenagers%';

-- [reading #102-105] CRITICAL factual error in the shared democracy passage: Cleisthenes'
-- reforms date to 508/507 BCE — the late 6th century BCE, not the 5th. No answer key
-- depends on the century.
UPDATE questions SET
  passage = REPLACE(passage, 'Greece, in the 5th century BCE', 'Greece, in the late 6th century BCE (around 508 BCE)')
  WHERE section = 'reading'
    AND passage LIKE '%Greece, in the 5th century BCE%';

-- ==========================================================================
-- VERBAL
-- ==========================================================================

-- [verbal #168] CRITICAL wrong key: 'All primary colors can mix to form secondary colors' does not license the converse, so True was invalid; premise 1 rewritten so the syllogism is genuinely valid
UPDATE questions SET
  prompt        = 'All secondary colors are formed by mixing primary colors. Green is a secondary color. Green can be formed from primary colors — true, false, or uncertain?',
  correct_index = 0,
  explanation   = 'Premise 1 covers every secondary color, and premise 2 says green is one. The conclusion follows directly from the premises: True.'
  WHERE section = 'verbal'
    AND prompt = 'All primary colors can mix to form secondary colors. Green is a secondary color. Green can be formed from primary colors — true, false, or uncertain?';

-- [verbal #45] MAJOR two defensible answers: a scene is the canonical subdivision of a Play as much as of a Movie; 'Play' replaced with 'Script'
UPDATE questions SET
  options       = '["Actor", "Script", "Movie", "Stage"]'::JSONB,
  correct_index = 2
  WHERE section = 'verbal'
    AND prompt = 'Chapter is to book as scene is to:';

-- [verbal #39] MAJOR two defensible answers: 'Kitchen' is the same worker-to-workplace relation as 'Restaurant'; replaced with 'Menu'
UPDATE questions SET
  options       = '["Food", "Recipe", "Menu", "Restaurant"]'::JSONB,
  correct_index = 3
  WHERE section = 'verbal'
    AND prompt = 'Doctor is to hospital as chef is to:';

-- [verbal #99] MAJOR two defensible answers: a shell is as characteristic of a Crab as of a Turtle; 'Crab' replaced with the shell-less 'Frog'
UPDATE questions SET
  options       = '["Ocean", "Pearl", "Turtle", "Frog"]'::JSONB,
  correct_index = 2
  WHERE section = 'verbal'
    AND prompt = 'Trunk is to elephant as shell is to:';

-- [verbal #101] MAJOR two defensible answers: stories and essays also take introductions; replaced with options that cannot have one
UPDATE questions SET
  options       = '["Chapter", "Book", "Sentence", "Index"]'::JSONB,
  correct_index = 1
  WHERE section = 'verbal'
    AND prompt = 'Prologue is to play as introduction is to:';

-- [verbal #43] MAJOR two defensible answers: skin is the outer covering of an Animal as much as of a Body; 'Animal' replaced with 'Bone'
UPDATE questions SET
  options       = '["Hair", "Body", "Bone", "Fur"]'::JSONB,
  correct_index = 1
  WHERE section = 'verbal'
    AND prompt = 'Bark is to tree as skin is to:';

-- [verbal #54] MAJOR two defensible groupings: 'Hat' is the odd one out under an essential-dress or head-vs-body reading; 'Hat' replaced with 'Jacket' so only clothing-vs-footwear survives
UPDATE questions SET
  options       = '["Shirt", "Pants", "Jacket", "Shoes"]'::JSONB,
  correct_index = 3,
  explanation   = 'Shirt, pants, and jacket are garments worn on the body; shoes are footwear — a different category.'
  WHERE section = 'verbal'
    AND prompt = 'Which word does NOT belong with the others?'
    AND options  = '["Shirt", "Pants", "Hat", "Shoes"]'::JSONB;

-- [verbal #118] MAJOR two defensible answers: the traditional ballad does have a fixed stanza form, and 'Haiku' is the odd one out under a Western-forms reading; 'Ballad' replaced with 'Free verse'
UPDATE questions SET
  options       = '["Sonnet", "Villanelle", "Haiku", "Free verse"]'::JSONB,
  correct_index = 3,
  explanation   = 'A sonnet, a villanelle, and a haiku all have strict formal requirements for length and structure. Free verse has no fixed form at all.'
  WHERE section = 'verbal'
    AND prompt = 'Which word does NOT belong with the others?'
    AND options  = '["Sonnet", "Villanelle", "Haiku", "Ballad"]'::JSONB;

-- [verbal #156] MAJOR two defensible answers: a novice lacks 'Skill' just as much as 'Mastery'; 'Skill' replaced with 'Enthusiasm'
UPDATE questions SET
  options       = '["Enthusiasm", "Beginner", "Learning", "Mastery"]'::JSONB,
  correct_index = 3
  WHERE section = 'verbal'
    AND prompt = 'Dilettante is to expertise as novice is to:';

-- [verbal #158] MAJOR two defensible answers: forgery is as commonly of a Signature as of a Document; 'Signature' replaced with 'Judge'
UPDATE questions SET
  options       = '["Judge", "Crime", "Document", "Money"]'::JSONB,
  correct_index = 2
  WHERE section = 'verbal'
    AND prompt = 'Perjury is to oath as forgery is to:';

-- [verbal #12] MAJOR two defensible answers: 'Dark' (and 'Cloudy') are the primary literal senses of gloomy, so 'most nearly means' had more than one right answer
UPDATE questions SET
  options       = '["Cheerful", "Hungry", "Loud", "Sad"]'::JSONB,
  correct_index = 3,
  explanation   = 'Gloomy means feeling or causing low spirits — sad.'
  WHERE section = 'verbal'
    AND prompt = 'GLOOMY most nearly means:';

-- ==========================================================================
-- LANGUAGE
-- ==========================================================================

-- [language #80] CRITICAL + self-contradiction (colon): keyed 'My three favorite sports are: ...' puts a colon straight after 'are', the very error items 77/84/88/158 penalize; keyed option rewritten so a complete clause precedes the colon
UPDATE questions SET
  options       = '["I have three favorite sports: soccer, basketball, and tennis.", "My three favorite sports: are soccer, basketball, and tennis.", "My three favorite sports are soccer, basketball: and tennis.", "My three favorite sports are soccer: basketball, and tennis."]'::JSONB,
  correct_index = 0,
  explanation   = 'A colon must follow a complete independent clause. "I have three favorite sports" is complete, so the colon may introduce the list.'
  WHERE section = 'language'
    AND prompt = 'Which sentence uses the colon correctly?'
    AND options  = '["My three favorite sports are: soccer, basketball, and tennis.", "My three favorite sports: are soccer, basketball, and tennis.", "My three favorite sports are soccer, basketball: and tennis.", "My three favorite sports are soccer: basketball, and tennis."]'::JSONB;

-- [language #25] CRITICAL two right answers: 'Wired' is itself a correctly spelled English word; replaced with the non-word 'Weard'
UPDATE questions SET
  options       = '["Wierd", "Weard", "Weird", "Weerd"]'::JSONB,
  correct_index = 2
  WHERE section = 'language'
    AND prompt = 'Which word is spelled correctly?'
    AND options  = '["Wierd", "Wired", "Weird", "Weerd"]'::JSONB;

-- [language #95] CRITICAL two right answers: 'Lay yourself down' is correct (lay + direct object), which the item's own explanation concedes; replaced with an unambiguous error
UPDATE questions SET
  options       = '["Lay down and rest for a while.", "Lie down and rest for a while.", "Laid down and rest for a while.", "Lays down and rest for a while."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Choose the correctly written sentence.'
    AND options  = '["Lay down and rest for a while.", "Lie down and rest for a while.", "Lay yourself down and rest for a while.", "Lays down and rest for a while."]'::JSONB;

-- [language #139] CRITICAL two right answers: 'taller than I' (elided verb) and 'taller than me' are both standard; distractors replaced with real errors (double comparative, then/than)
UPDATE questions SET
  options       = '["She is more taller than I am by three inches.", "She is taller then I am by three inches.", "She is taller than myself by three inches.", "She is taller than I am by three inches."]'::JSONB,
  correct_index = 3
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["She is taller than me by three inches.", "She is taller than I by three inches.", "She is taller than myself by three inches.", "She is taller than I am by three inches."]'::JSONB;

-- [language #137] CRITICAL + self-contradiction (split infinitive): no option contained a grammatical error — a split infinitive is not one, and item 179 keys one; distractors replaced with genuine errors
UPDATE questions SET
  options       = '["She want to complete the form quickly and accurately.", "She wants to complete the form quickly and accurately.", "She wants completing the form quickly and accurately.", "She wants to completes the form quickly and accurately."]'::JSONB,
  correct_index = 1,
  explanation   = 'The subject "she" takes "wants," and "wants" is followed by the infinitive "to complete." Only this option gets both right.'
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["She wants to quickly and accurately complete the form.", "She wants to complete the form quickly and accurately.", "She wants quickly and accurately to complete the form.", "Quickly and accurately, she wants to complete the form."]'::JSONB;

-- [language #3] CRITICAL two right answers: 'Each of the students has completed their projects.' contains no error; replaced with a real error ('each of the student')
UPDATE questions SET
  options       = '["Each of the students have completed their project.", "Each of the students has completed their project.", "Each of the students have completed his project.", "Each of the student has completed their project."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["Each of the students have completed their project.", "Each of the students has completed their project.", "Each of the students have completed his project.", "Each of the students has completed their projects."]'::JSONB;

-- [language #96] CRITICAL two right answers: 'Everyone has submitted his or her forms.' contains no error; replaced with a real pronoun error
UPDATE questions SET
  options       = '["Everyone have submitted their forms.", "Everyone has submitted their forms.", "Everyone have submitted his form.", "Everyone has submitted they forms."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["Everyone have submitted their forms.", "Everyone has submitted their forms.", "Everyone have submitted his form.", "Everyone has submitted his or her forms."]'::JSONB;

-- [language #165] CRITICAL + self-contradiction (collective noun): keyed answer used 'the team ... they', which items 90/104/155 mark wrong; changed to singular 'it'
UPDATE questions SET
  options       = '["Although the team practiced hard every day.", "Although the team practiced hard, it lost the championship.", "The team practiced hard, although.", "Although, the team practiced hard and lost."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Which sentence best revises this fragment: ''Although the team practiced hard''?';

-- [language #4] MAJOR two right answers: "The dogs' bone" is correct if several dogs share the bone; replaced with an unambiguous error
UPDATE questions SET
  options       = '["The dog''s bone is buried in the yard''s.", "The dogs bone is buried in the yard.", "The dog''s bone is buried in the yard.", "The dogs''s bone is buried in the yard."]'::JSONB,
  correct_index = 2
  WHERE section = 'language'
    AND prompt = 'Which sentence uses the apostrophe correctly?'
    AND options  = '["The dog''s bone is buried in the yard''s.", "The dogs bone is buried in the yard.", "The dog''s bone is buried in the yard.", "The dogs'' bone is buried in the yard."]'::JSONB;

-- [language #86] MAJOR two right answers: "The bosses' office" is correct if several bosses share it; replaced with an unambiguous error
UPDATE questions SET
  options       = '["The boss''s office is on the third floor.", "The boss'' office is on the third floor.", "The bosses office is on the third floor.", "The bosses''s office is on the third floor."]'::JSONB,
  correct_index = 0
  WHERE section = 'language'
    AND prompt = 'Which sentence uses the apostrophe correctly?'
    AND options  = '["The boss''s office is on the third floor.", "The boss'' office is on the third floor.", "The bosses office is on the third floor.", "The bosses'' office is on the third floor."]'::JSONB;

-- [language #50] MAJOR + self-contradiction (serial comma): 'I need eggs, milk and butter.' was marked wrong although omitting the Oxford comma is optional (AP style); replaced so the item no longer hinges on it
UPDATE questions SET
  options       = '["I need eggs milk, and butter.", "I need eggs, milk and, butter.", "I need eggs, milk, and butter.", "I need, eggs, milk, and butter."]'::JSONB,
  correct_index = 2,
  explanation   = 'Commas separate the items of a series. Only this option places them between the items rather than after "need" or after "and."'
  WHERE section = 'language'
    AND prompt = 'Which sentence uses commas correctly?'
    AND options  = '["I need eggs milk, and butter.", "I need eggs, milk and butter.", "I need eggs, milk, and butter.", "I need, eggs, milk, and butter."]'::JSONB;

-- [language #9] MAJOR no correct answer: the keyed sentence dangles only if you assume Sarah was running — grammatically the modifier attaches to the squirrel, which can plausibly run; replaced with a subject that cannot perform the action
UPDATE questions SET
  options       = '["Running through the park, the dog chased the squirrel.", "Running through the park, the homework was forgotten by Sarah.", "Sarah chased the squirrel through the park.", "The squirrel ran as Sarah chased it."]'::JSONB,
  correct_index = 1,
  explanation   = '"Running through the park" has to modify the subject that follows it — but homework cannot run, so the modifier dangles.'
  WHERE section = 'language'
    AND prompt = 'Which sentence contains a dangling modifier?';

-- [language #65] MAJOR keyed answer wrong: a list renaming 'three dogs' needs a colon, not a comma; as punctuated the keyed sentence read as a four-item list
UPDATE questions SET
  options       = '["She has three dogs a golden retriever a poodle and a beagle.", "She has three dogs: a golden retriever, a poodle, and a beagle.", "She has three dogs a golden retriever, a poodle, and a beagle.", "She has, three dogs a golden retriever a poodle and a beagle."]'::JSONB,
  correct_index = 1,
  explanation   = 'A colon after the complete clause "She has three dogs" introduces the list, and commas separate the three breeds.'
  WHERE section = 'language'
    AND prompt = 'Which sentence uses the comma correctly?'
    AND options  = '["She has three dogs a golden retriever a poodle and a beagle.", "She has three dogs, a golden retriever, a poodle, and a beagle.", "She has three dogs a golden retriever, a poodle, and a beagle.", "She has, three dogs a golden retriever a poodle and a beagle."]'::JSONB;

-- [language #66] MAJOR keyed answer wrong: 'small' (size) and 'red' (color) are cumulative adjectives and take no comma, so the keyed sentence taught an incorrect comma; swapped to genuinely coordinate adjectives
UPDATE questions SET
  options       = '["The long, boring lecture finally ended.", "The long boring, lecture finally ended.", "The, long boring lecture finally ended.", "The long boring lecture, finally ended."]'::JSONB,
  correct_index = 0,
  explanation   = '"Long" and "boring" are coordinate adjectives — "long and boring lecture" and "boring, long lecture" both work — so they are separated by a comma.'
  WHERE section = 'language'
    AND prompt = 'Which sentence uses the comma correctly?'
    AND options  = '["The small, red car was parked outside.", "The small red, car was parked outside.", "The, small red car was parked outside.", "The small red car, was parked outside."]'::JSONB;

-- [language #69] MAJOR two defensible answers: 'my dog Buddy, the golden retriever.' is correct under a restrictive reading of 'my dog Buddy'; that option replaced with a clear error
UPDATE questions SET
  options       = '["That is my dog Buddy the golden retriever.", "That is my dog, Buddy, the golden retriever.", "That is my dog Buddy the golden, retriever.", "That is my dog, Buddy the golden retriever."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Which sentence uses the comma correctly?'
    AND options  = '["That is my dog Buddy the golden retriever.", "That is my dog, Buddy, the golden retriever.", "That is my dog Buddy, the golden retriever.", "That is my dog, Buddy the golden retriever."]'::JSONB;

-- [language #94] MAJOR two right answers: 'The data were showing...' is grammatical under the same plural-data rule the item enforces; replaced with a real verb-form error
UPDATE questions SET
  options       = '["The data shows that the experiment failed.", "The data show that the experiment failed.", "The data is showing that the experiment failed.", "The data has show that the experiment failed."]'::JSONB,
  correct_index = 1,
  explanation   = 'In formal scientific writing "data" is the plural of "datum" and takes the plural verb "show."'
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["The data shows that the experiment failed.", "The data show that the experiment failed.", "The data is showing that the experiment failed.", "The data were showing that the experiment failed."]'::JSONB;

-- [language #107] MAJOR two right answers: 'Fewer students attend today than yesterday.' uses 'fewer' correctly and is grammatical; replaced with a subject-verb agreement error
UPDATE questions SET
  options       = '["Less students attended today than yesterday.", "Fewer students attends today than yesterday.", "Fewer students attended today than yesterday.", "Less students attend today than yesterday."]'::JSONB,
  correct_index = 2
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["Less students attended today than yesterday.", "Fewer students attend today than yesterday.", "Fewer students attended today than yesterday.", "Less students attend today than yesterday."]'::JSONB;

-- [language #131] MAJOR two right answers: 'We found the sunset breathtaking, walking along the pier.' correctly modifies 'we'; replaced with a true dangler
UPDATE questions SET
  options       = '["Walking along the pier, the sunset was breathtaking.", "Walking along the pier, we found the sunset breathtaking.", "The sunset, walking along the pier, was breathtaking.", "The sunset was found breathtaking, walking along the pier."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["Walking along the pier, the sunset was breathtaking.", "Walking along the pier, we found the sunset breathtaking.", "The sunset, walking along the pier, was breathtaking.", "We found the sunset breathtaking, walking along the pier."]'::JSONB;

-- [language #132] MAJOR two right answers: 'It is important that he attended the meeting.' is grammatical under the factive reading; replaced with an unambiguous error
UPDATE questions SET
  options       = '["It is important that he attends the meeting.", "It is important that he attend the meeting.", "It is important that he to attend the meeting.", "It is important that he attending the meeting."]'::JSONB,
  correct_index = 1
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["It is important that he attends the meeting.", "It is important that he attend the meeting.", "It is important that he attended the meeting.", "It is important that he attending the meeting."]'::JSONB;

-- [language #152] MAJOR broken option: the key was the meta-option 'Both A and B are correct.', which breaks whenever options are shuffled (migration 019 shuffles them); rebuilt as a single-answer item
UPDATE questions SET
  options       = '["You look as if you could use a rest.", "You look as if you could used a rest.", "You looks as though you could use a rest.", "You look like as if you could use a rest."]'::JSONB,
  correct_index = 0,
  explanation   = '"As if" introduces the subordinate clause "you could use a rest." The other options misuse the verb, the subject-verb agreement, or double up "like as if."'
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["You look as if you could use a rest.", "You look as though you could use a rest.", "Both A and B are correct.", "You look like you need a rest right now."]'::JSONB;

-- [language #154] MAJOR two right answers: 'anxious to' meaning eager is standard English (Merriam-Webster), so option 0 contained no error; replaced with a genuine error
UPDATE questions SET
  options       = '["I am eagerly to start the new job next week.", "I am eager to start the new job next week.", "I am eager starting the new job next week.", "I am anxious starting the new job next week."]'::JSONB,
  correct_index = 1,
  explanation   = '"Eager" is an adjective followed by the infinitive "to start." The other options use an adverb in place of the adjective or drop the infinitive.'
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["I am anxious to start the new job next week.", "I am eager to start the new job next week.", "I am eager starting the new job next week.", "I am anxious starting the new job next week."]'::JSONB;

-- [language #101] Difficulty relabel: this item tests the identical whoever/whomever-as-embedded-subject rule as item #126, which is labelled difficulty 3; raised 2 -> 3 so the same rule is not graded two ways (raising difficulty can only add Clutch Points, never remove them)
UPDATE questions SET
  difficulty    = 3
  WHERE section = 'language'
    AND prompt = 'Choose the grammatically correct sentence.'
    AND options  = '["Please give the package to whoever answers the door.", "Please give the package to whomever answers the door.", "Please give the package to who answers the door.", "Please give the package to whom answers the door."]'::JSONB;

COMMIT;

-- ============================================================================
-- VERIFICATION — every row must report bad_rows = 0.
-- ============================================================================
SELECT defect, bad_rows FROM (
  -- math: 2/7 ÷ 4/21 must key 3/2
  SELECT 'math 170: key is not 3/2' AS defect, COUNT(*) AS bad_rows FROM questions
    WHERE section = 'math' AND prompt = 'What is 2/7 ÷ 4/21?'
      AND (options ->> correct_index) IS DISTINCT FROM '3/2'
  UNION ALL
  SELECT 'math 170: explanation still says = 3', COUNT(*) FROM questions
    WHERE section = 'math' AND prompt = 'What is 2/7 ÷ 4/21?' AND explanation LIKE '%42/28 = 3.%'
  UNION ALL
  -- math: options that duplicate the value of the keyed answer
  SELECT 'math: value-duplicate options remain', COUNT(*) FROM questions
    WHERE section = 'math'
      AND (   (prompt = 'What is 2/3 × 3/4?'                            AND options::text LIKE '%6/12%')
           OR (prompt = 'What is 2/3 × 3/4?'                            AND options::text LIKE '%2/4%')
           OR (prompt = 'What is 2/3 ÷ 4?'                              AND options::text LIKE '%2/12%')
           OR (prompt = 'What is 5/6 + 2/3?'                            AND options::text LIKE '%9/6%')
           OR (prompt = 'What is 0.75 expressed as a fraction in lowest terms?' AND options::text LIKE '%15/20%')
           OR (prompt = 'What is 1/2 + 1/4?'                            AND options::text LIKE '%2/6%'))
  UNION ALL
  SELECT 'math 100: 66% / 67% rounding pair remains', COUNT(*) FROM questions
    WHERE section = 'math'
      AND prompt = 'A store buys shirts for $15 each and sells them for $25 each. What is the percent profit?'
      AND options::text LIKE '%67%'
  UNION ALL
  -- quantitative: the three broken series must be gone
  SELECT 'quant: unfixable series still present', COUNT(*) FROM questions
    WHERE section = 'quantitative'
      AND (prompt LIKE '%2, 4, 3, 6, 5, 10%' OR prompt LIKE '%2, 3, 7, 13, 21, 31%' OR prompt LIKE '%1, 2, 5, 14, 42%')
  UNION ALL
  SELECT 'quant 78: drafting note left in explanation', COUNT(*) FROM questions
    WHERE section = 'quantitative' AND explanation LIKE '%actually pattern is%'
  UNION ALL
  -- reading: passage facts
  SELECT 'reading: adult sleep figure still taught', COUNT(*) FROM questions
    WHERE section = 'reading' AND passage LIKE '%seven to nine hours for teenagers%'
  UNION ALL
  SELECT 'reading: Cleisthenes still misdated', COUNT(*) FROM questions
    WHERE section = 'reading' AND passage LIKE '%Greece, in the 5th century BCE%'
  UNION ALL
  -- verbal: the second-defensible-answer distractors must be gone
  SELECT 'verbal: co-correct distractors remain', COUNT(*) FROM questions
    WHERE section = 'verbal'
      AND (   (prompt = 'Chapter is to book as scene is to:'            AND options::text LIKE '%Play%')
           OR (prompt = 'Doctor is to hospital as chef is to:'          AND options::text LIKE '%Kitchen%')
           OR (prompt = 'Trunk is to elephant as shell is to:'          AND options::text LIKE '%Crab%')
           OR (prompt = 'Bark is to tree as skin is to:'                AND options::text LIKE '%Animal%')
           OR (prompt = 'Dilettante is to expertise as novice is to:'   AND options::text LIKE '%Skill%')
           OR (prompt = 'Perjury is to oath as forgery is to:'          AND options::text LIKE '%Signature%')
           OR (prompt = 'GLOOMY most nearly means:'                     AND options::text LIKE '%Dark%'))
  UNION ALL
  SELECT 'verbal 168: illicit-conversion syllogism remains', COUNT(*) FROM questions
    WHERE section = 'verbal' AND prompt LIKE 'All primary colors can mix to form secondary colors.%'
  UNION ALL
  -- language: the specific broken strings must be gone
  SELECT 'language: broken options remain', COUNT(*) FROM questions
    WHERE section = 'language'
      AND (   options::text LIKE '%My three favorite sports are: soccer%'   -- colon after "are"
           OR options::text LIKE '%Lay yourself down and rest%'             -- second correct answer
           OR options::text LIKE '%Each of the students has completed their projects.%'
           OR options::text LIKE '%Everyone has submitted his or her forms.%'
           OR options::text LIKE '%Although the team practiced hard, they lost%'  -- collective noun
           OR options::text LIKE '%I need eggs, milk and butter.%'          -- Oxford comma as "error"
           OR options::text LIKE '%Both A and B are correct.%'              -- shuffle-breaking meta-option
           OR options::text LIKE '%The small, red car%'                     -- cumulative adjectives
           OR options::text LIKE '%She has three dogs, a golden retriever%'
           OR options::text LIKE '%"Wired"%')
  UNION ALL
  SELECT 'language 137: still penalizes a split infinitive', COUNT(*) FROM questions
    WHERE section = 'language' AND explanation LIKE '%split infinitive%'
  UNION ALL
  -- structural invariants for every row this migration touched
  SELECT 'any question without 4 distinct options', COUNT(*) FROM (
    SELECT q.id FROM questions q, LATERAL jsonb_array_elements_text(q.options) AS o
     GROUP BY q.id HAVING COUNT(DISTINCT o) <> 4
  ) t
  UNION ALL
  SELECT 'any question with correct_index out of range', COUNT(*) FROM questions
    WHERE correct_index < 0 OR correct_index > 3
) v ORDER BY defect;

-- ============================================================================
-- SCORING SAFETY — the row count must be identical to the pre-migration count, and
-- the difficulty distribution must differ by exactly one item moved from 2 to 3
-- (language #101). No row was added, removed or re-sectioned, and no history row was
-- touched, so no student can have lost Clutch Points.
-- ============================================================================
SELECT 'questions total (must be unchanged)' AS check, COUNT(*)::TEXT FROM questions
UNION ALL
SELECT 'difficulty distribution (must be unchanged)',
       string_agg(d || '=' || n, ' ' ORDER BY d)
FROM (SELECT difficulty AS d, COUNT(*) AS n FROM questions GROUP BY difficulty) t;
