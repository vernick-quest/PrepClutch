'use client'

// ── Training walkthrough ─────────────────────────────────────────────────────
//
// One question at a time, easiest first, explained immediately. The opposite of
// a quiz in every way that matters:
//
//   no timer         the point is understanding, not pace
//   no score         nothing here touches Clutch Points or mastery
//   no auto-advance  the student decides when they have finished reading
//
// Questions come from `training_questions`, a table no scoring query can see,
// so none of this can move a section total.

import { useState, useEffect, useCallback } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { SECTION_CONFIG, DIFF_NAME } from '@/lib/constants'
import type { Section } from '@/types/database'

export interface TrainingQuestion {
  id: string
  section: string
  prompt: string
  passage: string | null
  options: string[]
  correct_index: number
  difficulty: number
  explanation: string
  /** One note per choice. Authored training questions always have them; quiz
   *  questions revisited in review mode have only the single explanation. */
  option_notes?: string[]
  /** Optional named pattern this question teaches, e.g. "Analogies — part to
   *  whole". Absent until migration 060 adds it. */
  concept?: string | null
}

const DIFF_COLOR: Record<number, string> = { 1: '#10b981', 2: '#f59e0b', 3: '#f43f5e' }
const LETTER = ['A', 'B', 'C', 'D']

export default function TrainingClient({
  section, questions, mastered = 0, review,
}: {
  section: Section
  questions: TrainingQuestion[]
  /** Quiz questions this student has mastered in the section — shown as a way
   *  into review mode. */
  mastered?: number
  /** Set when revisiting mastered quiz questions rather than the authored set. */
  review?: { difficulty: number; available: number }
}) {
  const cfg = SECTION_CONFIG[section]
  const router = useRouter()
  // Review rounds are a fresh random draw each time, so a saved position would
  // point at a different question. Only the authored set resumes.
  const storageKey = review ? null : `prepclutch:training:${section}`
  const reviewHref = `/training/${section}/review`

  const [idx, setIdx]           = useState(0)
  const [selected, setSelected] = useState<number | null>(null)
  const [locked, setLocked]     = useState(false)
  const [restored, setRestored] = useState(false)

  const total = questions.length
  const q     = questions[Math.min(idx, total - 1)]

  // Resume where they left off. Browser-only and best-effort: cleared storage
  // just starts them at the beginning, which is a fine outcome for training.
  //
  // `restored` must be STATE, not a ref, even though the lint rule below would
  // be satisfied by a ref. Effects run in declaration order: with a ref, the
  // save effect would fire on the same pass with `idx` still 0 and overwrite
  // the saved position with zero before the restore ever took. The setState
  // forces a re-render, so the save effect re-runs seeing the restored index.
  useEffect(() => {
    if (!storageKey) return
    try {
      const saved = Number(window.localStorage.getItem(storageKey))
      // Reading localStorage requires an effect — it does not exist during the
      // server render — so restoring position is necessarily a setState here.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (Number.isFinite(saved) && saved > 0 && saved < total) setIdx(saved)
    } catch { /* private mode or blocked storage */ }
    setRestored(true)
  }, [storageKey, total])

  useEffect(() => {
    if (!restored || !storageKey) return
    try { window.localStorage.setItem(storageKey, String(idx)) } catch { /* ignore */ }
  }, [idx, storageKey, restored])

  const choose = useCallback((i: number) => {
    if (locked) return
    setSelected(i)
    setLocked(true)
  }, [locked])

  const next = useCallback(() => {
    setSelected(null)
    setLocked(false)
    setIdx(i => i + 1)
  }, [])

  const restart = useCallback(() => {
    setIdx(0); setSelected(null); setLocked(false)
    if (storageKey) {
      try { window.localStorage.removeItem(storageKey) } catch { /* ignore */ }
    }
  }, [storageKey])

  // ── Finished ──────────────────────────────────────────────────────────────
  if (idx >= total) {
    if (review) {
      const more = review.available > total
      return (
        <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4">
          <div className="max-w-md w-full text-center space-y-6">
            <p className="text-5xl">⭐</p>
            <div>
              <h1 className="text-2xl font-black text-white">Review round done</h1>
              <p className="text-zinc-500 text-sm mt-2">
                You went back over {total} {DIFF_NAME[review.difficulty]} {cfg.label} question{total === 1 ? '' : 's'}.
                Your score and mastery are exactly as they were.
              </p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => { restart(); router.refresh() }}
                className="bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors"
              >
                {more ? '↻ Another round' : '↺ Go again'}
              </button>
              <Link
                href={reviewHref}
                className="flex items-center justify-center bg-sky-500 hover:bg-sky-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
              >
                Pick a level
              </Link>
            </div>
            <Link href="/" className="block text-sm text-zinc-500 hover:text-white transition-colors">Dashboard</Link>
          </div>
        </div>
      )
    }
    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4">
        <div className="max-w-md w-full text-center space-y-6">
          <p className="text-5xl">🧠</p>
          <div>
            <h1 className="text-2xl font-black text-white">{cfg.label} training complete</h1>
            <p className="text-zinc-500 text-sm mt-2">
              You worked through all {total} questions. None of it counted toward your
              score.
            </p>
          </div>
          {/* No hand-off into a quiz. Training ends at understanding; the
              student decides when they are ready to be timed and scored. */}
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={restart}
              className="bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors"
            >
              ↺ Start over
            </button>
            <Link
              href="/"
              className="flex items-center justify-center bg-sky-500 hover:bg-sky-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
            >
              Dashboard
            </Link>
          </div>
          {/* Quizzes stop serving a question once it is answered correctly, so
              this is the only way back to those — and it is still training. */}
          {mastered > 0 && (
            <Link
              href={reviewHref}
              className="block rounded-2xl border border-amber-500/30 bg-amber-500/10 hover:bg-amber-500/15 px-4 py-4 transition-colors"
            >
              <p className="font-bold text-amber-200">⭐ Review questions you&rsquo;ve mastered</p>
              <p className="text-xs text-amber-200/70 mt-1">
                {mastered} {cfg.label} quiz question{mastered === 1 ? '' : 's'} you got right · pick Easy, Medium or Hard
              </p>
            </Link>
          )}
        </div>
      </div>
    )
  }

  const isCorrect = locked && selected === q.correct_index
  const hasNotes  = (q.option_notes?.length ?? 0) > 0

  function optionStyle(i: number): string {
    if (!locked) {
      return 'bg-white/5 border-white/10 text-zinc-200 hover:bg-white/8 hover:border-white/25'
    }
    if (i === q.correct_index) return 'bg-emerald-500/15 border-emerald-500/50 text-emerald-100'
    if (i === selected)        return 'bg-rose-500/15 border-rose-500/45 text-rose-100'
    return 'bg-white/[0.02] border-white/8 text-zinc-400'
  }

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex flex-col">
      {/* Top bar. No timer here, deliberately. */}
      <div className="sticky top-0 z-30 border-b border-white/5 bg-[#0a0a0f]/90 backdrop-blur-sm">
        <div className="max-w-3xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href={review ? reviewHref : '/'} className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">
            ← Exit
          </Link>
          <div className="flex-1">
            <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full bg-sky-400 transition-all duration-300"
                style={{ width: `${(idx / total) * 100}%` }}
              />
            </div>
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{idx + 1} / {total}</span>
        </div>
      </div>

      <div className="flex-1 max-w-3xl mx-auto w-full px-4 py-8">
        <div className="flex items-center gap-2 mb-5 flex-wrap">
          <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-sky-500/10 border border-sky-500/30 text-sky-300">
            {review ? '⭐ Review' : '🧠 Training'}
          </span>
          <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${cfg.bg} border ${cfg.border} ${cfg.color}`}>
            {cfg.emoji} {cfg.label}
          </span>
          <span
            className="text-xs font-semibold px-2.5 py-1 rounded-full border"
            style={{
              color: DIFF_COLOR[q.difficulty],
              borderColor: DIFF_COLOR[q.difficulty] + '50',
              backgroundColor: DIFF_COLOR[q.difficulty] + '15',
            }}
          >
            {DIFF_NAME[q.difficulty] ?? 'Medium'}
          </span>
          {q.concept && (
            <span className="text-xs text-zinc-500 px-2.5 py-1 rounded-full bg-white/5 border border-white/10">
              {q.concept}
            </span>
          )}
          {!review && mastered > 0 && (
            <Link href={reviewHref} className="ml-auto text-xs text-amber-300/80 hover:text-amber-200 transition-colors">
              ⭐ Review {mastered} mastered →
            </Link>
          )}
        </div>

        {q.passage && (
          <div className="mb-5 rounded-2xl bg-white/3 border border-white/10 p-5 max-h-72 overflow-y-auto">
            {q.passage.split('\n\n').map((para, i) => (
              <p key={i} className={`text-sm text-zinc-300 leading-relaxed ${i > 0 ? 'mt-4' : ''}`}>
                {para}
              </p>
            ))}
          </div>
        )}

        <p className="text-lg font-semibold text-white leading-relaxed whitespace-pre-line mb-5">
          {q.prompt}
        </p>

        {/* Once answered, EVERY option explains itself — not just the one the
            student picked. A student who guessed right needs to see why the
            other three fail, or they learn nothing from the guess. */}
        <div className="space-y-2.5">
          {q.options.map((opt, i) => {
            const isAnswer = i === q.correct_index
            const isPick   = i === selected
            return (
              <button
                key={`${q.id}-${i}`}
                onClick={() => choose(i)}
                disabled={locked}
                className={`w-full rounded-2xl border text-left transition-all disabled:cursor-default ${optionStyle(i)}`}
              >
                <div className="flex items-start gap-3 p-4">
                  <span className="text-xs font-black opacity-60 shrink-0 mt-0.5 w-4">{LETTER[i] ?? i + 1}</span>
                  <span className="text-sm leading-relaxed flex-1">{opt}</span>
                  {locked && isPick && (
                    <span className="shrink-0 text-[10px] font-bold uppercase tracking-wide opacity-70 mt-0.5">Your pick</span>
                  )}
                  {locked && (isAnswer
                    ? <span className="shrink-0 text-emerald-400">✓</span>
                    : <span className={`shrink-0 ${isPick ? 'text-rose-400' : 'text-zinc-600'}`}>✗</span>)}
                </div>
                {locked && q.option_notes?.[i] && (
                  <p className={`px-4 pb-4 pl-11 -mt-1 text-[13px] leading-relaxed ${
                    isAnswer ? 'text-emerald-200/90' : isPick ? 'text-rose-200/90' : 'text-zinc-500'
                  }`}>
                    {q.option_notes?.[i]}
                  </p>
                )}
              </button>
            )
          })}
        </div>

        {locked && (
          <div className="mt-5 space-y-3">
            <div className={`rounded-2xl border px-4 py-3 ${
              isCorrect ? 'bg-emerald-500/8 border-emerald-500/25' : 'bg-rose-500/8 border-rose-500/25'
            }`}>
              <p className={`text-sm font-bold ${isCorrect ? 'text-emerald-300' : 'text-rose-300'}`}>
                {isCorrect
                  ? hasNotes
                    ? '✅ Correct! Read why the other three don\u2019t work — that is where the learning is.'
                    : '✅ Correct! Read the explanation below to make sure it wasn\u2019t a lucky guess.'
                  : hasNotes
                    ? `❌ Not quite — the answer is ${LETTER[q.correct_index]}. Each choice is explained above.`
                    : `❌ Not quite — the answer is ${LETTER[q.correct_index]}. The explanation is below.`}
              </p>
            </div>

            {/* The method, shown whether they were right or wrong. */}
            {q.explanation && <div className="rounded-2xl border border-white/10 bg-white/3 p-4">
              <p className="text-xs font-bold uppercase tracking-wide text-zinc-500 mb-1.5">
                💡 How to get there
              </p>
              <p className="text-sm text-zinc-300 leading-relaxed">{q.explanation}</p>
            </div>}

            <button
              onClick={next}
              className="w-full bg-sky-500 hover:bg-sky-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
            >
              {idx === total - 1 ? (review ? 'Finish review →' : 'Finish training →') : 'Next question →'}
            </button>
          </div>
        )}

        {!locked && (
          <p className="text-center text-xs text-zinc-600 mt-6">
            Take your time — nothing here is timed or scored.
          </p>
        )}
      </div>
    </div>
  )
}
