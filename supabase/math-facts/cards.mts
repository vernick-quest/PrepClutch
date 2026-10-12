// Generates migration 064 from lib/math-facts.ts, the one definition of the
// card set. Run: node supabase/math-facts/cards.mts
//
// Refuses to write a file whose string literals contain ; $ or -- because the
// Supabase SQL editor misparses those (see migration 060).

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { allCards, MAX_FACT_POINTS } from '../../lib/math-facts.ts'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')

const lit = (v: string | number | undefined) =>
  v === undefined ? 'NULL' : typeof v === 'number' ? String(v) : `'${v.replace(/'/g, "''")}'`

const rows = allCards().map(c => {
  const t = c.topic === 'times'
  return `(${[lit(c.key), lit(c.topic), lit(t ? c.op : undefined), lit(t ? c.a : undefined),
             lit(t ? c.b : undefined), lit(t ? c.form : undefined), lit(c.points), lit(c.targetMs)].join(', ')})`
})

// 23 from 063 + 4 new in 064.
const BADGES = 27

const sql = fs.readFileSync(path.join(here, '064.template.sql'), 'utf8')
  .replace('__ROWS__', rows.join(',\n'))
  .replace('__MAXPTS__', String(MAX_FACT_POINTS))
  .replace('__BADGES__', String(BADGES))

// Literal check, comments stripped first so an apostrophe in a comment does
// not throw the scanner off.
const code = sql.split('\n').filter(l => !l.trimStart().startsWith('--')).join('\n')
const risky = (code.match(/'(?:[^']|'')*'/g) ?? []).filter(s => /;|\$|--/.test(s))
if (risky.length) {
  console.error('Refusing to write: risky literals', risky.slice(0, 5))
  process.exit(1)
}

const out = path.join(root, 'supabase/migrations/064_math_facts_topics.sql')
fs.writeFileSync(out, sql)
console.log(`wrote ${path.relative(root, out)}: ${rows.length} cards, max ${MAX_FACT_POINTS} points`)
