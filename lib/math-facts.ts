// ── Math Facts ───────────────────────────────────────────────────────────────
//
// A separate track inside PrepClutch with its own Fact Points and
// leaderboards. Nothing here touches `questions`, Clutch Points or mastery.
//
// Cards are GENERATED, not authored, in three topics:
//
//   times  × and ÷, factors 1-12, three forms each              864 cards
//          c  a × b = ?      l  ? × b = c      r  a × ? = c
//          c  c ÷ a = ?      l  ? ÷ a = b      r  c ÷ ? = b
//
//   equiv  equivalent fractions, a whole-number blank           304 cards
//          un ½ = ?/8   ud ½ = 4/?   (build up)
//          dn 4/8 = ?/2 dd 4/8 = 1/? (simplify)
//
//   fdp    fraction / decimal / percent benchmarks               90 cards
//          fp ¾ = ?%    fd ¾ = ? (decimal)   dp 0.75 = ?%
//          pd 75% = ? (decimal)   pf 75% = ?/4   df 0.75 = ?/4
//
// This file is the ONE definition of the card set. Migration 064 loads it into
// the math_cards table (supabase/math-facts/cards.mts generates the rows), and
// the database is what decides points and mastery from then on. The parity
// test fails if the two ever disagree.
//
// Points need FLUENCY, not just accuracy: a card is mastered the first time it
// is answered correctly within its target time, and stays mastered for good.
//
// No '@/' imports on purpose, so Node can run this file directly for the
// generator and the parity check.

export type Topic    = 'times' | 'equiv' | 'fdp'
export type FactOp   = 'mul' | 'div'
export type FactForm = 'c' | 'l' | 'r'

export const TOPICS: Topic[] = ['times', 'equiv', 'fdp']
export const TOPIC_LABEL: Record<Topic, string> = {
  times: 'Times tables',
  equiv: 'Equivalent fractions',
  fdp:   'Fractions, decimals & percents',
}
export const TOPIC_EMOJI: Record<Topic, string> = { times: '✖️', equiv: '½', fdp: '%' }

export const FACT_MIN = 1
export const FACT_MAX = 12
export const FACT_TABLES = Array.from({ length: FACT_MAX }, (_, i) => i + 1)

export const SESSION_SIZE = 20

/** A fraction on the card. Either half may be the blank (null). */
export interface Frac { n: number | null; d: number | null }
/** A percentage on the card; null is a blank followed by %. */
export interface Pct  { pct: number | string | null }
export type Tok = number | string | null | Frac | Pct

export interface FactCard {
  key:      string
  topic:    Topic
  /** Times-table cards only. */
  op?:      FactOp
  a?:       number
  b?:       number
  form:     string
  /** Equation tokens; exactly one blank (a null, or a null inside Frac/Pct). */
  parts:    Tok[]
  /** The answer as typed, e.g. "56", "0.375", "37.5". */
  answer:   string
  decimal:  boolean
  points:   number
  targetMs: number
  /** Short instruction above the card. */
  hint:     string
  /** The whole equation, answer filled in, for feedback. */
  full:     string
}

export function isFrac(t: Tok): t is Frac { return typeof t === 'object' && t !== null && 'n' in t }
export function isPct(t: Tok):  t is Pct  { return typeof t === 'object' && t !== null && 'pct' in t }

/** True when the typed answer equals the card's answer. "0.5", ".5" and
 *  "0.50" are the same number; nothing else is compared loosely. */
export function isCorrect(card: FactCard, given: string): boolean {
  if (given === '' || given === '.') return false
  return Number(given) === Number(card.answer)
}

// Whole-number answers and decimal answers are scored differently: a decimal
// takes longer to type and is a harder recall.
const OTHER_INT = { points: 15, targetMs: 5000 }
const OTHER_DEC = { points: 20, targetMs: 8000 }

// ── times ────────────────────────────────────────────────────────────────────

export function factKey(op: FactOp, a: number, b: number, form: FactForm): string {
  return `${op}:${a}:${b}:${form}`
}

export function makeCard(op: FactOp, a: number, b: number, form: FactForm): FactCard {
  const c = a * b
  // mul: a × b = c        div: c ÷ a = b
  const terms = op === 'mul' ? [a, b, c] : [c, a, b]
  const sym = op === 'mul' ? '×' : '÷'
  const blank = form === 'c' ? 2 : form === 'l' ? 0 : 1
  const parts: Tok[] = [terms[0], sym, terms[1], '=', terms[2]]
  parts[blank * 2] = null
  return {
    key: factKey(op, a, b, form), topic: 'times', op, a, b, form, parts,
    answer: String(terms[blank]), decimal: false,
    points: form === 'c' ? 10 : 15,
    targetMs: form === 'c' ? 3000 : 5000,
    hint: form === 'c' ? 'Solve it' : 'Find the missing number',
    full: `${terms[0]} ${sym} ${terms[1]} = ${terms[2]}`,
  }
}

// ── equiv ────────────────────────────────────────────────────────────────────

/** Every fraction in simplest form with denominator 2, 3, 4, 5, 6, 8 or 10. */
export const EQUIV_BASES: [number, number][] = [
  [1, 2],
  [1, 3], [2, 3],
  [1, 4], [3, 4],
  [1, 5], [2, 5], [3, 5], [4, 5],
  [1, 6], [5, 6],
  [1, 8], [3, 8], [5, 8], [7, 8],
  [1, 10], [3, 10], [7, 10], [9, 10],
]
export const EQUIV_MULTIPLIERS = [2, 3, 4, 5]
export type EquivForm = 'un' | 'ud' | 'dn' | 'dd'
export const EQUIV_FORMS: EquivForm[] = ['un', 'ud', 'dn', 'dd']

export function makeEquivCard(a: number, b: number, k: number, form: EquivForm): FactCard {
  const small: Frac = { n: a, d: b }
  const big: Frac   = { n: a * k, d: b * k }
  const up = form === 'un' || form === 'ud'
  const [left, right] = up ? [small, big] : [big, small]
  const blankNum = form === 'un' || form === 'dn'
  const answer = blankNum ? right.n! : right.d!
  const shown: Frac = blankNum ? { n: null, d: right.d } : { n: right.n, d: null }
  return {
    key: `eq:${a}:${b}:${k}:${form}`, topic: 'equiv', form,
    parts: [left, '=', shown],
    answer: String(answer), decimal: false, ...OTHER_INT,
    hint: up ? 'Make an equivalent fraction' : 'Simplify',
    full: `${left.n}/${left.d} = ${right.n}/${right.d}`,
  }
}

// ── fdp ──────────────────────────────────────────────────────────────────────

/** Benchmark fractions with an exact decimal: halves, quarters, fifths,
 *  eighths and tenths. Thirds are left out: 0.333… cannot be typed exactly. */
export const FDP_BASES: [number, number][] = [
  [1, 2],
  [1, 4], [3, 4],
  [1, 5], [2, 5], [3, 5], [4, 5],
  [1, 8], [3, 8], [5, 8], [7, 8],
  [1, 10], [3, 10], [7, 10], [9, 10],
]
export type FdpForm = 'fp' | 'fd' | 'dp' | 'pd' | 'pf' | 'df'
export const FDP_FORMS: FdpForm[] = ['fp', 'fd', 'dp', 'pd', 'pf', 'df']

/** Exact decimal and percent strings for a/b. Computed from integers:
 *  7/10 × 100 in floating point is 70.00000000000001. */
function fdpValues(a: number, b: number): { dec: string; pct: string } {
  const thousandths = (a * 1000) / b              // a whole number for every FDP_BASES entry
  return { dec: String(thousandths / 1000), pct: String((a * 100) / b) }
}

export function makeFdpCard(a: number, b: number, form: FdpForm): FactCard {
  const { dec, pct } = fdpValues(a, b)
  const f: Frac = { n: a, d: b }
  const card = (parts: Tok[], answer: string, hint: string, full: string) => ({ parts, answer, hint, full })
  const c = {
    fp: card([f, '=', { pct: null }],          pct,       'As a percent',  `${a}/${b} = ${pct}%`),
    fd: card([f, '=', null],                   dec,       'As a decimal',  `${a}/${b} = ${dec}`),
    dp: card([dec, '=', { pct: null }],        pct,       'As a percent',  `${dec} = ${pct}%`),
    pd: card([{ pct }, '=', null],             dec,       'As a decimal',  `${pct}% = ${dec}`),
    pf: card([{ pct }, '=', { n: null, d: b }], String(a), 'As a fraction', `${pct}% = ${a}/${b}`),
    df: card([dec, '=', { n: null, d: b }],    String(a), 'As a fraction', `${dec} = ${a}/${b}`),
  }[form]
  const decimal = c.answer.includes('.')
  return {
    key: `fdp:${a}:${b}:${form}`, topic: 'fdp', form, ...c, decimal,
    ...(decimal ? OTHER_DEC : OTHER_INT),
  }
}

// ── The whole set ────────────────────────────────────────────────────────────

export function parseFactKey(key: string): FactCard | null {
  let m = /^(mul|div):(\d+):(\d+):([clr])$/.exec(key)
  if (m) {
    const a = Number(m[2]), b = Number(m[3])
    if (a < FACT_MIN || a > FACT_MAX || b < FACT_MIN || b > FACT_MAX) return null
    return makeCard(m[1] as FactOp, a, b, m[4] as FactForm)
  }
  m = /^eq:(\d+):(\d+):(\d+):(un|ud|dn|dd)$/.exec(key)
  if (m) {
    const [a, b, k] = [Number(m[1]), Number(m[2]), Number(m[3])]
    if (!EQUIV_BASES.some(([x, y]) => x === a && y === b) || !EQUIV_MULTIPLIERS.includes(k)) return null
    return makeEquivCard(a, b, k, m[4] as EquivForm)
  }
  m = /^fdp:(\d+):(\d+):(fp|fd|dp|pd|pf|df)$/.exec(key)
  if (m) {
    const [a, b] = [Number(m[1]), Number(m[2])]
    if (!FDP_BASES.some(([x, y]) => x === a && y === b)) return null
    return makeFdpCard(a, b, m[3] as FdpForm)
  }
  return null
}

let ALL: FactCard[] | null = null
export function allCards(): FactCard[] {
  if (ALL) return ALL
  const out: FactCard[] = []
  for (const op of ['mul', 'div'] as FactOp[])
    for (const a of FACT_TABLES)
      for (const b of FACT_TABLES)
        for (const form of ['c', 'l', 'r'] as FactForm[])
          out.push(makeCard(op, a, b, form))
  for (const [a, b] of EQUIV_BASES)
    for (const k of EQUIV_MULTIPLIERS)
      for (const form of EQUIV_FORMS)
        out.push(makeEquivCard(a, b, k, form))
  for (const [a, b] of FDP_BASES)
    for (const form of FDP_FORMS)
      out.push(makeFdpCard(a, b, form))
  return (ALL = out)
}

export const MAX_FACT_POINTS = allCards().reduce((s, c) => s + c.points, 0)

export function topicCards(topic: Topic): FactCard[] {
  return allCards().filter(c => c.topic === topic)
}

// ── Session options ──────────────────────────────────────────────────────────

export type OpMode   = 'mul' | 'div' | 'mixed'
export type FormMode = 'both' | 'classic' | 'missing'
/** Narrows a non-times topic. equiv: up | down. fdp: pct | dec | frac. */
export type Focus    = 'all' | 'up' | 'down' | 'pct' | 'dec' | 'frac'

export interface DeckOptions {
  topic:  Topic
  op:     OpMode
  type:   FormMode
  tables: number[]
  focus:  Focus
}

const FOCUS_FORMS: Record<Exclude<Focus, 'all'>, string[]> = {
  up:   ['un', 'ud'],
  down: ['dn', 'dd'],
  pct:  ['fp', 'dp'],
  dec:  ['fd', 'pd'],
  frac: ['pf', 'df'],
}
export const TOPIC_FOCUSES: Record<Topic, Focus[]> = {
  times: ['all'],
  equiv: ['all', 'up', 'down'],
  fdp:   ['all', 'pct', 'dec', 'frac'],
}

export function parseDeckOptions(
  p: { topic?: string; op?: string; type?: string; t?: string; f?: string },
): DeckOptions {
  const topic: Topic = p.topic === 'equiv' || p.topic === 'fdp' ? p.topic : 'times'
  const op: OpMode = p.op === 'mul' || p.op === 'div' ? p.op : 'mixed'
  const type: FormMode = p.type === 'classic' || p.type === 'missing' ? p.type : 'both'
  const tables = [...new Set((p.t ?? '').split(',').map(Number))]
    .filter(n => Number.isInteger(n) && n >= FACT_MIN && n <= FACT_MAX)
    .sort((x, y) => x - y)
  const focus = (TOPIC_FOCUSES[topic] as string[]).includes(p.f ?? '') ? p.f as Focus : 'all'
  return { topic, op, type, tables: tables.length ? tables : FACT_TABLES, focus }
}

export function deckHref(o: DeckOptions): string {
  const q = new URLSearchParams({ topic: o.topic })
  if (o.topic === 'times') {
    q.set('op', o.op)
    q.set('type', o.type)
    if (o.tables.length && o.tables.length < FACT_MAX) q.set('t', o.tables.join(','))
  } else if (o.focus !== 'all') {
    q.set('f', o.focus)
  }
  return `/math/play?${q}`
}

export function deckPool(opts: DeckOptions): FactCard[] {
  if (opts.topic !== 'times') {
    const forms = opts.focus === 'all' ? null : FOCUS_FORMS[opts.focus]
    return topicCards(opts.topic).filter(c => !forms || forms.includes(c.form))
  }
  const tables = new Set(opts.tables)
  return topicCards('times').filter(c =>
    (opts.op === 'mixed' || c.op === opts.op) &&
    (opts.type === 'both' || (opts.type === 'classic') === (c.form === 'c')) &&
    (tables.has(c.a!) || tables.has(c.b!)))
}

// ── Per-student history ──────────────────────────────────────────────────────

export interface FactHistoryRow {
  fact_key:      string
  times_correct: number
  times_wrong:   number
  best_ms:       number | null
  fluent_at:     string | null
}

export type CardState = 'unseen' | 'struggling' | 'learning' | 'fluent'

export function cardState(h: FactHistoryRow | undefined): CardState {
  if (!h) return 'unseen'
  if (h.fluent_at) return 'fluent'
  return h.times_wrong > 0 ? 'struggling' : 'learning'
}

function shuffle<T>(xs: T[]): T[] {
  const a = [...xs]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

// Unmastered first. Missed cards come back soonest, then correct-but-slow ones
// (one more fast answer masters them), then new ones. A couple of mastered
// cards are mixed in as review, and fill the deck once nothing else is left.
const QUOTA: [CardState, number][] = [['struggling', 6], ['learning', 6], ['unseen', 18], ['fluent', 2]]

export function buildDeck(opts: DeckOptions, history: Map<string, FactHistoryRow>): FactCard[] {
  const buckets = new Map<CardState, FactCard[]>()
  for (const c of shuffle(deckPool(opts))) {
    const s = cardState(history.get(c.key))
    buckets.set(s, [...(buckets.get(s) ?? []), c])
  }

  const deck: FactCard[] = []
  for (const [state, n] of QUOTA) {
    deck.push(...(buckets.get(state) ?? []).splice(0, Math.min(n, SESSION_SIZE - deck.length)))
  }
  for (const state of ['struggling', 'learning', 'unseen', 'fluent'] as CardState[]) {
    deck.push(...(buckets.get(state) ?? []).splice(0, SESSION_SIZE - deck.length))
  }
  return shuffle(deck)
}
