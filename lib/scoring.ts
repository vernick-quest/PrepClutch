import { SECTION_BENCHMARKS_MS, DIFFICULTY_BASE_POINTS, DIFF_NAME } from '@/lib/constants'
import type { Section } from '@/types/database'

export interface QuestionScore {
  base:       number
  speedBonus: number
  total:      number
}

/**
 * Score a single question answer.
 *
 * Scoring is base-points only — correct answers always earn the full base
 * regardless of time taken. Speed data is retained for results-page feedback
 * (time chip, timing flags) but does not affect the score.
 *
 * - Incorrect / timeout → 0
 * - Correct             → base (Easy=10, Medium=20, Hard=35)
 *
 * timeTakenMs and section are kept in the signature so call-sites don't need
 * to change, and so classifyTiming() can still use them for feedback.
 */
export function scoreQuestion(
  correct:     boolean,
  difficulty:  number,
  timeTakenMs: number,   // used only for classifyTiming feedback, not scoring
  section:     Section | string, // same
): QuestionScore {
  if (!correct) return { base: 0, speedBonus: 0, total: 0 }

  const diffName = DIFF_NAME[difficulty] ?? 'Medium'
  const base     = DIFFICULTY_BASE_POINTS[diffName] ?? 20
  return { base, speedBonus: 0, total: base }
}

// ── Post-exam timing flags ────────────────────────────────────────────────────

export type TimingFlag = 'time_sink' | 'rushed_error' | 'speed_demon'

export interface FlagInfo {
  label:   string
  message: string
  color:   string
  bg:      string
}

export const FLAG_LABELS: Record<TimingFlag, FlagInfo> = {
  time_sink: {
    label:   'Time Sink',
    message: 'Cut losses earlier on hard questions.',
    color:   '#f43f5e',
    bg:      'rgba(244,63,94,0.12)',
  },
  rushed_error: {
    label:   'Rushed Error',
    message: 'Slow down: Avoid careless errors on easy items.',
    color:   '#f97316',
    bg:      'rgba(249,115,22,0.12)',
  },
  speed_demon: {
    label:   'Speed Demon',
    message: 'Answered correctly well under target time.',
    color:   '#10b981',
    bg:      'rgba(16,185,129,0.12)',
  },
}

/**
 * Classify the timing behavior of a single answer for analytics display.
 * Returns null if no flag applies.
 */
export function classifyTiming(
  correct:     boolean,
  timeTakenMs: number,
  section:     Section | string,
): TimingFlag | null {
  const benchmark = SECTION_BENCHMARKS_MS[section as Section]
  if (!benchmark) return null

  const ratio = timeTakenMs / benchmark

  if (!correct && ratio > 1.5) return 'time_sink'
  if (!correct && ratio < 0.3) return 'rushed_error'
  if (correct  && ratio < 0.5) return 'speed_demon'
  return null
}
