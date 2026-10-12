// Geography: the small, data-free part of lib/geo.ts. Client components
// import from here so the 193-country table is not shipped to the browser
// just to draw a tab bar. lib/geo.ts re-exports everything in this file.

import type { Continent } from './geo-data'

export type { Continent }

export const SESSION_SIZE = 10

export const CONTINENTS: Continent[] = ['af', 'as', 'eu', 'na', 'sa', 'oc']
export const CONTINENT_LABEL: Record<Continent, string> = {
  af: 'Africa', as: 'Asia', eu: 'Europe', na: 'North America', sa: 'South America', oc: 'Oceania',
}
export const CONTINENT_SHORT: Record<Continent, string> = {
  af: 'Africa', as: 'Asia', eu: 'Europe', na: 'N. America', sa: 'S. America', oc: 'Oceania',
}
export const CONTINENT_EMOJI: Record<Continent, string> = {
  af: '🌍', as: '🌏', eu: '🌍', na: '🌎', sa: '🌎', oc: '🌏',
}

export type GeoKind = 'cap' | 'capr' | 'flag' | 'flagr' | 'cur' | 'lang' | 'cont' | 'shape'
export const KINDS: GeoKind[] = ['cap', 'capr', 'flag', 'flagr', 'cur', 'lang', 'cont', 'shape']
/** The kinds migration 069 loaded. 'shape' (Name that country, on the map)
 *  arrives with the map migration; until it is applied the catalogue has no
 *  shape cards and pages offer only these (see availableGeoKinds). */
export const KINDS_069: GeoKind[] = ['cap', 'capr', 'flag', 'flagr', 'cur', 'lang', 'cont']

/** The groups a student can pick to play. One group = one or two kinds. */
export type KindGroup = 'all' | 'capitals' | 'flags' | 'money' | 'languages' | 'continents' | 'shapes'
export const GROUPS: KindGroup[] = ['all', 'capitals', 'flags', 'money', 'languages', 'continents', 'shapes']
export const GROUP_KINDS: Record<KindGroup, GeoKind[]> = {
  all: KINDS, capitals: ['cap', 'capr'], flags: ['flag', 'flagr'],
  money: ['cur'], languages: ['lang'], continents: ['cont'], shapes: ['shape'],
}
export const GROUP_LABEL: Record<KindGroup, string> = {
  all: 'Everything', capitals: 'Capitals', flags: 'Flags', money: 'Money',
  languages: 'Languages', continents: 'Continents', shapes: 'Shapes',
}
export const GROUP_EMOJI: Record<KindGroup, string> = {
  all: '✨', capitals: '🏛️', flags: '🚩', money: '🪙', languages: '💬', continents: '🗺️', shapes: '🧩',
}
/** A group's kinds that the catalogue has (empty = do not offer the group). */
export const groupKinds = (g: KindGroup, available: GeoKind[]) => GROUP_KINDS[g].filter(k => available.includes(k))

export const KIND_SCORE: Record<GeoKind, { points: number; targetMs: number }> = {
  cont:  { points: 5,  targetMs: 6000 },
  flag:  { points: 10, targetMs: 6000 },
  capr:  { points: 10, targetMs: 7000 },
  flagr: { points: 10, targetMs: 7000 },
  cap:   { points: 15, targetMs: 7000 },
  lang:  { points: 15, targetMs: 8000 },
  cur:   { points: 15, targetMs: 8000 },
  // Naming a highlighted country is a real map skill, worth a capital. The
  // extra second is for taking in the map before the four names.
  shape: { points: 15, targetMs: 8000 },
}
export const KIND_LABEL: Record<GeoKind, string> = {
  cap: 'Capital', capr: 'Capital → country', flag: 'Flag', flagr: 'Find the flag',
  cur: 'Currency', lang: 'Language', cont: 'Continent', shape: 'Name that country',
}

export interface GeoOption {
  /** What is compared: an ISO code, a currency code, a name. */
  value: string
  /** What the button says. Flag options show the flag instead. */
  label: string
  /** ISO code of a flag to draw on the button. */
  flag?: string
}

export interface GeoCard {
  key:       string
  iso:       string
  kind:      GeoKind
  continent: Continent
  points:    number
  targetMs:  number
  /** The question. */
  prompt:    string
  /** ISO code of a big flag shown with the question (flag cards). */
  flag?:     string
  /** ISO code of a country shown highlighted on the map (shape cards). */
  map?:      string
  answer:    string
  /** The right option first, then three wrong ones. Shuffle before showing. */
  options:   GeoOption[]
  /** The fact in one sentence, for feedback and round history. */
  full:      string
}

export const geoKey = (kind: GeoKind, iso: string) => `${kind}:${iso.toLowerCase()}`

/** Path of a bundled flag (public/flags, from flag-icons, MIT). */
export const flagSrc = (iso: string) => `/flags/${iso.toLowerCase()}.svg`

// ── Session options ──────────────────────────────────────────────────────────

export interface DeckOptions {
  continent: Continent | 'all'
  group:     KindGroup
}

export function parseDeckOptions(p: { c?: string; k?: string }): DeckOptions {
  const continent = (CONTINENTS as string[]).includes(p.c ?? '') ? p.c as Continent : 'all'
  const group = (GROUPS as string[]).includes(p.k ?? '') ? p.k as KindGroup : 'all'
  return { continent, group }
}

export function deckHref(o: DeckOptions): string {
  const q = new URLSearchParams()
  if (o.continent !== 'all') q.set('c', o.continent)
  if (o.group !== 'all') q.set('k', o.group)
  const s = q.toString()
  return s ? `/geo/play?${s}` : '/geo/play'
}

/** Round-history label, e.g. "af:capitals". */
export const deckId = (o: DeckOptions) => `${o.continent}:${o.group}`

export function deckLabel(id: string): string {
  const [c, g] = id.split(':')
  const where = (CONTINENTS as string[]).includes(c) ? `${CONTINENT_EMOJI[c as Continent]} ${CONTINENT_LABEL[c as Continent]}` : '🌐 World'
  const what = (GROUPS as string[]).includes(g) && g !== 'all' ? ` · ${GROUP_LABEL[g as KindGroup]}` : ''
  return where + what
}

// ── Per-student history ──────────────────────────────────────────────────────

export interface GeoHistoryRow {
  card_key:      string
  times_correct: number
  times_wrong:   number
  best_ms:       number | null
  fluent_at:     string | null
}

/** Same states, and so the same map colours, as Math Facts. */
export type GeoCardState = 'unseen' | 'struggling' | 'learning' | 'fluent'

export function geoCardState(h: GeoHistoryRow | undefined): GeoCardState {
  if (!h) return 'unseen'
  if (h.fluent_at) return 'fluent'
  return h.times_wrong > 0 ? 'struggling' : 'learning'
}

/** One map tile: a country, without the rest of its data. */
export interface MapCountry { iso: string; name: string; continent: Continent; capital: string }
