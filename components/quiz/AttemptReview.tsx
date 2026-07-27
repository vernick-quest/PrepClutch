'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import QuestionReviewCard from './QuestionReviewCard'
import type { Question, QuizAnswer } from '@/types/database'

interface AttemptReviewProps {
  answers: QuizAnswer[]
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

/** Collapsed-by-default review of one past attempt. Question text is not stored
 *  on the attempt, so it is fetched on first expand — a student can have dozens
 *  of attempts and eager-loading every one of them would stall the page. */
export default function AttemptReview({ answers }: AttemptReviewProps) {
  const [open, setOpen]         = useState(false)
  const [questions, setQuestions] = useState<Map<string, Question> | null>(null)
  const [loading, setLoading]   = useState(false)
  const [error, setError]       = useState(false)

  async function load() {
    setLoading(true)
    setError(false)
    // Legacy attempts stored non-UUID question ids (e.g. "bio-q1"); passing one
    // to a uuid column makes Postgres reject the whole query.
    const ids = [...new Set(answers.map(a => a.question_id).filter(id => UUID_RE.test(id)))]

    if (ids.length === 0) {
      setQuestions(new Map())
      setLoading(false)
      return
    }

    const supabase = createClient()
    const { data, error: err } = await supabase
      .from('questions')
      .select('id, section, prompt, passage, passage_id, options, correct_index, difficulty, explanation')
      .in('id', ids)

    if (err) {
      setError(true)
      setLoading(false)
      return
    }

    setQuestions(new Map((data as Question[]).map(q => [q.id, q])))
    setLoading(false)
  }

  function toggle() {
    const next = !open
    setOpen(next)
    if (next && questions === null && !loading) load()
  }

  return (
    <div className="border-t border-white/5">
      <button
        onClick={toggle}
        className="w-full flex items-center justify-between px-4 py-2.5 text-xs text-zinc-400 hover:text-white transition-colors"
      >
        <span className="font-semibold">📋 Review answers ({answers.length})</span>
        <span>{open ? '▲ collapse' : '▼ expand'}</span>
      </button>

      {open && (
        <div className="px-4 pb-4">
          {loading && <p className="text-xs text-zinc-500 py-2">Loading questions…</p>}

          {error && (
            <div className="flex items-center justify-between gap-3 py-2">
              <p className="text-xs text-rose-400">Couldn&rsquo;t load this review.</p>
              <button
                onClick={load}
                className="text-xs font-semibold text-amber-400 hover:underline shrink-0"
              >
                Try again
              </button>
            </div>
          )}

          {questions && !loading && !error && (
            <div className="space-y-3">
              {answers.map((a, i) => (
                <QuestionReviewCard
                  key={`${a.question_id}-${i}`}
                  question={questions.get(a.question_id) ?? null}
                  answer={a}
                  showPassage
                />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
