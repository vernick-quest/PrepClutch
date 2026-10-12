import type { FactHistoryRow } from '@/lib/math-facts'

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
