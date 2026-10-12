// ── Worked steps for every Math Facts card ───────────────────────────────────
//
// Learn mode, and the "how?" on a missed card, show a student HOW to get an
// answer, not just the answer. Because every card is generated, so are its
// steps: each one is built from the same numbers as the card, so a step can
// never disagree with the answer it leads to (the parity test checks that the
// last step of every card ends on that card's answer).
//
// The times-table steps teach the strategies teachers use: anchor on an easy
// fact (×10, ×5, ×2) and adjust, rather than memorising 144 unrelated facts.
//
import { parseFactKey, deckPool, cardState, SESSION_SIZE } from './math-facts'
import type { FactCard, DeckOptions, FactHistoryRow } from './math-facts'

// Easiest anchor first. A card uses whichever of its two factors comes first
// here, so 7 × 5 is taught through the 5s, not the 7s.
const ANCHOR_ORDER = [1, 10, 2, 5, 11, 9, 4, 3, 6, 8, 12, 7]
const rank = (n: number) => ANCHOR_ORDER.indexOf(n)

/** How to work out x × n with n the easier factor. Ends on the product. */
export function timesSteps(x: number, n: number): string[] {
  const p = x * n
  switch (n) {
    case 1:  return [`Anything times 1 stays the same.`, `${x} × 1 = ${p}`]
    case 10: return [`Times 10: write a zero on the end.`, `${x} × 10 = ${p}`]
    case 2:  return [`Times 2 is doubling.`, `${x} + ${x} = ${p}`]
    case 5:  return [`Times 5 is half of times 10.`, `${x} × 10 = ${x * 10}, and half of ${x * 10} is ${p}`]
    case 11:
      return x <= 9
        ? [`Times 11 with a single digit: write the digit twice.`, `${x} × 11 = ${p}`]
        : [`Times 11 is times 10, plus one more ${x}.`, `${x} × 10 = ${x * 10}, + ${x} = ${p}`]
    case 9:  return [`Times 9 is times 10, minus one ${x}.`, `${x} × 10 = ${x * 10}, − ${x} = ${p}`]
    case 4:  return [`Times 4 is double, then double again.`, `${x} → ${x * 2} → ${p}`]
    case 3:  return [`Times 3 is times 2, plus one more ${x}.`, `${x} × 2 = ${x * 2}, + ${x} = ${p}`]
    case 6:  return [`Times 6 is times 5, plus one more ${x}.`, `${x} × 5 = ${x * 5}, + ${x} = ${p}`]
    case 8:  return [`Times 8 is doubling three times.`, `${x} → ${x * 2} → ${x * 4} → ${p}`]
    case 12: return [`Times 12 is times 10, plus times 2.`, `${x * 10} + ${x * 2} = ${p}`]
    case 7:  return [`Times 7 is times 5, plus times 2.`, `${x * 5} + ${x * 2} = ${p}`]
    default: return [`${x} × ${n} = ${p}`]
  }
}

/** The product a × b, taught through whichever factor is the easier anchor. */
function productSteps(a: number, b: number): string[] {
  return rank(a) < rank(b) ? timesSteps(b, a) : timesSteps(a, b)
}

const UNIT: Record<number, { pct: string; dec: string }> = {
  2: { pct: '50', dec: '0.5' }, 4: { pct: '25', dec: '0.25' }, 5: { pct: '20', dec: '0.2' },
  8: { pct: '12.5', dec: '0.125' }, 10: { pct: '10', dec: '0.1' },
}

export function cardSteps(card: FactCard): string[] {
  const ans = card.answer

  if (card.topic === 'times') {
    const a = card.a!, b = card.b!, c = a * b
    if (card.op === 'mul') {
      if (card.form === 'c') return [...productSteps(a, b), `So ${a} × ${b} = ${ans}.`]
      const known = card.form === 'l' ? b : a
      return [
        `Find the number that times ${known} makes ${c}. That is ${c} ÷ ${known}.`,
        `Which ${known}s fact makes ${c}? It's ${a} × ${b}:`,
        ...productSteps(a, b),
        `So the missing number is ${ans}.`,
      ]
    }
    // div: c ÷ a = b
    if (card.form === 'c') return [
      `Division undoes times: what times ${a} makes ${c}?`,
      ...productSteps(a, b),
      `So ${c} ÷ ${a} = ${ans}.`,
    ]
    if (card.form === 'l') return [
      `The missing number is what gets divided. It is ${a} × ${b}.`,
      ...productSteps(a, b),
      `So ${ans} ÷ ${a} = ${b}.`,
    ]
    return [
      `What do you divide ${c} by to get ${b}? Ask: ${b} × ? = ${c}.`,
      `It's ${a} × ${b}:`,
      ...productSteps(a, b),
      `So ${c} ÷ ${ans} = ${b}.`,
    ]
  }

  if (card.topic === 'equiv') {
    const m = /^eq:(\d+):(\d+):(\d+):(\w+)$/.exec(card.key)!
    const [a, b, k] = [Number(m[1]), Number(m[2]), Number(m[3])]
    switch (m[4]) {
      case 'un': return [`Bottoms: ${b} → ${b * k}. That's × ${k}.`, `Do the same to the top: ${a} × ${k} = ${ans}.`, `So ${a}/${b} = ${ans}/${b * k}.`]
      case 'ud': return [`Tops: ${a} → ${a * k}. That's × ${k}.`, `Do the same to the bottom: ${b} × ${k} = ${ans}.`, `So ${a}/${b} = ${a * k}/${ans}.`]
      case 'dn': return [`Bottoms: ${b * k} → ${b}. That's ÷ ${k}.`, `Do the same to the top: ${a * k} ÷ ${k} = ${ans}.`, `So ${a * k}/${b * k} = ${ans}/${b}.`]
      default:   return [`Tops: ${a * k} → ${a}. That's ÷ ${k}.`, `Do the same to the bottom: ${b * k} ÷ ${k} = ${ans}.`, `So ${a * k}/${b * k} = ${a}/${ans}.`]
    }
  }

  // fdp
  const m = /^fdp:(\d+):(\d+):(\w+)$/.exec(card.key)!
  const [a, b] = [Number(m[1]), Number(m[2])]
  const u = UNIT[b]
  const pct = String((a * 100) / b), dec = String((a * 1000) / b / 1000)
  const lots = (unit: string, total: string) => a === 1
    ? `${a}/${b} is exactly ${unit}.`
    : `${a}/${b} is ${a} lots of that: ${a} × ${unit} = ${total}.`
  switch (m[3]) {
    case 'fp': return [`Learn the unit: 1/${b} = ${u.pct}%.`, lots(`${u.pct}%`, `${pct}%`), `So ${a}/${b} = ${ans}%.`]
    case 'fd': return [`Learn the unit: 1/${b} = ${u.dec}.`, lots(u.dec, dec), `So ${a}/${b} = ${ans}.`]
    case 'dp': return [`Percent means "out of 100", so multiply by 100.`, `Move the decimal point two places right: ${dec} → ${pct}.`, `So ${dec} = ${ans}%.`]
    case 'pd': return [`Percent means "out of 100", so divide by 100.`, `Move the decimal point two places left: ${pct} → ${dec}.`, `So ${pct}% = ${ans}.`]
    case 'pf': return [`Learn the unit: 1/${b} = ${u.pct}%.`, `How many ${u.pct}%s make ${pct}%? ${pct} ÷ ${u.pct} = ${ans}.`, `So ${pct}% = ${ans}/${b}.`]
    default:   return [`Learn the unit: 1/${b} = ${u.dec}.`, `How many ${u.dec}s make ${dec}? ${dec} ÷ ${u.dec} = ${ans}.`, `So ${dec} = ${ans}/${b}.`]
  }
}

export function stepsForKey(key: string): string[] {
  const c = parseFactKey(key)
  return c ? cardSteps(c) : []
}


// ── Learn decks ──────────────────────────────────────────────────────────────

// The order tables are taught in: friendly anchors first, the 7s last but
// one, and the 1s at the very end because there is nothing to learn there.
const LEARN_TABLES = [2, 5, 10, 11, 9, 4, 3, 6, 8, 12, 7, 1]

/** Ten cards to learn, in teaching order. Cards this student has missed come
 *  first, then ones they get right but slowly. New cards follow a lesson
 *  plan instead of the shuffle Play uses:
 *
 *   times   one table at a time (LEARN_TABLES), its plain cards before its
 *           missing-number cards, never the same fact twice in one deck
 *           (7 × 8 and 8 × 7 are one fact)
 *   ½ / %   one card of each kind before a second of any kind */
export function learnDeck(opts: DeckOptions, history: Map<string, FactHistoryRow>): FactCard[] {
  const pool = deckPool(opts)
  const st = (c: FactCard) => cardState(history.get(c.key))
  const deck: FactCard[] = [
    ...pool.filter(c => st(c) === 'struggling'),
    ...pool.filter(c => st(c) === 'learning'),
  ].slice(0, SESSION_SIZE)

  const fresh = pool.filter(c => st(c) === 'unseen')
  if (opts.topic === 'times') {
    const fact = (c: FactCard) => `${c.op}:${Math.min(c.a!, c.b!)}:${Math.max(c.a!, c.b!)}`
    const seen = new Set(deck.map(fact))
    const tableOf = (c: FactCard) => Math.min(...[c.a!, c.b!].map(n => LEARN_TABLES.indexOf(n)))
    const ordered = fresh.slice().sort((x, y) =>
      tableOf(x) - tableOf(y) ||
      Number(x.form !== 'c') - Number(y.form !== 'c') ||
      Math.max(x.a!, x.b!) - Math.max(y.a!, y.b!))
    for (const c of ordered) {
      if (deck.length >= SESSION_SIZE) break
      if (seen.has(fact(c))) continue
      seen.add(fact(c))
      deck.push(c)
    }
  } else {
    // Round-robin over card kinds, so the first deck shows every kind once.
    const kinds = [...new Set(fresh.map(c => c.form))]
    const queues = kinds.map(k => fresh.filter(c => c.form === k))
    for (let i = 0; deck.length < SESSION_SIZE && queues.some(q => q.length); i++) {
      const q = queues[i % queues.length]
      if (q.length) deck.push(q.shift()!)
    }
  }
  // Everything mastered? Review the mastered ones rather than show nothing.
  if (deck.length < SESSION_SIZE) deck.push(...pool.filter(c => st(c) === 'fluent').slice(0, SESSION_SIZE - deck.length))
  return deck
}
