---
name: add-questions
description: Add HSPT questions to the PrepClutch question bank — formats them into seed SQL, validates the answer key and difficulty mix, and produces a paste-ready migration. Use when adding, drafting, or importing quiz questions for any section (verbal, quantitative, reading, math, language), including reading passages and standalone vocabulary questions.
---

# Adding questions to the PrepClutch bank

Turn plain-English questions into validated, paste-ready SQL. The hard parts are
not the formatting — they are the answer key, the difficulty mix, and **not
destroying existing student mastery**. This skill exists to get those right.

## The one rule that matters most

**NEVER re-run `supabase/seed_questions.sql` to add questions.** It now aborts
against a non-empty `questions` table, but treat that guard as a backstop, not
a workflow — it can be bypassed with a TRUNCATE.

It begins with `delete from questions;` and `questions.id` defaults to
`uuid_generate_v4()`. The rows are not merely orphaned — `user_question_history`
declares `question_id ... REFERENCES questions(id) ON DELETE CASCADE`, so
deleting the bank **deletes every student's answer history outright**. Scores
are computed as `user_question_history JOIN questions`, so every Clutch Point
total and the whole leaderboard go to zero.

It is not recoverable. Migration 008 once rebuilt history from `quiz_attempts`,
but that matched on `question_id`, and re-seeding regenerates every id. Earned
badges survive (no FK to `questions`), so a student would keep a "250 questions
mastered" badge next to a score of 0.

New questions are **always** added as an `INSERT` migration with **deterministic
ids**, never by re-seeding. Use `md5(<stable-key>)::UUID` so re-running the
migration is a no-op instead of a duplicate insert (migration 014 is the
reference implementation).

## Workflow

### 1. Collect the questions

Ask for them in plain English. A complete question needs: prompt, four options,
which option is correct, difficulty, and a one-sentence explanation. Draft any
missing explanations yourself — every question must have one, it is what
students learn from.

For **reading**, also establish whether each question is:
- **passage-based** — belongs to a passage (`passage` column set), or
- **standalone vocabulary** — no passage. Real HSPT format is a short phrase
  with one word underlined: *"a **monotonous** lecture"* → single / **boring** /
  brief / interesting. These are ~35% of the real reading section.

### 2. Validate before writing any SQL

Check every question. Any failure means fix it, do not emit it:

- **Exactly 4 options.** The `questions` table has
  `check (correct_index between 0 and 3)`.
- **`correct_index` points at the genuinely correct option.** Re-read the option
  text at that index and confirm it answers the prompt. This is the single most
  common error and it silently teaches students the wrong answer.
- **Exactly one defensible answer.** No two options that could both be right.
- **Difficulty is 1, 2, or 3** (Easy / Medium / Hard).
- **Explanation present**, and it explains *why* — not just a restatement of the
  correct option.
- **No duplicate prompts** against the existing bank (grep
  `supabase/seed_questions.sql`).
- For **reading**, the answer must be derivable from the passage, not from
  outside knowledge.

**Write math the way the exam prints it**, not the way you would say it aloud:

- Exponents and radicals use symbols: `3³`, `4²`, `√81`, `(2/3)²` — never
  "3 cubed" or "the square root of 81". Prose about a formula is the exception:
  "the radius squared" stays in words, because "radius²" is not what a student
  would write.
- **Comparison questions put each item on its own line.** Prompts render with
  `whitespace-pre-line`, so embed real newlines:

  ```
  Examine (a), (b), and (c) and find the best answer.
  (a) 3³ − 2³
  (b) 2 × 3²
  (c) 4² + 3
  ```

  On one line they wrap on a phone and the third item rolls off mid-expression,
  which makes them impossible to scan in order. This applies to any question
  that asks the student to compare a list, in any section.

### 3. Check the difficulty mix

Sessions target **3 Easy / 4 Medium / 3 Hard** (`DIFFICULTY_TARGETS` in
`app/quiz/[section]/page.tsx`). A section whose bank skews easy cannot fill that
split and silently degrades. Report the resulting section-wide mix and flag any
difficulty that is thin.

### 4. Emit the migration

Write to `supabase/migrations/NNN_<description>.sql`, where NNN is the next
unused number — **check the directory, and do not reuse a number that has ever
been used for a diagnostic query either.**

Structure:

```sql
-- NNN — <Title>

INSERT INTO questions (id, section, passage, prompt, options, correct_index, difficulty, explanation)
SELECT md5(v.key)::UUID, 'reading'::section_type, v.passage, v.prompt,
       v.options, v.correct_index, v.difficulty, v.explanation
FROM (VALUES
  ('vocab-monotonous', NULL, 'Choose the word that means the same as the underlined word: a monotonous lecture',
   '["single","boring","brief","interesting"]'::JSONB, 1, 2,
   'Monotonous means dull and unvarying in tone — boring is the closest match.')
) AS v(key, passage, prompt, options, correct_index, difficulty, explanation)
ON CONFLICT (id) DO NOTHING;

-- Verification — always end with this so a failed apply is visible
SELECT 'inserted (expect N)' AS check, COUNT(*)::TEXT AS value
  FROM questions WHERE id IN (SELECT md5(x)::UUID FROM unnest(ARRAY['vocab-monotonous']) x);
```

Notes:
- Passage text repeated per question bloats the file badly. Put passages in a
  `WITH p(pkey, body) AS (VALUES …)` CTE and join — it roughly halves the size.
- Escape single quotes by doubling them (`don''t`).
- If any question has a passage, follow the insert with the `passage_id`
  grouping block from migration 014 so its questions are served together.

### 5. Deliver it

Migrations are applied **by hand** in the Supabase SQL editor. Three delivery
rules, each learned from a failure:

- **Robert cannot open `.sql` files.** Send a `.txt` copy via SendUserFile, or
  paste the SQL inline in a fenced block.
- **Never hand off via `pbcopy`.** Any code block he copies afterwards
  overwrites the clipboard, and the wrong thing gets run.
- **Never reuse a number** between a diagnostic query and a migration. A
  read-only query labelled `010` was once run in place of migration `010`, and
  the resulting "it didn't work" took three rounds to diagnose.

Always end the migration with a verification `SELECT` so a non-apply is
impossible to miss.

### 6. Report the impact

Adding questions raises the section's `max_score`, which **shrinks every
student's progress bar** even though nobody lost a point. Before they apply it,
state: questions added, new section total, and the effect on the top student's
percentage. Ranks never change — only the denominator grows.

## Reference

- Bank: `supabase/seed_questions.sql` (read-only reference — never re-run)
- Schema: `supabase/migrations/001_initial.sql`
- Deterministic-id insert to copy: `supabase/migrations/014_adopt_legacy_reading_questions.sql`
- Base points: Easy 10 · Medium 20 · Hard 35 (`lib/constants.ts`)
- Reading passages are grouped by `questions.passage_id`; the reading quiz
  serves whole passages, so a passage's questions must share one `passage_id`.
