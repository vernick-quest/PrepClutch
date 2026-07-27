'use client'

import { useState } from 'react'
import { SECTION_BENCHMARKS_MS } from '@/lib/constants'
import type { Question, QuizAnswer, Section } from '@/types/database'

interface QuestionReviewCardProps {
  /** Null when the question row could not be resolved (legacy or deleted id). */
  question: Question | null
  answer?: QuizAnswer
  /** Reading questions carry a passage; only history shows it, results does not. */
  showPassage?: boolean
}

/** One question-review card. Shared by /results and the Quiz History review so
 *  the two views cannot drift apart. */
export default function QuestionReviewCard({ question, answer, showPassage = false }: QuestionReviewCardProps) {
  const [passageOpen, setPassageOpen] = useState(false)

  // Trust the answer's OWN correct_index, not the question's current one.
  // Options are positional, and migration 019 reshuffled every question — so
  // the live correct_index describes today's option order while the stored
  // selected_index describes the order at answer time. Comparing across the
  // two labelled correct answers as Wrong, and a card still reads correctly
  // when the question row is gone entirely.
  const correctIndex = answer?.correct_index ?? question?.correct_index ?? -1
  const isCorrect    = answer ? answer.selected_index === correctIndex : false

  // True when the option array has been reordered since this attempt, which
  // makes the stored indices point at the wrong text. Migration 028 remaps
  // historical answers; until it runs, suppress the option text rather than
  // show the student something they never chose.
  const staleOrder =
    !!question && !!answer &&
    answer.correct_index !== undefined &&
    answer.correct_index !== question.correct_index
  const timedOut     = answer?.selected_index === -1
  const qSection     = (answer?.section ?? question?.section) as Section
  // Reading records a per-question target: the first question of a passage
  // includes the time to read it, so it is not judged against the same
  // benchmark as follow-up questions.
  const benchmarkMs  = answer?.target_ms ?? SECTION_BENCHMARKS_MS[qSection] ?? 30000
  const benchmarkS   = (benchmarkMs / 1000).toFixed(0)
  const takenMs      = answer?.time_taken_ms ?? 0
  const takenS       = (takenMs / 1000).toFixed(1)
  const difficulty   = question?.difficulty ?? 2
  const diffLabel    = difficulty === 1 ? 'Easy' : difficulty === 3 ? 'Hard' : 'Medium'

  // Time color: green ≤ target, yellow ≤ 125% of target, red > 125%
  const overRatio    = takenMs / benchmarkMs
  const timeColor    = overRatio <= 1 ? '#10b981' : overRatio <= 1.25 ? '#f59e0b' : '#f43f5e'
  const timeBg       = overRatio <= 1 ? '#10b98118' : overRatio <= 1.25 ? '#f59e0b18' : '#f43f5e18'

  // Both indices address the option order as it was AT ANSWER TIME. If the
  // order has since changed, resolving them against today's options would show
  // text the student never saw, so show nothing rather than something false.
  const userAnswer    = (question && answer && answer.selected_index >= 0 && !staleOrder)
    ? question.options[answer.selected_index] : null
  const correctAnswer = (question && !staleOrder) ? question.options[correctIndex] : null

  return (
    <div
      className={`rounded-2xl border overflow-hidden ${
        isCorrect
          ? 'border-emerald-500/25 bg-emerald-500/5'
          : 'border-rose-500/25 bg-rose-500/5'
      }`}
    >
      {/* ── Topline ── */}
      <div className="flex flex-wrap items-center gap-x-4 gap-y-1.5 px-4 py-3 border-b border-white/5">
        {/* Correct / Wrong */}
        <span className="text-base font-bold shrink-0">
          {isCorrect ? '✅ Correct' : timedOut ? '⏰ Timed Out' : '❌ Wrong'}
        </span>

        {/* Difficulty dots — meaningless without the question row */}
        {question && (
          <div className="flex items-center gap-1 shrink-0">
            {[1, 2, 3].map(d => (
              <div
                key={d}
                className="w-2 h-2 rounded-full"
                style={{ backgroundColor: d <= difficulty ? '#f59e0b' : 'rgba(255,255,255,0.15)' }}
              />
            ))}
            <span className="text-xs text-zinc-500 ml-1">{diffLabel}</span>
          </div>
        )}

        {/* Time chip */}
        <div
          className="flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold shrink-0"
          style={{ color: timeColor, backgroundColor: timeBg }}
        >
          ⏱ {takenS}s
        </div>

        {/* Target time */}
        <span className="text-xs text-zinc-500 shrink-0">
          Target <span className="text-zinc-300 font-medium">{benchmarkS}s</span>
        </span>
      </div>

      {/* ── Body ── */}
      <div className="px-4 py-4 space-y-3">
        {!question ? (
          <p className="text-xs text-zinc-500 italic leading-relaxed">
            This question is no longer in the question bank, so it can&rsquo;t be reviewed.
          </p>
        ) : (
          <>
            {/* Passage — long, so it stays collapsed and scrolls when opened */}
            {showPassage && question.passage && (
              <div className="rounded-xl bg-white/5 border border-white/10 overflow-hidden">
                <button
                  onClick={() => setPassageOpen(o => !o)}
                  className="w-full flex items-center justify-between px-3 py-2 text-xs text-zinc-400 hover:text-white transition-colors"
                >
                  <span className="font-semibold uppercase tracking-wide">📖 Passage</span>
                  <span>{passageOpen ? '▲ hide' : '▼ show'}</span>
                </button>
                {passageOpen && (
                  <p className="px-3 pb-3 max-h-60 overflow-y-auto text-xs text-zinc-400 leading-relaxed whitespace-pre-line">
                    {question.passage}
                  </p>
                )}
              </div>
            )}

            {/* Question */}
            <p className="text-sm text-zinc-200 leading-relaxed font-medium">{question.prompt}</p>

            {/* Answers */}
            <div className="space-y-1.5">
              {/* Your answer — always shown */}
              <div className="flex items-start gap-2">
                <span className="text-xs text-zinc-500 shrink-0 mt-0.5 w-24">Your answer:</span>
                {userAnswer ? (
                  <span className={`text-xs font-medium ${isCorrect ? 'text-emerald-400' : 'text-rose-400'}`}>
                    {userAnswer}
                  </span>
                ) : (
                  <span className="text-xs text-zinc-600 italic">No answer (timed out)</span>
                )}
              </div>

              {/* Correct answer — always shown if wrong, or as confirmation if right */}
              {!isCorrect && correctAnswer && (
                <div className="flex items-start gap-2">
                  <span className="text-xs text-zinc-500 shrink-0 mt-0.5 w-24">Correct answer:</span>
                  <span className="text-xs font-medium text-emerald-400">{correctAnswer}</span>
                </div>
              )}
            </div>

            {staleOrder && (
              <div className="pt-2 border-t border-white/5">
                <p className="text-xs text-amber-400/80 leading-relaxed">
                  ⓘ The answer choices for this question were reordered after this
                  quiz was taken, so the specific option you picked can no longer be
                  shown. Your result and points are unaffected.
                </p>
              </div>
            )}

            {/* Rationale — always shown */}
            {question.explanation && (
              <div className="pt-2 border-t border-white/5">
                <p className="text-xs text-zinc-500 font-semibold mb-1 uppercase tracking-wide">💡 Rationale</p>
                <p className="text-xs text-zinc-400 leading-relaxed">{question.explanation}</p>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}
