'use client'

// ── Pin the map: places ──────────────────────────────────────────────────────
//
// "Find Nairobi" or "Find Rio de Janeiro": tap the map where you think it
// is. The map draws the line to the real place and the distance scores,
// scaled to the continent's map (lib/geo-pin.ts), with a verdict on every
// pin. Ten places a round, capitals and famous cities mixed, one continent
// at a time. The line under the name always says which country (lib/geo-pin.ts
// explains why). One screen tall like every round, so nothing scrolls on a
// phone; pinch or +/- to zoom in for a precise pin.
//
// The whole round is saved at the end through record_geo_pin_round, which
// scores the pins again itself. Before the map migration is applied
// (canSave false) the round still plays, it just is not saved.
//
// Each place is a pin card too (074): a Bullseye or Great pin within the
// card's target time masters it, for Explorer Points. The server judges that
// in the same call; `canMaster` (074 is applied) turns on the end screen's
// Explorer Points and newly mastered list.

import { useState, useEffect, useRef, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { REGION_BOX, pinViewBox } from '@/lib/geo-map'
import {
  PIN_ACCURACY, PIN_VERDICT_LABEL, pinScore, pinDeckId, pinVerdict,
} from '@/lib/geo-pin'
import type { PinLevel, PinPlace } from '@/lib/geo-pin'
import { CONTINENT_LABEL, CONTINENT_EMOJI, KIND_SCORE, homeHref, pinCardKey } from '@/lib/geo-meta'
import type { Continent } from '@/lib/geo-meta'
import WorldMap, { useWorldMap } from '@/components/geo/WorldMap'
import type { LatLon } from '@/components/geo/WorldMap'
import PinEnd, { usePinSave, fastEnough } from '@/components/geo/PinEnd'
import type { PinMastery } from '@/components/geo/PinEnd'

interface Pin { tap: LatLon | null; ms: number; km: number | null; points: number }

const SHOW_MS = 3200
const fmtKm = (km: number) => (km < 10 ? km.toFixed(1) : Math.round(km).toLocaleString('en-US'))
const VERDICT_TONE = { bull: 'text-emerald-300', great: 'text-emerald-300', close: 'text-sky-300', off: 'text-amber-300', way: 'text-rose-300', skip: 'text-zinc-400' }

export default function PinClient({ places, continent, level, canSave, canMaster = false }: {
  places: PinPlace[]
  continent: Continent
  level: PinLevel
  canSave: boolean
  /** The catalogue has pin cards (074): the round masters them. */
  canMaster?: boolean
}) {
  const deck = pinDeckId(continent, level)
  const home = homeHref({ continent, group: 'pin' })
  const { shapes, failed } = useWorldMap()
  const box = useMemo(() => pinViewBox(continent, places), [continent, places])
  const [idx, setIdx] = useState(0)
  const [pins, setPins] = useState<Pin[]>([])
  const shownAt = useRef(0)
  const answered = useRef(false)

  const done = idx >= places.length
  const place = places[idx]
  const shown = pins.length > idx ? pins[idx] : null
  const ready = !!shapes

  useEffect(() => { shownAt.current = performance.now(); answered.current = false }, [idx, ready])

  const answer = useCallback((tap: LatLon | null) => {
    if (!ready || done || answered.current) return
    answered.current = true
    const ms = Math.round(performance.now() - shownAt.current)
    const s = pinScore(continent, place, tap, ms)
    setPins(p => [...p, { tap, ms, km: s.km, points: s.points }])
  }, [ready, done, place, continent])

  // Show the answer for a moment, then the next place.
  useEffect(() => {
    if (pins.length !== idx + 1) return
    const t = setTimeout(() => setIdx(i => i + 1), SHOW_MS)
    return () => clearTimeout(t)
  }, [pins.length, idx])
  const next = () => { if (pins.length === idx + 1) setIdx(i => i + 1) }

  // The round's pin cards. Perfect = every pin Bullseye or Great and fast
  // enough to master, judged as the server judges it.
  const mastery: PinMastery | null = canMaster && canSave ? {
    cards: places.map(pl => ({ key: pinCardKey(pl.key), label: `${pl.kind === 'city' ? '🏙️' : '🏛️'} ${pl.name}`, points: KIND_SCORE.pin.points })),
    perfect: pins.length === places.length && pins.every(p => {
      const v = pinVerdict(continent, p.km)
      return fastEnough(v === 'bull' || v === 'great', p.ms, KIND_SCORE.pin.targetMs)
    }),
  } : null

  // Saved once, at the end. The server's score is the one that counts.
  const save = usePinSave(done, canSave, deck, 'record_geo_pin_round', () => ({
    p_deck: deck,
    p_pins: pins.map((p, i) => ({
      i: places[i].key,
      lat: p.tap ? Math.round(p.tap.lat * 1e4) / 1e4 : null,
      lon: p.tap ? Math.round(p.tap.lon * 1e4) / 1e4 : null,
      ms: p.ms,
    })),
  }), mastery)

  const total = pins.reduce((s, p) => s + p.points, 0)
  const acc = PIN_ACCURACY[continent]

  // ── Summary ────────────────────────────────────────────────────────────────
  if (done) {
    return (
      <PinEnd
        score={save.serverScore ?? total}
        continent={continent}
        level={level}
        mode="place"
        save={save}
        mastery={mastery}
        footnote={`On the ${CONTINENT_LABEL[continent]} map: 100 points within ${acc.bull} km, fewer the farther off, none from ${acc.zero.toLocaleString('en-US')} km. Up to +10 for speed.`}
        rows={places.map((pl, i) => {
          const p = pins[i]
          const v = pinVerdict(continent, p?.km ?? null)
          return (
            <div key={pl.key} className="flex items-center gap-3 text-sm min-w-0">
              <span className="w-0 flex-1 truncate text-white">{pl.kind === 'city' ? '🏙️' : '🏛️'} {pl.name} <span className="text-zinc-500">· {pl.country}</span></span>
              <span className={`shrink-0 text-xs ${VERDICT_TONE[v]}`}>{v === 'skip' ? 'skipped' : `${PIN_VERDICT_LABEL[v].split(' ')[0]} ${fmtKm(p!.km!)} km`}</span>
              <span className={`shrink-0 w-10 text-right font-bold tabular-nums ${p?.points ? 'text-emerald-300' : 'text-zinc-600'}`}>+{p?.points ?? 0}</span>
            </div>
          )
        })}
      />
    )
  }

  // ── A place ────────────────────────────────────────────────────────────────
  const target = { lat: place.lat, lon: place.lon }
  const v = shown ? pinVerdict(continent, shown.km) : null
  return (
    // Fixed to the viewport so the top bar can't slide under an iPhone's
    // status bar (see GeoClient), and so dragging the map never scrolls the page.
    <div className="fixed inset-0 overflow-hidden bg-[#0a0a0f] flex flex-col" style={{ paddingTop: 'env(safe-area-inset-top)', paddingBottom: 'env(safe-area-inset-bottom)' }}>
      <div className="border-b border-white/5 bg-[#0a0a0f]/90">
        <div className="max-w-3xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href={home} className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
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
            <h1 className="text-xl sm:text-2xl font-black text-white leading-tight line-clamp-2">📍 Find {place.name}</h1>
            <p className="text-xs text-zinc-400 truncate">{place.where}</p>
          </div>
          <span className="shrink-0 text-[11px] text-zinc-500">{CONTINENT_EMOJI[continent]} Level {level}</span>
        </div>

        <div className="relative flex-1 min-h-0 rounded-xl overflow-hidden ring-1 ring-white/10">
          <div className="absolute inset-0">
            {shapes ? (
              <WorldMap
                shapes={shapes}
                box={box}
                bounds={REGION_BOX[continent]}
                shaded
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
            {shown && shown.km !== null && v && (
              <span className={VERDICT_TONE[v]}>
                {PIN_VERDICT_LABEL[v]}! {fmtKm(shown.km)} km away · +{shown.points}
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
