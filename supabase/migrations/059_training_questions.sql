-- 059 — Training questions: a separate, unscored practice bank
--
-- Students asked to work through questions one at a time and understand the
-- reasoning, rather than race ten of them. Training questions are walked in
-- order, easiest to hardest, and every one is explained afterwards — including
-- why the option the student picked was wrong.
--
-- WHY A SEPARATE TABLE, NOT A FLAG ON `questions`:
--
-- `questions` is read by get_section_mastery, leaderboard_view, both quiz
-- selectors and AttemptReview. A training flag would mean remembering to
-- exclude it in five places, and missing ONE silently inflates every section's
-- denominator: progress bars shrink for every student, `isSectionComplete`
-- stops firing, and the tier-6 "All 300 mastered" badges start lying again --
-- which is exactly how the tier-5 badge came to claim 250 was the whole bank.
--
-- A separate table makes that impossible rather than merely unlikely. Training
-- cannot touch a score because nothing that computes a score can see it.
--
-- SAFE: creates one new table. Reads nothing, changes nothing, and no existing
-- query's results move by a single row.


-- exam_type may or may not exist yet — migration 058 is still pending, and
-- these two must be applicable in either order.
DO $$ BEGIN
  CREATE TYPE exam_type AS ENUM ('hspt', 'ssat');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS training_questions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  exam          exam_type    NOT NULL DEFAULT 'hspt',
  section       section_type NOT NULL,

  -- Position within (exam, section). Students walk these in order, so the
  -- sequence is authored, not derived: difficulty ASC is the spine, but two
  -- Mediums can still be deliberately ordered so one teaches the other.
  sort_order    INT          NOT NULL,

  prompt        TEXT         NOT NULL,
  passage       TEXT,
  options       JSONB        NOT NULL,
  correct_index INT          NOT NULL CHECK (correct_index BETWEEN 0 AND 3),
  difficulty    INT          NOT NULL CHECK (difficulty BETWEEN 1 AND 3),

  -- Why the CORRECT answer is correct — the method, not just the label.
  explanation   TEXT         NOT NULL,

  -- One note per option, same order as `options`. The student sees the note
  -- for the option THEY picked, which is the whole ask: "why was mine wrong?"
  -- The correct option's note explains why it works, because a student who
  -- guessed right still needs to know why.
  option_notes  JSONB        NOT NULL,

  created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),

  -- Four options, four notes. Enforced here because a missing note shows a
  -- student a blank explanation at the exact moment they asked for one.
  CONSTRAINT training_four_options CHECK (jsonb_array_length(options) = 4),
  CONSTRAINT training_four_notes   CHECK (jsonb_array_length(option_notes) = 4),
  CONSTRAINT training_order_unique UNIQUE (exam, section, sort_order)
);

CREATE INDEX IF NOT EXISTS training_questions_walk_idx
  ON training_questions (exam, section, difficulty, sort_order);

ALTER TABLE training_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Training questions are publicly readable" ON training_questions;
CREATE POLICY "Training questions are publicly readable"
  ON training_questions FOR SELECT
  USING (true);


-- ── Pilot: three verbal questions, one per difficulty ────────────────────────
--
-- Enough to click through the real UI and judge the format before 250 more are
-- written to it. Deterministic ids so re-running replaces rather than
-- duplicates.

INSERT INTO training_questions
  (id, section, sort_order, prompt, options, correct_index, difficulty, explanation, option_notes)
SELECT md5(v.key)::UUID, 'verbal'::section_type, v.sort_order, v.prompt,
       v.options, v.correct_index, v.difficulty, v.explanation, v.option_notes
FROM (VALUES
  ('train-verbal-1', 1,
   'ABUNDANT most nearly means:',
   '["plentiful","costly","hidden","recent"]'::JSONB, 0, 1,
   'Abundant describes having a great deal of something — more than enough. Think of an abundant harvest: the barns are full. The word is about QUANTITY, so the answer has to be a quantity word.',
   '["Correct. Plentiful and abundant both mean there is a large supply of something.","Costly is about PRICE, not amount. Something abundant is often cheap precisely because there is so much of it — the opposite pull.","Hidden is about whether you can SEE something. An abundant thing is usually the easiest thing to find.","Recent is about TIME. A harvest can be recent and tiny, or abundant and years old. Different measure entirely."]'::JSONB),

  ('train-verbal-2', 2,
   'Chapter is to book as scene is to:',
   '["actor","play","stage","ticket"]'::JSONB, 1, 2,
   'Work out the relationship in words first, then test each option with the SAME sentence. A chapter is one section of a book. A scene is one section of a play. The pattern is part-to-whole, and both parts are the divisions the work is written in.',
   '["An actor performs IN a scene but is not a part of it the way a chapter is part of a book. A book is not made of readers.","Correct. A scene is a division of a play exactly as a chapter is a division of a book — same part-to-whole relationship.","A stage is WHERE a scene is performed, not what it is part of. Location, not composition.","A ticket gets you IN to a play. It is not a piece of the play at all."]'::JSONB),

  ('train-verbal-3', 3,
   'All violinists are musicians. Some musicians are composers. Therefore some violinists are composers — true, false, or uncertain?',
   '["True","False","Uncertain","Neither"]'::JSONB, 2, 3,
   'Draw the circles. Violinists sit entirely inside musicians. Composers overlap musicians somewhere — but nothing tells you WHERE. That overlap could land on the violinists, or entirely on the pianists. When a conclusion could go either way, the answer is uncertain.',
   '["True would require the composer overlap to definitely touch violinists. Nothing says it does — the composers could all be drummers.","False would require the overlap to definitely MISS violinists. Nothing says that either. Both True and False claim to know something the premises never state.","Correct. The premises allow the conclusion but do not force it, and that gap is exactly what uncertain means.","Neither is not one of the three verdicts this question type uses. On a true/false/uncertain item it is always a throwaway option."]'::JSONB)
) AS v(key, sort_order, prompt, options, correct_index, difficulty, explanation, option_notes)
ON CONFLICT (id) DO UPDATE SET
  prompt = EXCLUDED.prompt, options = EXCLUDED.options,
  correct_index = EXCLUDED.correct_index, difficulty = EXCLUDED.difficulty,
  explanation = EXCLUDED.explanation, option_notes = EXCLUDED.option_notes,
  sort_order = EXCLUDED.sort_order;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected:
--   training_total            3   the verbal pilot
--   every_note_populated   true   no option shows a blank explanation
--   questions_unchanged    1500   the scoring bank is untouched
--   walk_order        1 · 2 · 3   easiest first

SELECT
  (SELECT COUNT(*) FROM training_questions)                                  AS training_total,
  (SELECT bool_and(jsonb_array_length(option_notes) = 4
                   AND NOT (option_notes::TEXT LIKE '%""%'))
     FROM training_questions)                                               AS every_note_populated,
  (SELECT COUNT(*) FROM questions)                                          AS questions_unchanged,
  (SELECT string_agg(difficulty::TEXT, ' · ' ORDER BY sort_order)
     FROM training_questions WHERE section = 'verbal')                      AS walk_order;
