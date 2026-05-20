import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTIONS, QUESTIONS_PER_SESSION, MAX_CORRECT_RECYCLED } from '@/lib/constants'
import QuizClient from '@/components/quiz/QuizClient'
import ReadingQuizClient from '@/components/quiz/ReadingQuizClient'
import { SAMPLE_PASSAGES } from '@/lib/reading-passages'
import type { Section, Question } from '@/types/database'

export const dynamic = 'force-dynamic'

interface Props {
  params: Promise<{ section: string }>
}

export default async function QuizPage({ params }: Props) {
  const { section } = await params
  const isValidSection = SECTIONS.includes(section as Section) || section === 'full'
  if (!isValidSection) notFound()

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('id, display_name, avatar_color')
    .eq('id', user.id)
    .single()

  if (!profile) redirect('/onboarding')

  // Reading section uses the dedicated passage-based quiz flow
  if (section === 'reading') {
    return (
      <ReadingQuizClient
        passages={SAMPLE_PASSAGES}
        userId={user.id}
      />
    )
  }

  let questions: Question[]

  if (section === 'full') {
    const perSection = await Promise.all(
      SECTIONS.map(s => selectSectionQuestions(supabase, user.id, s))
    )
    questions = perSection.flat()
  } else {
    questions = await selectSectionQuestions(supabase, user.id, section)
  }

  if (questions.length === 0) {
    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-center">
          <p className="text-4xl mb-4">🚧</p>
          <p className="text-zinc-400">No questions found. Please run the seed script.</p>
        </div>
      </div>
    )
  }

  return (
    <QuizClient
      section={section as Section | 'full'}
      questions={questions}
      userId={user.id}
    />
  )
}

// ── Smart question selection ──────────────────────────────────────────────────
//
// Targets 3 Easy / 4 Medium / 3 Hard per 10-question session.
// Within each difficulty bucket, priority is: unseen → prev-wrong → mastered.
// Mastered (previously-correct) questions are avoided unless the pool is
// exhausted; a global cap (MAX_CORRECT_RECYCLED) limits recycled mastered Qs.
// If a difficulty has fewer questions than needed, the shortfall is padded
// from any remaining unselected questions as a last resort.

// Desired difficulty split: difficulty key → question count
const DIFFICULTY_TARGETS: Record<number, number> = { 1: 3, 2: 4, 3: 3 }

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function selectSectionQuestions(supabase: any, userId: string, section: string): Promise<Question[]> {
  const { data: allQuestions } = await supabase
    .from('questions')
    .select('*')
    .eq('section', section)

  if (!allQuestions || allQuestions.length === 0) return []

  const { data: history } = await supabase
    .from('user_question_history')
    .select('question_id, times_correct, times_wrong')
    .eq('user_id', userId)
    .in('question_id', allQuestions.map((q: Question) => q.id))

  const historyMap = new Map(
    (history ?? []).map((h: { question_id: string; times_correct: number; times_wrong: number }) =>
      [h.question_id, h]
    )
  )

  const shuffle = <T,>(arr: T[]): T[] => arr.slice().sort(() => Math.random() - 0.5)

  // Partition every question by difficulty, then by history status
  const byDiff: Record<number, { unseen: Question[]; wrong: Question[]; correct: Question[] }> = {
    1: { unseen: [], wrong: [], correct: [] },
    2: { unseen: [], wrong: [], correct: [] },
    3: { unseen: [], wrong: [], correct: [] },
  }

  for (const q of allQuestions as Question[]) {
    const d = q.difficulty ?? 2
    const bucket = byDiff[d] ?? byDiff[2]
    const h = historyMap.get(q.id)
    if (!h) {
      bucket.unseen.push(q)
    } else if ((h as { times_wrong: number }).times_wrong > 0) {
      bucket.wrong.push(q)
    } else {
      bucket.correct.push(q)
    }
  }

  const selected: Question[] = []
  let masteredUsed = 0  // global cap on recycled-mastered questions

  // Phase 1 & 2: fill each difficulty bucket from unseen then prevWrong
  const shortfalls: { diff: number; need: number }[] = []

  for (const [diffStr, target] of Object.entries(DIFFICULTY_TARGETS)) {
    const diff = Number(diffStr)
    const { unseen, wrong, correct } = byDiff[diff]

    const picked: Question[] = []
    const pick = (pool: Question[], limit: number) => {
      const taken = shuffle(pool).slice(0, limit)
      picked.push(...taken)
    }

    pick(unseen, target)
    if (picked.length < target) pick(wrong, target - picked.length)

    selected.push(...picked)

    const remaining = target - picked.length
    if (remaining > 0) {
      // Record shortfall: needs mastered Qs or fallback
      shortfalls.push({ diff, need: remaining })
      // Stash the correct pool on byDiff so phase 3 can reach it
      byDiff[diff].correct = shuffle(correct)
    }
  }

  // Phase 3: fill shortfalls using mastered questions, globally capped
  for (const { diff, need } of shortfalls) {
    const correct = byDiff[diff].correct
    const canUse = Math.min(need, correct.length, MAX_CORRECT_RECYCLED - masteredUsed)
    if (canUse > 0) {
      selected.push(...correct.slice(0, canUse))
      masteredUsed += canUse
    }
  }

  // Phase 4: last-resort padding (e.g. section has very few hard questions)
  if (selected.length < QUESTIONS_PER_SESSION) {
    const selectedIds = new Set(selected.map(q => q.id))
    const remainder = shuffle(
      (allQuestions as Question[]).filter(q => !selectedIds.has(q.id))
    )
    selected.push(...remainder.slice(0, QUESTIONS_PER_SESSION - selected.length))
  }

  if (section === 'reading') return batchByPassage(selected)
  return selected
}

// ── Passage batching (reading section only) ───────────────────────────────────

function batchByPassage(questions: Question[]): Question[] {
  const passageGroups = new Map<string, Question[]>()
  const standalone: Question[] = []

  for (const q of questions) {
    if (q.passage_id) {
      const group = passageGroups.get(q.passage_id) ?? []
      group.push(q)
      passageGroups.set(q.passage_id, group)
    } else {
      standalone.push(q)
    }
  }

  return [...Array.from(passageGroups.values()).flat(), ...standalone]
}
