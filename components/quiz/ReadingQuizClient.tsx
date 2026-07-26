'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { scoreQuestion } from '@/lib/scoring'
import type { ReadingPassage } from '@/lib/reading-passages'

// ── Types ─────────────────────────────────────────────────────────────────────

interface SavedAnswer {
  selectedIndex: number  // -1 = timed out
  timeTakenMs: number
  xpEarned: number
  targetMs: number       // fair benchmark for this question (see targetMsFor)
}

interface Props {
  passages: ReadingPassage[]
  userId: string
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const DIFF_LABEL: Record<number, string> = { 1: 'Easy', 2: 'Medium', 3: 'Hard' }
const DIFF_COLOR: Record<number, string> = {
  1: '#10b981',
  2: '#f59e0b',
  3: '#f43f5e',
}
const TYPE_LABEL: Record<string, string> = {
  main_idea:      'Main Idea',
  detail:         'Detail',
  inference:      'Inference',
  authors_purpose: "Author's Purpose",
  vocabulary:     'Vocabulary',
}
const TOPIC_LABEL: Record<string, string> = {
  science:        '🔬 Science',
  social_studies: '🌍 Social Studies',
  humanities:     '📜 Humanities',
}

function formatTime(ms: number): string {
  const totalSeconds = Math.max(0, Math.ceil(ms / 1000))
  const m = Math.floor(totalSeconds / 60)
  const s = totalSeconds % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}

function globalIdx(passages: ReadingPassage[], pIdx: number, qIdx: number): number {
  return passages.slice(0, pIdx).reduce((s, p) => s + p.questions.length, 0) + qIdx
}

// ── Component ─────────────────────────────────────────────────────────────────

export default function ReadingQuizClient({ passages, userId }: Props) {
  const router = useRouter()

  const totalQuestions = passages.reduce((s, p) => s + p.questions.length, 0)

  // ── Position ──────────────────────────────────────────────────────────────
  const [passageIdx, setPassageIdx] = useState(0)
  const [qInPassage, setQInPassage] = useState(0)
  const passageIdxRef = useRef(0)
  const qInPassageRef = useRef(0)

  // ── Interaction ───────────────────────────────────────────────────────────
  const [selectedOption, setSelectedOption] = useState<number | null>(null)
  const [locked, setLocked] = useState(false)

  // ── Answers flat array (indexed by global question position) ──────────────
  const [answers, setAnswers] = useState<(SavedAnswer | null)[]>(() =>
    new Array(totalQuestions).fill(null)
  )
  const answersRef = useRef<(SavedAnswer | null)[]>(new Array(totalQuestions).fill(null))

  // ── Timer ─────────────────────────────────────────────────────────────────
  // Passage timer = estimated reading time + question target time.
  // Reading time: word count ÷ 200 wpm (generous pace for test-takers).
  // Question target (24s each) is kept separate — it's a benchmark shown in
  // results feedback only, not the actual countdown limit.
  const readingMsFor = useCallback((idx: number) => {
    const wordCount = passages[idx].body.split(/\s+/).length
    return Math.ceil(wordCount / 200) * 60_000              // 200 wpm
  }, [passages])

  const passageTimeMs = useCallback((idx: number) => {
    const questionMs = passages[idx].questions.length * 24_000  // target benchmark
    return readingMsFor(idx) + questionMs
  }, [passages, readingMsFor])

  // The first question of a passage absorbs the entire read, so judging it
  // against the flat 24s benchmark always marks it red no matter how quickly
  // the student actually worked. Give it the reading allowance on top.
  const targetMsFor = useCallback((pIdx: number, qIdx: number) =>
    qIdx === 0 ? 24_000 + readingMsFor(pIdx) : 24_000
  , [readingMsFor])
  const [timeRemainingMs, setTimeRemainingMs] = useState(() => passageTimeMs(0))
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const questionStartRef = useRef<number>(Date.now())
  const [passageTimedOut, setPassageTimedOut] = useState(false)

  // ── Sync refs with state ──────────────────────────────────────────────────
  useEffect(() => { passageIdxRef.current = passageIdx }, [passageIdx])
  useEffect(() => { qInPassageRef.current = qInPassage }, [qInPassage])

  // ── Finish quiz ───────────────────────────────────────────────────────────
  const finishQuiz = useCallback(async (finalAnswers: (SavedAnswer | null)[]) => {
    if (timerRef.current) clearInterval(timerRef.current)

    const allQuestions = passages.flatMap(p => p.questions)

    const answersForResults = finalAnswers.map((a, i) => ({
      question_id:    allQuestions[i].id,
      selected_index: a?.selectedIndex ?? -1,
      correct_index:  allQuestions[i].correctIndex,
      time_taken_ms:  a?.timeTakenMs ?? 0,
      xp_earned:      a?.xpEarned ?? 0,
      target_ms:      a?.targetMs ?? 24_000,
      section:        'reading',
    }))

    const score = finalAnswers.filter(
      (a, i) => a?.selectedIndex === allQuestions[i].correctIndex
    ).length

    const totalXP = finalAnswers.reduce((s, a) => s + (a?.xpEarned ?? 0), 0)

    // Map to the Question shape the results page expects
    const questionsForResults = passages.flatMap(p =>
      p.questions.map(q => ({
        id:            q.id,
        section:       'reading',
        prompt:        q.text,
        options:       q.options,
        correct_index: q.correctIndex,
        difficulty:    q.difficulty,
        explanation:   q.explanation,
        passage:       p.body,
        passage_id:    p.id,
      }))
    )

    sessionStorage.setItem('quiz_result', JSON.stringify({
      section:         'reading',
      answers:         answersForResults,
      total_xp:        totalXP,
      score,
      total_questions: totalQuestions,
      questions:       questionsForResults,
    }))

    // Persist to DB
    const supabase = createClient()
    await supabase.from('quiz_attempts').insert({
      user_id:         userId,
      section:         'reading',
      score,
      total_questions: totalQuestions,
      total_xp:        totalXP,
      answers:         answersForResults,
      completed_at:    new Date().toISOString(),
    })

    // Record per-question history. get_section_mastery and leaderboard_view
    // both derive the section total from user_question_history JOIN questions,
    // so skipping this leaves reading points stranded on the results page and
    // out of the student's actual score.
    for (const a of answersForResults) {
      await supabase.rpc('upsert_question_history', {
        p_user_id:     userId,
        p_question_id: a.question_id,
        p_correct:     a.selected_index === a.correct_index,
      })
    }

    router.push('/results')
  }, [passages, totalQuestions, userId, router])

  // ── Handle passage timeout ────────────────────────────────────────────────
  const handlePassageTimeout = useCallback(() => {
    const pIdx = passageIdxRef.current
    const passage = passages[pIdx]
    const base = passages.slice(0, pIdx).reduce((s, p) => s + p.questions.length, 0)

    const newAnswers = [...answersRef.current]
    passage.questions.forEach((_, i) => {
      const gIdx = base + i
      if (!newAnswers[gIdx]) {
        newAnswers[gIdx] = {
          selectedIndex: -1,
          timeTakenMs: 0,
          xpEarned: 0,
          targetMs: targetMsFor(pIdx, i),
        }
      }
    })
    answersRef.current = newAnswers
    setAnswers([...newAnswers])

    if (pIdx < passages.length - 1) {
      const next = pIdx + 1
      passageIdxRef.current = next
      qInPassageRef.current = 0
      setPassageIdx(next)
      setQInPassage(0)
      setSelectedOption(null)
      setLocked(false)
    } else {
      finishQuiz(newAnswers)
    }
  }, [passages, finishQuiz, targetMsFor])

  // ── React to timeout signal (avoids stale closure in interval) ───────────
  useEffect(() => {
    if (passageTimedOut) {
      setPassageTimedOut(false)
      handlePassageTimeout()
    }
  }, [passageTimedOut, handlePassageTimeout])

  // ── Timer: reset when passage changes ────────────────────────────────────
  useEffect(() => {
    const ms = passageTimeMs(passageIdx)
    setTimeRemainingMs(ms)
    questionStartRef.current = Date.now()

    if (timerRef.current) clearInterval(timerRef.current)

    timerRef.current = setInterval(() => {
      setTimeRemainingMs(prev => {
        if (prev <= 100) {
          clearInterval(timerRef.current!)
          setPassageTimedOut(true)
          return 0
        }
        return prev - 100
      })
    }, 100)

    return () => { if (timerRef.current) clearInterval(timerRef.current) }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [passageIdx])

  // ── Advance to next question / passage / finish ───────────────────────────
  const advance = useCallback((newAnswers: (SavedAnswer | null)[]) => {
    const pIdx = passageIdxRef.current
    const qIdx = qInPassageRef.current
    const passage = passages[pIdx]

    setTimeout(() => {
      setSelectedOption(null)
      setLocked(false)

      if (qIdx < passage.questions.length - 1) {
        // Next question within same passage
        const nq = qIdx + 1
        qInPassageRef.current = nq
        setQInPassage(nq)
        questionStartRef.current = Date.now()
      } else if (pIdx < passages.length - 1) {
        // Next passage — timer resets via useEffect
        const np = pIdx + 1
        passageIdxRef.current = np
        qInPassageRef.current = 0
        setPassageIdx(np)
        setQInPassage(0)
        questionStartRef.current = Date.now()
      } else {
        finishQuiz(newAnswers)
      }
    }, 750)
  }, [passages, finishQuiz])

  // ── Handle user selecting an answer ──────────────────────────────────────
  const handleSelect = useCallback((optionIdx: number) => {
    if (locked) return

    const pIdx = passageIdxRef.current
    const qIdx = qInPassageRef.current
    const gIdx = globalIdx(passages, pIdx, qIdx)
    const question = passages[pIdx].questions[qIdx]

    const timeTakenMs = Date.now() - questionStartRef.current
    const isCorrect = optionIdx === question.correctIndex
    const scored = scoreQuestion(isCorrect, question.difficulty, timeTakenMs, 'reading')

    const saved: SavedAnswer = {
      selectedIndex: optionIdx,
      timeTakenMs,
      xpEarned: scored.total,
      targetMs: targetMsFor(pIdx, qIdx),
    }

    const newAnswers = [...answersRef.current]
    newAnswers[gIdx] = saved
    answersRef.current = newAnswers
    setAnswers([...newAnswers])
    setSelectedOption(optionIdx)
    setLocked(true)

    advance(newAnswers)
  }, [locked, passages, advance, targetMsFor])

  // ── Derived display values ────────────────────────────────────────────────
  const currentPassage  = passages[passageIdx]
  const currentQuestion = currentPassage.questions[qInPassage]
  const gIdx            = globalIdx(passages, passageIdx, qInPassage)
  const totalPassageMs  = passageTimeMs(passageIdx)
  const timerPct        = totalPassageMs > 0 ? (timeRemainingMs / totalPassageMs) * 100 : 0
  const timerColor      = timerPct > 50 ? '#10b981' : timerPct > 25 ? '#f59e0b' : '#f43f5e'
  const answeredCount   = answers.filter(a => a !== null).length

  const optionLabel = (i: number) => ['A', 'B', 'C', 'D'][i] ?? String(i + 1)

  function optionStyle(i: number): string {
    if (!locked) {
      return selectedOption === i
        ? 'bg-amber-500/20 border-amber-500/60 text-white'
        : 'bg-white/5 border-white/10 text-zinc-200 hover:bg-white/8 hover:border-white/20'
    }
    // Locked — reveal correct / wrong
    if (i === currentQuestion.correctIndex) return 'bg-emerald-500/20 border-emerald-500/60 text-emerald-300'
    if (i === selectedOption)               return 'bg-rose-500/20 border-rose-500/50 text-rose-300'
    return 'bg-white/3 border-white/5 text-zinc-600'
  }

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex flex-col">

      {/* ── Top bar ──────────────────────────────────────────────────────── */}
      <div className="sticky top-0 z-30 bg-[#0a0a0f]/90 backdrop-blur-sm border-b border-white/5">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center gap-4">

          {/* Back */}
          <a
            href="/"
            className="text-zinc-500 hover:text-zinc-300 transition-colors text-sm shrink-0"
          >
            ← Exit
          </a>

          {/* Progress */}
          <div className="flex-1">
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-xs text-zinc-500">
                Question <span className="text-zinc-300 font-semibold">{gIdx + 1}</span> of {totalQuestions}
              </span>
              <span className="text-xs text-zinc-500">
                Passage {passageIdx + 1} of {passages.length}
                <span className="text-zinc-600"> · </span>
                {qInPassage + 1}/{currentPassage.questions.length} in passage
              </span>
            </div>
            {/* Global progress bar */}
            <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full bg-emerald-500 transition-all duration-300"
                style={{ width: `${(answeredCount / totalQuestions) * 100}%` }}
              />
            </div>
          </div>

          {/* Passage timer */}
          <div className="shrink-0 flex items-center gap-2">
            <div className="flex flex-col items-end">
              <span
                className="text-lg font-black tabular-nums leading-none"
                style={{ color: timerColor }}
              >
                {formatTime(timeRemainingMs)}
              </span>
              <span className="text-[10px] text-zinc-600">passage time</span>
            </div>
            {/* Timer arc bar */}
            <div className="w-16 h-2 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-100"
                style={{ width: `${timerPct}%`, backgroundColor: timerColor }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* ── Main content ──────────────────────────────────────────────────── */}
      <div className="flex-1 max-w-6xl mx-auto w-full px-4 py-6">
        <div className="grid lg:grid-cols-[1fr_420px] gap-6 items-start">

          {/* ── LEFT: Passage panel ──────────────────────────────────────── */}
          <div className="lg:sticky lg:top-[73px] bg-white/3 border border-white/8 rounded-2xl overflow-hidden">
            {/* Passage header */}
            <div className="px-5 py-4 border-b border-white/8 flex items-start justify-between gap-3">
              <div>
                <h2 className="text-base font-bold text-white leading-tight">
                  {currentPassage.title}
                </h2>
                {currentPassage.topic && (
                  <span className="text-xs text-zinc-500 mt-0.5 block">
                    {TOPIC_LABEL[currentPassage.topic]}
                  </span>
                )}
              </div>
              <span className="text-[10px] text-zinc-600 border border-white/10 rounded-full px-2 py-0.5 shrink-0 mt-0.5">
                {currentPassage.questions.length} questions
              </span>
            </div>

            {/* Passage body — scrollable on mobile */}
            <div className="px-5 py-4 max-h-[40vh] lg:max-h-[calc(100vh-180px)] overflow-y-auto">
              {currentPassage.body.split('\n\n').map((para, i) => (
                <p key={i} className={`text-sm text-zinc-300 leading-relaxed ${i > 0 ? 'mt-4' : ''}`}>
                  {para}
                </p>
              ))}
            </div>
          </div>

          {/* ── RIGHT: Question panel ─────────────────────────────────────── */}
          <div className="space-y-4">
            {/* Question meta */}
            <div className="flex items-center gap-2 flex-wrap">
              <span
                className="text-xs font-semibold px-2.5 py-1 rounded-full border"
                style={{
                  color: DIFF_COLOR[currentQuestion.difficulty],
                  borderColor: DIFF_COLOR[currentQuestion.difficulty] + '50',
                  backgroundColor: DIFF_COLOR[currentQuestion.difficulty] + '15',
                }}
              >
                {DIFF_LABEL[currentQuestion.difficulty]}
              </span>
              {currentQuestion.type && (
                <span className="text-xs text-zinc-600 bg-white/5 border border-white/10 px-2.5 py-1 rounded-full">
                  {TYPE_LABEL[currentQuestion.type]}
                </span>
              )}
            </div>

            {/* Question text */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
              <p className="text-sm font-medium text-zinc-100 leading-relaxed">
                {currentQuestion.text}
              </p>
            </div>

            {/* Options */}
            <div className="space-y-2">
              {currentQuestion.options.map((opt, i) => (
                <button
                  key={`${currentQuestion.id}-${i}`}
                  onClick={() => handleSelect(i)}
                  disabled={locked}
                  className={`w-full flex items-start gap-3 p-4 rounded-2xl border text-left transition-all active:scale-[0.99] disabled:cursor-default ${optionStyle(i)}`}
                >
                  <span className="text-xs font-black opacity-60 shrink-0 mt-0.5 w-4">{optionLabel(i)}</span>
                  <span className="text-sm leading-relaxed">{opt}</span>
                  {locked && i === currentQuestion.correctIndex && (
                    <span className="ml-auto shrink-0 text-emerald-400 text-base">✓</span>
                  )}
                  {locked && i === selectedOption && i !== currentQuestion.correctIndex && (
                    <span className="ml-auto shrink-0 text-rose-400 text-base">✗</span>
                  )}
                </button>
              ))}
            </div>

            {/* Locked feedback */}
            {locked && (
              <div
                className={`rounded-xl px-4 py-3 text-xs leading-relaxed border ${
                  selectedOption === currentQuestion.correctIndex
                    ? 'bg-emerald-500/8 border-emerald-500/20 text-emerald-300'
                    : 'bg-rose-500/8 border-rose-500/20 text-rose-300'
                }`}
              >
                <span className="font-semibold">
                  {selectedOption === currentQuestion.correctIndex ? '✅ Correct — ' : '❌ Incorrect — '}
                </span>
                {currentQuestion.explanation}
              </div>
            )}

            {/* Hint below last question of passage */}
            {qInPassage === currentPassage.questions.length - 1 && !locked && passageIdx < passages.length - 1 && (
              <p className="text-center text-xs text-zinc-600">
                Next passage begins after this question
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
