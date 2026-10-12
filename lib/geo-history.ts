import { KINDS, KINDS_069 } from '@/lib/geo-meta'
import type { GeoHistoryRow, GeoKind } from '@/lib/geo-meta'

// The card kinds the catalogue has. Shape cards (Name that country) arrive
// with the map migration, applied by hand after 069; until then they are not
// offered, counted or shown, exactly like availableTopics in math-history.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function availableGeoKinds(supabase: any): Promise<GeoKind[]> {
  const { data, error } = await supabase.from('geo_cards').select('card_key').eq('kind', 'shape').limit(1)
  return error || !data?.length ? KINDS_069 : KINDS
}

/** Whether Pin the map rounds can be saved (the map migration is applied). */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function pinReady(supabase: any): Promise<boolean> {
  const { error } = await supabase.from('geo_pin_rounds').select('id').limit(1)
  return !error
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
