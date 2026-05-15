'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { SECTION_CONFIG, XP_PER_CORRECT, XP_SPEED_BONUS, SPEED_BONUS_THRESHOLD_MS, QUESTION_TIME_LIMIT_S } from '@/lib/constants'
import type { Section, Question, QuizAnswer } from '@/types/database'
import Link from 'next/link'

interface Props {
  section: Section | 'full'
  questions: Question[]
  userId: string
}

type AnswerState = 'unanswered' | 'correct' | 'incorrect'

export default function QuizClient({ section, questions, userId }: Props) {
  const router = useRouter()
  const [currentIdx, setCurrentIdx] = useState(0)
  const [answerState, setAnswerState] = useState<AnswerState>('unanswered')
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)
  const [timeLeft, setTimeLeft] = useState(QUESTION_TIME_LIMIT_S)
  const [answers, setAnswers] = useState<QuizAnswer[]>([])
  const [questionStartTime, setQuestionStartTime] = useState<number>(Date.now())
  const [isSubmitting, setIsSubmitting] = useState(false)
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null)

  const currentQuestion = questions[currentIdx]
  const totalQuestions = questions.length
  const progress = ((currentIdx + (answerState !== 'unanswered' ? 1 : 0)) / totalQuestions) * 100

  const cfg = section === 'full'
    ? { label: 'Full Practice Test', color: 'text-amber-400', accent: 'amber', bg: 'bg-amber-500/10', border: 'border-amber-500/30', emoji: '🎯' }
    : SECTION_CONFIG[section as Section]

  const getSectionCfg = (s: Section) => SECTION_CONFIG[s]

  const stopTimer = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current)
      timerRef.current = null
    }
  }, [])

  const handleAnswer = useCallback((index: number) => {
    if (answerState !== 'unanswered') return
    stopTimer()

    const timeTaken = Date.now() - questionStartTime
    const isCorrect = index === currentQuestion.correct_index
    let xp = isCorrect ? XP_PER_CORRECT : 0
    if (isCorrect && timeTaken < SPEED_BONUS_THRESHOLD_MS) xp += XP_SPEED_BONUS

    setSelectedIndex(index)
    setAnswerState(isCorrect ? 'correct' : 'incorrect')
    setAnswers(prev => [...prev, {
      question_id: currentQuestion.id,
      selected_index: index,
      correct_index: currentQuestion.correct_index,
      time_taken_ms: timeTaken,
      xp_earned: xp,
    }])
  }, [answerState, currentQuestion, questionStartTime, stopTimer])

  // Auto-advance on time up
  useEffect(() => {
    setTimeLeft(QUESTION_TIME_LIMIT_S)
    setQuestionStartTime(Date.now())
    setAnswerState('unanswered')
    setSelectedIndex(null)

    timerRef.current = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          stopTimer()
          // Time's up — mark as wrong with no selection
          handleAnswer(-1)
          return 0
        }
        return prev - 1
      })
    }, 1000)

    return stopTimer
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentIdx])

  async function handleNext() {
    if (currentIdx < totalQuestions - 1) {
      setCurrentIdx(i => i + 1)
    } else {
      await finishQuiz()
    }
  }

  async function finishQuiz() {
    setIsSubmitting(true)
    const supabase = createClient()

    const score = answers.filter(a => a.selected_index === a.correct_index).length
    const totalXP = answers.reduce((sum, a) => sum + a.xp_earned, 0)

    // Determine section for the attempt
    const attemptSection = section === 'full' ? 'full' : section

    const { data: attempt } = await supabase
      .from('quiz_attempts')
      .insert({
        user_id: userId,
        section: attemptSection,
        score,
        total_questions: totalQuestions,
        answers: answers,
        total_xp: totalXP,
        completed_at: new Date().toISOString(),
      })
      .select()
      .single()

    // Check and award achievements
    await checkAchievements(supabase, userId, answers, score, totalQuestions, attemptSection)

    // Store results in session storage for results page
    sessionStorage.setItem('quiz_result', JSON.stringify({
      attempt_id: attempt?.id,
      section,
      answers,
      total_xp: totalXP,
      score,
      total_questions: totalQuestions,
      questions,
    }))

    router.push('/results')
  }

  const timerPercent = (timeLeft / QUESTION_TIME_LIMIT_S) * 100
  const timerColor = timeLeft > 20 ? '#10b981' : timeLeft > 10 ? '#f59e0b' : '#f43f5e'
  const circumference = 2 * Math.PI * 20

  const currentSectionCfg = currentQuestion
    ? (section === 'full' ? getSectionCfg(currentQuestion.section as Section) : cfg)
    : cfg

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
                style={{
                  width: `${progress}%`,
                  backgroundColor: section === 'full' ? '#f59e0b' : getAccentHex(cfg.accent),
                }}
              />
            </div>
          </div>
          <span className="text-sm text-zinc-400 shrink-0">
            {currentIdx + 1} / {totalQuestions}
          </span>
        </div>
      </div>

      <div className="flex-1 max-w-3xl mx-auto w-full px-4 py-8 flex flex-col">
        {/* Section label */}
        <div className="flex items-center justify-between mb-6">
          <div className={`flex items-center gap-2 px-3 py-1.5 rounded-full ${currentSectionCfg.bg} border ${currentSectionCfg.border}`}>
            <span>{currentSectionCfg.emoji}</span>
            <span className={`text-sm font-medium ${currentSectionCfg.color}`}>
              {section === 'full' ? currentSectionCfg.label : cfg.label}
            </span>
          </div>

          {/* Timer */}
          <div className="relative w-12 h-12">
            <svg className="w-12 h-12 -rotate-90" viewBox="0 0 48 48">
              <circle cx="24" cy="24" r="20" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="4" />
              <circle
                cx="24" cy="24" r="20"
                fill="none"
                stroke={timerColor}
                strokeWidth="4"
                strokeLinecap="round"
                strokeDasharray={circumference}
                strokeDashoffset={circumference * (1 - timerPercent / 100)}
                style={{ transition: 'stroke-dashoffset 1s linear, stroke 0.5s' }}
              />
            </svg>
            <span className="absolute inset-0 flex items-center justify-center text-sm font-bold text-white">{timeLeft}</span>
          </div>
        </div>

        {/* Passage (reading comprehension) */}
        {currentQuestion?.passage && (
          <div className="mb-6 p-4 bg-emerald-500/5 border border-emerald-500/20 rounded-2xl max-h-48 overflow-y-auto">
            <p className="text-zinc-300 text-sm leading-relaxed">{currentQuestion.passage}</p>
          </div>
        )}

        {/* Question */}
        <div className="mb-8">
          <p className="text-xl font-semibold text-white leading-relaxed">
            {currentQuestion?.prompt}
          </p>
          {currentQuestion?.difficulty && (
            <div className="flex gap-1 mt-3">
              {[1, 2, 3].map(d => (
                <div
                  key={d}
                  className={`w-2 h-2 rounded-full ${d <= currentQuestion.difficulty ? 'bg-amber-400' : 'bg-white/20'}`}
                />
              ))}
              <span className="text-xs text-zinc-500 ml-1">
                {currentQuestion.difficulty === 1 ? 'Easy' : currentQuestion.difficulty === 2 ? 'Medium' : 'Hard'}
              </span>
            </div>
          )}
        </div>

        {/* Answer options */}
        <div className="space-y-3 flex-1">
          {currentQuestion?.options?.map((option: string, idx: number) => {
            const letter = ['A', 'B', 'C', 'D'][idx]
            let state: 'default' | 'correct' | 'incorrect' | 'missed' = 'default'

            if (answerState !== 'unanswered') {
              if (idx === currentQuestion.correct_index) state = 'correct'
              else if (idx === selectedIndex) state = 'incorrect'
            }

            return (
              <button
                key={idx}
                onClick={() => handleAnswer(idx)}
                disabled={answerState !== 'unanswered'}
                className={`w-full flex items-center gap-4 p-4 rounded-2xl border text-left transition-all ${
                  state === 'correct'
                    ? 'bg-emerald-500/20 border-emerald-500 text-white'
                    : state === 'incorrect'
                    ? 'bg-rose-500/20 border-rose-500 text-white'
                    : answerState !== 'unanswered'
                    ? 'bg-white/3 border-white/5 text-zinc-500'
                    : 'bg-white/5 border-white/10 text-white hover:bg-white/8 hover:border-white/20 active:scale-[0.99]'
                }`}
              >
                <span className={`w-8 h-8 rounded-lg flex items-center justify-center text-sm font-bold shrink-0 ${
                  state === 'correct' ? 'bg-emerald-500 text-black'
                  : state === 'incorrect' ? 'bg-rose-500 text-white'
                  : 'bg-white/10 text-zinc-400'
                }`}>
                  {state === 'correct' ? '✓' : state === 'incorrect' ? '✗' : letter}
                </span>
                <span className="text-base">{option}</span>
              </button>
            )
          })}
        </div>

        {/* Feedback + Next */}
        {answerState !== 'unanswered' && (
          <div className="mt-6 space-y-4">
            <div className={`p-4 rounded-2xl border ${
              answerState === 'correct'
                ? 'bg-emerald-500/10 border-emerald-500/30'
                : 'bg-rose-500/10 border-rose-500/30'
            }`}>
              <div className="flex items-center gap-2 mb-2">
                <span className="text-xl">{answerState === 'correct' ? '🎉' : '💡'}</span>
                <span className={`font-bold ${answerState === 'correct' ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {answerState === 'correct' ? 'Correct!' : 'Not quite.'}
                </span>
                {answerState === 'correct' && (
                  <span className="ml-auto text-amber-400 font-bold text-sm">
                    +{answers[answers.length - 1]?.xp_earned} XP
                    {answers[answers.length - 1]?.xp_earned > XP_PER_CORRECT && ' ⚡ Speed bonus!'}
                  </span>
                )}
              </div>
              {currentQuestion?.explanation && (
                <p className="text-zinc-300 text-sm">{currentQuestion.explanation}</p>
              )}
            </div>

            <button
              onClick={handleNext}
              disabled={isSubmitting}
              className="w-full bg-white text-black font-bold py-3.5 rounded-2xl hover:bg-zinc-100 transition-colors disabled:opacity-50"
            >
              {isSubmitting ? 'Saving…' : currentIdx < totalQuestions - 1 ? 'Next Question →' : 'See Results 🏁'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}

function getAccentHex(accent: string): string {
  const map: Record<string, string> = {
    amber: '#f59e0b',
    cyan: '#06b6d4',
    emerald: '#10b981',
    rose: '#f43f5e',
    violet: '#8b5cf6',
  }
  return map[accent] ?? '#ffffff'
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function checkAchievements(supabase: any, userId: string, answers: QuizAnswer[], score: number, total: number, section: string) {
  const { data: existing } = await supabase
    .from('user_achievements')
    .select('achievement_key')
    .eq('user_id', userId)

  const earned = new Set(existing?.map((a: { achievement_key: string }) => a.achievement_key) ?? [])
  const toInsert: { user_id: string; achievement_key: string }[] = []

  const add = (key: string) => {
    if (!earned.has(key)) toInsert.push({ user_id: userId, achievement_key: key })
  }

  // First Blood
  add('first_blood')

  // Sharp Shooter — 100% on a section
  if (score === total) add('sharp_shooter')

  // Speed Demon — 5 consecutive under 10s
  let streak = 0
  for (const a of answers) {
    if (a.time_taken_ms < 10000 && a.selected_index === a.correct_index) {
      streak++
      if (streak >= 5) { add('speed_demon'); break }
    } else streak = 0
  }

  // Section aces (90%+)
  const pct = (score / total) * 100
  if (pct >= 90) {
    const aceMap: Record<string, string> = {
      verbal: 'verbal_ace',
      math: 'math_ace',
      reading: 'reading_ace',
      quantitative: 'quant_ace',
      language: 'language_ace',
    }
    if (aceMap[section]) add(aceMap[section])
  }

  // All-Rounder — check if all sections done
  if (!earned.has('all_rounder')) {
    const { data: attempts } = await supabase
      .from('quiz_attempts')
      .select('section')
      .eq('user_id', userId)
      .not('completed_at', 'is', null)

    const completedSections = new Set(attempts?.map((a: { section: string }) => a.section) ?? [])
    completedSections.add(section)
    if (['verbal', 'quantitative', 'reading', 'math', 'language'].every(s => completedSections.has(s))) {
      add('all_rounder')
    }
  }

  // Top of Class
  if (!earned.has('top_of_class')) {
    const { data: lb } = await supabase
      .from('leaderboard_view')
      .select('user_id')
      .order('aggregate_score', { ascending: false })
      .limit(1)

    if (lb?.[0]?.user_id === userId) add('top_of_class')
  }

  if (toInsert.length > 0) {
    await supabase.from('user_achievements').insert(toInsert)
  }
}
