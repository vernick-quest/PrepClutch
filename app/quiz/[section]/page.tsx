import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTIONS, QUESTIONS_PER_SESSION, MAX_CORRECT_RECYCLED } from '@/lib/constants'
import QuizClient from '@/components/quiz/QuizClient'
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

  const unseen:      Question[] = []
  const prevWrong:   Question[] = []
  const prevCorrect: Question[] = []

  for (const q of allQuestions) {
    const h = historyMap.get(q.id)
    if (!h) {
      unseen.push(q)
    } else if ((h as { times_wrong: number }).times_wrong > 0) {
      prevWrong.push(q)
    } else {
      prevCorrect.push(q)
    }
  }

  const shuffle = <T,>(arr: T[]): T[] => arr.slice().sort(() => Math.random() - 0.5)

  const selected: Question[] = []

  const pickUp = (pool: Question[], limit: number) => {
    const taken = shuffle(pool).slice(0, limit)
    selected.push(...taken)
  }

  // Priority 1: unseen
  pickUp(unseen, QUESTIONS_PER_SESSION)

  // Priority 2: previously wrong
  if (selected.length < QUESTIONS_PER_SESSION) {
    pickUp(prevWrong, QUESTIONS_PER_SESSION - selected.length)
  }

  // Priority 3: previously correct — hard cap at MAX_CORRECT_RECYCLED
  // unless the entire pool is exhausted (unseen + wrong < session size)
  if (selected.length < QUESTIONS_PER_SESSION) {
    const poolExhausted = unseen.length + prevWrong.length < QUESTIONS_PER_SESSION
    const cap = poolExhausted
      ? QUESTIONS_PER_SESSION - selected.length
      : Math.min(QUESTIONS_PER_SESSION - selected.length, MAX_CORRECT_RECYCLED)
    pickUp(prevCorrect, cap)
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
