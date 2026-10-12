// Generates supabase/migrations/073_geo_pin_countries.sql (Pin the map: find
// the country, places scored on each continent's scale, the rescore) from
// lib/geo-pin.ts and 073.template.sql. Run:
//
//   node supabase/geography/pin-countries.mts               writes 073_geo_pin_countries.sql
//   node supabase/geography/pin-countries.mts --number 074  if 073 is taken
//
// Everything the SQL must agree with the app on comes from lib/geo-pin.ts:
// PIN_ACCURACY, PIN_SPEED, TINY_COUNTRIES, COUNTRY_RING_KM, DISPUTED_AREAS.
// Refuses to write a file that is not pure ASCII, or whose string literals
// contain ; $ or -- (the Supabase SQL editor misparses those; see 060).
// Positive control: `--plant-raw` appends a literal with a semicolon and
// MUST be refused.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const geo = await import('../../lib/geo.ts')
const pin = await import('../../lib/geo-pin.ts')

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const ni = process.argv.indexOf('--number')
const NUM = ni > 0 ? process.argv[ni + 1] : '073'
if (!/^\d{3}$/.test(NUM)) { console.error(`bad --number ${NUM}`); process.exit(1) }

const RISKY = /;|\$|--/
function q(s: string): string {
  if (RISKY.test(s) || /[^ -~]/.test(s)) {
    console.error(`Refusing to write: risky or non-ASCII literal: ${s.slice(0, 80)}`)
    process.exit(1)
  }
  return `'${s.replace(/'/g, "''")}'`
}
const num = (n: number) => {
  if (!Number.isFinite(n)) { console.error(`not a number: ${n}`); process.exit(1) }
  return String(n)
}
const arr = (xs: string[]) => `ARRAY[${xs.map(q).join(', ')}]`
const dbl = (n: number) => `${num(n)}::DOUBLE PRECISION`

const acc = geo.CONTINENTS.map(c => `(${q(c)}, ${dbl(pin.PIN_ACCURACY[c].bull)}, ${dbl(pin.PIN_ACCURACY[c].zero)})`).join(', ')
const accComment = geo.CONTINENTS.map(c => `${c} ${pin.PIN_ACCURACY[c].bull}/${pin.PIN_ACCURACY[c].zero} km`).join(', ')
const speedCase = pin.PIN_SPEED.map(([ms, p]) => `WHEN p_ms BETWEEN 0 AND ${num(ms)} THEN ${num(p)}`).join(' ')
const areaRows = pin.DISPUTED_AREAS.map(a =>
  `(${q(a.key)}, ${q(a.name)}, ${q(a.drawn)}, ${arr(a.claimants)}::TEXT[], ${a.ring ? `ARRAY[${a.ring.map(num).join(', ')}]::DOUBLE PRECISION[]` : 'NULL'})`)
const capitals = geo.pinPlaces().filter(p => p.kind === 'capital').length

let sql = fs.readFileSync(path.join(here, '073.template.sql'), 'utf8')
  .replace('__ACCURACY__', acc)
  .replace('__ACC_COMMENT__', accComment)
  .replace('__SPEED_CASE__', speedCase)
  .replace('__TINY__', pin.TINY_COUNTRIES.map(q).join(', '))
  .replace('__AREA_ROWS__', areaRows.join(',\n'))
  .replace('__AREA_KEYS__', pin.DISPUTED_AREAS.map(a => q(a.key)).join(', '))
  .replaceAll('__CONTINENTS__', geo.CONTINENTS.map(q).join(', '))
  .replaceAll('__NUM__', NUM)
  .replaceAll('__ROUND__', num(pin.PIN_ROUND))
  .replaceAll('__RING_KM__', num(pin.COUNTRY_RING_KM))
  .replaceAll('__TINY_KM2__', num(pin.TINY_COUNTRY_KM2))
  .replaceAll('__TINY_COUNT__', num(pin.TINY_COUNTRIES.length))
  .replaceAll('__AREA_COUNT__', num(pin.DISPUTED_AREAS.length))
  .replaceAll('__CAPITALS__', num(capitals))

if (/__[A-Z0-9_]+__/.test(sql)) { console.error('unfilled placeholder', sql.match(/__[A-Z0-9_]+__/)![0]); process.exit(1) }
if (process.argv.includes('--plant-raw')) sql += "\nSELECT 'planted; raw';\n"

if (/[^\x09\x0a\x20-\x7e]/.test(sql)) {
  const line = sql.split('\n').findIndex(l => /[^\x09\x20-\x7e]/.test(l)) + 1
  console.error(`Refusing to write: non-ASCII character on line ${line}`)
  process.exit(1)
}
// Whole-file literal check, comment lines stripped first.
const code = sql.split('\n').filter(l => !l.trimStart().startsWith('--')).join('\n')
const risky = (code.match(/'(?:[^']|'')*'/g) ?? []).filter(s => RISKY.test(s))
if (risky.length) {
  console.error('Refusing to write: risky literals', risky.slice(0, 5))
  process.exit(1)
}

const out = path.join(root, `supabase/migrations/${NUM}_geo_pin_countries.sql`)
fs.writeFileSync(out, sql)
console.log(`wrote ${path.relative(root, out)}: ${pin.TINY_COUNTRIES.length} tiny countries, ${pin.DISPUTED_AREAS.length} disputed areas, accuracy ${accComment}`)
