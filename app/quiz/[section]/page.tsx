import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTIONS } from '@/lib/constants'
import QuizClient from '@/components/quiz/QuizClient'
import type { Section } from '@/types/database'

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

  // Fetch questions
  let query = supabase.from('questions').select('*')
  if (section !== 'full') {
    query = query.eq('section', section)
  }
  const { data: allQuestions } = await query

  if (!allQuestions || allQuestions.length === 0) {
    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-center">
          <p className="text-4xl mb-4">🚧</p>
          <p className="text-zinc-400">No questions found. Please run the seed script.</p>
        </div>
      </div>
    )
  }

  // Shuffle and pick 10 per section (or 10 per section for full = 50)
  let questions = allQuestions
  if (section === 'full') {
    const bySection = SECTIONS.map(s =>
      allQuestions.filter(q => q.section === s).sort(() => Math.random() - 0.5).slice(0, 10)
    )
    questions = bySection.flat()
  } else {
    questions = allQuestions.sort(() => Math.random() - 0.5).slice(0, 10)
  }

  return (
    <QuizClient
      section={section as Section | 'full'}
      questions={questions}
      userId={user.id}
    />
  )
}
