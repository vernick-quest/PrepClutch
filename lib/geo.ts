// ── Geography ────────────────────────────────────────────────────────────────
//
// A separate track inside PrepClutch with its own Explorer Points, badges and
// leaderboards. Nothing here touches questions, Clutch Points or Math Facts.
//
// Seven cards per country, 193 countries (lib/geo-data.ts), 1,351 cards:
//
//   kind   question                                   points  target
//   cont   Which continent is Egypt in?                  5     6s
//   flag   [flag] Which country's flag is this?         10     6s
//   capr   Canberra is the capital of which country?    10     7s
//   flagr  Which is the flag of Japan? (pick 1 of 4)    10     7s
//   cap    What is the capital of Australia?            15     7s
//   lang   Which is an official language of Peru?       15     8s
//   cur    Which currency does Japan use?               15     8s
//
// Every card is multiple choice with 4 options. The three wrong options are
// chosen from the same continent first, so they are plausible, and are fixed
// per card (seeded by its key) so a card is equally hard every time. Their
// ORDER is shuffled every round so the right answer's position means nothing.
//
// This file is the ONE definition of the card set. The migration loads it
// into geo_cards (supabase/geography/cards.mts generates the rows), and the
// database decides points and mastery from then on, exactly like Math Facts:
// a card is mastered the first time it is answered correctly within its
// target time, and stays mastered for good.
//
// No '@/' imports, so the Node generators can load this file.

import { COUNTRIES, LOOKALIKE_FLAGS } from './geo-data'
import type { Country, Continent } from './geo-data'

export type { Country, Continent }
export { COUNTRIES }

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

export type GeoKind = 'cap' | 'capr' | 'flag' | 'flagr' | 'cur' | 'lang' | 'cont'
export const KINDS: GeoKind[] = ['cap', 'capr', 'flag', 'flagr', 'cur', 'lang', 'cont']

/** The groups a student can pick to play. One group = one or two kinds. */
export type KindGroup = 'all' | 'capitals' | 'flags' | 'money' | 'languages' | 'continents'
export const GROUPS: KindGroup[] = ['all', 'capitals', 'flags', 'money', 'languages', 'continents']
export const GROUP_KINDS: Record<KindGroup, GeoKind[]> = {
  all: KINDS, capitals: ['cap', 'capr'], flags: ['flag', 'flagr'],
  money: ['cur'], languages: ['lang'], continents: ['cont'],
}
export const GROUP_LABEL: Record<KindGroup, string> = {
  all: 'Everything', capitals: 'Capitals', flags: 'Flags', money: 'Money',
  languages: 'Languages', continents: 'Continents',
}
export const GROUP_EMOJI: Record<KindGroup, string> = {
  all: '✨', capitals: '🏛️', flags: '🚩', money: '🪙', languages: '💬', continents: '🗺️',
}

export const KIND_SCORE: Record<GeoKind, { points: number; targetMs: number }> = {
  cont:  { points: 5,  targetMs: 6000 },
  flag:  { points: 10, targetMs: 6000 },
  capr:  { points: 10, targetMs: 7000 },
  flagr: { points: 10, targetMs: 7000 },
  cap:   { points: 15, targetMs: 7000 },
  lang:  { points: 15, targetMs: 8000 },
  cur:   { points: 15, targetMs: 8000 },
}
export const KIND_LABEL: Record<GeoKind, string> = {
  cap: 'Country → capital', capr: 'Capital → country', flag: 'Flag → country', flagr: 'Country → flag',
  cur: 'Currency', lang: 'Language', cont: 'Continent',
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
  answer:    string
  /** The right option first, then three wrong ones. Shuffle before showing. */
  options:   GeoOption[]
  /** The fact in one sentence, for feedback and round history. */
  full:      string
}

export const geoKey = (kind: GeoKind, iso: string) => `${kind}:${iso.toLowerCase()}`

// ── Deterministic choice ─────────────────────────────────────────────────────

function seed(s: string): () => number {
  let h = 2166136261
  for (let i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 16777619) }
  let a = h >>> 0
  return () => {                                   // mulberry32
    a = (a + 0x6D2B79F5) >>> 0
    let t = a
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

function shuffleWith<T>(xs: T[], rnd: () => number): T[] {
  const a = [...xs]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rnd() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

/**
 * Three wrong options for a card: same continent first, then anywhere.
 * `ok` decides whether a candidate may sit beside the options already
 * chosen (the right answer is chosen[0]).
 */
function pickWrong<T extends { continent: Continent }>(
  key: string, c: Country, pool: T[], ok: (cand: T, chosen: T[]) => boolean, right: T,
): T[] {
  const rnd = seed(key)
  const near = shuffleWith(pool.filter(p => p.continent === c.continent), rnd)
  const far  = shuffleWith(pool.filter(p => p.continent !== c.continent), rnd)
  const chosen: T[] = [right]
  for (const cand of [...near, ...far]) {
    if (chosen.length === 4) break
    if (ok(cand, chosen)) chosen.push(cand)
  }
  if (chosen.length < 4) throw new Error(`not enough wrong options for ${key}`)
  return chosen.slice(1)
}

const lc = (s: string) => s.toLowerCase()

/** Countries English puts "the" in front of mid-sentence. */
const THE = new Set(['BS', 'GM', 'US', 'GB', 'NL', 'PH', 'AE', 'CZ', 'DO', 'CF', 'CG', 'CD', 'MH', 'SB', 'MV', 'KM', 'SC'])
/** The country as it reads inside a sentence: "the Netherlands". */
export const inSentence = (c: Country) => (THE.has(c.iso) ? `the ${c.name}` : c.name)
/** ...and at the start of one: "The Netherlands". */
const atStart = (c: Country) => (THE.has(c.iso) ? `The ${c.name}` : c.name)
const byIso = new Map(COUNTRIES.map(c => [c.iso, c]))
const lookalike = (a: string, b: string) =>
  LOOKALIKE_FLAGS.some(([x, y]) => (x === a && y === b) || (x === b && y === a))

/** Currencies that sound like the same word are one family: a rial is not a
 *  fair wrong answer for a riyal country, nor a krona for a krone one. */
export function currencyFamily(short: string): string {
  const w = lc(short).normalize('NFD').replace(/[̀-ͯ]/g, '').split(' ').pop()!
  return ({ riyal: 'rial', krone: 'krona' } as Record<string, string>)[w] ?? w
}

function listOf(xs: string[]): string {
  return xs.length <= 1 ? xs.join('') : `${xs.slice(0, -1).join(', ')} and ${xs[xs.length - 1]}`
}

// ── Cards ────────────────────────────────────────────────────────────────────

function makeCard(c: Country, kind: GeoKind): GeoCard {
  const key = geoKey(kind, c.iso)
  const base = { key, iso: c.iso, kind, continent: c.continent, ...KIND_SCORE[kind] }
  const country = (x: Country): GeoOption => ({ value: x.iso, label: x.name })
  const of = inSentence(c)
  const others = COUNTRIES.filter(x => x.iso !== c.iso)
  const capital = c.capitals[0].name
  const alsoCaps = c.capitals.slice(1).map(x => x.name)
  const capFact = `The capital of ${of} is ${capital}${alsoCaps.length ? ` (${listOf(alsoCaps)} ${alsoCaps.length > 1 ? 'are capitals' : 'is a capital'} too)` : ''}.`

  switch (kind) {
    case 'cap': {
      const mine = new Set(c.capitals.map(x => lc(x.name)))
      const wrong = pickWrong(key, c, others, (x, ch) =>
        !mine.has(lc(x.capitals[0].name)) && !ch.some(y => lc(y.capitals[0].name) === lc(x.capitals[0].name)), c)
      return { ...base, prompt: `What is the capital of ${of}?`, answer: capital,
        options: [c, ...wrong].map(x => ({ value: x.capitals[0].name, label: x.capitals[0].name })), full: capFact }
    }
    case 'capr': {
      const wrong = pickWrong(key, c, others, () => true, c)
      return { ...base, prompt: `${capital} is the capital of which country?`, answer: c.iso,
        options: [c, ...wrong].map(country), full: capFact }
    }
    case 'flag': {
      const wrong = pickWrong(key, c, others, x => !lookalike(x.iso, c.iso), c)
      return { ...base, prompt: 'Which country does this flag belong to?', flag: c.iso, answer: c.iso,
        options: [c, ...wrong].map(country), full: `That is the flag of ${of}.` }
    }
    case 'flagr': {
      const wrong = pickWrong(key, c, others, x => !lookalike(x.iso, c.iso), c)
      return { ...base, prompt: `Which is the flag of ${of}?`, answer: c.iso,
        options: [c, ...wrong].map(x => ({ value: x.iso, label: x.name, flag: x.iso })),
        full: `That is the flag of ${of}.` }
    }
    case 'cur': {
      const mine = new Set(c.currencies.map(x => currencyFamily(x.short)))
      const pool = others.map(x => ({ continent: x.continent, cur: x.currencies[0] }))
      const right = { continent: c.continent, cur: c.currencies[0] }
      const wrong = pickWrong(key, c, pool, (x, ch) =>
        !mine.has(currencyFamily(x.cur.short)) &&
        !ch.some(y => currencyFamily(y.cur.short) === currencyFamily(x.cur.short)), right)
      const [first, ...rest] = c.currencies
      return { ...base, prompt: `Which currency does ${of} use?`, answer: first.code,
        options: [right, ...wrong].map(x => ({ value: x.cur.code, label: x.cur.short })),
        full: `${atStart(c)} uses the ${first.name} (${first.code})${rest.length ? `. The ${listOf(rest.map(r => r.name))} ${rest.length > 1 ? 'are' : 'is'} used there too` : ''}.` }
    }
    case 'lang': {
      const never = new Set([...c.languages, ...c.notWrong].map(lc))
      const pool = others.map(x => ({ continent: x.continent, lang: x.languages[0] }))
      const right = { continent: c.continent, lang: c.languages[0] }
      const wrong = pickWrong(key, c, pool, (x, ch) =>
        !never.has(lc(x.lang)) && !ch.some(y => lc(y.lang) === lc(x.lang)), right)
      const shown = c.languages.length > 4 ? [...c.languages.slice(0, 4), `${c.languages.length - 4} more`] : c.languages
      return { ...base, prompt: `Which is an official language of ${of}?`, answer: c.languages[0],
        options: [right, ...wrong].map(x => ({ value: x.lang, label: x.lang })),
        full: `${c.languages.length > 1 ? 'Official languages' : 'Official language'} of ${of}: ${listOf(shown)}.` }
    }
    case 'cont': {
      const also = c.alsoContinent ?? []
      const rnd = seed(key)
      const wrong = shuffleWith(CONTINENTS.filter(x => x !== c.continent && !also.includes(x)), rnd).slice(0, 3)
      return { ...base, prompt: `Which continent is ${of} in?`, answer: c.continent,
        options: [c.continent, ...wrong].map(x => ({ value: x, label: CONTINENT_LABEL[x] })),
        full: `${atStart(c)} is in ${CONTINENT_LABEL[c.continent]}${also.length ? ` (a part of it is in ${listOf(also.map(a => CONTINENT_LABEL[a]))})` : ''}.` }
    }
  }
}

let ALL: GeoCard[] | null = null
export function allGeoCards(): GeoCard[] {
  if (ALL) return ALL
  return (ALL = COUNTRIES.flatMap(c => KINDS.map(k => makeCard(c, k))))
}

const BY_KEY = new Map<string, GeoCard>()
export function parseGeoKey(key: string): GeoCard | null {
  if (!BY_KEY.size) for (const c of allGeoCards()) BY_KEY.set(c.key, c)
  return BY_KEY.get(key) ?? null
}

export const MAX_GEO_POINTS = COUNTRIES.length * KINDS.reduce((s, k) => s + KIND_SCORE[k].points, 0)
export const GEO_CARD_COUNT = COUNTRIES.length * KINDS.length

export function countryByIso(iso: string): Country | undefined { return byIso.get(iso.toUpperCase()) }

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

export function deckPool(o: DeckOptions): GeoCard[] {
  const kinds = GROUP_KINDS[o.group]
  return allGeoCards().filter(c => (o.continent === 'all' || c.continent === o.continent) && kinds.includes(c.kind))
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

function shuffle<T>(xs: T[]): T[] { return shuffleWith(xs, Math.random) }

// Unmastered first, exactly as Math Facts: missed cards soonest, then
// right-but-slow ones, then new ones, with a mastered card as review.
const QUOTA: [GeoCardState, number][] = [['struggling', 3], ['learning', 3], ['unseen', 9], ['fluent', 1]]

/** A round: up to SESSION_SIZE cards, each with its options in a fresh order. */
export function buildDeck(o: DeckOptions, history: Map<string, GeoHistoryRow>): GeoCard[] {
  const buckets = new Map<GeoCardState, GeoCard[]>()
  for (const c of shuffle(deckPool(o))) {
    const s = geoCardState(history.get(c.key))
    buckets.set(s, [...(buckets.get(s) ?? []), c])
  }
  const deck: GeoCard[] = []
  for (const [state, n] of QUOTA) {
    deck.push(...(buckets.get(state) ?? []).splice(0, Math.min(n, SESSION_SIZE - deck.length)))
  }
  for (const state of ['struggling', 'learning', 'unseen', 'fluent'] as GeoCardState[]) {
    deck.push(...(buckets.get(state) ?? []).splice(0, SESSION_SIZE - deck.length))
  }
  return shuffle(deck).map(c => ({ ...c, options: shuffle(c.options) }))
}
