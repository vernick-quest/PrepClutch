'use client'

// ── The end of a Pin the map round, both modes ───────────────────────────────
//
// Saves the round once, then says how it went the way a Traveler IQ level
// does: stars against a pass mark (lib/geo-pin.ts PIN_STARS), the student's
// previous best on this map, how the score compares with every round played
// here (geo_pin_percentile, 073: aggregates only, shown from 10 rounds), and
// the leaderboard. A passed round's main button is the next step: the next
// level, and after the last country level, the places.
//
// The server's score is the one that counts (it scores the taps itself).
// Before the migrations are applied (canSave false) nothing is saved and the
// page says so; a missing comparison function just hides the comparison.

import { useEffect, useRef, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  PIN_LEVELS, PIN_LEVEL_LABEL, COUNTRY_LEVEL_LABEL, PIN_STARS, PIN_PASS, MAX_PIN_SCORE, pinStars, pinHref,
} from '@/lib/geo-pin'
import type { PinLevel, PinMode } from '@/lib/geo-pin'
import { CONTINENT_LABEL, CONTINENT_EMOJI, homeHref } from '@/lib/geo-meta'
import type { Continent } from '@/lib/geo-meta'

interface BoardRow { user_id: string; display_name: string; best: number }
type Saved = 'saving' | 'saved' | 'error' | 'off'

/** Save a finished round through `rpc`, then load what the end screen shows. */
export function usePinSave(done: boolean, canSave: boolean, deck: string, rpc: string, args: () => Record<string, unknown>) {
  const [saved, setSaved] = useState<Saved>(canSave ? 'saving' : 'off')
  const [serverScore, setServerScore] = useState<number | null>(null)
  const [board, setBoard] = useState<BoardRow[]>([])
  const [me, setMe] = useState<string | null>(null)
  const [prevBest, setPrevBest] = useState<number | null>(null)
  const [stats, setStats] = useState<{ rounds: number; better_than_pct: number } | null>(null)
  const saving = useRef(false)
  const argsRef = useRef(args)
  useEffect(() => { argsRef.current = args })

  useEffect(() => {
    if (!done || !canSave || saving.current) return
    saving.current = true
    void (async () => {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        setMe(user.id)
        // Best before this round: read first, the round is saved next.
        const { data: mine } = await supabase.from('geo_pin_rounds').select('score')
          .eq('user_id', user.id).eq('deck', deck).order('score', { ascending: false }).limit(1)
        if (mine?.length) setPrevBest(mine[0].score as number)
      }
      const { data, error } = await supabase.rpc(rpc, argsRef.current())
      if (error || typeof data !== 'number') { setSaved('error'); return }
      setServerScore(data)
      setSaved('saved')
      const [{ data: rows }, cmp] = await Promise.all([
        supabase.from('geo_pin_leaderboard_view').select('user_id, display_name, best')
          .eq('deck', deck).order('best', { ascending: false }).limit(10),
        supabase.rpc('geo_pin_percentile', { p_deck: deck, p_score: data }),
      ])
      if (rows) setBoard(rows as BoardRow[])
      const st = cmp.data as { rounds?: unknown; better_than_pct?: unknown } | null
      if (!cmp.error && st && typeof st.rounds === 'number' && typeof st.better_than_pct === 'number') {
        setStats({ rounds: st.rounds, better_than_pct: st.better_than_pct })
      }
    })()
  }, [done, canSave, deck, rpc])

  return { saved, serverScore, board, me, prevBest, stats }
}

const stars = (n: number) => '★'.repeat(n) + '☆'.repeat(PIN_STARS.length - n)

export default function PinEnd({ score, continent, level, mode, save, rows, footnote }: {
  score: number
  continent: Continent
  level: PinLevel
  mode: PinMode
  save: ReturnType<typeof usePinSave>
  rows: React.ReactNode
  footnote: string
}) {
  const router = useRouter()
  const n = pinStars(score)
  const passed = n > 0
  const home = homeHref({ continent, group: 'all' })
  const labels = mode === 'country' ? COUNTRY_LEVEL_LABEL : PIN_LEVEL_LABEL
  const headline = n === 3 ? 'Brilliant round!' : n === 2 ? 'Great round!' : n === 1 ? 'Passed!' : 'Not quite'
  const { saved, board, me, prevBest, stats } = save

  // The next step once passed: the next level, then (after the last country
  // level) the places.
  const next: { href: string; label: string; places?: boolean } | null = !passed ? null
    : level < 3 ? { href: pinHref(continent, (level + 1) as PinLevel, mode), label: `Level ${level + 1} →` }
    : mode === 'country' ? { href: pinHref(continent, 1, 'place'), label: 'Next: 📍 Places →', places: true }
    : null
  const again = (
    <button onClick={() => router.refresh()}
            className={`font-bold py-3.5 rounded-2xl transition-colors ${next ? 'bg-white/5 border border-white/10 hover:border-white/25 text-white' : 'bg-sky-500 hover:bg-sky-400 text-black'}`}>
      {passed ? 'Play again' : 'Try again'}
    </button>
  )

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex justify-center px-4 py-10">
      <div className="max-w-md w-full space-y-6 text-center">
        <div>
          <p className={`text-4xl tracking-widest ${passed ? 'text-amber-300' : 'text-zinc-600'}`} aria-label={`${n} of ${PIN_STARS.length} stars`}>{stars(n)}</p>
          <h1 className="mt-2 text-2xl font-black text-white">{headline}</h1>
          {!passed && <p className="text-sm text-zinc-300 mt-1">{PIN_PASS - score} more points to pass.</p>}
          <p className="mt-3 text-3xl font-black text-white tabular-nums">{score}<span className="text-base font-normal text-zinc-500"> / {MAX_PIN_SCORE.toLocaleString('en-US')}</span></p>
          <p className="text-zinc-400 text-sm mt-1">
            {CONTINENT_EMOJI[continent]} {CONTINENT_LABEL[continent]} · {mode === 'country' ? '🗺️ Countries' : '📍 Places'} · Level {level}
          </p>
          <p className="text-[11px] text-zinc-500 mt-1">★ {PIN_STARS[0]} to pass · ★★ {PIN_STARS[1]} · ★★★ {PIN_STARS[2]}</p>
          {prevBest !== null && (
            <p className="text-xs mt-1 text-zinc-400">
              {score > prevBest ? <span className="text-emerald-300 font-semibold">New best! </span> : null}
              Your best here before: <span className="tabular-nums">{prevBest}</span>
            </p>
          )}
          {stats && stats.rounds >= 10 && (
            <p className="text-xs mt-1 text-sky-300">Better than {stats.better_than_pct}% of {stats.rounds.toLocaleString('en-US')} rounds on this map</p>
          )}
          <p className="text-xs mt-1 text-zinc-500">
            {saved === 'saving' && 'Saving…'}
            {saved === 'saved' && 'Saved.'}
            {saved === 'error' && <span className="text-rose-300">This round didn&rsquo;t save. Check your connection and play again.</span>}
            {saved === 'off' && 'Scores are saved once Pin the map is fully set up.'}
          </p>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {next ? (
            <>
              <Link href={next.href} className="flex items-center justify-center bg-sky-500 hover:bg-sky-400 text-black font-bold py-3.5 rounded-2xl transition-colors">
                {next.label}
              </Link>
              {again}
            </>
          ) : (
            <>
              {again}
              <Link href={home}
                    className="flex items-center justify-center bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors">
                Geography home
              </Link>
            </>
          )}
        </div>

        {mode === 'country' && !next?.places && (
          <Link href={pinHref(continent, 1, 'place')}
                className="block text-left rounded-2xl border border-sky-400/30 bg-sky-500/10 hover:bg-sky-500/15 p-4 transition-colors min-w-0">
            <span className="block text-xs font-bold uppercase tracking-wide text-sky-300">Step 2</span>
            <span className="block font-bold text-white">📍 Places: capitals and cities →</span>
            <span className="block text-xs text-zinc-400">Now find {CONTINENT_LABEL[continent]}&rsquo;s capitals and famous cities.</span>
          </Link>
        )}

        <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4 space-y-1.5">{rows}</div>

        {board.length > 0 && (
          <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4">
            <p className="text-xs font-bold uppercase tracking-wide text-sky-300 mb-2">🏆 Best scores here</p>
            <div className="space-y-1">
              {board.map((r, i) => (
                <div key={r.user_id} className={`flex items-center gap-3 text-sm min-w-0 ${r.user_id === me ? 'text-sky-300' : 'text-white'}`}>
                  <span className="w-6 shrink-0 text-zinc-500 tabular-nums">{i + 1}</span>
                  <span className="w-0 flex-1 truncate">{r.display_name}{r.user_id === me ? ' (you)' : ''}</span>
                  <span className="shrink-0 font-bold tabular-nums">{r.best}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="space-y-2">
          <div className="grid grid-cols-2 gap-2">
            {(['country', 'place'] as PinMode[]).map((m, i) => (
              <Link key={m} href={pinHref(continent, m === mode ? level : 1, m)}
                    className={`rounded-xl border px-2 py-2 text-xs font-semibold transition-colors min-w-0 ${
                      m === mode ? 'border-sky-400/50 bg-sky-500/15 text-sky-100' : 'border-white/10 text-zinc-300 hover:border-white/25'
                    }`}>
                <span className="block truncate">{i + 1}. {m === 'country' ? '🗺️ Countries' : '📍 Places'}</span>
              </Link>
            ))}
          </div>
          <div className="grid grid-cols-3 gap-2">
            {PIN_LEVELS.map(l => (
              <Link key={l} href={pinHref(continent, l, mode)}
                    className={`rounded-xl border px-2 py-2 text-xs font-semibold transition-colors min-w-0 ${
                      l === level ? 'border-sky-400/50 bg-sky-500/15 text-sky-100' : 'border-white/10 text-zinc-300 hover:border-white/25'
                    }`}>
                Level {l}<span className="block font-normal text-zinc-500 truncate">{labels[l]}</span>
              </Link>
            ))}
          </div>
          {next && (
            <Link href={home} className="inline-block text-sm text-sky-300 hover:text-sky-200 pt-1">← Geography home</Link>
          )}
        </div>

        <p className="text-[11px] text-zinc-600">{footnote}</p>
      </div>
    </div>
  )
}
