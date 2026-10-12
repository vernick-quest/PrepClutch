'use client'

// ── Math Facts session ───────────────────────────────────────────────────────
//
// Flash cards with a typed answer: no choices to guess between, and speed is
// the point. Each FIRST answer to a card is saved as it happens, so leaving
// mid-session loses nothing. A missed card shows its answer and comes back
// once at the end for practice; that retry is not recorded, because answering
// a card you were just shown is not recall.

import { useState, useEffect, useRef, useCallback } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { FORM_POINTS, FORM_TARGET_MS, parseFactKey } from '@/lib/math-facts'
import type { FactCard } from '@/lib/math-facts'

interface Shown { card: FactCard; retry: boolean }
interface Result { card: FactCard; correct: boolean; ms: number }
type Feedback = { kind: 'fast' | 'slow' | 'wrong'; ms: number; given: string } | null

const MAX_DIGITS = 3

export default function FactsClient({ deck }: { deck: FactCard[] }) {
  const router = useRouter()
  const [queue, setQueue]       = useState<Shown[]>(() => deck.map(card => ({ card, retry: false })))
  const [idx, setIdx]           = useState(0)
  const [input, setInput]       = useState('')
  const [feedback, setFeedback] = useState<Feedback>(null)
  const [results, setResults]   = useState<Result[]>([])
  const [newlyFluent, setNewlyFluent] = useState<string[]>([])
  const [saveError, setSaveError]     = useState(false)
  const [pending, setPending]   = useState(0)
  const shownAt = useRef(0)
  // Two Enter presses can land before React re-renders with `feedback` set;
  // the ref stops the second one recording the same card twice.
  const answered = useRef(false)

  const current = queue[idx]
  const done = idx >= queue.length

  useEffect(() => { shownAt.current = performance.now(); answered.current = false }, [idx])

  const save = useCallback(async (card: FactCard, correct: boolean, ms: number) => {
    setPending(n => n + 1)
    try {
      const { data, error } = await createClient()
        .rpc('record_fact_answer', { p_key: card.key, p_correct: correct, p_ms: ms })
      if (error) throw error
      if (data === true) setNewlyFluent(k => [...k, card.key])
    } catch {
      setSaveError(true)
    } finally {
      setPending(n => n - 1)
    }
  }, [])

  const advance = useCallback(() => {
    setFeedback(null)
    setInput('')
    setIdx(i => i + 1)
  }, [])

  const submit = useCallback((given: string) => {
    if (!current || feedback || given === '' || answered.current) return
    answered.current = true
    const ms = Math.round(performance.now() - shownAt.current)
    const correct = Number(given) === current.card.answer
    const fast = correct && ms <= FORM_TARGET_MS[current.card.form]

    if (!current.retry) {
      setResults(r => [...r, { card: current.card, correct, ms }])
      void save(current.card, correct, ms)
    }
    if (!correct && !current.retry) {
      setQueue(q => [...q, { card: current.card, retry: true }])
    }
    setFeedback({ kind: !correct ? 'wrong' : fast ? 'fast' : 'slow', ms, given })
    setTimeout(advance, !correct ? 2200 : fast ? 550 : 1300)
  }, [current, feedback, save, advance])

  const press = useCallback((k: string) => {
    if (feedback) return
    if (k === 'enter') return submit(input)
    if (k === 'back')  return setInput(s => s.slice(0, -1))
    if (k === 'skip')  return submit('-1')
    setInput(s => (s.length >= MAX_DIGITS ? s : (s === '0' ? k : s + k)))
  }, [feedback, input, submit])

  useEffect(() => {
    // preventDefault matters: without it, Enter also "clicks" whichever
    // keypad button still has focus, typing a stray digit into the next card.
    function onKey(e: KeyboardEvent) {
      const k = /^[0-9]$/.test(e.key) ? e.key
        : e.key === 'Backspace' ? 'back' : e.key === 'Enter' ? 'enter' : null
      if (!k) return
      e.preventDefault()
      press(k)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [press])

  // ── Summary ────────────────────────────────────────────────────────────────
  if (done) {
    const correct = results.filter(r => r.correct).length
    const fast    = results.filter(r => r.correct && r.ms <= FORM_TARGET_MS[r.card.form]).length
    const missed  = results.filter(r => !r.correct)
    const slow    = results.filter(r => r.correct && r.ms > FORM_TARGET_MS[r.card.form])
    const earned  = newlyFluent.reduce((s, k) => s + (FORM_POINTS[parseFactKey(k)?.form ?? 'c']), 0)

    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4 py-10">
        <div className="max-w-md w-full space-y-6 text-center">
          <p className="text-5xl">{correct === results.length ? '🏆' : '🧮'}</p>
          <div>
            <h1 className="text-2xl font-black text-white">{correct} / {results.length} correct</h1>
            <p className="text-zinc-400 text-sm mt-1">{fast} fast enough to count as mastered</p>
          </div>

          <div className="rounded-2xl border border-amber-500/30 bg-amber-500/10 p-4">
            {pending > 0 ? (
              <p className="text-amber-200 text-sm">Saving…</p>
            ) : (
              <>
                <p className="text-3xl font-black text-amber-400">+{earned}</p>
                <p className="text-xs text-amber-200/70 mt-1">
                  Fact Points · {newlyFluent.length} card{newlyFluent.length === 1 ? '' : 's'} newly mastered
                </p>
              </>
            )}
          </div>

          {saveError && (
            <p className="text-sm text-rose-300 rounded-xl border border-rose-500/30 bg-rose-500/10 p-3">
              Some answers didn&rsquo;t save, so points may be missing. Check your connection and play again.
            </p>
          )}

          {missed.length > 0 && (
            <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4">
              <p className="text-xs font-bold uppercase tracking-wide text-rose-300 mb-2">Practice these</p>
              <div className="flex flex-wrap gap-2">
                {missed.map(r => (
                  <span key={r.card.key} className="font-mono text-sm text-white bg-white/5 rounded-lg px-2 py-1">{r.card.full}</span>
                ))}
              </div>
            </div>
          )}
          {slow.length > 0 && (
            <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4">
              <p className="text-xs font-bold uppercase tracking-wide text-amber-300 mb-2">Right, now get them faster</p>
              <div className="flex flex-wrap gap-2">
                {slow.map(r => (
                  <span key={r.card.key} className="font-mono text-sm text-white bg-white/5 rounded-lg px-2 py-1">
                    {r.card.full} <span className="text-zinc-500">{(r.ms / 1000).toFixed(1)}s</span>
                  </span>
                ))}
              </div>
            </div>
          )}

          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => router.refresh()}
              className="bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
            >
              Play again
            </button>
            <Link
              href="/math"
              className="flex items-center justify-center bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors"
            >
              Math Facts home
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // ── Card ───────────────────────────────────────────────────────────────────
  const card = current.card
  const target = FORM_TARGET_MS[card.form]
  const blankText = feedback ? (feedback.kind === 'wrong' ? String(card.answer) : feedback.given) : (input || '?')
  // Once answered the blank always shows the right answer, so it is green.
  const blankColor = feedback ? 'text-emerald-300 border-emerald-400/60' : 'text-amber-300 border-amber-400/60'

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex flex-col">
      <div className="sticky top-0 z-30 border-b border-white/5 bg-[#0a0a0f]/90 backdrop-blur-sm">
        <div className="max-w-xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href="/math" className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
          <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full rounded-full bg-amber-400 transition-all duration-300" style={{ width: `${(idx / queue.length) * 100}%` }} />
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{Math.min(idx + 1, queue.length)} / {queue.length}</span>
        </div>
      </div>

      <div className="flex-1 max-w-xl mx-auto w-full px-4 py-6 flex flex-col">
        <div className="flex items-center justify-between text-xs mb-6">
          <span className="text-zinc-500">
            {current.retry ? '🔁 Practice — not scored' : card.form === 'c' ? 'Solve it' : 'Find the missing number'}
          </span>
          <span className="text-zinc-500">Aim for under {target / 1000}s</span>
        </div>

        {/* Equation */}
        <div className="flex-1 flex items-center justify-center">
          <div className="flex items-center gap-3 sm:gap-4 text-4xl sm:text-6xl font-black text-white tabular-nums">
            {card.parts.map((p, i) => p === null ? (
              <span key={i} className={`min-w-[1.6em] text-center border-b-4 pb-1 ${blankColor}`}>{blankText}</span>
            ) : (
              <span key={i} className={typeof p === 'string' ? 'text-zinc-500' : ''}>{p}</span>
            ))}
          </div>
        </div>

        {/* Feedback line — fixed height so the keypad never jumps */}
        <div className="h-10 flex items-center justify-center text-sm font-bold">
          {feedback?.kind === 'fast'  && <span className="text-emerald-300">⚡ {(feedback.ms / 1000).toFixed(1)}s</span>}
          {feedback?.kind === 'slow'  && <span className="text-amber-300">✓ Right — {(feedback.ms / 1000).toFixed(1)}s. Under {target / 1000}s to master it.</span>}
          {feedback?.kind === 'wrong' && (
            <span className="text-rose-300">
              {feedback.given === '-1' ? 'Here it is' : `Not ${feedback.given}`} — {card.full}. It&rsquo;ll come back at the end.
            </span>
          )}
        </div>

        {/* Keypad */}
        <div className="grid grid-cols-3 gap-2.5 mt-2">
          {['1','2','3','4','5','6','7','8','9'].map(d => (
            <Key key={d} onClick={() => press(d)}>{d}</Key>
          ))}
          <Key onClick={() => press('back')} muted>⌫</Key>
          <Key onClick={() => press('0')}>0</Key>
          <button
            onMouseDown={e => e.preventDefault()}
            onClick={() => press('enter')}
            disabled={!!feedback || input === ''}
            className="h-16 rounded-2xl bg-amber-500 hover:bg-amber-400 disabled:opacity-40 text-black text-2xl font-black transition-colors"
          >
            ✓
          </button>
        </div>
        <button
          onClick={() => press('skip')}
          disabled={!!feedback}
          className="mt-3 text-xs text-zinc-600 hover:text-zinc-400 disabled:opacity-0 transition-colors"
        >
          I don&rsquo;t know — show me
        </button>
      </div>
    </div>
  )
}

function Key({ children, onClick, muted }: { children: React.ReactNode; onClick: () => void; muted?: boolean }) {
  return (
    <button
      // Keep focus off the keypad so the keyboard Enter can't re-press it.
      onMouseDown={e => e.preventDefault()}
      onClick={onClick}
      className={`h-16 rounded-2xl border text-2xl font-bold transition-colors active:scale-[0.97] ${
        muted ? 'bg-white/3 border-white/8 text-zinc-400 hover:bg-white/8'
              : 'bg-white/5 border-white/10 text-white hover:bg-white/10'
      }`}
    >
      {children}
    </button>
  )
}
