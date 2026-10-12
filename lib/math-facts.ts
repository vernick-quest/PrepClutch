// ── Math Facts ───────────────────────────────────────────────────────────────
//
// A separate track inside PrepClutch with its own Fact Points and
// leaderboards. Nothing here touches `questions`, Clutch Points or mastery.
//
// Cards are GENERATED, not authored: every multiplication and division fact
// with factors 1-12, each in three forms.
//
//   mul a×b=c   c  a × b = ?      l  ? × b = c      r  a × ? = c
//   div c÷a=b   c  c ÷ a = ?      l  ? ÷ a = b      r  c ÷ ? = b
//
// 2 ops × 12 × 12 × 3 forms = 864 cards. Migration 062's math_fact_cards view
// generates the identical set in SQL and is the source of truth for points and
// targets: keep FORM_POINTS and FORM_TARGET_MS in step with it.
//
// Points need FLUENCY, not just accuracy: a card is mastered the first time it
// is answered correctly within its target time, and stays mastered for good.
//
// This file has no '@/' imports on purpose, so Node can run it directly for
// the SQL-parity check.

export type FactOp   = 'mul' | 'div'
export type FactForm = 'c' | 'l' | 'r'

export const FACT_MIN = 1
export const FACT_MAX = 12
export const FACT_TABLES = Array.from({ length: FACT_MAX }, (_, i) => i + 1)

export const FORM_POINTS: Record<FactForm, number>    = { c: 10, l: 15, r: 15 }
export const FORM_TARGET_MS: Record<FactForm, number> = { c: 3000, l: 5000, r: 5000 }

export const SESSION_SIZE = 20

export interface FactCard {
  key:    string
  op:     FactOp
  a:      number
  b:      number
  form:   FactForm
  /** Equation tokens; exactly one is null (the blank). */
  parts:  (number | string | null)[]
  answer: number
  /** The whole equation, answer filled in, for feedback. */
  full:   string
}

export function factKey(op: FactOp, a: number, b: number, form: FactForm): string {
  return `${op}:${a}:${b}:${form}`
}

export function makeCard(op: FactOp, a: number, b: number, form: FactForm): FactCard {
  const c = a * b
  // mul: a × b = c        div: c ÷ a = b
  const terms = op === 'mul' ? [a, b, c] : [c, a, b]
  const sym = op === 'mul' ? '×' : '÷'
  const blank = form === 'c' ? 2 : form === 'l' ? 0 : 1
  const parts: (number | string | null)[] = [terms[0], sym, terms[1], '=', terms[2]]
  parts[blank * 2] = null
  return {
    key: factKey(op, a, b, form), op, a, b, form, parts,
    answer: terms[blank],
    full: `${terms[0]} ${sym} ${terms[1]} = ${terms[2]}`,
  }
}

export function parseFactKey(key: string): FactCard | null {
  const m = /^(mul|div):(\d+):(\d+):([clr])$/.exec(key)
  if (!m) return null
  const a = Number(m[2]), b = Number(m[3])
  if (a < FACT_MIN || a > FACT_MAX || b < FACT_MIN || b > FACT_MAX) return null
  return makeCard(m[1] as FactOp, a, b, m[4] as FactForm)
}

export function allCards(): FactCard[] {
  const out: FactCard[] = []
  for (const op of ['mul', 'div'] as FactOp[])
    for (const a of FACT_TABLES)
      for (const b of FACT_TABLES)
        for (const form of ['c', 'l', 'r'] as FactForm[])
          out.push(makeCard(op, a, b, form))
  return out
}

export const MAX_FACT_POINTS = allCards().reduce((s, c) => s + FORM_POINTS[c.form], 0)

// ── Session options ──────────────────────────────────────────────────────────

export type OpMode   = 'mul' | 'div' | 'mixed'
export type FormMode = 'both' | 'classic' | 'missing'

export interface DeckOptions { op: OpMode; type: FormMode; tables: number[] }

export function parseDeckOptions(p: { op?: string; type?: string; t?: string }): DeckOptions {
  const op: OpMode = p.op === 'mul' || p.op === 'div' ? p.op : 'mixed'
  const type: FormMode = p.type === 'classic' || p.type === 'missing' ? p.type : 'both'
  const tables = [...new Set((p.t ?? '').split(',').map(Number))]
    .filter(n => Number.isInteger(n) && n >= FACT_MIN && n <= FACT_MAX)
    .sort((x, y) => x - y)
  return { op, type, tables: tables.length ? tables : FACT_TABLES }
}

export function deckHref(o: DeckOptions): string {
  const q = new URLSearchParams({ op: o.op, type: o.type })
  if (o.tables.length && o.tables.length < FACT_MAX) q.set('t', o.tables.join(','))
  return `/math/play?${q}`
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
  const tables = new Set(opts.tables)
  const pool = allCards().filter(c =>
    (opts.op === 'mixed' || c.op === opts.op) &&
    (opts.type === 'both' || (opts.type === 'classic') === (c.form === 'c')) &&
    (tables.has(c.a) || tables.has(c.b)))

  const buckets = new Map<CardState, FactCard[]>()
  for (const c of shuffle(pool)) {
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
