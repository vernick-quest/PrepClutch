'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { SECTION_CONFIG, QUESTION_TIME_LIMIT_S, DIFFICULTY_BASE_POINTS, SECTION_TO_BADGE, DIFF_NAME, MAX_BASE_SCORE } from '@/lib/constants'
import { scoreQuestion } from '@/lib/scoring'
import { evaluateBadges } from '@/lib/badges'
import type { BadgeStats } from '@/lib/badges'
import type { Section, Question, QuizAnswer } from '@/types/database'
import Link from 'next/link'

interface Props {
  section: Section | 'full'
  questions: Question[]
  userId: string
}

function getAccentHex(accent: string): string {
  const map: Record<string, string> = {
    amber: '#f59e0b', cyan: '#06b6d4', emerald: '#10b981', rose: '#f43f5e', violet: '#8b5cf6',
  }
  return map[accent] ?? '#ffffff'
}

export default function QuizClient({ section, questions, userId }: Props) {
  const router = useRouter()
  const [currentIdx, setCurrentIdx] = useState(0)
  const [timeLeft, setTimeLeft] = useState(QUESTION_TIME_LIMIT_S)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const answersRef   = useRef<QuizAnswer[]>([])
  const startTimeRef = useRef<number>(Date.now())
  const handledRef   = useRef(false)
  const timerRef     = useRef<ReturnType<typeof setInterval> | null>(null)

  const currentQuestion = questions[currentIdx]
  const prevQuestion    = currentIdx > 0 ? questions[currentIdx - 1] : null
  const totalQuestions  = questions.length
  const progress        = (currentIdx / totalQuestions) * 100

  const samePassage =
    !!currentQuestion?.passage_id &&
    prevQuestion?.passage_id === currentQuestion.passage_id

  const cfg = section === 'full'
    ? { label: 'Full Practice Test', color: 'text-amber-400', accent: 'amber', bg: 'bg-amber-500/10', border: 'border-amber-500/30', emoji: '🎯' }
    : SECTION_CONFIG[section as Section]

  const currentSectionCfg = currentQuestion
    ? (section === 'full' ? SECTION_CONFIG[currentQuestion.section as Section] : cfg)
    : cfg

  const stopTimer = useCallback(() => {
    if (timerRef.current) { clearInterval(timerRef.current); timerRef.current = null }
  }, [])

  // ─── Timer: resets on each question ──────────────────────────────────────
  useEffect(() => {
    handledRef.current = false
    startTimeRef.current = Date.now()
    setTimeLeft(QUESTION_TIME_LIMIT_S)

    timerRef.current = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          stopTimer()
          handleAnswer(-1)
          return 0
        }
        return prev - 1
      })
    }, 1000)

    return stopTimer
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentIdx])

  const finishQuiz = useCallback(async (finalAnswers: QuizAnswer[]) => {
    setIsSubmitting(true)
    const supabase = createClient()

    const score   = finalAnswers.filter(a => a.selected_index === a.correct_index).length
    const totalXP = finalAnswers.reduce((s, a) => s + a.xp_earned, 0)

    const { data: attempt } = await supabase
      .from('quiz_attempts')
      .insert({
        user_id:         userId,
        section:         section === 'full' ? 'full' : section,
        score,
        total_questions: totalQuestions,
        answers:         finalAnswers,
        total_xp:        totalXP,
        completed_at:    new Date().toISOString(),
      })
      .select()
      .single()

    // Record per-question history (smart deduplication for future sessions)
    for (const a of finalAnswers) {
      await supabase.rpc('upsert_question_history', {
        p_user_id:     userId,
        p_question_id: a.question_id,
        p_correct:     a.selected_index === a.correct_index,
      })
    }

    await checkAchievements(supabase, userId, finalAnswers, score, totalQuestions, section === 'full' ? 'full' : section, questions)

    sessionStorage.setItem('quiz_result', JSON.stringify({
      attempt_id:      attempt?.id,
      section,
      answers:         finalAnswers,
      total_xp:        totalXP,
      score,
      total_questions: totalQuestions,
      questions,
    }))

    router.push('/results')
  }, [userId, section, totalQuestions, questions, router])

  // ─── Handle answer ────────────────────────────────────────────────────────
  const handleAnswer = useCallback((index: number) => {
    if (handledRef.current) return
    handledRef.current = true
    stopTimer()

    const timeTakenMs = Date.now() - startTimeRef.current
    const isCorrect   = index >= 0 && index === currentQuestion.correct_index
    const qSection    = section === 'full' ? currentQuestion.section : (section as string)
    const scored      = scoreQuestion(isCorrect, currentQuestion.difficulty, timeTakenMs, qSection)

    const newAnswer: QuizAnswer = {
      question_id:    currentQuestion.id,
      selected_index: index,
      correct_index:  currentQuestion.correct_index,
      time_taken_ms:  timeTakenMs,
      xp_earned:      scored.total,
      section:        qSection,
    }

    const updatedAnswers = [...answersRef.current, newAnswer]
    answersRef.current = updatedAnswers

    if (currentIdx < totalQuestions - 1) {
      setCurrentIdx(i => i + 1)
    } else {
      finishQuiz(updatedAnswers)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentIdx, currentQuestion, section, totalQuestions, stopTimer, finishQuiz])

  const timerPercent  = (timeLeft / QUESTION_TIME_LIMIT_S) * 100
  const timerColor    = timeLeft > 20 ? '#10b981' : timeLeft > 10 ? '#f59e0b' : '#f43f5e'
  const circumference = 2 * Math.PI * 20

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex flex-col">
      {/* Top bar */}
      <div className="border-b border-white/5 bg-[#0a0a0f]/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-3xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href="/" className="text-zinc-500 hover:text-white transition-colors text-sm">← Exit</Link>
          <div className="flex-1">
            <div className="h-2 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{ width: `${progress}%`, backgroundColor: section === 'full' ? '#f59e0b' : getAccentHex(cfg.accent) }}
              />
            </div>
          </div>
          <span className="text-sm text-zinc-400 shrink-0">{currentIdx + 1} / {totalQuestions}</span>
        </div>
      </div>

      <div className="flex-1 max-w-3xl mx-auto w-full px-4 py-8 flex flex-col">
        {/* Section label + timer */}
        <div className="flex items-center justify-between mb-6">
          <div className={`flex items-center gap-2 px-3 py-1.5 rounded-full ${currentSectionCfg.bg} border ${currentSectionCfg.border}`}>
            <span>{currentSectionCfg.emoji}</span>
            <span className={`text-sm font-medium ${currentSectionCfg.color}`}>
              {section === 'full' ? currentSectionCfg.label : cfg.label}
            </span>
          </div>

          <div className="relative w-12 h-12">
            <svg className="w-12 h-12 -rotate-90" viewBox="0 0 48 48">
              <circle cx="24" cy="24" r="20" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="4" />
              <circle
                cx="24" cy="24" r="20" fill="none"
                stroke={timerColor} strokeWidth="4" strokeLinecap="round"
                strokeDasharray={circumference}
                strokeDashoffset={circumference * (1 - timerPercent / 100)}
                style={{ transition: 'stroke-dashoffset 1s linear, stroke 0.5s' }}
              />
            </svg>
            <span className="absolute inset-0 flex items-center justify-center text-sm font-bold text-white">{timeLeft}</span>
          </div>
        </div>

        {/* Passage — stable key prevents remount across same-passage questions */}
        {currentQuestion?.passage && (
          <div
            key={currentQuestion.passage_id ?? currentQuestion.id}
            className="mb-6 p-4 bg-emerald-500/5 border border-emerald-500/20 rounded-2xl max-h-48 overflow-y-auto"
          >
            {samePassage && (
              <p className="text-emerald-600 text-xs font-medium mb-2 uppercase tracking-wide">Same passage — continued</p>
            )}
            <p className="text-zinc-300 text-sm leading-relaxed">{currentQuestion.passage}</p>
          </div>
        )}

        {/* Question */}
        <div className="mb-8">
          <p className="text-xl font-semibold text-white leading-relaxed">{currentQuestion?.prompt}</p>
          {currentQuestion?.difficulty && (
            <div className="flex gap-1 mt-3">
              {[1, 2, 3].map(d => (
                <div key={d} className={`w-2 h-2 rounded-full ${d <= currentQuestion.difficulty ? 'bg-amber-400' : 'bg-white/20'}`} />
              ))}
              <span className="text-xs text-zinc-500 ml-1">
                {DIFF_NAME[currentQuestion.difficulty] ?? 'Medium'}
              </span>
            </div>
          )}
        </div>

        {/* Answer choices */}
        <div className="space-y-3 flex-1">
          {currentQuestion?.options?.map((option: string, idx: number) => {
            const letter = ['A', 'B', 'C', 'D'][idx]
            return (
              <button
                key={idx}
                onClick={() => handleAnswer(idx)}
                disabled={isSubmitting}
                className="w-full flex items-center gap-4 p-4 rounded-2xl border text-left transition-all bg-white/5 border-white/10 text-white hover:bg-white/8 hover:border-white/20 active:scale-[0.99] disabled:opacity-50"
              >
                <span className="w-8 h-8 rounded-lg flex items-center justify-center text-sm font-bold shrink-0 bg-white/10 text-zinc-400">
                  {letter}
                </span>
                <span className="text-base">{option}</span>
              </button>
            )
          })}
        </div>

        <p className="text-center text-xs text-zinc-600 mt-6">
          Click to lock in your answer — full review shown at the end
        </p>

        {isSubmitting && (
          <div className="text-center text-zinc-400 text-sm mt-4">Saving results…</div>
        )}
      </div>
    </div>
  )
}

async function checkAchievements(
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
    // Speed badge: total time ≤ 60% of the sum of per-question benchmarks
    const { SECTION_BENCHMARKS_MS } = await import('@/lib/constants')
    const benchmark = SECTION_BENCHMARKS_MS[section] ?? 30_000
    const totalBenchmarkMs = questions.length * benchmark
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
