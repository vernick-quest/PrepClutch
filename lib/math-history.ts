import type { FactHistoryRow, Topic } from '@/lib/math-facts'

// Topics the database can score. Migration 064 adds `topic` to the catalogue
// and loads the fraction and decimal cards; until it is applied only times
// tables exist there, and offering the others would mean every answer is
// refused as an unknown card. Applying 064 turns them on, no redeploy needed.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function availableTopics(supabase: any): Promise<Topic[]> {
  const { data, error } = await supabase.from('math_fact_cards').select('topic').neq('topic', 'times').limit(1)
  return error || !data?.length ? ['times'] : ['times', 'equiv', 'fdp']
}

// Reads a student's Math Facts history. `ready: false` means the table is not
// there yet (migration 062 unapplied) or could not be read. Migrations are
// applied by hand, so a deploy can land first and the pages must say so
// instead of erroring.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function loadFactHistory(supabase: any, userId: string):
  Promise<{ ready: boolean; rows: Map<string, FactHistoryRow> }> {
  const { data, error } = await supabase
    .from('fact_history')
    .select('fact_key, times_correct, times_wrong, best_ms, fluent_at')
    .eq('user_id', userId)
  if (error) return { ready: false, rows: new Map() }
  return {
    ready: true,
    rows: new Map((data as FactHistoryRow[]).map(r => [r.fact_key, r])),
  }
}

export interface FactRound {
  id:           string
  deck:         string
  cards:        number
  correct:      number
  fast:         number
  points:       number
  answers:      { k: string; g: string; c: boolean; ms: number }[]
  completed_at: string
}

/** A student's most recent Math Facts rounds, newest first. Empty if
 *  migration 068 is not applied yet, or the viewer may not see them. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function loadRounds(supabase: any, userId: string, limit = 10): Promise<FactRound[]> {
  const { data, error } = await supabase
    .from('fact_rounds')
    .select('id, deck, cards, correct, fast, points, answers, completed_at')
    .eq('user_id', userId)
    .order('completed_at', { ascending: false })
    .limit(limit)
  return error ? [] : (data as FactRound[])
}
