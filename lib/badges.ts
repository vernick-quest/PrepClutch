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
// per section, read from the get_section_mastery() RPC.
//
// A section holds 300 questions. Tier 5 was the top when the bank was 250 and
// its badge announced "All 250 ... mastered" — which quietly became a lie when
// migrations 034-038 grew every section to 300. Tier 6 is the real
// section-complete; tier 5 is now an honest waypoint. Migration 057 rewords it.

export const SECTION_MASTERY_CATEGORY = 'Section Mastery'

/**
 * True when every question in a section has been answered correctly at least
 * once — the tier-6 state.
 *
 * Worth marking in the UI: practice still works, but nothing can raise the
 * section total any more, so the results page shows +0. That is identical to
 * how a genuine scoring bug looked, and without a "complete" marker a student
 * cannot tell the difference between "you finished this" and "something is
 * broken".
 */
export function isSectionComplete(m?: { correct?: number; total?: number } | null): boolean {
  const total = m?.total ?? 0
  return total > 0 && (m?.correct ?? 0) >= total
}

/** Correct-question thresholds, tier 1 → tier 6. Tier 6 = the full section. */
export const SECTION_MASTERY_TIERS = [50, 100, 150, 200, 250, 300] as const

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

// ── Display order ────────────────────────────────────────────────────────────
//
// The Bestiary used to render whatever order the database returned, so the
// biceps appeared scrambled — a tier IV next to a tier I, with a section's
// five tiers split across two rows. The badges themselves were right; only the
// placement was wrong. These two helpers give every badge a deliberate
// easiest-to-hardest position.

/** Rarity ladder, easiest → hardest. Anything unrecognised sorts last. */
const RARITY_RANK: Record<string, number> = {
  Common: 0, Uncommon: 1, Rare: 2, Epic: 3, Legendary: 4, Mythic: 5, Ascendant: 6,
}

/** Question threshold for a section-mastery key (50–300), 0 for anything else. */
export function sectionMasteryThreshold(key: string): number {
  const match = /^mastery_[a-z]+_(\d+)$/.exec(key)
  return match ? Number(match[1]) : 0
}

/** Position of a section-mastery key's section, or -1. Groups a section's
 *  six tiers together so one row shows one bicep growing. */
function sectionMasteryOrder(key: string): number {
  const match = /^mastery_([a-z]+)_\d+$/.exec(key)
  if (!match) return -1
  return (SECTION_MASTERY_SECTIONS as readonly string[]).indexOf(match[1])
}

/** Canonical section order, matching SECTIONS in lib/constants. Badge keys use
 *  both "math" and "mathematics", so both map to the same slot. */
const SECTION_RANK: Record<string, number> = {
  verbal: 0, quantitative: 1, quant: 1, reading: 2, math: 3, mathematics: 3, language: 4,
}

/**
 * How hard a badge is to earn, used to break ties WITHIN a rarity. Rarity is
 * the author's own difficulty encoding and dominates; this only settles the
 * order of equally-rare badges, where an alphabetical fallback would put
 * "Completed 10 challenges" before "Completed 3 challenges".
 */
function difficultyRank(key: string): number {
  if (key === 'combo_all_five')        return 5     // every section at once
  if (key === 'milestone_all_sections') return 100
  if (key === 'milestone_all_perfect')  return 1000

  // combo_verbal_quant = 2 sections, combo_v_q_m = 3. More sections, harder.
  const combo = /^combo_(.+)$/.exec(key)
  if (combo) return combo[1].split('_').length

  // milestone_3 before milestone_10.
  const milestone = /^milestone_(\d+)$/.exec(key)
  if (milestone) return Number(milestone[1])

  // first_/perfect_/speed_ are equally hard across sections, so order them the
  // way every other list in the app does rather than alphabetically.
  const sectioned = /^(?:first|perfect|speed)_([a-z]+)$/.exec(key)
  if (sectioned) return SECTION_RANK[sectioned[1]] ?? 99

  return 0
}

/**
 * Sort comparator for badges inside one category: easiest first, hardest last.
 *
 * Section mastery sorts by section, then by threshold, so each section reads
 * 50 → 250 left to right and the arm visibly grows across the row.
 *
 * Everything else sorts by rarity ascending — Common, Uncommon, Rare, Epic,
 * Legendary, Mythic — then by difficultyRank. Unearned badges keep their slot
 * rather than being pushed to the end, so the ladder stays readable and a
 * student can see what the next rung costs.
 */
export function compareBadges(
  a: { key: string; rarity: string; label: string },
  b: { key: string; rarity: string; label: string },
): number {
  const secA = sectionMasteryOrder(a.key)
  const secB = sectionMasteryOrder(b.key)
  if (secA >= 0 && secB >= 0) {
    return secA - secB || sectionMasteryThreshold(a.key) - sectionMasteryThreshold(b.key)
  }

  const rarityA = RARITY_RANK[a.rarity] ?? 99
  const rarityB = RARITY_RANK[b.rarity] ?? 99
  return rarityA - rarityB
      || difficultyRank(a.key) - difficultyRank(b.key)
      || a.label.localeCompare(b.label)
}

/** 1–5 for a section-mastery badge key, 0 for anything else. */
export function sectionMasteryTier(key: string): number {
  const match = /^mastery_[a-z]+_(\d+)$/.exec(key)
  if (!match) return 0
  const idx = (SECTION_MASTERY_TIERS as readonly number[]).indexOf(Number(match[1]))
  return idx < 0 ? 0 : idx + 1
}

/** Multiplier applied to the base emoji size so the bicep visibly grows. */
// Six tiers now share the row, so each card is narrower — the ladder is
// rescaled to stay monotonic without the tier-6 emoji overflowing its card.
const BICEP_SCALE = [1, 1.3, 1.7, 2.2, 2.8, 3.4]

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
