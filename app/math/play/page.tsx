import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { buildDeck, parseDeckOptions } from '@/lib/math-facts'
import { loadFactHistory, availableTopics } from '@/lib/math-history'
import FactsClient from '@/components/math/FactsClient'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

interface Props { searchParams: Promise<{ op?: string; type?: string; t?: string }> }

export default async function MathPlayPage({ searchParams }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/math'))

  const { ready, rows } = await loadFactHistory(supabase, user.id)
  if (!ready) redirect('/math')

  const opts = parseDeckOptions(await searchParams)
  if (!(await availableTopics(supabase)).includes(opts.topic)) redirect('/math')

  const deck = buildDeck(opts, rows)
  if (deck.length === 0) redirect('/math')

  // A new deck is a new session: remount so "Play again" starts clean.
  // Round history label: the tab played, plus the table if it was just one.
  const deckId = opts.topic === 'times'
    ? `${opts.op === 'mixed' ? 'times' : opts.op}${opts.tables.length === 1 ? `:${opts.tables[0]}` : ''}`
    : opts.topic

  return <FactsClient key={deck.map(c => c.key).join()} deck={deck} deckId={deckId} />
}
