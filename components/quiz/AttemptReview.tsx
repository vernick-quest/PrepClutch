'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import QuestionReviewCard from './QuestionReviewCard'
import type { Question, QuizAnswer } from '@/types/database'

interface AttemptReviewProps {
  answers: QuizAnswer[]
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// The retired hardcoded reading flow stored these ids. Migration 014 adopted
// the same questions into the bank as md5(legacy_id)::UUID, so past attempts
// can still be reviewed.
const LEGACY_ID_MAP: Record<string, string> = {
  'bio-q1':  '4f9d48ee-9826-f1ad-2f8b-67f5c34044b5',
  'bio-q2':  '6aece053-77e4-5a6d-1fd1-e61c74d95adf',
  'bio-q3':  '878e86fb-0f98-82c7-2018-77041a518c35',
  'silk-q1': '85a4174f-84d9-130e-4b8e-d513539d2c1f',
  'silk-q2': '36e0ad62-b027-c3a4-9f6e-300aa44397c9',
  'silk-q3': '093b3182-2c25-f2a9-e1e4-61e94fc2bd41',
  'silk-q4': '2c2c4ecf-7ad0-c4bc-0408-5c6f9c98d615',
  'obs-q1':  'c8cd25f9-47f5-ed72-b125-51ba94c56cbf',
  'obs-q2':  'd283274f-a160-2db2-4211-394daf244d16',
  'obs-q3':  '7d517cbd-41d2-de6e-1ae4-26ad6a7a886a',
}

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
    // to a uuid column makes Postgres reject the whole query. Those questions
    // were later adopted into the bank under md5(legacy_id)::UUID by migration
    // 014, so map them across rather than showing them as unavailable.
    const ids = [...new Set(
      answers
        .map(a => LEGACY_ID_MAP[a.question_id] ?? a.question_id)
        .filter(id => UUID_RE.test(id))
    )]

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

    // Key by the id the ANSWER carries, so legacy answers resolve too.
    const byId = new Map((data as Question[]).map(q => [q.id, q]))
    const resolved = new Map<string, Question>()
    for (const a of answers) {
      const q = byId.get(LEGACY_ID_MAP[a.question_id] ?? a.question_id)
      if (q) resolved.set(a.question_id, q)
    }
    setQuestions(resolved)
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
