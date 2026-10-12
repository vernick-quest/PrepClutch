// ── Pin the map ──────────────────────────────────────────────────────────────
//
// A darts game on the map, in two steps per continent:
//
//   1. Countries ("Tap Kenya"): tap anywhere inside the country. Right is
//      100 points, wrong or "show me" is 0.
//   2. Places ("Find Nairobi", "Find Rio de Janeiro"): tap where the place
//      is; the map draws the line to it and the distance scores.
//
// Places: distance scaled to the map. A pin within the continent's bullseye
// radius scores 100; from there points fall smoothly (a square curve, so a
// near miss keeps most of its points and a pin in the wrong country does not)
// to 0 at the continent's zero radius:
//
//   t = (zero - km) / (zero - bull),  points = floor(100 * t * t + 0.5)
//
// Both radii come from the size of the continent's map (REGION_BOX in
// lib/geo-map.ts): bull = 0.9% and zero = 11.5% of the box's corner-to-corner
// distance, rounded (PIN_ACCURACY; the unit check re-derives them). So
// Europe is tight (50 km / 650 km: Paris pinned on Brussels, 264 km, scores
// 41) and Asia is looser (120 km / 1,500 km). Until 073 every continent
// used the same rings (100 points within 100 km ... 10 within 1,500 km), so
// a pin 300 km off in Europe, usually the wrong country, still scored 70.
// 073 rescored the rounds saved under those rings (Robert's call).
//
// Every pin gets a verdict (Bullseye, Great, Close, Off, Way off: fractions
// of the zero radius), and every round gets stars, one star being a pass
// (PIN_STARS), like a Traveler IQ level's pass mark.
//
// Both modes add a small speed bonus on any scoring pin: +10 within 3 s, +5
// within 6 s. Ten pins a round, so 1,100 at most. Rounds are one continent
// at a time, so a phone shows the whole board at a usable size.
//
// Places are every country's asked capital (lib/geo-data.ts) and the famous
// non-capital cities (lib/geo-cities.ts), both from Wikidata, CC0. Each has
// a tier 1-3. A capital's tier is its country's population third on the
// continent (Natural Earth, public domain): 1 the most populous (the
// capitals kids have heard of), 3 the least (the microstates). A city's tier
// is its fame, assigned by hand. Level L asks places of tier L, up to half
// of them cities (PIN_CITY_SHARE), topped up from the nearest other tier
// when a continent is short, so every round mixes the two where it can.
// Africa has no tier-1 cities, so its level 1 is capitals only. Country
// rounds use the capitals' tiers: level L asks the countries of tier L.
//
// The places prompt always names the country: "Find Rio de Janeiro, a city
// in Brazil", as it always said "Find Nairobi, the capital of Kenya". Pin the
// map tests WHERE a place is; WHICH country a city is in is the city card's
// question, and naming it here turns a guess about Timbuktu into map
// reading (find Mali, then the Niger bend), which is the skill we want.
//
// Countries: the tap is matched to the shape drawn under it (shapeAt in
// lib/geo-map.ts). Two rules on top, both re-checked in SQL by
// record_geo_country_round (073), so KEEP THE CONSTANTS BELOW IN STEP WITH IT:
//   - Tiny countries (TINY_COUNTRIES, under TINY_COUNTRY_KM2 of land: too
//     small to tap on a phone without zooming) also count within
//     COUNTRY_RING_KM of their capital, unless the tap is inside ANOTHER tiny
//     country (Union Island is St Vincent's, not Grenada's).
//   - Disputed land (DISPUTED_AREAS): a tap there is right for every country
//     that is a party to the dispute, so no student is ever marked on a
//     contested line, and the feedback never names a side.
//
// Scores are worked out again in SQL (record_geo_pin_round,
// record_geo_country_round) from the taps, so a saved score always follows
// these rules. Pins never touch Explorer Points or card mastery.
//
// Client-safe: no country table. No '@/' imports.

import { haversineKm } from './geo-projection'
import type { Continent } from './geo-data'

export const PIN_ROUND = 10
export type PinLevel = 1 | 2 | 3
export const PIN_LEVELS: PinLevel[] = [1, 2, 3]
export const PIN_LEVEL_LABEL: Record<PinLevel, string> = { 1: 'Famous places', 2: 'Harder places', 3: 'Tiny & tricky' }
export const COUNTRY_LEVEL_LABEL: Record<PinLevel, string> = { 1: 'Big countries', 2: 'Harder countries', 3: 'Tiny & tricky' }
/** At most this many of a round's places are cities; the rest are capitals. */
export const PIN_CITY_SHARE = 5

export type PinMode = 'country' | 'place'

// ── Scoring ──────────────────────────────────────────────────────────────────

/** Per continent: full points within `bull` km, none from `zero` km.
 *  Mirrored in SQL (geo_pin_points, 073); keep the two in step. */
export const PIN_ACCURACY: Record<Continent, { bull: number; zero: number }> = {
  eu: { bull: 50,  zero: 650 },
  na: { bull: 80,  zero: 1000 },
  sa: { bull: 80,  zero: 1000 },
  oc: { bull: 90,  zero: 1200 },
  af: { bull: 110, zero: 1400 },
  as: { bull: 120, zero: 1500 },
}
/** How PIN_ACCURACY was derived from REGION_BOX (the unit check re-derives
 *  it: bull rounded to 10 km, zero to 50 km). */
export const PIN_BULL_SHARE = 0.009
export const PIN_ZERO_SHARE = 0.115

/** [up to this many ms, bonus points]. Mirrored in SQL (geo_pin_speed). */
export const PIN_SPEED: [number, number][] = [[3000, 10], [6000, 5]]
export const PIN_HIT = 100
export const MAX_PIN_SCORE = PIN_ROUND * (PIN_HIT + PIN_SPEED[0][1])

/** Stars for a round's score: one star is a pass. */
export const PIN_STARS = [500, 750, 900]
export const PIN_PASS = PIN_STARS[0]
export const pinStars = (score: number) => PIN_STARS.filter(s => score >= s).length

/** Distance points, 0-100. floor(x + 0.5) rather than Math.round so SQL
 *  does the same arithmetic in the same order (geo_pin_points, 073). */
export function distancePoints(continent: Continent, km: number): number {
  const { bull, zero } = PIN_ACCURACY[continent]
  if (km <= bull) return PIN_HIT
  if (km >= zero) return 0
  const t = (zero - km) / (zero - bull)
  return Math.floor(100 * t * t + 0.5)
}
export function speedBonus(ms: number | null): number {
  if (ms === null || ms < 0) return 0
  for (const [max, pts] of PIN_SPEED) if (ms <= max) return pts
  return 0
}
/** A place pin's score. No tap (gave up) scores nothing. */
export function pinScore(continent: Continent, target: { lat: number; lon: number }, tap: { lat: number; lon: number } | null, ms: number | null) {
  if (!tap) return { km: null, ring: 0, bonus: 0, points: 0 }
  const km = haversineKm(target, tap)
  const ring = distancePoints(continent, km)
  const bonus = ring > 0 ? speedBonus(ms) : 0
  return { km, ring, bonus, points: ring + bonus }
}

/** The rings migration 070 scored places with until 073: the same on every
 *  continent. Kept only so map-cards.mts still regenerates 070 as applied
 *  and pglite-map-test.mjs still checks 070 as written. Not used to score. */
export const PIN_RINGS_070: [number, number][] = [[100, 100], [300, 70], [600, 40], [1000, 20], [1500, 10]]
export function pinScore070(target: { lat: number; lon: number }, tap: { lat: number; lon: number } | null, ms: number | null) {
  if (!tap) return { km: null, points: 0 }
  const km = haversineKm(target, tap)
  const ring = PIN_RINGS_070.find(([max]) => km <= max)?.[1] ?? 0
  return { km, points: ring + (ring > 0 ? speedBonus(ms) : 0) }
}

export type PinVerdict ='bull' | 'great' | 'close' | 'off' | 'way' | 'skip'
/** Upper bounds as fractions of the continent's zero radius ('bull' is its
 *  own radius). For the words only: points come from distancePoints. */
export const PIN_VERDICT_SHARE = { great: 0.2, close: 0.4 }
export const PIN_VERDICT_LABEL: Record<PinVerdict, string> = {
  bull: '🎯 Bullseye', great: '🔥 Great', close: '👍 Close', off: '😬 Off', way: '🙈 Way off', skip: 'Skipped',
}
export function pinVerdict(continent: Continent, km: number | null): PinVerdict {
  if (km === null) return 'skip'
  const { bull, zero } = PIN_ACCURACY[continent]
  if (km <= bull) return 'bull'
  if (km <= zero * PIN_VERDICT_SHARE.great) return 'great'
  if (km <= zero * PIN_VERDICT_SHARE.close) return 'close'
  return km < zero ? 'off' : 'way'
}

// ── Places ───────────────────────────────────────────────────────────────────

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

/** Round-history decks: "eu:1" (places), "eu:1:country". Each has its own leaderboard. */
export const pinDeckId = (c: Continent, l: PinLevel) => `${c}:${l}`
export const countryDeckId = (c: Continent, l: PinLevel) => `${c}:${l}:country`
export function parsePinDeck(id: string): { continent: Continent; level: PinLevel; mode: PinMode } | null {
  const m = /^(af|as|eu|na|sa|oc):([123])(:country)?$/.exec(id)
  return m ? { continent: m[1] as Continent, level: Number(m[2]) as PinLevel, mode: m[3] ? 'country' : 'place' } : null
}
/** /geo/pin?c=eu&l=1 (places) or /geo/pin?c=eu&l=1&m=country. */
export const pinHref = (c: Continent, l: PinLevel, mode: PinMode = 'place') =>
  `/geo/pin?c=${c}&l=${l}${mode === 'country' ? '&m=country' : ''}`

// ── Countries ────────────────────────────────────────────────────────────────

export interface PinCountry {
  iso:       string
  name:      string
  continent: Continent
  tier:      PinLevel
  /** Its asked capital: the centre of a tiny country's ring. */
  lat:       number
  lon:       number
  tiny:      boolean
}

/** Land area under which a country counts as tiny (km², Natural Earth). */
export const TINY_COUNTRY_KM2 = 6000
/** A tap within this many km of a tiny country's capital counts.
 *  Mirrored in SQL (record_geo_country_round, 073); keep the two in step. */
export const COUNTRY_RING_KM = 75
/** Every UN member under TINY_COUNTRY_KM2 on the map (public/geo/world-50m.json).
 *  The unit check re-derives it from the map; geo_pin_tiny_isos() in 073
 *  must return exactly these (the PGlite test compares them). */
export const TINY_COUNTRIES = [
  'AD', 'AG', 'BB', 'BH', 'BN', 'CV', 'DM', 'FM', 'GD', 'KI', 'KM', 'KN', 'LC', 'LI', 'LU', 'MC',
  'MH', 'MT', 'MU', 'MV', 'NR', 'PW', 'SC', 'SG', 'SM', 'ST', 'TO', 'TT', 'TV', 'VC', 'WS',
]
const TINY = new Set(TINY_COUNTRIES)
export const isTinyCountry = (iso: string) => TINY.has(iso)

/**
 * Disputed land, as public/geo/world-50m.json draws it, and the countries
 * that are party to each dispute. A tap here is RIGHT for any party, so a
 * student is never marked on a contested line; for anyone else it is an
 * ordinary miss, named by the area ("That's Crimea"), never by a side.
 *
 * `drawn` is what a tap there reports: the ISO alpha-2 of the UN member
 * whose shape the map draws over it, or the alpha-3 of a neutral shape
 * (land the map gives no UN member). `ring` [lon, lat, lon, lat, ...] narrows
 * a UN member's shape to the area. It is a rough outline (tens of km); only
 * taps that are ALSO inside `drawn` count, so it may spill into neighbours
 * or the sea. Neutral shapes need no ring: all of the shape is the area.
 *
 * Checked against the map 2026-10-12 (supabase/geography/pin-country-check.mts
 * taps a point in each). Not listed: Abkhazia, South Ossetia (drawn as
 * Georgia), Transnistria (Moldova), Somaliland (Somalia), Northern Cyprus
 * (Cyprus): no other UN member claims them, so a tap there is already right
 * for the one country that does. Bir Tawil (drawn as Sudan) is claimed by
 * nobody. Hong Kong is not disputed, but the map draws it as its own shape,
 * so it is listed for China.
 *
 * Mirrored in SQL as the geo_disputed_areas table (073); the PGlite test
 * compares every row.
 */
export interface DisputedArea { key: string; name: string; drawn: string; claimants: string[]; ring?: number[] }
// Kashmir, the former princely state, roughly (Jammu to the Karakoram,
// Muzaffarabad to Aksai Chin). Shared by the shapes drawn over it.
const KASHMIR = [
  73.45, 33.0, 73.4, 34.0, 73.4, 34.45, 73.7, 34.6, 73.95, 34.85, 73.8, 35.3, 72.5, 35.9, 73.6, 36.9, 74.6, 37.1, 75.8, 36.9,
  76.6, 36.4, 77.8, 35.9, 78.5, 36.0, 80.2, 35.9, 80.4, 35.2, 79.6, 34.3, 78.8, 33.0, 79.5, 32.5,
  78.4, 32.4, 77.9, 32.8, 76.6, 33.1, 75.9, 32.6, 75.45, 32.3, 74.6, 32.7,
]
export const DISPUTED_AREAS: DisputedArea[] = [
  { key: 'crimea', name: 'Crimea', drawn: 'RU', claimants: ['RU', 'UA'],
    ring: [32.3, 45.2, 32.9, 45.95, 33.4, 46.25, 34.6, 46.2, 35.2, 45.7, 36.62, 45.6, 36.62, 44.9, 35.0, 44.3, 33.3, 44.3] },
  { key: 'donbas', name: 'the Donbas', drawn: 'UA', claimants: ['RU', 'UA'],
    ring: [36.55, 47.6, 36.6, 48.3, 37.0, 49.0, 37.6, 49.2, 38.0, 49.9, 38.9, 50.15, 39.9, 49.7, 40.2, 49.0, 39.8, 47.85, 38.25, 47.1, 37.3, 46.95, 36.8, 47.1] },
  { key: 'zaporizhzhia-kherson', name: 'Zaporizhzhia and Kherson', drawn: 'UA', claimants: ['RU', 'UA'],
    ring: [32.0, 46.4, 32.2, 47.2, 33.3, 47.6, 34.3, 47.85, 35.2, 48.1, 36.3, 47.9, 36.8, 47.1, 36.6, 46.7, 35.2, 46.2, 34.4, 46.0, 33.4, 46.05, 32.5, 46.1] },
  { key: 'kurils', name: 'the southern Kuril Islands', drawn: 'RU', claimants: ['JP', 'RU'],
    ring: [145.3, 43.2, 149.0, 43.2, 149.0, 45.7, 145.3, 45.7] },
  { key: 'golan', name: 'the Golan Heights', drawn: 'IL', claimants: ['IL', 'SY'],
    ring: [35.69, 33.33, 35.85, 33.33, 35.95, 32.9, 35.85, 32.7, 35.63, 32.7, 35.64, 32.85, 35.65, 33.0, 35.62, 33.1, 35.66, 33.25] },
  { key: 'palestine', name: 'Palestine', drawn: 'PSX', claimants: ['IL'] },
  { key: 'kashmir-in', name: 'Kashmir', drawn: 'IN', claimants: ['IN', 'PK'], ring: KASHMIR },
  { key: 'kashmir-pk', name: 'Kashmir', drawn: 'PK', claimants: ['IN', 'PK'], ring: KASHMIR },
  { key: 'kashmir-siachen', name: 'Kashmir', drawn: 'KAS', claimants: ['IN', 'PK'] },
  { key: 'aksai-chin', name: 'Aksai Chin', drawn: 'CN', claimants: ['CN', 'IN'], ring: KASHMIR },
  { key: 'arunachal', name: 'Arunachal Pradesh', drawn: 'IN', claimants: ['CN', 'IN'],
    ring: [91.55, 26.95, 92.6, 26.9, 93.8, 27.1, 94.6, 27.5, 95.4, 27.25, 96.2, 27.2, 97.5, 27.8, 97.5, 29.6, 91.55, 29.6] },
  { key: 'taiwan', name: 'Taiwan', drawn: 'TWN', claimants: ['CN'] },
  { key: 'hong-kong', name: 'Hong Kong', drawn: 'HKG', claimants: ['CN'] },
  { key: 'kosovo', name: 'Kosovo', drawn: 'KOS', claimants: ['RS'] },
  { key: 'western-sahara', name: 'Western Sahara', drawn: 'SAH', claimants: ['MA'] },
  { key: 'essequibo', name: 'Essequibo', drawn: 'GY', claimants: ['GY', 'VE'],
    ring: [-61.4, 1.1, -58.55, 1.1, -58.55, 8.6, -61.4, 8.6] },
  { key: 'abyei', name: 'Abyei', drawn: 'SD', claimants: ['SD', 'SS'],
    ring: [27.8, 9.3, 29.0, 9.3, 29.0, 10.1, 27.8, 10.1] },
  { key: 'halaib', name: 'the Halaib Triangle', drawn: 'EG', claimants: ['EG', 'SD'],
    ring: [33.95, 22.0, 36.9, 22.0, 35.62, 23.15] },
  { key: 'falklands', name: 'the Falkland Islands', drawn: 'FLK', claimants: ['AR', 'GB'] },
  { key: 'south-georgia', name: 'South Georgia', drawn: 'SGS', claimants: ['AR', 'GB'] },
  { key: 'chagos', name: 'the Chagos Islands', drawn: 'IOT', claimants: ['GB', 'MU'] },
]

/** Names for the other neutral shapes a tap can land on (not UN members),
 *  for "That's Greenland". Anything unnamed is "land outside these countries". */
export const NEUTRAL_NAMES: Record<string, string> = {
  GRL: 'Greenland', FRO: 'the Faroe Islands', PRI: 'Puerto Rico', NCL: 'New Caledonia', PYF: 'French Polynesia',
  IMN: 'the Isle of Man', JEY: 'Jersey', GGY: 'Guernsey', ALD: 'the Åland Islands', BMU: 'Bermuda',
  CYM: 'the Cayman Islands', TCA: 'the Turks and Caicos Islands', VGB: 'the British Virgin Islands',
  VIR: 'the US Virgin Islands', ABW: 'Aruba', CUW: 'Curaçao', SXM: 'Sint Maarten', MAF: 'Saint Martin',
  AIA: 'Anguilla', MSR: 'Montserrat', SPM: 'Saint Pierre and Miquelon', GUM: 'Guam',
  MNP: 'the Northern Mariana Islands', ASM: 'American Samoa', COK: 'the Cook Islands', NIU: 'Niue',
  WLF: 'Wallis and Futuna', SHN: 'Saint Helena', ATF: 'the French Southern Lands', HMD: 'Heard Island',
  IOA: 'Christmas Island',
}

/** Even-odd test on one flat [lon, lat, ...] ring (SQL: geo_in_ring). */
export function inFlatRing(ring: number[], lon: number, lat: number): boolean {
  let inside = false
  const n = ring.length
  for (let i = 0, j = n - 2; i < n; j = i, i += 2) {
    const xi = ring[i], yi = ring[i + 1], xj = ring[j], yj = ring[j + 1]
    if ((yi > lat) !== (yj > lat) && lon < ((xj - xi) * (lat - yi)) / (yj - yi) + xi) inside = !inside
  }
  return inside
}

/** The disputed area a tap is in. `code` is what the map has there: a UN
 *  member's alpha-2, a neutral shape's alpha-3, or null for the sea. */
export function disputedAreaAt(code: string | null, lat: number, lon: number): DisputedArea | null {
  if (!code) return null
  return DISPUTED_AREAS.find(a => a.drawn === code && (!a.ring || inFlatRing(a.ring, lon, lat))) ?? null
}

/** How a tap found the country: inside its shape, inside a tiny country's
 *  ring, or on land it shares a dispute over. */
export type CountryHow = 'inside' | 'ring' | 'shared'
/** Whether a tap finds the country (null: it does not). `tap` null = gave up. */
export function countryHit(target: { iso: string; lat: number; lon: number },
                           tap: { code: string | null; lat: number; lon: number } | null): CountryHow | null {
  if (!tap) return null
  if (tap.code === target.iso) return 'inside'
  if (TINY.has(target.iso) && !(tap.code && TINY.has(tap.code)) && haversineKm(target, tap) <= COUNTRY_RING_KM) return 'ring'
  const area = disputedAreaAt(tap.code, tap.lat, tap.lon)
  if (area && area.claimants.includes(target.iso)) return 'shared'
  return null
}
export const countryPoints = (hit: CountryHow | null, ms: number | null) => (hit ? PIN_HIT + speedBonus(ms) : 0)
