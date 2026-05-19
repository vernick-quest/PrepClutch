import { Section } from '@/types/database'

export const SECTION_CONFIG: Record<Section, { label: string; color: string; accent: string; bg: string; border: string; emoji: string }> = {
  verbal: {
    label: 'Verbal',
    color: 'text-amber-400',
    accent: 'amber',
    bg: 'bg-amber-500/10',
    border: 'border-amber-500/30',
    emoji: '📚',
  },
  quantitative: {
    label: 'Quantitative',
    color: 'text-cyan-400',
    accent: 'cyan',
    bg: 'bg-cyan-500/10',
    border: 'border-cyan-500/30',
    emoji: '🔢',
  },
  reading: {
    label: 'Reading',
    color: 'text-emerald-400',
    accent: 'emerald',
    bg: 'bg-emerald-500/10',
    border: 'border-emerald-500/30',
    emoji: '📖',
  },
  math: {
    label: 'Mathematics',
    color: 'text-rose-400',
    accent: 'rose',
    bg: 'bg-rose-500/10',
    border: 'border-rose-500/30',
    emoji: '🧮',
  },
  language: {
    label: 'Language',
    color: 'text-violet-400',
    accent: 'violet',
    bg: 'bg-violet-500/10',
    border: 'border-violet-500/30',
    emoji: '✏️',
  },
}

export const AVATAR_COLORS = [
  '#f59e0b', '#06b6d4', '#10b981', '#f43f5e', '#8b5cf6',
  '#3b82f6', '#ec4899', '#14b8a6', '#f97316', '#a855f7',
]

export const SECTIONS: Section[] = ['verbal', 'quantitative', 'reading', 'math', 'language']

export const QUESTION_TIME_LIMIT_S = 60

// Difficulty base points — difficulty 1=Easy, 2=Medium, 3=Hard
export const DIFFICULTY_BASE_POINTS: Record<string, number> = {
  Easy: 10, Medium: 20, Hard: 35,
}
// Per-section time benchmarks (ms) derived from official HSPT timing
export const SECTION_BENCHMARKS_MS: Record<string, number> = {
  verbal: 16_000, quantitative: 34_000, reading: 24_000, math: 42_000, language: 25_000,
}
// Max achievable XP per 10-question section attempt (used for leaderboard bar normalization)
// 2×base at 0ms * 10 questions worst-case upper bound ≈ 2×35×10 = 700; use 500 as practical cap
export const MAX_SECTION_XP = 500
// Maps PrepClutch section names → badge section names
export const SECTION_TO_BADGE: Record<string, string> = {
  verbal: 'Verbal', quantitative: 'Quantitative',
  reading: 'Reading', math: 'Mathematics', language: 'Language',
}
export const DIFF_NAME: Record<number, string> = { 1: 'Easy', 2: 'Medium', 3: 'Hard' }
export const MAX_BASE_SCORE = 215 // 3×10 + 4×20 + 3×35
// Max questions recycled from "previously correct" per session before pool is exhausted
export const MAX_CORRECT_RECYCLED = 1
export const QUESTIONS_PER_SESSION = 10
