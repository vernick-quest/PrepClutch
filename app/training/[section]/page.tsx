import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTIONS } from '@/lib/constants'
import { masteredCounts } from '@/lib/mastered-review'
import TrainingClient from '@/components/training/TrainingClient'
import type { TrainingQuestion } from '@/components/training/TrainingClient'
import type { Section } from '@/types/database'

export const dynamic = 'force-dynamic'

interface Props { params: Promise<{ section: string }> }

export default async function TrainingPage({ params }: Props) {
  const { section } = await params
  if (!SECTIONS.includes(section as Section)) notFound()

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  // Easiest first, then the authored order — two Mediums can be deliberately
  // sequenced so the first teaches the second.
  const { data, error } = await supabase
    .from('training_questions')
    // '*' rather than a column list, so `concept` flows through once migration
    // 060 adds it — and nothing errors before it does.
    .select('*')
    .eq('section', section)
    .order('difficulty', { ascending: true })
    .order('sort_order', { ascending: true })

  // A missing table means migration 059 has not been applied. Fail soft: this
  // is an optional extra, and a 404 beats an error page for something the
  // student was only browsing. (Deploy-before-migration took the quiz down
  // once already — see 8edffd9.)
  if (error) notFound()

  const questions = (data ?? []) as TrainingQuestion[]
  if (questions.length === 0) notFound()

  // For the "review what you've mastered" links. Best-effort: a failure here
  // must not take training down with it.
  const counts = await masteredCounts(supabase, user.id, section).catch(() => null)
  const mastered = counts ? counts[1] + counts[2] + counts[3] : 0

  return <TrainingClient section={section as Section} questions={questions} mastered={mastered} />
}
