// ── Reading Comprehension Data Layer ─────────────────────────────────────────
//
// Passages are built from the `questions` table, grouped by `passage_id`.
// Reading questions MUST carry their real `questions.id` UUID — the cumulative
// score (get_section_mastery / leaderboard_view) is computed by joining
// user_question_history to questions, so a question with a synthetic id can
// never contribute to a section total. See migration 008.
//
// Difficulty distribution per session: 3 easy · 4 medium · 3 hard.

export type QuestionType =
  | 'main_idea'
  | 'detail'
  | 'inference'
  | 'authors_purpose'
  | 'vocabulary'

export type PassageTopic = 'science' | 'social_studies' | 'humanities'

export interface ReadingQuestion {
  id: string                 // questions.id UUID — must match the DB row
  text: string
  options: string[]          // always 4 options
  correctIndex: number       // 0-based
  difficulty: 1 | 2 | 3     // 1 = Easy, 2 = Medium, 3 = Hard
  type?: QuestionType        // absent for DB-sourced questions
  explanation: string
}

export interface ReadingPassage {
  id: string                 // questions.passage_id UUID
  title: string
  body: string               // full passage text (may contain \n\n paragraph breaks)
  topic?: PassageTopic       // absent for DB-sourced passages
  questions: ReadingQuestion[]
}

// ── Session shape ────────────────────────────────────────────────────────────
//
// The real HSPT reading subtest is 62 questions in 25 minutes: 40 comprehension
// questions spread over a handful of short social-studies / science / humanities
// passages, plus 22 standalone vocabulary questions. That works out to roughly
// 6-8 questions per passage — the reading cost of a passage is amortised over
// many questions rather than charged to one or two.
//
// Our bank averages 4 questions per passage, so we keep sessions to 2 passages.
// That lands at 8-10 questions (in line with every other section) while halving
// the number of passages a student must read per session compared to 3.
export const PASSAGES_PER_SESSION = 2

// ── DB row → passage grouping ────────────────────────────────────────────────

export interface ReadingQuestionRow {
  id: string
  prompt: string
  passage: string | null
  passage_id: string | null
  options: string[]
  correct_index: number
  difficulty: number
  explanation: string | null
}

// The question bank has no passage titles, so derive one from the opening
// sentence. Keeps the passage header meaningful without inventing content.
function deriveTitle(body: string): string {
  const firstSentence = body.trim().split(/(?<=[.!?])\s/)[0] ?? body
  const words = firstSentence.split(/\s+/)
  if (words.length <= 8) return firstSentence.replace(/[.!?]$/, '')
  return words.slice(0, 8).join(' ').replace(/[,;:]$/, '') + '…'
}

/**
 * Group flat `questions` rows into passages, preserving the real UUIDs that the
 * cumulative scoring join depends on. Rows without passage text are skipped.
 */
export function buildPassagesFromRows(rows: ReadingQuestionRow[]): ReadingPassage[] {
  const byPassage = new Map<string, ReadingPassage>()

  for (const row of rows) {
    if (!row.passage) continue
    const key = row.passage_id ?? row.passage

    let passage = byPassage.get(key)
    if (!passage) {
      passage = {
        id:        key,
        title:     deriveTitle(row.passage),
        body:      row.passage,
        questions: [],
      }
      byPassage.set(key, passage)
    }

    passage.questions.push({
      id:           row.id,
      text:         row.prompt,
      options:      row.options,
      correctIndex: row.correct_index,
      difficulty:   (row.difficulty as 1 | 2 | 3) ?? 2,
      explanation:  row.explanation ?? '',
    })
  }

  // Easy → hard within each passage, so a passage ramps in difficulty
  for (const passage of byPassage.values()) {
    passage.questions.sort((a, b) => a.difficulty - b.difficulty)
  }

  return [...byPassage.values()]
}
