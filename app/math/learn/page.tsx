import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { parseDeckOptions, homeHref } from '@/lib/math-facts'
import { learnDeck } from '@/lib/math-steps'
import { loadFactHistory, availableTopics } from '@/lib/math-history'
import { loginUrl } from '@/lib/tracks'
import LearnClient from '@/components/math/LearnClient'
import RoundGuard from '@/components/ui/RoundGuard'

export const dynamic = 'force-dynamic'

interface Props { searchParams: Promise<{ topic?: string; op?: string; type?: string; t?: string; f?: string }> }

// Learn: ten cards, one at a time, untimed and unscored, each with its worked
// steps. Reads history only to pick what this student most needs to learn;
// nothing here writes anything.
export default async function MathLearnPage({ searchParams }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/math'))

  const params = await searchParams
  const opts = parseDeckOptions(params)
  if (!(await availableTopics(supabase)).includes(opts.topic)) redirect('/math')

  const { rows } = await loadFactHistory(supabase, user.id)
  const deck = learnDeck(opts, rows)
  if (deck.length === 0) redirect('/math')

  const playHref = `/math/play?${new URLSearchParams(Object.entries(params).filter(([, v]) => v) as [string, string][])}`
  return <RoundGuard round={crypto.randomUUID()} home={homeHref(opts)}><LearnClient key={deck.map(c => c.key).join()} deck={deck} playHref={playHref} home={homeHref(opts)} /></RoundGuard>
}
