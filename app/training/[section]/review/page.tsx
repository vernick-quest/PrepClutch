import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTIONS, SECTION_CONFIG, DIFF_NAME } from '@/lib/constants'
import { masteredCounts, masteredRound, REVIEW_ROUND } from '@/lib/mastered-review'
import TrainingClient from '@/components/training/TrainingClient'
import type { Section } from '@/types/database'

export const dynamic = 'force-dynamic'

interface Props {
  params: Promise<{ section: string }>
  searchParams: Promise<{ level?: string }>
}

const LEVEL_STYLE: Record<number, string> = {
  1: 'border-emerald-500/40 bg-emerald-500/10 text-emerald-300',
  2: 'border-amber-500/40 bg-amber-500/10 text-amber-300',
  3: 'border-rose-500/40 bg-rose-500/10 text-rose-300',
}

// Questions the student already got right in a quiz, offered back as training.
// No level chosen → the Easy / Medium / Hard picker. Level chosen → a random
// round of up to REVIEW_ROUND at that difficulty, in the training walkthrough.
export default async function ReviewPage({ params, searchParams }: Props) {
  const { section } = await params
  const { level } = await searchParams
  if (!SECTIONS.includes(section as Section)) notFound()
  const cfg = SECTION_CONFIG[section as Section]

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const difficulty = Number(level)
  if (difficulty === 1 || difficulty === 2 || difficulty === 3) {
    const { questions, available } = await masteredRound(supabase, user.id, section, difficulty)
    if (questions.length === 0) redirect(`/training/${section}/review`)
    return (
      <TrainingClient
        // A new round is a new set: remount so it starts at question 1.
        key={questions.map(q => q.id).join()}
        section={section as Section}
        questions={questions}
        review={{ difficulty, available }}
      />
    )
  }

  const counts = await masteredCounts(supabase, user.id, section)
  const total = counts[1] + counts[2] + counts[3]

  return (
    <div className="min-h-screen bg-[#0a0a0f] px-4 py-10">
      <div className="max-w-md mx-auto space-y-6">
        <Link href="/" className="text-zinc-500 hover:text-white text-sm transition-colors">← Dashboard</Link>
        <div className="text-center space-y-2">
          <p className="text-5xl">⭐</p>
          <h1 className="text-2xl font-black text-white">{cfg.emoji} {cfg.label} review</h1>
          <p className="text-zinc-500 text-sm">
            Quiz questions you&rsquo;ve already answered correctly. Quizzes stop
            showing these once you get them right, so this is where to revisit them.
            Not timed, and it can&rsquo;t change your score.
          </p>
        </div>

        {total === 0 ? (
          <p className="text-center text-zinc-400 text-sm rounded-2xl border border-white/10 bg-white/3 p-5">
            Nothing here yet. Every {cfg.label} quiz question you get right will show up here.
          </p>
        ) : (
          <div className="space-y-2.5">
            {([1, 2, 3] as const).map(d => counts[d] > 0 ? (
              <Link
                key={d}
                href={`/training/${section}/review?level=${d}`}
                className={`flex items-center justify-between rounded-2xl border px-5 py-4 font-bold transition-all hover:scale-[1.01] ${LEVEL_STYLE[d]}`}
              >
                <span>{DIFF_NAME[d]}</span>
                <span className="text-sm font-normal opacity-80">
                  {counts[d]} mastered{counts[d] > REVIEW_ROUND ? ` · ${REVIEW_ROUND} at a time` : ''}
                </span>
              </Link>
            ) : (
              <div key={d} className="flex items-center justify-between rounded-2xl border border-white/8 px-5 py-4 text-zinc-600">
                <span className="font-bold">{DIFF_NAME[d]}</span>
                <span className="text-sm">none yet</span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
