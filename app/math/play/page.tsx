import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { buildDeck, parseDeckOptions } from '@/lib/math-facts'
import { loadFactHistory } from '@/lib/math-history'
import FactsClient from '@/components/math/FactsClient'

export const dynamic = 'force-dynamic'

interface Props { searchParams: Promise<{ op?: string; type?: string; t?: string }> }

export default async function MathPlayPage({ searchParams }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { ready, rows } = await loadFactHistory(supabase, user.id)
  if (!ready) redirect('/math')

  const deck = buildDeck(parseDeckOptions(await searchParams), rows)
  if (deck.length === 0) redirect('/math')

  // A new deck is a new session: remount so "Play again" starts clean.
  return <FactsClient key={deck.map(c => c.key).join()} deck={deck} />
}
