import type { createClient } from '@/lib/supabase/client'
import { evaluateSectionMasteryBadges } from '@/lib/badges'
import type { SectionMasteryRow } from '@/lib/badges'

type BrowserClient = ReturnType<typeof createClient>

/**
 * Awards the cumulative section-mastery badges (the growing bicep).
 *
 * MUST be called AFTER every upsert_question_history() call for the finished
 * quiz has completed — get_section_mastery() reads user_question_history, so
 * running it earlier would miss the milestone the final question just crossed.
 *
 * Read-only with respect to mastery data: it calls the RPC and writes only to
 * user_achievements. Idempotent — (user_id, achievement_key) is the primary
 * key, so re-earning is ignored rather than erroring.
 */
export async function awardSectionMasteryBadges(
  supabase: BrowserClient,
  userId: string,
): Promise<string[]> {
  const { data: masteryRaw, error: masteryError } = await supabase
    .rpc('get_section_mastery', { p_user_id: userId })
  if (masteryError) return []

  const rows = (masteryRaw ?? []) as SectionMasteryRow[]

  const { data: existing } = await supabase
    .from('user_achievements')
    .select('achievement_key')
    .eq('user_id', userId)
  const earnedKeys: string[] = (existing ?? []).map(
    (a: { achievement_key: string }) => a.achievement_key
  )

  const newly = evaluateSectionMasteryBadges(rows, earnedKeys)
  if (newly.length === 0) return []

  await supabase
    .from('user_achievements')
    .upsert(
      newly.map(key => ({ user_id: userId, achievement_key: key })),
      { onConflict: 'user_id,achievement_key', ignoreDuplicates: true },
    )

  return newly
}
