// ── Geography ────────────────────────────────────────────────────────────────
//
// A separate track inside PrepClutch with its own Explorer Points, badges and
// leaderboards. Nothing here touches questions, Clutch Points or Math Facts.
//
// Eight cards per country, 193 countries (lib/geo-data.ts), 1,544 cards:
//
//   kind   question                                   points  target
//   cont   Which continent is Egypt in?                  5     6s
//   flag   [flag] Which country's flag is this?         10     6s
//   capr   Canberra is the capital of which country?    10     7s
//   flagr  Which is the flag of Japan? (pick 1 of 4)    10     7s
//   cap    What is the capital of Australia?            15     7s
//   lang   Which is an official language of Peru?       15     8s
//   cur    Which currency does Japan use?               15     8s
//   shape  [map, one country lit] Which country is this? 15    8s
//
// The first seven kinds came with migration 069 (KINDS_069). Shape cards
// came with the map migration (supabase/geography/NNN.template.sql); until
// it is applied pages ask availableGeoKinds and leave them out.
//
// Every card is multiple choice with 4 options. The three wrong options are
// chosen from the same continent first (for shape cards: from the nearest
// countries, which are on the same map), so they are plausible, and are fixed
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
import { NEIGHBOURS, POPULATION } from './geo-map-data'
import { PIN_ROUND } from './geo-pin'
import type { PinLevel, PinPlace } from './geo-pin'
import type { Country, Continent } from './geo-data'
import {
  CONTINENTS, CONTINENT_LABEL, KINDS, GROUP_KINDS, KIND_SCORE, SESSION_SIZE, geoKey, geoCardState,
} from './geo-meta'
import type { GeoKind, GeoOption, GeoCard, DeckOptions, GeoHistoryRow, GeoCardState, MapCountry } from './geo-meta'

export * from './geo-meta'
export type { Country }
export { COUNTRIES }

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
    case 'shape': {
      // Three of the six nearest countries (lib/geo-map-data.ts, from the
      // map), fixed per card like every other card's wrong answers.
      const near = shuffleWith(NEIGHBOURS[c.iso].slice(0, 6), seed(key)).slice(0, 3).map(i => byIso.get(i)!)
      const wrong = near.length === 3 ? near : pickWrong(key, c, others, () => true, c)
      return { ...base, prompt: 'Which country is this?', map: c.iso, answer: c.iso,
        options: [c, ...wrong].map(country), full: `That is ${of}, in ${CONTINENT_LABEL[c.continent]}.` }
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
/** Every card of every kind, including any the catalogue may not have yet. */
export function allGeoCards(): GeoCard[] {
  if (ALL) return ALL
  return (ALL = COUNTRIES.flatMap(c => KINDS.map(k => makeCard(c, k))))
}
/** The cards of the given kinds, e.g. the ones the catalogue has. */
export const geoCards = (kinds: GeoKind[]) => allGeoCards().filter(c => kinds.includes(c.kind))

const BY_KEY = new Map<string, GeoCard>()
export function parseGeoKey(key: string): GeoCard | null {
  if (!BY_KEY.size) for (const c of allGeoCards()) BY_KEY.set(c.key, c)
  return BY_KEY.get(key) ?? null
}

export const maxGeoPoints = (kinds: GeoKind[] = KINDS) => COUNTRIES.length * kinds.reduce((s, k) => s + KIND_SCORE[k].points, 0)
export const geoCardCount = (kinds: GeoKind[] = KINDS) => COUNTRIES.length * kinds.length

export function countryByIso(iso: string): Country | undefined { return byIso.get(iso.toUpperCase()) }

/** The map's tiles: just what a tile needs, so the page can pass it to the
 *  client without the rest of the data. */
export function mapCountries(): MapCountry[] {
  return COUNTRIES.map(c => ({ iso: c.iso, name: c.name, continent: c.continent, capital: c.capitals[0].name }))
}

// ── Rounds ───────────────────────────────────────────────────────────────────

/** The cards a deck draws from. `available` = the kinds the catalogue has. */
export function deckPool(o: DeckOptions, available: GeoKind[] = KINDS): GeoCard[] {
  const kinds = GROUP_KINDS[o.group].filter(k => available.includes(k))
  return allGeoCards().filter(c => (o.continent === 'all' || c.continent === o.continent) && kinds.includes(c.kind))
}

function shuffle<T>(xs: T[]): T[] { return shuffleWith(xs, Math.random) }

// Unmastered first, exactly as Math Facts: missed cards soonest, then
// right-but-slow ones, then new ones, with a mastered card as review.
const QUOTA: [GeoCardState, number][] = [['struggling', 3], ['learning', 3], ['unseen', 9], ['fluent', 1]]

/** A round: up to SESSION_SIZE cards, each with its options in a fresh order. */
export function buildDeck(o: DeckOptions, history: Map<string, GeoHistoryRow>, available: GeoKind[] = KINDS): GeoCard[] {
  const buckets = new Map<GeoCardState, GeoCard[]>()
  for (const c of shuffle(deckPool(o, available))) {
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

// ── Pin the map ──────────────────────────────────────────────────────────────

/** Every country's Pin the map level on its continent: population thirds,
 *  most populous first (lib/geo-pin.ts). Loaded into geo_pin_places too. */
export function pinTiers(): Map<string, PinLevel> {
  const out = new Map<string, PinLevel>()
  for (const ct of CONTINENTS) {
    const cs = COUNTRIES.filter(c => c.continent === ct)
      .sort((a, b) => POPULATION[b.iso] - POPULATION[a.iso] || (a.iso < b.iso ? -1 : 1))
    cs.forEach((c, i) => out.set(c.iso, (1 + Math.floor((3 * i) / cs.length)) as PinLevel))
  }
  return out
}

/** Ten capitals for a round: from the level's own third, topped up from the
 *  nearest other third when a continent is small. */
export function buildPinRound(continent: Continent, level: PinLevel): PinPlace[] {
  const tiers = pinTiers()
  const order: PinLevel[] = level === 1 ? [1, 2, 3] : level === 2 ? [2, 1, 3] : [3, 2, 1]
  const picked: Country[] = []
  for (const t of order) {
    const pool = shuffle(COUNTRIES.filter(c => c.continent === continent && tiers.get(c.iso) === t))
    picked.push(...pool.slice(0, PIN_ROUND - picked.length))
  }
  return shuffle(picked).map(c => ({
    iso: c.iso, country: c.name, capital: c.capitals[0].name, lat: c.capitals[0].lat, lon: c.capitals[0].lon,
  }))
}
