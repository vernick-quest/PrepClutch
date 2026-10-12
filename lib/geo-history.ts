import { KINDS, KINDS_069 } from '@/lib/geo-meta'
import type { GeoHistoryRow, GeoKind } from '@/lib/geo-meta'

// The card kinds the catalogue has. Shape cards (Name that country) and city
// cards (Which country is Rio in?) arrive with the map migration (070),
// applied by hand after 069; until then they are not offered, counted or
// shown, exactly like availableTopics in math-history. Each later kind is
// probed on its own, so a catalogue that has one but not the other (an
// older draft of 070, say) offers only what it really has: a card the
// catalogue lacks would be refused when saved.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function availableGeoKinds(supabase: any): Promise<GeoKind[]> {
  const later = KINDS.filter(k => !KINDS_069.includes(k))
  const found = await Promise.all(later.map(async k => {
    const { data, error } = await supabase.from('geo_cards').select('card_key').eq('kind', k).limit(1)
    return !error && data?.length ? k : null
  }))
  return KINDS.filter(k => KINDS_069.includes(k) || found.includes(k))
}

/** Whether Pin the map rounds can be saved: the map migration is applied,
 *  with its places keyed by place (capitals AND cities). Until then a round
 *  still plays, it just is not saved. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function pinReady(supabase: any): Promise<boolean> {
  const [rounds, places] = await Promise.all([
    supabase.from('geo_pin_rounds').select('id').limit(1),
    supabase.from('geo_pin_places').select('place_key').eq('kind', 'city').limit(1),
  ])
  return !rounds.error && !places.error && !!places.data?.length
}

// Reads a student's Geography history. `ready: false` means the table is not
// there yet (the Geography migration is not applied) or could not be read.
// Migrations are applied by hand, often after the deploy, so every page must
// say "almost ready" instead of erroring until it is.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function loadGeoHistory(supabase: any, userId: string):
  Promise<{ ready: boolean; rows: Map<string, GeoHistoryRow> }> {
  const { data, error } = await supabase
    .from('geo_history')
    .select('card_key, times_correct, times_wrong, best_ms, fluent_at')
    .eq('user_id', userId)
  if (error) return { ready: false, rows: new Map() }
  return {
    ready: true,
    rows: new Map((data as GeoHistoryRow[]).map(r => [r.card_key, r])),
  }
}

export interface GeoRound {
  id:           string
  deck:         string
  cards:        number
  correct:      number
  fast:         number
  points:       number
  answers:      { k: string; g: string; c: boolean; ms: number }[]
  completed_at: string
}

/** A student's most recent Geography rounds, newest first. Empty if the
 *  migration is not applied yet, or the viewer may not see them. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function loadGeoRounds(supabase: any, userId: string, limit = 10): Promise<GeoRound[]> {
  const { data, error } = await supabase
    .from('geo_rounds')
    .select('id, deck, cards, correct, fast, points, answers, completed_at')
    .eq('user_id', userId)
    .order('completed_at', { ascending: false })
    .limit(limit)
  return error ? [] : (data as GeoRound[])
}
