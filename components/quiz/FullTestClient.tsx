'use client'

// ── Full practice test ───────────────────────────────────────────────────────
//
// Five sections back to back, each behaving exactly as it does on its own —
// reading in particular keeps its passage-based timer instead of the flat
// per-question countdown the other sections use.
//
// Before this existed, `full` ran every section through QuizClient, which gave
// a reading question 60 seconds to read a 250-word passage AND answer. It also
// picked reading questions individually rather than by passage, so a student
// faced roughly ten different passages for one question each. Both are gone:
// the blocks below are built by the same selectors the solo quizzes use.
//
// Answers accumulate here and are written ONCE at the end, as a single
// `full` attempt. Recording per section would show as five separate quizzes in
// history and run the badge evaluation five times.

import { useState, useRef, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { SECTION_CONFIG } from '@/lib/constants'
import { finishAndRecordQuiz } from '@/lib/finish-quiz'
import QuizClient from '@/components/quiz/QuizClient'
import ReadingQuizClient from '@/components/quiz/ReadingQuizClient'
import type { ReadingPassage } from '@/lib/reading-passages'
import type { Section, Question, QuizAnswer } from '@/types/database'

export type FullTestBlock =
  | { kind: 'reading';  section: 'reading'; passages: ReadingPassage[] }
  | { kind: 'standard'; section: Section;   questions: Question[] }

interface Props {
  blocks: FullTestBlock[]
  userId: string
  masteredIds: string[]
}

function blockLength(b: FullTestBlock): number {
  return b.kind === 'reading'
    ? b.passages.reduce((s, p) => s + p.questions.length, 0)
    : b.questions.length
}

export default function FullTestClient({ blocks, userId, masteredIds }: Props) {
  const router = useRouter()

  const [idx, setIdx]     = useState(0)
  const [phase, setPhase] = useState<'quiz' | 'break' | 'saving'>('quiz')

  // Refs, not state: these are appended from a child's completion callback and
  // read again immediately on the final section. State would still hold the
  // previous value at that point and the last section's answers would be lost.
  const answersRef   = useRef<QuizAnswer[]>([])
  const questionsRef = useRef<Question[]>([])
  const savingRef    = useRef(false)

  const total = useMemo(() => blocks.reduce((s, b) => s + blockLength(b), 0), [blocks])

  // Questions completed before block i. Each block always yields exactly one
  // answer per question (timeouts included, as -1), so this doubles as the
  // running answered-count without reading the accumulator during render.
  const offsets = useMemo(
    () => blocks.map((_, i) => blocks.slice(0, i).reduce((s, b) => s + blockLength(b), 0)),
    [blocks],
  )

  const finishTest = useCallback(async () => {
    if (savingRef.current) return   // never write the attempt twice
    savingRef.current = true
    setPhase('saving')
    await finishAndRecordQuiz({
      supabase: createClient(),
      userId,
      section:  'full',
      // answers[i] must line up with questions[i] — the results page derives
      // its per-section breakdown by index, not by looking up question_id.
      answers:   answersRef.current,
      questions: questionsRef.current,
      masteredIds,
    })
    router.replace('/results')
  }, [userId, masteredIds, router])

  const handleBlockComplete = useCallback((answers: QuizAnswer[], questions: Question[]) => {
    answersRef.current   = [...answersRef.current, ...answers]
    questionsRef.current = [...questionsRef.current, ...questions]

    if (idx < blocks.length - 1) setPhase('break')
    else finishTest()
  }, [idx, blocks.length, finishTest])

  if (phase === 'saving') {
    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-center">
          <p className="text-4xl mb-4 animate-pulse">🎯</p>
          <p className="text-zinc-400">Scoring your full practice test…</p>
        </div>
      </div>
    )
  }

  // ── Section break ─────────────────────────────────────────────────────────
  // A gate between sections, not just a pause. Reading starts its passage
  // clock the moment it mounts, so dropping a student straight into it from
  // the last question of the previous section would burn their reading time
  // before they had looked up.
  if (phase === 'break') {
    const done = idx + 1
    const next = blocks[done]
    const cfg  = SECTION_CONFIG[next.section as Section]
    const answered = offsets[done]

    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4">
        <div className="max-w-md w-full text-center space-y-6">
          <div>
            <p className="text-5xl mb-3">✅</p>
            <h1 className="text-2xl font-black text-white">
              {SECTION_CONFIG[blocks[idx].section as Section].label} complete
            </h1>
            <p className="text-zinc-500 text-sm mt-2">
              {answered} of {total} questions answered · {blocks.length - done} section
              {blocks.length - done === 1 ? '' : 's'} to go
            </p>
          </div>

          <div className="h-2 bg-white/10 rounded-full overflow-hidden">
            <div
              className="h-full rounded-full bg-amber-500 transition-all duration-500"
              style={{ width: `${(answered / total) * 100}%` }}
            />
          </div>

          <div className={`rounded-2xl border ${cfg.border} ${cfg.bg} p-5`}>
            <p className="text-xs text-zinc-500 uppercase tracking-wide mb-1">Up next</p>
            <p className={`text-lg font-bold ${cfg.color}`}>{cfg.emoji} {cfg.label}</p>
            <p className="text-zinc-500 text-xs mt-1">{blockLength(next)} questions</p>
          </div>

          <button
            onClick={() => { setIdx(done); setPhase('quiz') }}
            className="w-full bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
          >
            Start {cfg.label} →
          </button>

          <p className="text-zinc-600 text-xs">
            The timer starts when you tap. Your answers are all reviewed at the end.
          </p>
        </div>
      </div>
    )
  }

  // ── Active section ────────────────────────────────────────────────────────
  const block  = blocks[idx]
  const offset = offsets[idx]

  // key={idx} forces a fresh mount per section, so timers and internal
  // position state reset instead of carrying over from the previous one.
  return block.kind === 'reading' ? (
    <ReadingQuizClient
      key={idx}
      passages={block.passages}
      userId={userId}
      masteredIds={masteredIds}
      embedded
      onComplete={handleBlockComplete}
      questionOffset={offset}
      totalOverride={total}
      revealFeedback={false}
    />
  ) : (
    <QuizClient
      key={idx}
      section={block.section}
      questions={block.questions}
      userId={userId}
      masteredIds={masteredIds}
      embedded
      onComplete={handleBlockComplete}
      questionOffset={offset}
      totalOverride={total}
    />
  )
}
