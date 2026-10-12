// ── Geography ────────────────────────────────────────────────────────────────
//
// A separate track inside PrepClutch with its own Explorer Points, badges and
// leaderboards. Nothing here touches questions, Clutch Points or Math Facts.
//
// Cards per country and kind, 193 countries (lib/geo-data.ts), plus one
// card per famous city (lib/geo-cities.ts):
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
//   city   Which country is Rio de Janeiro in?          10     7s
//
// Currency and language cards are built but not in the catalogue
// (EXPERT_KINDS). The other five kinds came with migration 069 (KINDS_069).
// Shape and city cards come with the map migration (070); until it is
// applied pages ask availableGeoKinds and leave them out.
//
// Every card is multiple choice with 4 options. The three wrong options are
// chosen from the same continent first (for shape cards: from the nearest
// countries, which are on the same map; for city cards: two of the country's
// nearest neighbours on its continent, then the rest of the continent), so
// they are plausible, and are fixed
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
import { CITIES } from './geo-cities'
import { NEIGHBOURS, POPULATION } from './geo-map-data'
import { PIN_ROUND, PIN_CITY_SHARE, pinPlaceKey } from './geo-pin'
import type { PinLevel, PinPlace } from './geo-pin'
import type { Country, Continent } from './geo-data'
import type { City } from './geo-cities'
import {
  CONTINENTS, CONTINENT_LABEL, KINDS, COUNTRY_KINDS, EXPERT_KINDS, GROUP_KINDS, KIND_SCORE, SESSION_SIZE, geoKey, geoCardState,
} from './geo-meta'
import type { GeoKind, GeoOption, GeoCard, DeckOptions, GeoHistoryRow, GeoCardState, MapCountry } from './geo-meta'

export * from './geo-meta'
export type { Country, City }
export { COUNTRIES, CITIES }

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
    case 'city':
      throw new Error('city cards are made per city (makeCityCard)')
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

/** "Which country is Rio de Janeiro in?" Two wrong answers from the
 *  country's six nearest neighbours on its own continent (the plausible
 *  mix-ups: Argentina for Rio, Oman for Dubai), one from anywhere else on
 *  the continent, never one the city's notWrong lists (a same-named place is
 *  really there), all fixed by the card's key. */
function makeCityCard(city: City): GeoCard {
  const key = geoKey('city', city.id)
  const c = byIso.get(city.iso)!
  const never = new Set([c.iso, ...(city.notWrong ?? [])])
  const rnd = seed(key)
  const sameCont = (iso: string) => byIso.get(iso)!.continent === c.continent && !never.has(iso)
  const near = shuffleWith(NEIGHBOURS[c.iso].slice(0, 6).filter(sameCont), rnd).slice(0, 2)
  const rest = shuffleWith(COUNTRIES.filter(x => sameCont(x.iso) && !near.includes(x.iso)), rnd)
  const wrong = [...near.map(i => byIso.get(i)!), ...rest].slice(0, 3)
  if (wrong.length < 3) throw new Error(`not enough wrong options for ${key}`)
  return {
    key, iso: c.iso, kind: 'city', continent: c.continent, ...KIND_SCORE.city,
    prompt: `Which country is ${city.name} in?`, answer: c.iso,
    options: [c, ...wrong].map(x => ({ value: x.iso, label: x.name })),
    full: `${city.name} is in ${inSentence(c)}.`,
  }
}

// Robert, 2026-10-12: "if places are disputed, just remove the question."
// Natural Earth draws borders as controlled on the ground, so for these
// countries the outline itself takes a side in a sovereignty dispute (Crimea
// and the Kurils with Russia, the Golan with Israel, Kashmir split along
// control lines, Somaliland inside Somalia, Kosovo cut from Serbia, Western
// Sahara cut from Morocco, Abkhazia and South Ossetia, Transnistria,
// Essequibo, Abyei, Halaib). Their 'Name that country' card is left out; their
// capital, flag and continent cards stay. Checked with a point-in-shape test
// on the map asset, see the 2026-10-12 commit.
export const SHAPE_DISPUTED = new Set([
  'IL', 'RU', 'UA', 'RS', 'MA', 'SO', 'CY', 'IN', 'PK', 'CN', 'JP',
  'GE', 'MD', 'GY', 'VE', 'SD', 'SS', 'EG',
])

let ALL: GeoCard[] | null = null
/** Every card of every kind, including any the catalogue may not have yet:
 *  the country cards in country order, then one card per city. */
export function allGeoCards(): GeoCard[] {
  if (ALL) return ALL
  return (ALL = [
    ...COUNTRIES.flatMap(c => COUNTRY_KINDS.filter(k => KINDS.includes(k))
      .filter(k => !(k === 'shape' && SHAPE_DISPUTED.has(c.iso)))
      .map(k => makeCard(c, k))),
    ...(KINDS.includes('city') ? CITIES.map(makeCityCard) : []),
  ])
}
/** The cards of the given kinds, e.g. the ones the catalogue has. */
export const geoCards = (kinds: GeoKind[]) => allGeoCards().filter(c => kinds.includes(c.kind))

let EXPERT: GeoCard[] | null = null
/** Currency and language cards. Built and validated so they are ready to
 *  switch on as an Expert mode, but not in the catalogue (allGeoCards). */
export function expertGeoCards(): GeoCard[] {
  return (EXPERT ??= COUNTRIES.flatMap(c => EXPERT_KINDS.map(k => makeCard(c, k))))
}

const BY_KEY = new Map<string, GeoCard>()
export function parseGeoKey(key: string): GeoCard | null {
  if (!BY_KEY.size) for (const c of allGeoCards()) BY_KEY.set(c.key, c)
  return BY_KEY.get(key) ?? null
}

export const maxGeoPoints = (kinds: GeoKind[] = KINDS) => geoCards(kinds).reduce((s, c) => s + c.points, 0)
export const geoCardCount = (kinds: GeoKind[] = KINDS) => geoCards(kinds).length

export function countryByIso(iso: string): Country | undefined { return byIso.get(iso.toUpperCase()) }

/** The map's tiles: just what a tile needs, so the page can pass it to the
 *  client without the rest of the data. */
export function mapCountries(): MapCountry[] {
  return COUNTRIES.map(c => ({
    iso: c.iso, name: c.name, continent: c.continent, capital: c.capitals[0].name,
    cities: CITIES.filter(x => x.iso === c.iso).map(x => ({ key: geoKey('city', x.id), name: x.name })),
  }))
}

// ── Rounds ───────────────────────────────────────────────────────────────────

/** The cards a deck draws from. `available` = the kinds the catalogue has. */
export function deckPool(o: DeckOptions, available: GeoKind[] = KINDS): GeoCard[] {
  // Inside one continent, "which continent is Kenya on?" answers itself, so a
  // continent round never asks it. Those cards come up in World rounds.
  const kinds = GROUP_KINDS[o.group].filter(k => available.includes(k) && !(k === 'cont' && o.continent !== 'all'))
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

/** Every place Pin the map can ask: each country's asked capital (tier =
 *  pinTiers) and every famous city (tier = its fame). Loaded into
 *  geo_pin_places, which record_geo_pin_round scores against. */
export function pinPlaces(): PinPlace[] {
  const tiers = pinTiers()
  return [
    ...COUNTRIES.map((c): PinPlace => ({
      key: pinPlaceKey('capital', c.iso), kind: 'capital', name: c.capitals[0].name, iso: c.iso, country: c.name, continent: c.continent,
      tier: tiers.get(c.iso)!, lat: c.capitals[0].lat, lon: c.capitals[0].lon, where: `the capital of ${inSentence(c)}`,
    })),
    ...CITIES.map((x): PinPlace => ({
      key: pinPlaceKey('city', x.id), kind: 'city', name: x.name, iso: x.iso, country: byIso.get(x.iso)!.name, continent: x.continent,
      tier: x.tier, lat: x.lat, lon: x.lon, where: `a city in ${inSentence(byIso.get(x.iso)!)}`,
    })),
  ]
}

/** Ten places for a round: the level's own tier first, then the nearest
 *  other tiers when a continent is short. From each tier, cities first up
 *  to PIN_CITY_SHARE for the whole round, then capitals, then any cities
 *  still needed, so a round mixes the two wherever the continent can. */
export function buildPinRound(continent: Continent, level: PinLevel, rnd: () => number = Math.random): PinPlace[] {
  const all = pinPlaces().filter(p => p.continent === continent)
  const order: PinLevel[] = level === 1 ? [1, 2, 3] : level === 2 ? [2, 1, 3] : [3, 2, 1]
  const picked: PinPlace[] = []
  const take = (pool: PinPlace[], n: number) => picked.push(...pool.filter(p => !picked.includes(p)).slice(0, Math.max(0, n)))
  for (const t of order) {
    const cities = shuffleWith(all.filter(p => p.tier === t && p.kind === 'city'), rnd)
    const caps = shuffleWith(all.filter(p => p.tier === t && p.kind === 'capital'), rnd)
    take(cities, Math.min(PIN_CITY_SHARE - picked.filter(p => p.kind === 'city').length, PIN_ROUND - picked.length))
    take(caps, PIN_ROUND - picked.length)
    take(cities, PIN_ROUND - picked.length)
  }
  return shuffleWith(picked, rnd)
}
