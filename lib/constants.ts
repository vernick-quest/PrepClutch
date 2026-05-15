import { Section } from '@/types/database'

export const SECTION_CONFIG: Record<Section, { label: string; color: string; accent: string; bg: string; border: string; emoji: string }> = {
  verbal: {
    label: 'Verbal Skills',
    color: 'text-amber-400',
    accent: 'amber',
    bg: 'bg-amber-500/10',
    border: 'border-amber-500/30',
    emoji: '📚',
  },
  quantitative: {
    label: 'Quantitative Skills',
    color: 'text-cyan-400',
    accent: 'cyan',
    bg: 'bg-cyan-500/10',
    border: 'border-cyan-500/30',
    emoji: '🔢',
  },
  reading: {
    label: 'Reading Comprehension',
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
    emoji: '➕',
  },
  language: {
    label: 'Language Skills',
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

export const XP_PER_CORRECT = 10
export const XP_SPEED_BONUS = 5
export const SPEED_BONUS_THRESHOLD_MS = 15000
export const QUESTION_TIME_LIMIT_S = 60
