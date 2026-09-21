// ── Mastered-question review ─────────────────────────────────────────────────
//
// Once a student answers a quiz question correctly, the selector stops serving
// it (unseen → unmastered → shaky come first, and MAX_CORRECT_RECYCLED caps the
// rest at one per session). That is right for quizzes and leaves nothing to
// revisit, so Training offers these back, one at a time and explained.
//
// READ-ONLY. Nothing here writes user_question_history: a review answer can
// neither add points nor, more importantly, take a mastered question away.

import { hasExamColumn } from '@/lib/exam-scope'
import { DEFAULT_EXAM } from '@/lib/constants'
import type { ExamId } from '@/lib/constants'
import type { TrainingQuestion } from '@/components/training/TrainingClient'

/** Questions per review round — the same size as a training set. */
export const REVIEW_ROUND = 15

export type LevelCounts = Record<1 | 2 | 3, number>

interface MasteredRow {
  questions: {
    id: string; section: string; prompt: string; passage: string | null
    options: string[]; correct_index: number; difficulty: number
    explanation: string | null
  }
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function fetchMastered(supabase: any, userId: string, section: string, exam: ExamId) {
  const scoped = await hasExamColumn(supabase)
  const cols = 'id, section, prompt, passage, options, correct_index, difficulty, explanation'
  let q = supabase
    .from('user_question_history')
    .select(`questions!inner(${scoped ? `${cols}, exam` : cols})`)
    .eq('user_id', userId)
    .gt('times_correct', 0)
    .eq('questions.section', section)
  if (scoped) q = q.eq('questions.exam', exam)
  const { data, error } = await q
  if (error) throw new Error(`Could not load mastered questions: ${error.message}`)
  return ((data ?? []) as MasteredRow[]).map(r => r.questions)
}

/** How many questions the student has mastered in a section, per difficulty. */
export async function masteredCounts(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  supabase: any, userId: string, section: string, exam: ExamId = DEFAULT_EXAM,
): Promise<LevelCounts> {
  const counts: LevelCounts = { 1: 0, 2: 0, 3: 0 }
  for (const q of await fetchMastered(supabase, userId, section, exam)) {
    if (q.difficulty === 1 || q.difficulty === 2 || q.difficulty === 3) counts[q.difficulty]++
  }
  return counts
}

/** A random round of mastered questions at one difficulty, shaped for the
 *  training walkthrough. Quiz questions carry one explanation rather than a
 *  note per choice, so `option_notes` is left empty. */
export async function masteredRound(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  supabase: any, userId: string, section: string, difficulty: number,
  exam: ExamId = DEFAULT_EXAM,
): Promise<{ questions: TrainingQuestion[]; available: number }> {
  const pool = (await fetchMastered(supabase, userId, section, exam))
    .filter(q => q.difficulty === difficulty)
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[pool[i], pool[j]] = [pool[j], pool[i]]
  }
  return {
    available: pool.length,
    questions: pool.slice(0, REVIEW_ROUND).map(q => ({
      ...q,
      explanation: q.explanation ?? '',
      option_notes: [],
      concept: null,
    })),
  }
}
