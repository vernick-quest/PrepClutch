// ── Exam scoping, tolerant of an unapplied migration ─────────────────────────
//
// Migrations here are applied BY HAND, so a deploy can land before its schema
// change does. Code must therefore never HARD-require a new column: shipping
// the exam filter ahead of migration 058 took every quiz down with
// "column questions.exam does not exist".
//
// Probe once and cache only the positive result, so the filter switches itself
// on the moment 058 is applied — no redeploy, no restart.
let examColumnReady = false

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function hasExamColumn(supabase: any): Promise<boolean> {
  if (examColumnReady) return true
  const { error } = await supabase.from('questions').select('exam').limit(1)
  examColumnReady = !error
  return examColumnReady
}
