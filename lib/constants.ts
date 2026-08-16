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

// ── Exams ────────────────────────────────────────────────────────────────────
//
// One database, two isolated question banks. `questions.exam` is the hard
// divider (migration 058): separate questions, separate mastery, separate
// leaderboards and badges — but shared login, profiles and classes, so a
// student can move between them.
//
// The two exams are genuinely different instruments, not skins:
//
//   HSPT  5 sections, no penalty for a wrong answer, so always guess.
//   SSAT  3 sections, -1/4 raw point per wrong answer and 0 for an omission,
//         so knowing WHEN to skip is part of the test. Upper Level (grades
//         8-11) is the one 8th graders sit for high-school admission.
//
// SSAT is also far more generous per question — 72s on quantitative against
// the HSPT's 34s — which is why benchmarks live per exam rather than globally.

export type ExamId = 'hspt' | 'ssat'

export interface ExamConfig {
  label:        string
  blurb:        string
  sections:     Section[]
  benchmarksMs: Record<string, number>
  /** Raw-score cost of a wrong answer, as a fraction of one point. 0 = none. */
  wrongPenalty: number
  /** Whether a student may omit a question rather than answer it. */
  allowSkip:    boolean
}

export const EXAM_CONFIG: Record<ExamId, ExamConfig> = {
  hspt: {
    label: 'HSPT',
    blurb: 'High School Placement Test · 5 sections · no guessing penalty',
    sections: ['verbal', 'quantitative', 'reading', 'math', 'language'],
    benchmarksMs: { verbal: 16_000, quantitative: 34_000, reading: 24_000, math: 42_000, language: 25_000 },
    wrongPenalty: 0,
    allowSkip: false,
  },
  ssat: {
    label: 'SSAT',
    blurb: 'Upper Level · 3 sections · 1/4 point off for a wrong answer',
    sections: ['verbal', 'quantitative', 'reading'],
    // Upper Level pacing: verbal 60 Q / 30 min, quantitative 25 Q / 30 min,
    // reading 40 Q / 40 min.
    benchmarksMs: { verbal: 30_000, quantitative: 72_000, reading: 60_000 },
    wrongPenalty: 0.25,
    allowSkip: true,
  },
}

export const EXAMS: ExamId[] = ['hspt', 'ssat']
export const DEFAULT_EXAM: ExamId = 'hspt'

export function isExamId(v: string | undefined): v is ExamId {
  return v === 'hspt' || v === 'ssat'
}

// Legacy flat cutoff. Superseded by questionTimeoutMs(); kept only so older
// stored results and any straggler import still resolve to something sane.
export const QUESTION_TIME_LIMIT_S = 60

// Difficulty base points — difficulty 1=Easy, 2=Medium, 3=Hard
export const DIFFICULTY_BASE_POINTS: Record<string, number> = {
  Easy: 10, Medium: 20, Hard: 35,
}
// Per-section time benchmarks (ms) derived from official HSPT timing. These are
// the exam's per-question AVERAGES: math is 64 questions in 45 minutes, verbal
// 60 in 16, and so on.
export const SECTION_BENCHMARKS_MS: Record<string, number> = {
  verbal: 16_000, quantitative: 34_000, reading: 24_000, math: 42_000, language: 25_000,
}

// An average flattens the thing a student most needs to learn: a hard math
// question deserves more than a quarter of the time an easy one does. Targets
// scale off difficulty, and the factors are chosen so a 3 Easy / 4 Medium /
// 3 Hard session still averages 0.99x the section benchmark — pacing across a
// whole section is unchanged, only its distribution across questions.
export const DIFFICULTY_TIME_FACTOR: Record<number, number> = { 1: 0.6, 2: 0.9, 3: 1.5 }

/** Time a student should aim to spend on one question, in ms. */
export function questionTargetMs(section: string, difficulty: number, exam: ExamId = DEFAULT_EXAM): number {
  const base = EXAM_CONFIG[exam]?.benchmarksMs[section] ?? SECTION_BENCHMARKS_MS[section] ?? 30_000
  return Math.round(base * (DIFFICULTY_TIME_FACTOR[difficulty] ?? 1))
}

// ── Timing modes ─────────────────────────────────────────────────────────────
//
// PRACTICE (the default): each question has its own cutoff, scaled off its
// target. Nothing a student does on one question can cost them another, which
// is what you want when the goal is learning the material.
//
// TEST CONDITIONS: one clock for the whole section, sized as the sum of its
// questions' targets. Spending two minutes on a hard one means racing the
// easy ones — which is the actual skill the HSPT measures. Offered on the full
// practice test, where simulating the exam is the point.
export type TimingMode = 'practice' | 'test'

/** Hard cutoff for one question in practice mode. Twice its target, floored so
 *  no question is ever a scramble and capped so none can be sat on. */
export function questionTimeoutMs(section: string, difficulty: number, exam: ExamId = DEFAULT_EXAM): number {
  const target = questionTargetMs(section, difficulty, exam)
  return Math.min(Math.max(target * 2, 45_000), 120_000)
}

/** Clock for a whole section in test mode: the sum of its questions' targets. */
export function sectionBudgetMs(
  section: string,
  questions: { difficulty?: number }[],
  exam: ExamId = DEFAULT_EXAM,
): number {
  return questions.reduce((ms, q) => ms + questionTargetMs(section, q.difficulty ?? 2, exam), 0)
}
// Clutch Points are now cumulative mastery — max per section is derived from
// the question bank at runtime via get_section_mastery(). No fixed cap needed.
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

// Quiz history timestamps are rendered on the server (Vercel runs in UTC), so
// an unpinned toLocale* would show a 6pm PT attempt as the following day. Pin
// to Pacific — the students and the admin are all in San Francisco.
export const APP_TIME_ZONE = 'America/Los_Angeles'

/** e.g. "7/26/2026 · 6:14 PM" — date and time in San Francisco. */
export function formatAttemptTime(iso: string): string {
  const d = new Date(iso)
  const date = d.toLocaleDateString('en-US', { timeZone: APP_TIME_ZONE })
  const time = d.toLocaleTimeString('en-US', {
    timeZone: APP_TIME_ZONE, hour: 'numeric', minute: '2-digit',
  })
  return `${date} · ${time}`
}
