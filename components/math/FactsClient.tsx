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
import { SESSION_SIZE, parseFactKey, isCorrect } from '@/lib/math-facts'
import type { FactCard } from '@/lib/math-facts'
import { Equation, Keypad, typeKey } from '@/components/math/Equation'
import { stepsForKey } from '@/lib/math-steps'

interface Shown { card: FactCard; retry: boolean }
interface Result { card: FactCard; correct: boolean; ms: number; given: string }
interface Badge { key: string; label: string; icon_emoji: string; description: string }
type Feedback = { kind: 'fast' | 'slow' | 'wrong'; ms: number; given: string } | null


export default function FactsClient({ deck, deckId, home }: {
  deck: FactCard[]
  /** What was played, for round history: mul, div, equiv, fdp, or mul:7. */
  deckId: string
  /** Math Facts home on this deck's fact-map tab. */
  home: string
}) {
  const router = useRouter()
  const [queue, setQueue]       = useState<Shown[]>(() => deck.map(card => ({ card, retry: false })))
  const [idx, setIdx]           = useState(0)
  const [input, setInput]       = useState('')
  const [feedback, setFeedback] = useState<Feedback>(null)
  const [results, setResults]   = useState<Result[]>([])
  const [newlyFluent, setNewlyFluent] = useState<string[]>([])
  const [saveError, setSaveError]     = useState(false)
  const [pending, setPending]   = useState(0)
  const [badges, setBadges]     = useState<Badge[]>([])
  const awarded = useRef(false)
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
    const correct = isCorrect(current.card, given)
    const fast = correct && ms <= current.card.targetMs

    if (!current.retry) {
      setResults(r => [...r, { card: current.card, correct, ms, given }])
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
    if (k === 'skip')  return submit('-1')
    setInput(s => typeKey(s, k))
  }, [feedback, input, submit])

  useEffect(() => {
    // preventDefault matters: without it, Enter also "clicks" whichever
    // keypad button still has focus, typing a stray digit into the next card.
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

  // Once every answer has saved: record the round for history, then badges.
  // Badges are computed in SQL from the saved history, so asking earlier would
  // miss what the last card earned. Both fail soft: the round itself is
  // already saved card by card, and these only add history and badges.
  useEffect(() => {
    if (!done || pending > 0 || awarded.current) return
    awarded.current = true
    const perfect = results.length >= SESSION_SIZE &&
      results.every(r => r.correct && r.ms <= r.card.targetMs)
    void (async () => {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (user && results.length > 0) {
        await supabase.from('fact_rounds').insert({
          user_id: user.id,
          deck:    deckId,
          cards:   results.length,
          correct: results.filter(r => r.correct).length,
          fast:    results.filter(r => r.correct && r.ms <= r.card.targetMs).length,
          points:  newlyFluent.reduce((s, k) => s + (parseFactKey(k)?.points ?? 0), 0),
          answers: results.map(r => ({ k: r.card.key, g: r.given, c: r.correct, ms: r.ms })),
        })
      }
      const { data: keys, error } = await supabase.rpc('award_fact_badges', { p_perfect_round: perfect })
      if (error || !Array.isArray(keys) || keys.length === 0) return
      const { data: defs } = await supabase
        .from('achievement_definitions')
        .select('key, label, icon_emoji, description')
        .in('key', keys as string[])
      if (defs) setBadges(defs as Badge[])
    })()
  }, [done, pending, results, deckId, newlyFluent])

  // ── Summary ────────────────────────────────────────────────────────────────
  if (done) {
    const correct = results.filter(r => r.correct).length
    const fast    = results.filter(r => r.correct && r.ms <= r.card.targetMs).length
    const missed  = results.filter(r => !r.correct)
    const slow    = results.filter(r => r.correct && r.ms > r.card.targetMs)
    const earned  = newlyFluent.reduce((s, k) => s + (parseFactKey(k)?.points ?? 0), 0)

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

          {badges.length > 0 && (
            <div className="rounded-2xl border border-violet-500/30 bg-violet-500/10 p-4 text-left">
              <p className="text-xs font-bold uppercase tracking-wide text-violet-300 mb-3">
                🏅 New badge{badges.length === 1 ? '' : 's'}
              </p>
              <div className="space-y-2.5">
                {badges.map(b => (
                  <div key={b.key} className="flex items-center gap-3">
                    <span className="text-3xl">{b.icon_emoji}</span>
                    <div>
                      <p className="font-bold text-white">{b.label}</p>
                      <p className="text-xs text-zinc-400">{b.description}</p>
                    </div>
                  </div>
                ))}
              </div>
              <Link href="/profile" className="block mt-3 text-xs text-violet-300 hover:text-violet-200">See all your badges →</Link>
            </div>
          )}

          {saveError && (
            <p className="text-sm text-rose-300 rounded-xl border border-rose-500/30 bg-rose-500/10 p-3">
              Some answers didn&rsquo;t save, so points may be missing. Check your connection and play again.
            </p>
          )}

          {missed.length > 0 && (
            <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4">
              <p className="text-xs font-bold uppercase tracking-wide text-rose-300 mb-2">Practice these · tap for how</p>
              <div className="space-y-1.5">
                {missed.map(r => (
                  <details key={r.card.key} className="rounded-lg bg-white/5">
                    <summary className="cursor-pointer list-none [&::-webkit-details-marker]:hidden px-2 py-1.5 font-mono text-sm text-white">
                      {r.card.full} <span className="text-zinc-500 text-xs">· how?</span>
                    </summary>
                    <ol className="px-3 pb-2 space-y-1 text-xs text-zinc-300 list-decimal list-inside">
                      {stepsForKey(r.card.key).map((step, i) => <li key={i}>{step}</li>)}
                    </ol>
                  </details>
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
              href={home}
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
  const target = card.targetMs
  const blankText = feedback ? (feedback.kind === 'wrong' ? card.answer : feedback.given) : (input || card.blank)

  return (
    // Exactly one screen tall (dvh tracks the phone's visible area, address bar
    // included), so the keypad is always on screen with no scrolling. The
    // equation area absorbs whatever height is left; keys shrink on short phones.
    // Fixed to the viewport, not just 100dvh tall: iPhone Safari can still
    // scroll the document a little as its toolbar collapses, which slid the
    // Exit / progress bar up under the status bar.
    <div
      className="fixed inset-0 overflow-hidden bg-[#0a0a0f] flex flex-col"
      style={{ paddingTop: 'env(safe-area-inset-top)', paddingBottom: 'env(safe-area-inset-bottom)' }}
    >
      <div className="z-30 border-b border-white/5 bg-[#0a0a0f]/90 backdrop-blur-sm">
        <div className="max-w-xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href={home} className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
          <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full rounded-full bg-amber-400 transition-all duration-300" style={{ width: `${(idx / queue.length) * 100}%` }} />
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{Math.min(idx + 1, queue.length)} / {queue.length}</span>
        </div>
      </div>

      <div className="flex-1 min-h-0 max-w-xl mx-auto w-full px-4 pt-3 pb-3 flex flex-col">
        <div className="flex items-center justify-end text-xs mb-2 text-zinc-500">
          {current.retry ? '🔁 Practice, not scored' : `Aim for under ${target / 1000}s`}
        </div>

        {/* The instruction, big and right above the equation: it says what
            form the answer takes. */}
        <div className="flex-1 min-h-0 flex flex-col items-center justify-center gap-5">
          <p className="text-base sm:text-lg font-bold text-sky-200 bg-sky-500/10 border border-sky-500/30 rounded-full px-4 py-1.5">
            {card.hint}
          </p>
          <Equation card={card} blankText={blankText} done={!!feedback} />
        </div>

        {/* Feedback line — fixed height so the keypad never jumps */}
        <div className="h-10 flex items-center justify-center text-center text-xs sm:text-sm font-bold leading-tight">
          {feedback?.kind === 'fast'  && <span className="text-emerald-300">⚡ {(feedback.ms / 1000).toFixed(1)}s</span>}
          {feedback?.kind === 'slow'  && <span className="text-amber-300">✓ Right — {(feedback.ms / 1000).toFixed(1)}s. Under {target / 1000}s to master it.</span>}
          {feedback?.kind === 'wrong' && (
            <span className="text-rose-300">
              {feedback.given === '-1' ? 'Here it is' : `Not ${feedback.given}`} — {card.full}. It&rsquo;ll come back at the end.
            </span>
          )}
        </div>

        <Keypad onPress={press} canSubmit={input !== ''} disabled={!!feedback} />
        <button
          onClick={() => press('skip')}
          disabled={!!feedback}
          className="mt-1.5 py-1 text-xs text-zinc-600 hover:text-zinc-400 disabled:opacity-0 transition-colors"
        >
          I don&rsquo;t know — show me
        </button>
      </div>
    </div>
  )
}
