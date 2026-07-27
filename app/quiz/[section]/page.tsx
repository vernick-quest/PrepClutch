import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTIONS, QUESTIONS_PER_SESSION, MAX_CORRECT_RECYCLED } from '@/lib/constants'
import QuizClient from '@/components/quiz/QuizClient'
import ReadingQuizClient from '@/components/quiz/ReadingQuizClient'
import { buildPassagesFromRows, PASSAGES_PER_SESSION, MAX_QUESTIONS_PER_PASSAGE, VOCAB_PER_SESSION } from '@/lib/reading-passages'
import type { ReadingPassage, ReadingQuestionRow } from '@/lib/reading-passages'
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

  // Reading section uses the dedicated passage-based quiz flow.
  // Questions come from the `questions` table so their real UUIDs can be
  // recorded in user_question_history — that join is what feeds the section
  // total. Never serve reading from a hardcoded list. (See migration 008.)
  if (section === 'reading') {
    const passages = await selectReadingPassages(supabase, user.id)
    if (passages.length === 0) notFound()

    const masteredIds = await fetchMasteredIds(
      supabase,
      user.id,
      passages.flatMap(p => p.questions.map(q => q.id)),
    )

    return (
      <ReadingQuizClient
        passages={passages}
        userId={user.id}
        masteredIds={masteredIds}
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

  const masteredIds = await fetchMasteredIds(supabase, user.id, questions.map(q => q.id))

  return (
    <QuizClient
      section={section as Section | 'full'}
      questions={questions}
      userId={user.id}
      masteredIds={masteredIds}
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

// Questions the student had ALREADY mastered before this session started.
// Re-answering one of these is free review: it scores points for the session
// but adds nothing to the section total, which is only ever raised by newly
// mastered questions. The clients use this to report the two figures
// separately instead of implying every point earned is a point gained.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function fetchMasteredIds(supabase: any, userId: string, questionIds: string[]): Promise<string[]> {
  if (questionIds.length === 0) return []

  const { data } = await supabase
    .from('user_question_history')
    .select('question_id, times_correct')
    .eq('user_id', userId)
    .in('question_id', questionIds)

  return (data ?? [])
    .filter((h: { times_correct: number }) => h.times_correct > 0)
    .map((h: { question_id: string }) => h.question_id)
}

// ── Reading passage selection ────────────────────────────────────────────────
//
// Reading is selected a passage at a time (a passage and its questions are
// inseparable), so the per-difficulty targets used by the other sections do not
// apply. Instead we prefer passages the student has the most left to master,
// which keeps sessions fresh without ever repeating a fully-mastered passage
// while unmastered ones remain.

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function selectReadingPassages(supabase: any, userId: string): Promise<ReadingPassage[]> {
  const { data: rows } = await supabase
    .from('questions')
    .select('id, prompt, passage, passage_id, options, correct_index, difficulty, explanation')
    .eq('section', 'reading')

  if (!rows || rows.length === 0) return []

  const all = rows as ReadingQuestionRow[]
  const passages = buildPassagesFromRows(all.filter(r => r.passage))
  const vocabPool = all.filter(r => !r.passage)

  const { data: history } = await supabase
    .from('user_question_history')
    .select('question_id, times_correct')
    .eq('user_id', userId)
    .in('question_id', all.map(r => r.id))

  const mastered = new Set(
    (history ?? [])
      .filter((h: { times_correct: number }) => h.times_correct > 0)
      .map((h: { question_id: string }) => h.question_id)
  )

  const shuffle = <T,>(arr: T[]): T[] => {
    const out = arr.slice()
    for (let i = out.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[out[i], out[j]] = [out[j], out[i]]
    }
    return out
  }

  // Rank by the SHARE of a passage still unmastered, not the raw count.
  // Ranking on the count alone made bigger passages win every time — the
  // 7-question printing-press passage outranked everything and was served
  // to every student, every session.
  const ranked = passages
    .map(p => ({
      passage:  p,
      progress: p.questions.filter(q => !mastered.has(q.id)).length / p.questions.length,
      tiebreak: Math.random(),
    }))
    .filter(r => r.progress > 0)
    .sort((a, b) => b.progress - a.progress || a.tiebreak - b.tiebreak)

  // Fall back to fully-mastered passages only once nothing fresh is left.
  const pool = ranked.length >= PASSAGES_PER_SESSION
    ? ranked
    : [...ranked, ...shuffle(passages.filter(p => !ranked.some(r => r.passage.id === p.id))).map(p => ({ passage: p, progress: 0, tiebreak: 0 }))]

  const chosen: ReadingPassage[] = pool.slice(0, PASSAGES_PER_SESSION).map(r => {
    // Unmastered questions first, then mastered as filler, capped so session
    // length does not swing with passage size.
    const unseen = shuffle(r.passage.questions.filter(q => !mastered.has(q.id)))
    const seen   = shuffle(r.passage.questions.filter(q =>  mastered.has(q.id)))
    return { ...r.passage, questions: [...unseen, ...seen].slice(0, MAX_QUESTIONS_PER_PASSAGE) }
  })

  // Standalone vocabulary, unmastered first, carried as a body-less passage so
  // the client renders it without a passage panel.
  const vocabUnseen = shuffle(vocabPool.filter(r => !mastered.has(r.id)))
  const vocabSeen   = shuffle(vocabPool.filter(r =>  mastered.has(r.id)))
  const vocab = [...vocabUnseen, ...vocabSeen].slice(0, VOCAB_PER_SESSION)

  if (vocab.length > 0) {
    chosen.push({
      id:    'vocabulary',
      title: 'Vocabulary',
      body:  '',
      questions: vocab.map(r => ({
        id:           r.id,
        text:         r.prompt,
        options:      r.options,
        correctIndex: r.correct_index,
        difficulty:   (r.difficulty as 1 | 2 | 3) ?? 2,
        explanation:  r.explanation ?? '',
      })),
    })
  }

  return chosen
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function selectSectionQuestions(supabase: any, userId: string, section: string): Promise<Question[]> {
  const { data: allQuestions } = await supabase
    .from('questions')
    .select('*')
    .eq('section', section)

  if (!allQuestions || allQuestions.length === 0) return []

  const { data: history } = await supabase
    .from('user_question_history')
    .select('question_id, times_correct, times_wrong, last_answered_at')
    .eq('user_id', userId)
    .in('question_id', allQuestions.map((q: Question) => q.id))

  const historyMap = new Map(
    (history ?? []).map((h: { question_id: string; times_correct: number; times_wrong: number }) =>
      [h.question_id, h]
    )
  )

  // Fisher-Yates. NOT `sort(() => Math.random() - 0.5)` — a random comparator
  // does not produce uniform permutations, and the bias is severe: picking 3
  // of 10, the first element surfaced in ~42% of sessions and the ninth in
  // ~22%. Questions late in the array were effectively starved, which is why
  // students could not reach their last few unseen questions.
  const shuffle = <T,>(arr: T[]): T[] => {
    const out = arr.slice()
    for (let i = out.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[out[i], out[j]] = [out[j], out[i]]
    }
    return out
  }

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
    const pick = (pool: Question[], limit: number, randomise = true) => {
      const taken = (randomise ? shuffle(pool) : pool).slice(0, limit)
      picked.push(...taken)
    }

    // Unseen questions are interchangeable, so shuffle them. Previously-missed
    // ones are not: taking them at random leaves a coupon-collector tail where
    // the last few keep not coming up. Ordering oldest-seen-first guarantees
    // every missed question cycles back instead of relying on luck.
    const wrongOldestFirst = wrong.slice().sort((a, b) => {
      const at = (historyMap.get(a.id) as { last_answered_at?: string } | undefined)?.last_answered_at ?? ''
      const bt = (historyMap.get(b.id) as { last_answered_at?: string } | undefined)?.last_answered_at ?? ''
      return at.localeCompare(bt)
    })

    pick(unseen, target)
    if (picked.length < target) pick(wrongOldestFirst, target - picked.length, false)

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
