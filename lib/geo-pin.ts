// ── Pin the map ──────────────────────────────────────────────────────────────
//
// A darts game on the map: "Find Nairobi" or "Find Rio de Janeiro", the
// student taps where they think it is, the map draws the line to the real
// place, and the distance scores:
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
// so a phone shows the whole board at a usable size.
//
// Places are every country's asked capital (lib/geo-data.ts) and the famous
// non-capital cities (lib/geo-cities.ts), both from Wikidata, CC0. Each has
// a tier 1-3. A capital's tier is its country's population third on the
// continent (Natural Earth, public domain): 1 the most populous (the
// capitals kids have heard of), 3 the least (the microstates). A city's tier
// is its fame, assigned by hand. Level L asks places of tier L, up to half
// of them cities (PIN_CITY_SHARE), topped up from the nearest other tier
// when a continent is short, so every round mixes the two where it can.
// Africa has no tier-1 cities, so its level 1 is capitals only.
//
// The prompt always names the country: "Find Rio de Janeiro, a city in
// Brazil", as it always said "Find Nairobi, the capital of Kenya". Pin the
// map tests WHERE a place is; WHICH country a city is in is the city card's
// question, and naming it here turns a guess about Timbuktu into map
// reading (find Mali, then the Niger bend), which is the skill we want.
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
export const PIN_LEVEL_LABEL: Record<PinLevel, string> = { 1: 'Famous places', 2: 'Harder places', 3: 'Tiny & tricky' }
/** At most this many of a round's places are cities; the rest are capitals. */
export const PIN_CITY_SHARE = 5

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

export type PinKind = 'capital' | 'city'

/** A place Pin the map can ask. `key` is what a round saves and what
 *  geo_pin_places is keyed by: "cap:ke" for Kenya's capital, "city:rio-de-janeiro". */
export interface PinPlace {
  key:       string
  kind:      PinKind
  name:      string
  iso:       string
  /** The country's plain name, for the round summary. */
  country:   string
  continent: Continent
  tier:      PinLevel
  lat:       number
  lon:       number
  /** Shown under the name: "the capital of Kenya", "a city in the United States". */
  where:     string
}

export const pinPlaceKey = (kind: PinKind, id: string) => `${kind === 'capital' ? 'cap' : 'city'}:${id.toLowerCase()}`

export const pinDeckId = (c: Continent, l: PinLevel) => `${c}:${l}`
export function parsePinDeck(id: string): { continent: Continent; level: PinLevel } | null {
  const m = /^(af|as|eu|na|sa|oc):([123])$/.exec(id)
  return m ? { continent: m[1] as Continent, level: Number(m[2]) as PinLevel } : null
}
export const pinHref = (c: Continent, l: PinLevel) => `/geo/pin?c=${c}&l=${l}`
