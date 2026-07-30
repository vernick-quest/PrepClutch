// ── Post-quiz achievement evaluation ─────────────────────────────────────────
//
// Extracted from QuizClient so the full practice test can award badges through
// exactly the same path as a solo section. When this lived inside the client
// component, any flow that did not use that component silently skipped badges.

import { DIFFICULTY_BASE_POINTS, SECTION_TO_BADGE, DIFF_NAME, MAX_BASE_SCORE, SECTION_BENCHMARKS_MS } from '@/lib/constants'
import { evaluateBadges } from '@/lib/badges'
import type { BadgeStats } from '@/lib/badges'
import type { Question, QuizAnswer } from '@/types/database'

export async function checkAchievements(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  supabase: any,
  userId: string,
  answers: QuizAnswer[],
  score: number,
  total: number,
  section: string,
  questions: Question[],
) {
  const { data: existing } = await supabase
    .from('user_achievements')
    .select('achievement_key')
    .eq('user_id', userId)
  const earnedBadgeIds: string[] = (existing ?? []).map((a: { achievement_key: string }) => a.achievement_key)

  const { data: attempts } = await supabase
    .from('quiz_attempts')
    .select('section, score, total_questions')
    .eq('user_id', userId)
    .not('completed_at', 'is', null)

  const { data: profile } = await supabase
    .from('profiles')
    .select('badge_stats')
    .eq('id', userId)
    .single()
  const prevBadgeStats = (profile?.badge_stats ?? {}) as Partial<BadgeStats>

  const allAttempts = [...(attempts ?? []), { section, score, total_questions: total }]
  const completions: Record<string, number> = {}
  for (const a of allAttempts) {
    const bs = SECTION_TO_BADGE[a.section]
    if (bs) completions[bs] = (completions[bs] ?? 0) + 1
  }

  const curBadgeSec      = section !== 'full' ? SECTION_TO_BADGE[section] : null
  const totalCompletions = allAttempts.length

  const perfectSections: string[] = [...(prevBadgeStats.perfectSections ?? [])]
  if (curBadgeSec && score === total && !perfectSections.includes(curBadgeSec)) {
    perfectSections.push(curBadgeSec)
  }

  const speedBadgeSections: string[] = [...(prevBadgeStats.speedBadgeSections ?? [])]
  if (curBadgeSec && !speedBadgeSections.includes(curBadgeSec)) {
    // Speed badge: total time ≤ 60% of the sum of per-question benchmarks.
    // Reading stamps its own target_ms (the first question of a passage
    // carries the reading time), so prefer it over the flat section benchmark
    // — judging a passage read against 24s can never be beaten honestly.
    const benchmark = SECTION_BENCHMARKS_MS[section] ?? 30_000
    const totalBenchmarkMs = answers.reduce((s, a) => s + (a.target_ms ?? benchmark), 0)
    const totalTakenMs     = answers.reduce((s, a) => s + a.time_taken_ms, 0)
    if (totalTakenMs <= totalBenchmarkMs * 0.6) speedBadgeSections.push(curBadgeSec)
  }

  const highScoreSections: string[] = [...(prevBadgeStats.highScoreSections ?? [])]
  if (curBadgeSec && !highScoreSections.includes(curBadgeSec)) {
    const baseEarned = answers.reduce((s, a) => {
      if (a.selected_index !== a.correct_index) return s
      const q = questions.find(q => q.id === a.question_id)
      return s + (DIFFICULTY_BASE_POINTS[DIFF_NAME[q?.difficulty ?? 2] ?? 'Medium'] ?? 0)
    }, 0)
    if (baseEarned >= MAX_BASE_SCORE * 0.8) highScoreSections.push(curBadgeSec)
  }

  const newBadgeStats: BadgeStats = {
    earnedBadgeIds,
    completions,
    perfectSections,
    speedBadgeSections,
    highScoreSections,
    totalCompletions,
  }

  await supabase
    .from('profiles')
    .update({ badge_stats: { perfectSections, speedBadgeSections, highScoreSections } })
    .eq('id', userId)

  const newlyEarned = evaluateBadges(newBadgeStats)
  if (newlyEarned.length > 0) {
    await supabase.from('user_achievements').insert(
      newlyEarned.map(key => ({ user_id: userId, achievement_key: key }))
    )
  }
}
