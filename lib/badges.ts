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
