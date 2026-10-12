// ── Pin the map ──────────────────────────────────────────────────────────────
//
// A darts game on the map: "Find Nairobi", the student taps where they think
// it is, the map draws the line to the real place, and the distance scores:
//
//   ≤ 100 km  100  bullseye
//   ≤ 300 km   70
//   ≤ 600 km   40
//   ≤ 1000 km  20
//   ≤ 1500 km  10
//   farther     0
//
// plus a small speed bonus on any scoring pin: +10 within 3 s, +5 within 6 s.
// Ten places a round, so 1,100 at most. Rounds are one continent at a time,
// so a phone shows the whole board at a usable size. Places are capitals
// only (the asked capital of lib/geo-data.ts, Wikidata, CC0).
//
// Levels sort a continent's countries by population (Natural Earth, public
// domain) into thirds: level 1 the most populous (the capitals kids have
// heard of), level 3 the least (the microstates).
//
// Scores are worked out again in SQL (record_geo_pin_round) from the
// tapped coordinates, so a saved score always follows these rules. Pins
// never touch Explorer Points or card mastery.
//
// Client-safe: no country table. No '@/' imports.

import { haversineKm } from './geo-projection'
import type { Continent } from './geo-data'

export const PIN_ROUND = 10
export type PinLevel = 1 | 2 | 3
export const PIN_LEVELS: PinLevel[] = [1, 2, 3]
export const PIN_LEVEL_LABEL: Record<PinLevel, string> = { 1: 'Famous capitals', 2: 'Harder capitals', 3: 'Tiny & tricky' }

/** [up to this many km, points]. Mirrored in SQL; keep the two in step. */
export const PIN_RINGS: [number, number][] = [[100, 100], [300, 70], [600, 40], [1000, 20], [1500, 10]]
export const PIN_SPEED: [number, number][] = [[3000, 10], [6000, 5]]
export const MAX_PIN_SCORE = PIN_ROUND * (PIN_RINGS[0][1] + PIN_SPEED[0][1])

export function ringPoints(km: number): number {
  for (const [max, pts] of PIN_RINGS) if (km <= max) return pts
  return 0
}
export function speedBonus(ms: number | null): number {
  if (ms === null || ms < 0) return 0
  for (const [max, pts] of PIN_SPEED) if (ms <= max) return pts
  return 0
}
/** A pin's score. No tap (time ran out) scores nothing. */
export function pinScore(target: { lat: number; lon: number }, tap: { lat: number; lon: number } | null, ms: number | null) {
  if (!tap) return { km: null, ring: 0, bonus: 0, points: 0 }
  const km = haversineKm(target, tap)
  const ring = ringPoints(km)
  const bonus = ring > 0 ? speedBonus(ms) : 0
  return { km, ring, bonus, points: ring + bonus }
}

export interface PinPlace {
  iso:     string
  country: string
  capital: string
  lat:     number
  lon:     number
}

export const pinDeckId = (c: Continent, l: PinLevel) => `${c}:${l}`
export function parsePinDeck(id: string): { continent: Continent; level: PinLevel } | null {
  const m = /^(af|as|eu|na|sa|oc):([123])$/.exec(id)
  return m ? { continent: m[1] as Continent, level: Number(m[2]) as PinLevel } : null
}
export const pinHref = (c: Continent, l: PinLevel) => `/geo/pin?c=${c}&l=${l}`
