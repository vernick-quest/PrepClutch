import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { buildDeck, parseDeckOptions, deckId } from '@/lib/geo'
import { loadGeoHistory, availableGeoKinds } from '@/lib/geo-history'
import GeoClient from '@/components/geo/GeoClient'
import RoundGuard from '@/components/ui/RoundGuard'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

interface Props { searchParams: Promise<{ c?: string; k?: string }> }

export default async function GeoPlayPage({ searchParams }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/geo'))

  // Before the migration is applied every answer would be refused, so send
  // them to /geo, which says so.
  const { ready, rows } = await loadGeoHistory(supabase, user.id)
  if (!ready) redirect('/geo')

  // Only kinds the catalogue has: a shape card before the map migration
  // would be refused when saved.
  const opts = parseDeckOptions(await searchParams)
  const deck = buildDeck(opts, rows, await availableGeoKinds(supabase))
  if (deck.length === 0) redirect('/geo')

  // A new deck is a new session: remount so "Play again" starts clean.
  return <RoundGuard round={crypto.randomUUID()} home="/geo"><GeoClient key={deck.map(c => c.key).join()} deck={deck} deckId={deckId(opts)} /></RoundGuard>
}
