'use client'

// ── Pin the map ──────────────────────────────────────────────────────────────
//
// "Find Nairobi" or "Find Rio de Janeiro": tap the map where you think it
// is. The map draws the line to the real place and the distance scores
// (lib/geo-pin.ts). Ten places a round, capitals and famous cities mixed,
// one continent at a time. The line under the name always says which
// country (lib/geo-pin.ts explains why). One screen tall like every round, so
// nothing scrolls on a phone; pinch or +/- to zoom in for a precise pin.
//
// The whole round is saved at the end through record_geo_pin_round, which
// scores the pins again itself. Before the map migration is applied
// (canSave false) the round still plays, it just is not saved.

import { useState, useEffect, useRef, useCallback } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { REGION_BOX } from '@/lib/geo-map'
import {
  PIN_LEVELS, PIN_LEVEL_LABEL, PIN_RINGS, MAX_PIN_SCORE, pinScore, pinDeckId, pinHref,
} from '@/lib/geo-pin'
import type { PinLevel, PinPlace } from '@/lib/geo-pin'
import { CONTINENT_LABEL, CONTINENT_EMOJI } from '@/lib/geo-meta'
import type { Continent } from '@/lib/geo-meta'
import WorldMap, { useWorldMap } from '@/components/geo/WorldMap'
import type { LatLon } from '@/components/geo/WorldMap'

interface Pin { tap: LatLon | null; ms: number; km: number | null; points: number }
interface BoardRow { user_id: string; display_name: string; best: number }

const SHOW_MS = 3200
const fmtKm = (km: number) => (km < 10 ? km.toFixed(1) : Math.round(km).toLocaleString('en-US'))

export default function PinClient({ places, continent, level, canSave }: {
  places: PinPlace[]
  continent: Continent
  level: PinLevel
  canSave: boolean
}) {
  const router = useRouter()
  const deck = pinDeckId(continent, level)
  const { shapes, failed } = useWorldMap()
  const [idx, setIdx] = useState(0)
  const [pins, setPins] = useState<Pin[]>([])
  const [saved, setSaved] = useState<'saving' | 'saved' | 'error' | 'off'>(canSave ? 'saving' : 'off')
  const [serverScore, setServerScore] = useState<number | null>(null)
  const [board, setBoard] = useState<BoardRow[]>([])
  const [me, setMe] = useState<string | null>(null)
  const shownAt = useRef(0)
  const answered = useRef(false)
  const saving = useRef(false)

  const done = idx >= places.length
  const place = places[idx]
  const shown = pins.length > idx ? pins[idx] : null
  const ready = !!shapes

  useEffect(() => { shownAt.current = performance.now(); answered.current = false }, [idx, ready])

  const answer = useCallback((tap: LatLon | null) => {
    if (!ready || done || answered.current) return
    answered.current = true
    const ms = Math.round(performance.now() - shownAt.current)
    const s = pinScore(place, tap, ms)
    setPins(p => [...p, { tap, ms, km: s.km, points: s.points }])
  }, [ready, done, place])

  // Show the answer for a moment, then the next place.
  useEffect(() => {
    if (pins.length !== idx + 1) return
    const t = setTimeout(() => setIdx(i => i + 1), SHOW_MS)
    return () => clearTimeout(t)
  }, [pins.length, idx])
  const next = () => { if (pins.length === idx + 1) setIdx(i => i + 1) }

  // Save once, at the end. The server's score is the one that counts.
  useEffect(() => {
    if (!done || !canSave || saving.current) return
    saving.current = true
    void (async () => {
      const supabase = createClient()
      const p_pins = pins.map((p, i) => ({
        i: places[i].key,
        lat: p.tap ? Math.round(p.tap.lat * 1e4) / 1e4 : null,
        lon: p.tap ? Math.round(p.tap.lon * 1e4) / 1e4 : null,
        ms: p.ms,
      }))
      const { data, error } = await supabase.rpc('record_geo_pin_round', { p_deck: deck, p_pins })
      if (error || typeof data !== 'number') { setSaved('error'); return }
      setServerScore(data)
      setSaved('saved')
      const [{ data: rows }, { data: { user } }] = await Promise.all([
        supabase.from('geo_pin_leaderboard_view').select('user_id, display_name, best')
          .eq('deck', deck).order('best', { ascending: false }).limit(10),
        supabase.auth.getUser(),
      ])
      if (rows) setBoard(rows as BoardRow[])
      if (user) setMe(user.id)
    })()
  }, [done, canSave, pins, places, deck])

  const total = pins.reduce((s, p) => s + p.points, 0)

  // ── Summary ────────────────────────────────────────────────────────────────
  if (done) {
    const score = serverScore ?? total
    return (
      <div className="min-h-screen bg-[#0a0a0f] flex justify-center px-4 py-10">
        <div className="max-w-md w-full space-y-6 text-center">
          <p className="text-5xl">{score >= 800 ? '🏆' : '📍'}</p>
          <div>
            <h1 className="text-3xl font-black text-white tabular-nums">{score}<span className="text-base font-normal text-zinc-500"> / {MAX_PIN_SCORE}</span></h1>
            <p className="text-zinc-400 text-sm mt-1">{CONTINENT_EMOJI[continent]} {CONTINENT_LABEL[continent]} · Level {level}, {PIN_LEVEL_LABEL[level]}</p>
            <p className="text-xs mt-1 text-zinc-500">
              {saved === 'saving' && 'Saving…'}
              {saved === 'saved' && 'Saved.'}
              {saved === 'error' && <span className="text-rose-300">This round didn&rsquo;t save. Check your connection and play again.</span>}
              {saved === 'off' && 'Scores are saved once Pin the map is fully set up.'}
            </p>
          </div>

          <div className="text-left rounded-2xl border border-white/10 bg-white/3 p-4 space-y-1.5">
            {places.map((pl, i) => {
              const p = pins[i]
              return (
                <div key={pl.key} className="flex items-center gap-3 text-sm min-w-0">
                  <span className="w-0 flex-1 truncate text-white">{pl.kind === 'city' ? '🏙️' : '🏛️'} {pl.name} <span className="text-zinc-500">· {pl.country}</span></span>
                  <span className="shrink-0 text-zinc-400 tabular-nums">{p?.km == null ? 'skipped' : `${fmtKm(p.km)} km`}</span>
                  <span className={`shrink-0 w-10 text-right font-bold tabular-nums ${p?.points ? 'text-emerald-300' : 'text-zinc-600'}`}>+{p?.points ?? 0}</span>
                </div>
              )
            })}
          </div>

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

          <div className="grid grid-cols-3 gap-2">
            {PIN_LEVELS.map(l => (
              <Link key={l} href={pinHref(continent, l)}
                    className={`rounded-xl border px-2 py-2 text-xs font-semibold transition-colors ${
                      l === level ? 'border-sky-400/50 bg-sky-500/15 text-sky-100' : 'border-white/10 text-zinc-300 hover:border-white/25'
                    }`}>
                Level {l}<span className="block font-normal text-zinc-500 truncate">{PIN_LEVEL_LABEL[l]}</span>
              </Link>
            ))}
          </div>
          <div className="grid grid-cols-2 gap-3">
            <button onClick={() => router.refresh()}
                    className="bg-sky-500 hover:bg-sky-400 text-black font-bold py-3.5 rounded-2xl transition-colors">
              Play again
            </button>
            <Link href="/geo"
                  className="flex items-center justify-center bg-white/5 border border-white/10 hover:border-white/25 text-white font-medium py-3.5 rounded-2xl transition-colors">
              Geography home
            </Link>
          </div>
          <p className="text-[11px] text-zinc-600">
            Rings: {PIN_RINGS.map(([km, p]) => `${p} within ${km.toLocaleString('en-US')} km`).join(', ')}. Up to +10 for speed.
          </p>
        </div>
      </div>
    )
  }

  // ── A place ────────────────────────────────────────────────────────────────
  const target = { lat: place.lat, lon: place.lon }
  return (
    <div className="h-[100dvh] overflow-hidden bg-[#0a0a0f] flex flex-col" style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}>
      <div className="border-b border-white/5 bg-[#0a0a0f]/90">
        <div className="max-w-3xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href="/geo" className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
          <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full rounded-full bg-sky-400 transition-all duration-300" style={{ width: `${(idx / places.length) * 100}%` }} />
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{idx + 1} / {places.length}</span>
          <span className="text-sm font-bold text-sky-300 shrink-0 tabular-nums">{total}</span>
        </div>
      </div>

      <div className="flex-1 min-h-0 max-w-3xl mx-auto w-full px-3 pt-2 pb-3 flex flex-col gap-2">
        <div className="flex items-end gap-3 min-w-0 px-1">
          <div className="w-0 flex-1">
            <h1 className="text-xl sm:text-2xl font-black text-white leading-tight truncate">📍 Find {place.name}</h1>
            <p className="text-xs text-zinc-400 truncate">{place.where}</p>
          </div>
          <span className="shrink-0 text-[11px] text-zinc-500">{CONTINENT_EMOJI[continent]} Level {level}</span>
        </div>

        <div className="relative flex-1 min-h-0 rounded-xl overflow-hidden ring-1 ring-white/10">
          <div className="absolute inset-0">
            {shapes ? (
              <WorldMap
                shapes={shapes}
                box={REGION_BOX[continent]}
                interactive
                onTap={shown ? undefined : tap => answer(tap)}
                target={shown ? target : null}
                guess={shown?.tap ?? null}
                label={`Map of ${CONTINENT_LABEL[continent]}`}
              />
            ) : (
              <div className="h-full flex items-center justify-center text-sm text-zinc-400">
                {failed ? 'The map didn’t load. Go back and try again.' : 'Loading the map…'}
              </div>
            )}
          </div>
        </div>

        <div className="h-12 shrink-0 flex items-center gap-3 px-1" aria-live="polite">
          <div className="w-0 flex-1 text-sm font-bold leading-tight">
            {!shown && <span className="text-zinc-400 font-normal">Tap where it is. Pinch or + to zoom.</span>}
            {shown && shown.km === null && <span className="text-zinc-300">It&rsquo;s here, in {place.country}.</span>}
            {shown && shown.km !== null && (
              <span className={shown.points ? 'text-emerald-300' : 'text-rose-300'}>
                {shown.km <= PIN_RINGS[0][0] ? '🎯 Bullseye! ' : ''}{fmtKm(shown.km)} km away · +{shown.points}
              </span>
            )}
          </div>
          {shown ? (
            <button onClick={next} className="shrink-0 bg-sky-500 hover:bg-sky-400 text-black font-bold px-4 py-2.5 rounded-xl transition-colors">
              Next ▶
            </button>
          ) : (
            <button onClick={() => answer(null)} disabled={!ready}
                    className="shrink-0 text-xs text-zinc-500 hover:text-zinc-300 px-2 py-2 disabled:opacity-0 transition-colors">
              Show me
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
