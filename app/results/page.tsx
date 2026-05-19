'use client'

import { useEffect, useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { SECTION_CONFIG, SECTIONS, SECTION_BENCHMARKS_MS } from '@/lib/constants'
import { classifyTiming, FLAG_LABELS } from '@/lib/scoring'
import type { Section, Question, QuizAnswer } from '@/types/database'
import { createClient } from '@/lib/supabase/client'
import confetti from 'canvas-confetti'

interface StoredResult {
  section: Section | 'full'
  answers: QuizAnswer[]
  total_xp: number
  score: number
  total_questions: number
  questions: Question[]
}

type Achievement = { icon_emoji: string; label: string; description: string; rarity?: string; creature?: string; lore?: string }

export default function ResultsPage() {
  const router = useRouter()
  const [result, setResult] = useState<StoredResult | null>(null)
  const [newAchievements, setNewAchievements] = useState<Achievement[]>([])
  const [showBreakdown, setShowBreakdown] = useState(true)
  const [visibleBadge, setVisibleBadge] = useState(0)
  const [isNewBest, setIsNewBest] = useState(false)
  const [previousBest, setPreviousBest] = useState<number | null>(null)
  const confettiFired = useRef(false)

  function fireConfetti() {
    const colors = ['#f59e0b', '#a855f7', '#06b6d4', '#10b981', '#f43f5e', '#818cf8']
    confetti({ particleCount: 120, spread: 80, origin: { y: 0.5 }, colors })
    setTimeout(() => confetti({ particleCount: 60, spread: 120, origin: { y: 0.3 }, colors }), 300)
    setTimeout(() => confetti({ particleCount: 80, spread: 60, origin: { y: 0.6 }, colors }), 600)
  }

  useEffect(() => {
    const raw = sessionStorage.getItem('quiz_result')
    if (!raw) { router.push('/'); return }

    const parsed: StoredResult = JSON.parse(raw)
    setResult(parsed)

    const supabase = createClient()
    supabase.auth.getUser().then(async ({ data: { user } }) => {
      if (!user) return

      // Check if this run is a new personal best (only relevant for single sections)
      if (parsed.section !== 'full') {
        const { data: bestRows } = await supabase
          .from('quiz_attempts')
          .select('total_xp')
          .eq('user_id', user.id)
          .eq('section', parsed.section)
          .order('total_xp', { ascending: false })
          .limit(1)
        const dbBest = bestRows?.[0]?.total_xp ?? 0
        setPreviousBest(dbBest)
        // Current attempt is already saved; if this run's score equals the DB max it IS the new best
        setIsNewBest(parsed.total_xp >= dbBest)
      }

      const { data } = await supabase
        .from('user_achievements')
        .select('achievement_key, achievement_definitions(icon_emoji, label, description, rarity, creature, lore)')
        .eq('user_id', user.id)
        .gte('earned_at', new Date(Date.now() - 60000).toISOString())

      if (data && data.length > 0) {
        const earned = data
          .map((a: { achievement_definitions: unknown }) => a.achievement_definitions)
          .filter(Boolean) as Achievement[]
        setNewAchievements(earned)
        if (!confettiFired.current) {
          confettiFired.current = true
          fireConfetti()
        }
      }
    })
  }, [router])

  if (!result) return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
      <div className="text-zinc-400">Loading results…</div>
    </div>
  )

  const { section, answers, total_xp, score, total_questions, questions } = result
  const pct = Math.round((score / total_questions) * 100)
  const cfg = section === 'full'
    ? { label: 'Full Practice Test', emoji: '🎯', color: 'text-amber-400', bg: 'bg-amber-500/10', border: 'border-amber-500/30' }
    : SECTION_CONFIG[section as Section]

  const rank = getRank(pct)

  const avgTime = answers.length > 0
    ? Math.round(answers.reduce((s, a) => s + a.time_taken_ms, 0) / answers.length / 1000)
    : 0

  return (
    <div className="min-h-screen bg-[#0a0a0f] py-8 px-4">
      <div className="max-w-2xl mx-auto space-y-6">
        {/* Header */}
        <div className="text-center">
          <p className="text-zinc-500 text-sm mb-1">{cfg.emoji} {cfg.label}</p>
        </div>

        {/* Score card */}
        <div className="bg-white/5 border border-white/10 rounded-3xl p-8">
          {/* Rank */}
          <div className="text-center mb-6">
            <div className="text-6xl mb-2">{rank.emoji}</div>
            <div className="text-3xl font-black" style={{ color: rank.color }}>{rank.name}</div>
            <div className="text-zinc-400 text-sm mt-2 italic">{rank.blurb}</div>
          </div>

          <div className="flex items-center justify-around border-t border-white/10 pt-6">
            <div className="text-center">
              <div className="text-7xl font-black text-white">{score}<span className="text-3xl text-zinc-500">/{total_questions}</span></div>
              <div className="text-zinc-400 text-sm mt-1">questions correct</div>
            </div>
            {/* Only show Clutch Points if this is a single-section run AND it's a new personal best */}
            {section !== 'full' && isNewBest && (
              <div className="text-center">
                <div className="text-5xl font-black text-amber-400">+{total_xp}</div>
                <div className="text-amber-500/70 text-xs font-semibold mt-1 uppercase tracking-wide">🏆 New Personal Best</div>
                <div className="text-zinc-500 text-xs mt-0.5">Clutch Points</div>
              </div>
            )}
            {section !== 'full' && !isNewBest && previousBest !== null && (
              <div className="text-center">
                <div className="text-3xl font-black text-zinc-600">{total_xp}</div>
                <div className="text-zinc-600 text-xs mt-1">pts this run</div>
                <div className="text-zinc-500 text-xs mt-0.5">Best: <span className="text-zinc-400 font-semibold">{previousBest} pts</span></div>
              </div>
            )}
          </div>

          {/* Score bar */}
          <div className="mt-6">
            <div className="h-3 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full bg-amber-500 transition-all duration-1000"
                style={{ width: `${Math.min(pct, 100)}%` }}
              />
            </div>
          </div>

          {/* Stats row */}
          <div className="grid grid-cols-3 gap-4 mt-6 pt-6 border-t border-white/10">
            <div className="text-center">
              <div className="text-xl font-bold text-emerald-400">{score}</div>
              <div className="text-xs text-zinc-500">Correct</div>
            </div>
            <div className="text-center">
              <div className="text-xl font-bold text-rose-400">{total_questions - score}</div>
              <div className="text-xs text-zinc-500">Incorrect</div>
            </div>
            <div className="text-center">
              <div className="text-xl font-bold text-cyan-400">{avgTime}s</div>
              <div className="text-xs text-zinc-500">Avg Time</div>
            </div>
          </div>
        </div>

        {/* New badges */}
        {newAchievements.length > 0 && (
          <div>
            <h3 className="text-xl font-bold text-center text-white mb-2">🏅 Badge{newAchievements.length > 1 ? 's' : ''} Unlocked!</h3>
            <p className="text-center text-zinc-500 text-sm mb-4">{visibleBadge + 1} of {newAchievements.length}</p>

            {newAchievements.map((ach, i) => i === visibleBadge && (
              <div
                key={i}
                className="rounded-3xl p-8 flex flex-col items-center gap-4 text-center"
                style={{
                  background: 'radial-gradient(ellipse at 50% 0%, #1a0828 0%, #0a0a0f 70%)',
                  border: '1.5px solid #a855f744',
                  boxShadow: '0 0 60px #a855f733',
                  animation: 'badgePop 0.5s cubic-bezier(0.34,1.56,0.64,1) forwards',
                }}
              >
                <div
                  className="text-7xl"
                  style={{ filter: 'drop-shadow(0 0 20px #a855f788)', animation: 'badgeFloat 3s ease-in-out infinite' }}
                >
                  {ach.icon_emoji}
                </div>
                <div>
                  <div className="text-2xl font-black text-white mb-1">{ach.label}</div>
                  {ach.creature && (
                    <div className="text-xs uppercase tracking-[3px] text-purple-400/70 mb-2">{ach.creature}</div>
                  )}
                  {ach.rarity && (
                    <span className="inline-block text-xs font-bold uppercase tracking-widest px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 mb-3">
                      {ach.rarity}
                    </span>
                  )}
                  <p className="text-zinc-400 text-sm">{ach.description}</p>
                  {ach.lore && (
                    <p className="text-zinc-600 text-xs italic mt-3 leading-relaxed">{ach.lore}</p>
                  )}
                </div>
                {newAchievements.length > 1 && (
                  <button
                    onClick={() => {
                      if (visibleBadge < newAchievements.length - 1) {
                        setVisibleBadge(v => v + 1)
                        fireConfetti()
                      }
                    }}
                    className="mt-2 px-6 py-2.5 rounded-2xl font-bold text-black bg-amber-500 hover:bg-amber-400 transition-colors text-sm"
                  >
                    {visibleBadge < newAchievements.length - 1 ? `Next Badge →` : 'All Done! 🎉'}
                  </button>
                )}
              </div>
            ))}

            <style>{`
              @keyframes badgePop {
                from { opacity: 0; transform: scale(0.7); }
                to   { opacity: 1; transform: scale(1); }
              }
              @keyframes badgeFloat {
                0%, 100% { transform: translateY(0); }
                50%       { transform: translateY(-8px); }
              }
            `}</style>
          </div>
        )}

        {/* Section breakdown for full test */}
        {section === 'full' && (
          <div className="bg-white/3 border border-white/10 rounded-2xl p-5">
            <h3 className="font-bold text-white mb-4">Section Breakdown</h3>
            <div className="space-y-3">
              {SECTIONS.map(s => {
                const sectionAnswers = answers.filter((_, i) => questions[i]?.section === s)
                const sectionScore = sectionAnswers.filter(a => a.selected_index === a.correct_index).length
                const sectionTotal = sectionAnswers.length
                const sCfg = SECTION_CONFIG[s]
                const sPct = sectionTotal > 0 ? Math.round((sectionScore / sectionTotal) * 100) : 0
                return (
                  <div key={s}>
                    <div className="flex items-center justify-between mb-1">
                      <span className={`text-sm font-medium ${sCfg.color}`}>{sCfg.emoji} {sCfg.label}</span>
                      <span className="text-sm text-zinc-400">{sectionScore}/{sectionTotal} — {sPct}%</span>
                    </div>
                    <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                      <div
                        className="h-full rounded-full"
                        style={{ width: `${sPct}%`, backgroundColor: getAccentHex(sCfg.accent) }}
                      />
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Question review */}
        <div>
          <button
            onClick={() => setShowBreakdown(!showBreakdown)}
            className="w-full flex items-center justify-between p-4 bg-white/3 border border-white/10 rounded-2xl hover:border-white/20 transition-colors mb-3"
          >
            <span className="font-bold text-white">📋 Review Answers ({questions.length})</span>
            <span className="text-zinc-400 text-sm">{showBreakdown ? '▲ collapse' : '▼ expand'}</span>
          </button>

          {showBreakdown && (
            <div className="space-y-3">
              {questions.map((q, i) => {
                const a            = answers[i]
                const isCorrect    = a?.selected_index === q.correct_index
                const timedOut     = a?.selected_index === -1
                const qSection     = (a?.section ?? q.section) as Section
                const benchmarkMs  = SECTION_BENCHMARKS_MS[qSection] ?? 30000
                const benchmarkS   = (benchmarkMs / 1000).toFixed(0)
                const takenMs      = a?.time_taken_ms ?? 0
                const takenS       = (takenMs / 1000).toFixed(1)
                const difficulty   = q.difficulty ?? 2
                const diffLabel    = difficulty === 1 ? 'Easy' : difficulty === 3 ? 'Hard' : 'Medium'

                // Time color: green ≤ target, yellow ≤ 125% of target, red > 125%
                const overRatio    = takenMs / benchmarkMs
                const timeColor    = overRatio <= 1 ? '#10b981' : overRatio <= 1.25 ? '#f59e0b' : '#f43f5e'
                const timeBg       = overRatio <= 1 ? '#10b98118' : overRatio <= 1.25 ? '#f59e0b18' : '#f43f5e18'

                const userAnswer   = (a && a.selected_index >= 0) ? q.options[a.selected_index] : null
                const correctAnswer = q.options[q.correct_index]

                return (
                  <div
                    key={q.id}
                    className={`rounded-2xl border overflow-hidden ${
                      isCorrect
                        ? 'border-emerald-500/25 bg-emerald-500/5'
                        : 'border-rose-500/25 bg-rose-500/5'
                    }`}
                  >
                    {/* ── Topline ── */}
                    <div className="flex flex-wrap items-center gap-x-4 gap-y-1.5 px-4 py-3 border-b border-white/5">
                      {/* Correct / Wrong */}
                      <span className="text-base font-bold shrink-0">
                        {isCorrect ? '✅ Correct' : timedOut ? '⏰ Timed Out' : '❌ Wrong'}
                      </span>

                      {/* Difficulty dots */}
                      <div className="flex items-center gap-1 shrink-0">
                        {[1, 2, 3].map(d => (
                          <div
                            key={d}
                            className="w-2 h-2 rounded-full"
                            style={{ backgroundColor: d <= difficulty ? '#f59e0b' : 'rgba(255,255,255,0.15)' }}
                          />
                        ))}
                        <span className="text-xs text-zinc-500 ml-1">{diffLabel}</span>
                      </div>

                      {/* Time chip */}
                      <div
                        className="flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold shrink-0"
                        style={{ color: timeColor, backgroundColor: timeBg }}
                      >
                        ⏱ {takenS}s
                      </div>

                      {/* Target time */}
                      <span className="text-xs text-zinc-500 shrink-0">
                        Target <span className="text-zinc-300 font-medium">{benchmarkS}s</span>
                      </span>
                    </div>

                    {/* ── Body ── */}
                    <div className="px-4 py-4 space-y-3">
                      {/* Question */}
                      <p className="text-sm text-zinc-200 leading-relaxed font-medium">{q.prompt}</p>

                      {/* Answers */}
                      <div className="space-y-1.5">
                        {/* Your answer — always shown */}
                        <div className="flex items-start gap-2">
                          <span className="text-xs text-zinc-500 shrink-0 mt-0.5 w-24">Your answer:</span>
                          {userAnswer ? (
                            <span className={`text-xs font-medium ${isCorrect ? 'text-emerald-400' : 'text-rose-400'}`}>
                              {userAnswer}
                            </span>
                          ) : (
                            <span className="text-xs text-zinc-600 italic">No answer (timed out)</span>
                          )}
                        </div>

                        {/* Correct answer — always shown if wrong, or as confirmation if right */}
                        {!isCorrect && (
                          <div className="flex items-start gap-2">
                            <span className="text-xs text-zinc-500 shrink-0 mt-0.5 w-24">Correct answer:</span>
                            <span className="text-xs font-medium text-emerald-400">{correctAnswer}</span>
                          </div>
                        )}
                      </div>

                      {/* Rationale — always shown */}
                      {q.explanation && (
                        <div className="pt-2 border-t border-white/5">
                          <p className="text-xs text-zinc-500 font-semibold mb-1 uppercase tracking-wide">💡 Rationale</p>
                          <p className="text-xs text-zinc-400 leading-relaxed">{q.explanation}</p>
                        </div>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>

        {/* Action buttons */}
        <div className="grid grid-cols-2 gap-3 pb-8">
          <Link
            href={`/quiz/${section}`}
            className="flex items-center justify-center gap-2 bg-white/5 border border-white/10 hover:border-white/20 text-white font-medium py-3.5 rounded-2xl transition-colors"
          >
            🔄 Try Again
          </Link>
          <Link
            href="/"
            className="flex items-center justify-center gap-2 bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
          >
            🏠 Dashboard
          </Link>
        </div>
      </div>
    </div>
  )
}

function getRank(pct: number): { emoji: string; name: string; color: string; blurb: string } {
  if (pct === 100) return { emoji: '🌌', name: 'Wyrm',      color: '#a855f7', blurb: 'Flawless. The Tesseract Wyrm acknowledges you.' }
  if (pct >= 90)  return { emoji: '✨', name: 'Elder',     color: '#f59e0b', blurb: "The Grand Wordumph says 'adequate.' That's high praise." }
  if (pct >= 80)  return { emoji: '💫', name: 'Awakened',  color: '#10b981', blurb: 'Your creature is fully awake and paying attention.' }
  if (pct >= 70)  return { emoji: '🔷', name: 'Beastling', color: '#3b82f6', blurb: "You're outgrowing the hatchling phase." }
  if (pct >= 60)  return { emoji: '🌀', name: 'Stirring',  color: '#8b5cf6', blurb: 'Something is stirring inside your beast.' }
  if (pct >= 40)  return { emoji: '🪶', name: 'Fledgling', color: '#f97316', blurb: 'Your wings exist. They just need practice.' }
  return           { emoji: '🥚', name: 'Hatchling', color: '#64748b', blurb: 'The Pageslobber is not judging you.' }
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
