'use client'

// ── Math Facts Learn mode ────────────────────────────────────────────────────
//
// The math counterpart of HSPT training. One card at a time:
//
//   no timer         the point is understanding, not speed
//   no score         nothing here is saved; Fact Points and mastery untouched
//   no auto-advance  the student reads the steps, then moves on
//
// They can try the card first (and see whether they were right) or go straight
// to "Show me how". Either way every card ends on its worked steps.

import { useState, useEffect, useCallback } from 'react'
import Link from 'next/link'
import { isCorrect } from '@/lib/math-facts'
import type { FactCard } from '@/lib/math-facts'
import { cardSteps } from '@/lib/math-steps'
import { Equation, Keypad, typeKey } from '@/components/math/Equation'

type Outcome = 'right' | 'wrong' | 'shown' | null

export default function LearnClient({ deck, playHref, home }: { deck: FactCard[]; playHref: string; home: string }) {
  const [idx, setIdx]         = useState(0)
  const [input, setInput]     = useState('')
  const [outcome, setOutcome] = useState<Outcome>(null)

  const card = deck[idx]
  const done = idx >= deck.length

  const reveal = useCallback((o: Outcome) => setOutcome(o), [])
  const next = useCallback(() => { setIdx(i => i + 1); setInput(''); setOutcome(null) }, [])

  const press = useCallback((k: string) => {
    if (!card) return
    if (outcome) { if (k === 'enter') next(); return }
    if (k === 'enter') { if (input) reveal(isCorrect(card, input) ? 'right' : 'wrong'); return }
    setInput(s => typeKey(s, k))
  }, [card, outcome, input, next, reveal])

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const k = /^[0-9]$/.test(e.key) ? e.key
        : e.key === '.' || e.key === ',' ? '.'
        : e.key === 'Backspace' ? 'back' : e.key === 'Enter' ? 'enter' : null
      if (!k) return
      e.preventDefault()
      press(k)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [press])

  if (done) {
    return (
      <div className="min-h-[100dvh] bg-[#0a0a0f] flex items-center justify-center px-4">
        <div className="max-w-md w-full text-center space-y-6">
          <p className="text-5xl">📖</p>
          <div>
            <h1 className="text-2xl font-black text-white">You worked through {deck.length} cards</h1>
            <p className="text-zinc-400 text-sm mt-2">
              Nothing in Learn is scored. When they feel easy, play them to master them.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Link href={playHref} className="flex items-center justify-center bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 rounded-2xl transition-colors">
              ▶ Play these
            </Link>
            <Link href={home} className="flex items-center justify-center bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors">
              Math Facts
            </Link>
          </div>
        </div>
      </div>
    )
  }

  const steps = cardSteps(card)
  const blankText = outcome ? card.answer : (input || card.blank)

  return (
    <div className="fixed inset-0 overflow-hidden bg-[#0a0a0f] flex flex-col" style={{ paddingTop: 'env(safe-area-inset-top)', paddingBottom: 'env(safe-area-inset-bottom)' }}>
      <div className="border-b border-white/5">
        <div className="max-w-xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href={home} className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
          <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full rounded-full bg-sky-400 transition-all duration-300" style={{ width: `${(idx / deck.length) * 100}%` }} />
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{idx + 1} / {deck.length}</span>
        </div>
      </div>

      <div className="flex-1 min-h-0 max-w-xl mx-auto w-full px-4 pt-3 pb-3 flex flex-col">
        <div className="flex items-center justify-between text-xs mb-2">
          <span className="font-semibold px-2.5 py-1 rounded-full bg-sky-500/10 border border-sky-500/30 text-sky-300">📖 Learn</span>
          <span className="text-zinc-500">no timer</span>
        </div>

        <div className={`${outcome ? 'py-3' : 'flex-1 min-h-0'} flex flex-col items-center justify-center gap-4`}>
          <p className="text-base sm:text-lg font-bold text-sky-200 bg-sky-500/10 border border-sky-500/30 rounded-full px-4 py-1.5">
            {card.hint}
          </p>
          <Equation card={card} blankText={blankText} done={!!outcome} />
        </div>

        {outcome ? (
          <>
            <p className={`text-center text-sm font-bold mb-2 ${
              outcome === 'right' ? 'text-emerald-300' : outcome === 'wrong' ? 'text-rose-300' : 'text-sky-300'
            }`}>
              {outcome === 'right' ? '✅ Right! Here’s the thinking behind it.'
                : outcome === 'wrong' ? `❌ Not ${input}. Here’s how to get it.`
                : '💡 Here’s how to get it.'}
            </p>
            <ol className="flex-1 min-h-0 overflow-y-auto space-y-2">
              {steps.map((step, i) => (
                <li key={i} className="flex gap-3 rounded-xl border border-white/10 bg-white/3 px-3 py-2.5">
                  <span className="shrink-0 w-6 h-6 rounded-full bg-sky-500/15 text-sky-300 text-xs font-bold flex items-center justify-center">{i + 1}</span>
                  <span className="text-sm text-zinc-200 leading-relaxed">{step}</span>
                </li>
              ))}
            </ol>
            <button
              onClick={next}
              className="mt-3 h-14 w-full rounded-2xl bg-sky-500 hover:bg-sky-400 text-black text-lg font-black transition-colors"
            >
              {idx === deck.length - 1 ? 'Finish →' : 'Next card →'}
            </button>
          </>
        ) : (
          <>
            <Keypad onPress={press} canSubmit={input !== ''} submitLabel="Check" />
            <button
              onClick={() => reveal('shown')}
              className="mt-2 py-2 text-sm font-semibold text-sky-300 hover:text-sky-200 transition-colors"
            >
              💡 Show me how
            </button>
          </>
        )}
      </div>
    </div>
  )
}
