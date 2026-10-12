'use client'

// ── Geography round ──────────────────────────────────────────────────────────
//
// Four big choices per card, tap or press 1-4. Built like the Math Facts
// round (components/math/FactsClient.tsx): one screen tall so nothing
// scrolls on a phone, each FIRST answer is saved as it happens so leaving
// mid-round loses nothing, and a missed card shows its answer and comes back
// once at the end for practice, unscored, because picking an answer you were
// just shown is not recall.
//
// "Name that country" cards show the map (components/geo/WorldMap.tsx). A
// round with any of them loads the map before the first card, so the clock
// never runs while the map downloads.

import { useState, useEffect, useRef, useCallback } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { SESSION_SIZE, KIND_LABEL, flagSrc } from '@/lib/geo-meta'
import type { GeoCard } from '@/lib/geo-meta'
import Flag from '@/components/geo/Flag'
import WorldMap, { useWorldMap } from '@/components/geo/WorldMap'

interface Shown { card: GeoCard; retry: boolean }
interface Result { card: GeoCard; correct: boolean; ms: number; given: string }
interface Badge { key: string; label: string; icon_emoji: string; description: string }
type Feedback = { kind: 'fast' | 'slow' | 'wrong'; ms: number; given: string } | null

const SKIP = '-1'

export default function GeoClient({ deck, deckId }: {
  deck: GeoCard[]
  /** What was played, for round history: "af:capitals", "all:all". */
  deckId: string
}) {
  const router = useRouter()
  const [queue, setQueue]       = useState<Shown[]>(() => deck.map(card => ({ card, retry: false })))
  const [idx, setIdx]           = useState(0)
  const [feedback, setFeedback] = useState<Feedback>(null)
  const [results, setResults]   = useState<Result[]>([])
  const [newlyFluent, setNewlyFluent] = useState<string[]>([])
  const [saveError, setSaveError]     = useState(false)
  const [pending, setPending]   = useState(0)
  const [badges, setBadges]     = useState<Badge[]>([])
  const awarded = useRef(false)
  const shownAt = useRef(0)
  // Two taps can land before React re-renders with `feedback` set; the ref
  // stops the second one recording the same card twice.
  const answered = useRef(false)

  const current = queue[idx]
  const done = idx >= queue.length
  const needsMap = deck.some(c => c.map)
  const { shapes, failed: mapFailed } = useWorldMap(needsMap)
  const mapReady = !needsMap || !!shapes
  const pointsOf = useCallback((key: string) => deck.find(c => c.key === key)?.points ?? 0, [deck])

  // Load every flag in the round up front, so a flag still downloading never
  // eats into the answer time.
  useEffect(() => {
    for (const c of deck) {
      for (const iso of [c.flag, ...c.options.map(o => o.flag)]) {
        if (iso) { const img = new window.Image(); img.src = flagSrc(iso) }
      }
    }
  }, [deck])

  useEffect(() => { shownAt.current = performance.now(); answered.current = false }, [idx, mapReady])

  const save = useCallback(async (card: GeoCard, correct: boolean, ms: number) => {
    setPending(n => n + 1)
    try {
      const { data, error } = await createClient()
        .rpc('record_geo_answer', { p_key: card.key, p_correct: correct, p_ms: ms })
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
    setIdx(i => i + 1)
  }, [])

  const choose = useCallback((given: string) => {
    if (!current || feedback || answered.current || !mapReady) return
    answered.current = true
    const ms = Math.round(performance.now() - shownAt.current)
    const correct = given === current.card.answer
    const fast = correct && ms <= current.card.targetMs

    if (!current.retry) {
      setResults(r => [...r, { card: current.card, correct, ms, given }])
      void save(current.card, correct, ms)
    }
    if (!correct && !current.retry) {
      setQueue(q => [...q, { card: current.card, retry: true }])
    }
    setFeedback({ kind: !correct ? 'wrong' : fast ? 'fast' : 'slow', ms, given })
    setTimeout(advance, !correct ? 2600 : fast ? 700 : 1500)
  }, [current, feedback, save, advance, mapReady])

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (!current || feedback) return
      const n = Number(e.key)
      if (Number.isInteger(n) && n >= 1 && n <= current.card.options.length) {
        e.preventDefault()
        choose(current.card.options[n - 1].value)
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [current, feedback, choose])

  // Once every answer has saved: record the round, then ask for badges.
  // Badges are computed in SQL from saved history, so asking earlier would
  // miss what the last card earned. Both fail soft.
  useEffect(() => {
    if (!done || pending > 0 || awarded.current) return
    awarded.current = true
    const perfect = results.length >= SESSION_SIZE &&
      results.every(r => r.correct && r.ms <= r.card.targetMs)
    void (async () => {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (user && results.length > 0) {
        await supabase.from('geo_rounds').insert({
          user_id: user.id,
          deck:    deckId,
          cards:   results.length,
          correct: results.filter(r => r.correct).length,
          fast:    results.filter(r => r.correct && r.ms <= r.card.targetMs).length,
          points:  newlyFluent.reduce((s, k) => s + pointsOf(k), 0),
          answers: results.map(r => ({ k: r.card.key, g: r.given, c: r.correct, ms: r.ms })),
        })
      }
      const { data: keys, error } = await supabase.rpc('award_geo_badges', { p_perfect_round: perfect })
      if (error || !Array.isArray(keys) || keys.length === 0) return
      const { data: defs } = await supabase
        .from('achievement_definitions')
        .select('key, label, icon_emoji, description')
        .in('key', keys as string[])
      if (defs) setBadges(defs as Badge[])
    })()
  }, [done, pending, results, deckId, newlyFluent, pointsOf])

  // ── Summary ────────────────────────────────────────────────────────────────
  if (done) {
    const correct = results.filter(r => r.correct).length
    const fast    = results.filter(r => r.correct && r.ms <= r.card.targetMs).length
    const missed  = results.filter(r => !r.correct)
    const slow    = results.filter(r => r.correct && r.ms > r.card.targetMs)
    const earned  = newlyFluent.reduce((s, k) => s + pointsOf(k), 0)

    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4 py-10">
        <div className="max-w-md w-full space-y-6 text-center">
          <p className="text-5xl">{correct === results.length ? '🏆' : '🌍'}</p>
          <div>
            <h1 className="text-2xl font-black text-white">{correct} / {results.length} correct</h1>
            <p className="text-zinc-400 text-sm mt-1">{fast} fast enough to count as mastered</p>
          </div>

          <div className="rounded-2xl border border-sky-500/30 bg-sky-500/10 p-4">
            {pending > 0 ? (
              <p className="text-sky-200 text-sm">Saving…</p>
            ) : (
              <>
                <p className="text-3xl font-black text-sky-300">+{earned}</p>
                <p className="text-xs text-sky-200/70 mt-1">
                  Explorer Points · {newlyFluent.length} card{newlyFluent.length === 1 ? '' : 's'} newly mastered
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
              <p className="text-xs font-bold uppercase tracking-wide text-rose-300 mb-2">Practice these</p>
              <ul className="space-y-1.5">
                {missed.map(r => <li key={r.card.key} className="text-sm text-white">{r.card.full}</li>)}
              </ul>
            </div>
          )}
          {slow.length > 0 && (
            <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4">
              <p className="text-xs font-bold uppercase tracking-wide text-amber-300 mb-2">Right, now get them faster</p>
              <ul className="space-y-1.5">
                {slow.map(r => (
                  <li key={r.card.key} className="text-sm text-white">
                    {r.card.full} <span className="text-zinc-500">{(r.ms / 1000).toFixed(1)}s</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => router.refresh()}
              className="bg-sky-500 hover:bg-sky-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
            >
              Play again
            </button>
            <Link
              href="/geo"
              className="flex items-center justify-center bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors"
            >
              Geography home
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // ── Waiting for the map ────────────────────────────────────────────────────
  if (!mapReady) {
    return (
      <div className="h-[100dvh] bg-[#0a0a0f] flex flex-col items-center justify-center gap-4 px-4 text-center">
        <p className="text-5xl">{mapFailed ? '🗺️' : '🌍'}</p>
        <p className="text-white font-bold">{mapFailed ? 'The map didn’t load.' : 'Loading the map…'}</p>
        {mapFailed && (
          <Link href="/geo" className="text-sky-300 hover:text-sky-200 text-sm">← Geography home</Link>
        )}
      </div>
    )
  }

  // ── Card ───────────────────────────────────────────────────────────────────
  const card = current.card
  const zoom = card.map ? shapes?.find(s => s.iso === card.map)?.zoom : undefined
  const flags = card.kind === 'flagr'
  const tone = (value: string) => {
    if (!feedback) return 'bg-white/5 border-white/10 text-white hover:bg-white/10 hover:border-white/25'
    if (value === card.answer) return 'bg-emerald-500/25 border-emerald-400 text-white'
    if (value === feedback.given) return 'bg-rose-500/25 border-rose-400 text-white'
    return 'bg-white/3 border-white/5 text-zinc-500'
  }

  return (
    // Exactly one screen tall (dvh tracks the phone's visible area), so the
    // four choices are always on screen with no scrolling. The question area
    // absorbs whatever height is left.
    <div
      className="h-[100dvh] overflow-hidden bg-[#0a0a0f] flex flex-col"
      style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}
    >
      <div className="border-b border-white/5 bg-[#0a0a0f]/90">
        <div className="max-w-xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href="/geo" className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
          <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full rounded-full bg-sky-400 transition-all duration-300" style={{ width: `${(idx / queue.length) * 100}%` }} />
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{Math.min(idx + 1, queue.length)} / {queue.length}</span>
        </div>
      </div>

      <div className="flex-1 min-h-0 max-w-xl mx-auto w-full px-4 pt-3 pb-3 flex flex-col">
        <div className="flex items-center justify-between text-xs mb-2">
          <span className="text-zinc-500">{current.retry ? '🔁 Practice — not scored' : KIND_LABEL[card.kind]}</span>
          <span className="text-zinc-500">Aim for under {card.targetMs / 1000}s</span>
        </div>

        {/* Question */}
        <div className="flex-1 min-h-0 flex flex-col items-center justify-center gap-3 text-center">
          {card.flag && (
            <div className="min-h-0 flex-1 max-h-48 w-full flex items-center justify-center">
              <Flag iso={card.flag} alt="The flag to name" priority
                    className="max-h-full w-auto max-w-[80%] rounded-md shadow-lg ring-1 ring-white/10" />
            </div>
          )}
          {shapes && zoom && (
            <div className="relative min-h-0 flex-1 w-full rounded-xl overflow-hidden ring-1 ring-white/10">
              <div className="absolute inset-0">
                <WorldMap shapes={shapes} box={zoom} highlight={card.map} label="A map with one country highlighted" />
              </div>
            </div>
          )}
          <h1 className={`font-black text-white leading-tight ${card.flag || card.map ? 'text-xl sm:text-2xl' : 'text-2xl sm:text-3xl'}`}>
            {card.prompt}
          </h1>
        </div>

        {/* Feedback — fixed height so the choices never jump */}
        <div className="h-11 flex items-center justify-center text-center text-xs sm:text-sm font-bold leading-tight" aria-live="polite">
          {feedback?.kind === 'fast'  && <span className="text-emerald-300">⚡ {(feedback.ms / 1000).toFixed(1)}s</span>}
          {feedback?.kind === 'slow'  && <span className="text-amber-300">✓ Right — {(feedback.ms / 1000).toFixed(1)}s. Under {card.targetMs / 1000}s to master it.</span>}
          {feedback?.kind === 'wrong' && (
            <span className="text-rose-300 line-clamp-2">{card.full} It&rsquo;ll come back at the end.</span>
          )}
        </div>

        {/* Choices */}
        <div className={flags ? 'grid grid-cols-2 gap-2' : 'grid grid-cols-1 gap-2'}>
          {card.options.map((o, i) => (
            <button
              key={o.value}
              onClick={() => choose(o.value)}
              disabled={!!feedback}
              aria-label={flags ? `Flag ${i + 1}` : undefined}
              className={`relative rounded-2xl border-2 font-bold transition-colors active:scale-[0.98] ${tone(o.value)} ${
                flags ? 'h-[clamp(4.5rem,15dvh,8rem)] p-2 flex items-center justify-center'
                      : 'h-[clamp(3rem,8.5dvh,4rem)] pl-11 pr-3 text-left text-base sm:text-lg leading-tight'
              }`}
            >
              <span className={`absolute rounded-md bg-black/30 text-zinc-400 flex items-center justify-center ${
                flags ? 'left-1 top-1 w-5 h-5 text-[10px]' : 'left-2 top-1/2 -translate-y-1/2 w-6 h-6 text-xs'
              }`}>
                {i + 1}
              </span>
              {o.flag
                ? <Flag iso={o.flag} alt={`Flag ${i + 1}`} className="max-h-full w-auto max-w-[72%] rounded-sm ring-1 ring-white/10" />
                : <span className="line-clamp-2">{o.label}</span>}
            </button>
          ))}
        </div>
        <button
          onClick={() => choose(SKIP)}
          disabled={!!feedback}
          className="mt-1.5 py-1 text-xs text-zinc-600 hover:text-zinc-400 disabled:opacity-0 transition-colors"
        >
          I don&rsquo;t know — show me
        </button>
      </div>
    </div>
  )
}
