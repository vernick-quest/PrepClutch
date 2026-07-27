export interface BadgeStats {
  earnedBadgeIds: string[]
  completions: Record<string, number>
  perfectSections: string[]
  speedBadgeSections: string[]
  highScoreSections: string[]
  totalCompletions: number
}

export const BADGE_CONDITIONS: Record<string, (stats: BadgeStats) => boolean> = {
  first_verbal:      s => (s.completions['Verbal']        ?? 0) >= 1,
  first_quantitative:s => (s.completions['Quantitative']  ?? 0) >= 1,
  first_reading:     s => (s.completions['Reading']       ?? 0) >= 1,
  first_mathematics: s => (s.completions['Mathematics']   ?? 0) >= 1,
  first_language:    s => (s.completions['Language']      ?? 0) >= 1,
  perfect_verbal:         s => s.perfectSections.includes('Verbal'),
  perfect_quantitative:   s => s.perfectSections.includes('Quantitative'),
  perfect_reading:        s => s.perfectSections.includes('Reading'),
  perfect_mathematics:    s => s.perfectSections.includes('Mathematics'),
  perfect_language:       s => s.perfectSections.includes('Language'),
  speed_verbal:           s => s.speedBadgeSections.includes('Verbal'),
  speed_quantitative:     s => s.speedBadgeSections.includes('Quantitative'),
  speed_reading:          s => s.speedBadgeSections.includes('Reading'),
  speed_mathematics:      s => s.speedBadgeSections.includes('Mathematics'),
  speed_language:         s => s.speedBadgeSections.includes('Language'),
  combo_verbal_quant:     s => ['Verbal','Quantitative'].every(x => s.highScoreSections.includes(x)),
  combo_verbal_reading:   s => ['Verbal','Reading'].every(x => s.highScoreSections.includes(x)),
  combo_verbal_math:      s => ['Verbal','Mathematics'].every(x => s.highScoreSections.includes(x)),
  combo_verbal_language:  s => ['Verbal','Language'].every(x => s.highScoreSections.includes(x)),
  combo_quant_math:       s => ['Quantitative','Mathematics'].every(x => s.highScoreSections.includes(x)),
  combo_quant_reading:    s => ['Quantitative','Reading'].every(x => s.highScoreSections.includes(x)),
  combo_quant_language:   s => ['Quantitative','Language'].every(x => s.highScoreSections.includes(x)),
  combo_reading_math:     s => ['Reading','Mathematics'].every(x => s.highScoreSections.includes(x)),
  combo_reading_language: s => ['Reading','Language'].every(x => s.highScoreSections.includes(x)),
  combo_math_language:    s => ['Mathematics','Language'].every(x => s.highScoreSections.includes(x)),
  combo_v_q_m:  s => ['Verbal','Quantitative','Mathematics'].every(x => s.highScoreSections.includes(x)),
  combo_v_r_l:  s => ['Verbal','Reading','Language'].every(x => s.highScoreSections.includes(x)),
  combo_q_m_l:  s => ['Quantitative','Mathematics','Language'].every(x => s.highScoreSections.includes(x)),
  combo_r_q_m:  s => ['Reading','Quantitative','Mathematics'].every(x => s.highScoreSections.includes(x)),
  combo_v_r_m:  s => ['Verbal','Reading','Mathematics'].every(x => s.highScoreSections.includes(x)),
  combo_v_q_l:  s => ['Verbal','Quantitative','Language'].every(x => s.highScoreSections.includes(x)),
  combo_r_m_l:  s => ['Reading','Mathematics','Language'].every(x => s.highScoreSections.includes(x)),
  combo_q_r_l:  s => ['Quantitative','Reading','Language'].every(x => s.highScoreSections.includes(x)),
  combo_all_five: s => ['Verbal','Quantitative','Reading','Mathematics','Language'].every(x => s.highScoreSections.includes(x)),
  milestone_3:           s => s.totalCompletions >= 3,
  milestone_10:          s => s.totalCompletions >= 10,
  milestone_all_sections:s => ['Verbal','Quantitative','Reading','Mathematics','Language'].every(x => (s.completions[x] ?? 0) >= 1),
  milestone_all_perfect: s => ['Verbal','Quantitative','Reading','Mathematics','Language'].every(x => s.perfectSections.includes(x)),
}

// Returns keys of badges newly earned (not already in earnedBadgeIds)
export function evaluateBadges(stats: BadgeStats): string[] {
  return Object.entries(BADGE_CONDITIONS)
    .filter(([key, fn]) => !stats.earnedBadgeIds.includes(key) && fn(stats))
    .map(([key]) => key)
}

// ── Section Mastery (the growing bicep) ──────────────────────────────────────
//
// These badges are NOT derived from a single quiz attempt like everything
// above — they track cumulative mastery (questions with times_correct > 0)
// per section, read from the get_section_mastery() RPC. Each section holds
// 250 questions, so tier 5 is a genuine "section complete".

export const SECTION_MASTERY_CATEGORY = 'Section Mastery'

/** Correct-question thresholds, tier 1 → tier 5. */
export const SECTION_MASTERY_TIERS = [50, 100, 150, 200, 250] as const

export const SECTION_MASTERY_SECTIONS = [
  'verbal', 'quantitative', 'reading', 'math', 'language',
] as const

export function sectionMasteryKey(section: string, threshold: number): string {
  return `mastery_${section}_${threshold}`
}

/** Shape of one get_section_mastery() row (only the fields we need). */
export interface SectionMasteryRow {
  section: string
  correct: number
}

/**
 * Returns keys of section-mastery badges newly crossed. Cumulative, so a
 * student who jumps several thresholds at once earns every tier they passed.
 */
export function evaluateSectionMasteryBadges(
  rows: SectionMasteryRow[],
  earnedBadgeIds: string[],
): string[] {
  const earned = new Set(earnedBadgeIds)
  const newly: string[] = []
  for (const row of rows) {
    if (!(SECTION_MASTERY_SECTIONS as readonly string[]).includes(row.section)) continue
    for (const threshold of SECTION_MASTERY_TIERS) {
      const key = sectionMasteryKey(row.section, threshold)
      if ((row.correct ?? 0) >= threshold && !earned.has(key)) newly.push(key)
    }
  }
  return newly
}

/** 1–5 for a section-mastery badge key, 0 for anything else. */
export function sectionMasteryTier(key: string): number {
  const match = /^mastery_[a-z]+_(\d+)$/.exec(key)
  if (!match) return 0
  const idx = (SECTION_MASTERY_TIERS as readonly number[]).indexOf(Number(match[1]))
  return idx < 0 ? 0 : idx + 1
}

/** Multiplier applied to the base emoji size so the bicep visibly grows. */
const BICEP_SCALE = [1, 1.35, 1.8, 2.4, 3.2]

/**
 * Emoji rendering for a badge. Ordinary badges get the grid's base size and
 * whatever glow the caller passes; section-mastery badges get an escalating
 * size + glow so the same 💪 balloons across the five tiers.
 */
export function badgeEmojiStyle(
  key: string,
  baseFontSize: number,
  glowColor: string,
): { fontSize: number; filter: string; lineHeight: number } {
  const tier = sectionMasteryTier(key)
  if (tier === 0) {
    return { fontSize: baseFontSize, filter: `drop-shadow(0 0 8px ${glowColor}55)`, lineHeight: 1 }
  }
  return {
    fontSize: Math.round(baseFontSize * BICEP_SCALE[tier - 1]),
    filter: `drop-shadow(0 0 ${4 + tier * 6}px ${glowColor}${tier >= 4 ? 'cc' : '77'})`,
    lineHeight: 1,
  }
}
