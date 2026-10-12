'use client'

// ── Pin the map: find the country ────────────────────────────────────────────
//
// "Tap Kenya": tap anywhere inside it. Step 1 of Pin the map, before the
// places. The tap is matched to the shape under it on the client (shapeAt),
// then lib/geo-pin.ts countryHit decides: inside the country, within a tiny
// country's ring, or on land it shares a dispute over all count. Feedback
// lights the country green (with its ring if it is tiny) and, on a miss,
// outlines what was tapped in red and names it: "That's Tanzania". A tap on
// disputed land names the area ("That's Crimea"), never a side.
//
// Saved at the end through record_geo_country_round (073), which re-checks
// every tap's tiny-ring and disputed-land rules and scores the round itself.
// Until 073 is applied (canSave false) the round plays but is not saved.

import { useState, useEffect, useRef, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { REGION_BOX, pinViewBox, shapeAt, tapCode } from '@/lib/geo-map'
import {
  COUNTRY_RING_KM, NEUTRAL_NAMES, countryDeckId, countryHit, countryPoints, disputedAreaAt,
} from '@/lib/geo-pin'
import type { CountryHow, PinCountry, PinLevel } from '@/lib/geo-pin'
import { CONTINENT_LABEL, CONTINENT_EMOJI, homeHref } from '@/lib/geo-meta'
import type { Continent } from '@/lib/geo-meta'
import WorldMap, { useWorldMap } from '@/components/geo/WorldMap'
import type { LatLon, MapMark } from '@/components/geo/WorldMap'
import PinEnd, { usePinSave } from '@/components/geo/PinEnd'

interface Pin {
  tap: LatLon | null
  /** What the map has under the tap: alpha-2, a neutral alpha-3, or null (sea). */
  code: string | null
  /** The tapped shape's a3, to outline it. */
  a3: string | null
  ms: number
  hit: CountryHow | null
  points: number
}

const SHOW_MS = 3200

export default function CountryPinClient({ countries, names, continent, level, canSave }: {
  countries: PinCountry[]
  /** Every UN member's display name by ISO, to say what was tapped. */
  names: Record<string, string>
  continent: Continent
  level: PinLevel
  canSave: boolean
}) {
  const deck = countryDeckId(continent, level)
  const home = homeHref({ continent, group: 'all' })
  const { shapes, failed } = useWorldMap()
  const box = useMemo(() => pinViewBox(continent, countries), [continent, countries])
  const a3Of = useMemo(() => new Map((shapes ?? []).filter(s => s.iso).map(s => [s.iso!, s.a3])), [shapes])
  const [idx, setIdx] = useState(0)
  const [pins, setPins] = useState<Pin[]>([])
  const shownAt = useRef(0)
  const answered = useRef(false)

  const done = idx >= countries.length
  const country = countries[idx]
  const shown = pins.length > idx ? pins[idx] : null
  const ready = !!shapes

  useEffect(() => { shownAt.current = performance.now(); answered.current = false }, [idx, ready])

  const answer = useCallback((tap: LatLon | null) => {
    if (!shapes || done || answered.current) return
    answered.current = true
    const ms = Math.round(performance.now() - shownAt.current)
    const under = tap ? shapeAt(shapes, tap.lat, tap.lon) : null
    const code = tapCode(under)
    const hit = countryHit(country, tap ? { code, lat: tap.lat, lon: tap.lon } : null)
    setPins(p => [...p, { tap, code, a3: under?.a3 ?? null, ms, hit, points: countryPoints(hit, ms) }])
  }, [shapes, done, country])

  useEffect(() => {
    if (pins.length !== idx + 1) return
    const t = setTimeout(() => setIdx(i => i + 1), SHOW_MS)
    return () => clearTimeout(t)
  }, [pins.length, idx])
  const next = () => { if (pins.length === idx + 1) setIdx(i => i + 1) }

  const save = usePinSave(done, canSave, deck, 'record_geo_country_round', () => ({
    p_deck: deck,
    p_pins: pins.map((p, i) => ({
      iso: countries[i].iso,
      tap: p.code,
      lat: p.tap ? Math.round(p.tap.lat * 1e4) / 1e4 : null,
      lon: p.tap ? Math.round(p.tap.lon * 1e4) / 1e4 : null,
      ms: p.ms,
    })),
  }))

  /** What the student tapped, in words, without taking a side. */
  const tappedName = (p: Pin) => {
    if (!p.tap) return null
    const area = disputedAreaAt(p.code, p.tap.lat, p.tap.lon)
    if (area) return area.name
    if (!p.code) return null
    return names[p.code] ?? NEUTRAL_NAMES[p.code] ?? 'land outside these countries'
  }

  const total = pins.reduce((s, p) => s + p.points, 0)

  // ── Summary ────────────────────────────────────────────────────────────────
  if (done) {
    return (
      <PinEnd
        score={save.serverScore ?? total}
        continent={continent}
        level={level}
        mode="country"
        save={save}
        footnote={`100 points for each country found, up to +10 for speed. Tiny countries count within ${COUNTRY_RING_KM} km of their capital.`}
        rows={countries.map((c, i) => {
          const p = pins[i]
          const what = !p?.tap ? 'skipped' : p.hit ? '✓ found' : p.code ? `tapped ${tappedName(p)}` : 'tapped the sea'
          return (
            <div key={c.iso} className="flex items-center gap-3 text-sm min-w-0">
              <span className="w-0 flex-1 truncate text-white">🗺️ {c.name}</span>
              <span className={`shrink-0 max-w-[45%] truncate text-xs ${p?.hit ? 'text-emerald-300' : 'text-zinc-400'}`}>{what}</span>
              <span className={`shrink-0 w-10 text-right font-bold tabular-nums ${p?.points ? 'text-emerald-300' : 'text-zinc-600'}`}>+{p?.points ?? 0}</span>
            </div>
          )
        })}
      />
    )
  }

  // ── A country ──────────────────────────────────────────────────────────────
  const marks: MapMark[] = []
  if (shown) {
    const mine = a3Of.get(country.iso)
    // Outline what was tapped, unless it is part of a disputed area drawn
    // inside a bigger shape: outlining all of Russia for a tap in Crimea
    // would say more than "That's Crimea".
    const inArea = shown.tap && disputedAreaAt(shown.code, shown.tap.lat, shown.tap.lon)?.ring
    if (shown.a3 && !shown.hit && shown.a3 !== mine && !inArea) marks.push({ a3: shown.a3, tone: 'bad' })
    if (mine) marks.push({ a3: mine, tone: 'good' })
  }
  let feedback: React.ReactNode = null
  if (shown) {
    if (shown.hit) {
      feedback = <span className="text-emerald-300">✅ {shown.hit === 'ring' ? `Close enough: that's ${country.name}!` : `Yes, ${country.name}!`} +{shown.points}</span>
    } else if (!shown.tap) {
      feedback = <span className="text-zinc-300">Here it is, lit in green.</span>
    } else if (!shown.code) {
      feedback = <span className="text-rose-300">That&rsquo;s the sea. {country.name} is lit in green.</span>
    } else {
      feedback = <span className="text-rose-300">That&rsquo;s {tappedName(shown)}. {country.name} is lit in green.</span>
    }
  }

  return (
    <div className="fixed inset-0 overflow-hidden bg-[#0a0a0f] flex flex-col" style={{ paddingTop: 'env(safe-area-inset-top)', paddingBottom: 'env(safe-area-inset-bottom)' }}>
      <div className="border-b border-white/5 bg-[#0a0a0f]/90">
        <div className="max-w-3xl mx-auto px-4 py-3 flex items-center gap-4">
          <Link href={home} className="text-zinc-500 hover:text-white text-sm transition-colors shrink-0">← Exit</Link>
          <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full rounded-full bg-sky-400 transition-all duration-300" style={{ width: `${(idx / countries.length) * 100}%` }} />
          </div>
          <span className="text-sm text-zinc-400 shrink-0 tabular-nums">{idx + 1} / {countries.length}</span>
          <span className="text-sm font-bold text-sky-300 shrink-0 tabular-nums">{total}</span>
        </div>
      </div>

      <div className="flex-1 min-h-0 max-w-3xl mx-auto w-full px-3 pt-2 pb-3 flex flex-col gap-2">
        <div className="flex items-end gap-3 min-w-0 px-1">
          <div className="w-0 flex-1">
            <h1 className="text-xl sm:text-2xl font-black text-white leading-tight line-clamp-2">🗺️ Tap {country.name}</h1>
            <p className="text-xs text-zinc-400 truncate">
              {country.tiny ? 'It’s tiny: a tap close to it counts. Pinch or + to zoom.' : 'Tap anywhere inside it.'}
            </p>
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
                marks={marks}
                zone={shown && country.tiny ? { lat: country.lat, lon: country.lon, km: COUNTRY_RING_KM } : null}
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
          <div className="w-0 flex-1 text-sm font-bold leading-tight line-clamp-2">
            {shown ? feedback : <span className="text-zinc-400 font-normal">{country.tiny ? 'Tap on it or close to it.' : 'Tap inside the country.'}</span>}
          </div>
          {shown ? (
            <button onClick={next} className="shrink-0 bg-sky-500 hover:bg-sky-400 text-black font-bold px-4 py-2.5 rounded-xl transition-colors">
              Next ▶
            </button>
          ) : (
            <button onClick={() => answer(null)} disabled={!ready}
                    className="shrink-0 text-xs text-zinc-500 hover:text-zinc-300 px-2 py-2 disabled:opacity-0 transition-colors">
              I don&rsquo;t know
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
