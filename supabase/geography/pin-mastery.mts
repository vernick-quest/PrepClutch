// Generates supabase/migrations/074_geo_pin_mastery.sql (Pin the map masters
// cards: find and pin cards, geo_pin_master, the round functions with
// mastery, the backfill, the badges) from lib/geo.ts, lib/geo-meta.ts,
// lib/geo-pin.ts, the applied 072 and 073 migrations and 074.template.sql.
// Run:
//
//   node supabase/geography/pin-mastery.mts               writes 074_geo_pin_mastery.sql
//   node supabase/geography/pin-mastery.mts --number 075  if 074 is taken
//
// Copies record_geo_pin_round and record_geo_country_round from the applied
// 073 file and award_geo_badges_for from the applied 072 file, changing only
// the lines listed below (each must be found exactly once, or it refuses),
// so nothing else in them can drift.
//
// Refuses to write a file that is not pure ASCII (emoji travel as base64), or
// whose string literals contain ; $ or -- (the Supabase SQL editor misparses
// those, see 060). Positive controls, each MUST be refused:
//   --plant-semicolon  a semicolon in a badge's lore (caught by q())
//   --plant-raw        a raw literal with a semicolon that skips q()
//                      (caught by the whole-file scan)
//   --plant-nonascii   an emoji outside base64 (caught by the ASCII check)

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const geo = await import('../../lib/geo.ts')
const pin = await import('../../lib/geo-pin.ts')

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const ni = process.argv.indexOf('--number')
const NUM = ni > 0 ? process.argv[ni + 1] : '074'
if (!/^\d{3}$/.test(NUM)) { console.error(`bad --number ${NUM}`); process.exit(1) }
const die = (msg: string): never => { console.error(`Refusing to write: ${msg}`); process.exit(1) }

const RISKY = /;|\$|--/
function q(s: string): string {
  if (RISKY.test(s) || /[^ -~]/.test(s)) die(`risky or non-ASCII literal: ${s.slice(0, 80)}`)
  return `'${s.replace(/'/g, "''")}'`
}
const num = (n: number) => (Number.isFinite(n) ? String(n) : die(`not a number: ${n}`))
const dbl = (n: number) => `${num(n)}::DOUBLE PRECISION`
const b64 = (s: string) => `convert_from(decode('${Buffer.from(s, 'utf8').toString('base64')}', 'base64'), 'UTF8')`
const readMig = (f: string) => fs.readFileSync(path.join(root, 'supabase/migrations', f), 'utf8')
/** `text` with `from` replaced by `to`, which must occur exactly once. */
function once(text: string, from: string | RegExp, to: string, what: string): string {
  const n = typeof from === 'string' ? text.split(from).length - 1 : (text.match(new RegExp(from.source, 'g')) ?? []).length
  if (n !== 1) die(`${what}: expected exactly one match, found ${n}`)
  return text.replace(from, () => to)
}

// ── Cards ────────────────────────────────────────────────────────────────────
if (geo.PIN_KINDS.join() !== 'find,pin') die(`expected PIN_KINDS find,pin, found ${geo.PIN_KINDS}`)
const finds = geo.geoCards(['find'])
const pins = geo.geoCards(['pin'])
const all = geo.allGeoCards()
const old = geo.geoCards(geo.KINDS_070)
if (old.length + finds.length + pins.length !== all.length) die('the catalogue is not 070 cards + find + pin cards')
const places = geo.pinPlaces()
if (pins.length !== places.length || pins.some((c, i) => c.key !== geo.pinCardKey(places[i].key))) die('pin cards are not one per Pin the map place')
const asked = geo.COUNTRIES.filter(c => !geo.COUNTRY_NOT_ASKED.has(c.iso))
if (finds.length !== asked.length) die('find cards are not one per asked country')
const sf = geo.KIND_SCORE.find, sp = geo.KIND_SCORE.pin
if (sf.points !== sp.points || sf.targetMs !== sp.targetMs) die('find and pin score differently: update the header comment')
const rows = [...finds, ...pins].map(c => `(${[q(c.key), q(c.iso), q(c.kind), q(c.continent), num(c.points), num(c.targetMs)].join(', ')})`)

// ── The round functions, from 073 ────────────────────────────────────────────
const m073 = readMig('073_geo_pin_countries.sql')
function roundFunction(name: string, mode: 'place' | 'country'): string {
  const start = m073.indexOf(`CREATE OR REPLACE FUNCTION ${name}(p_deck TEXT, p_pins JSONB)`)
  const grant = `GRANT EXECUTE ON FUNCTION ${name}(TEXT, JSONB) TO authenticated;`
  const end = m073.indexOf(grant, start)
  if (start < 0 || end < 0 || m073.indexOf(`CREATE OR REPLACE FUNCTION ${name}(`, start + 1) >= 0) die(`${name} not found exactly once in 073`)
  const fn = m073.slice(start, end + grant.length)
  return once(fn,
    '  INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES (uid, p_deck, total, scored);\n  RETURN total;',
    '  INSERT INTO geo_pin_rounds (user_id, deck, score, answers, mastery_at) VALUES (uid, p_deck, total, scored, now());\n' +
    `  PERFORM geo_pin_master(uid, cont, ${q(mode)}, scored, now());\n  RETURN total;`,
    `${name}: the line saving the round`)
}
const placeFn = roundFunction('record_geo_pin_round', 'place')
const countryFn = roundFunction('record_geo_country_round', 'country')

// ── Badges ───────────────────────────────────────────────────────────────────
// [key, label, emoji, description, rarity, lore, threshold]
type Badge = [string, string, string, string, string, string, number]
const B: Badge[] = [
  ['geo_find_25', 'Country Seeker', '🔎', '25 Find the country cards mastered.', 'Uncommon',
   'Twenty-five countries found on a map with no names on it. The Seeker squints, taps once and is right, and has started covering up the labels on every map it meets.', 25],
  ['geo_find_all', 'Pathfinder', '🔎👑', `All ${finds.length} Find the country cards mastered.`, 'Legendary',
   'Every country Find the country asks, each found with one quick tap, from Russia down to Tuvalu. The Pathfinder could find Liechtenstein in the dark and once did, to win a bet.', finds.length],
  ['geo_pin_25', 'Sharp Pin', '📍', '25 Pin the map places mastered.', 'Uncommon',
   'Twenty-five capitals and cities pinned so close the map barely noticed. The Sharp Pin keeps a tiny flag in its pocket for each one.', 25],
  ['geo_pin_all', 'Grand Cartographer', '📍👑', `All ${pins.length} Pin the map places mastered.`, 'Legendary',
   'Every capital and every famous city on the list, pinned Great or better without a single label to help. The Grand Cartographer draws maps for fun, and they are better than most.', pins.length],
]
if (process.argv.includes('--plant-semicolon')) B[0][5] += ' Planted; on purpose.'
const badgeRows = B.map(([k, l, e, d, r, lo, t]) =>
  `(${q(k)}, ${q(l)}, ${b64(e)}, ${q(d)}, ${q(r)}, ${q(l)}, 'Geography',\n ${q(lo)}, ${num(t)})`).join(',\n\n')

// Every-card and continent badges: World Turtle counts every card, the
// continent ladder every card of the continent but 'cont' (072).
const contCount = (ct: string) => all.filter(c => c.continent === ct && c.kind !== 'cont').length
const retotal = [
  `UPDATE achievement_definitions SET description = ${q(`Every one of the ${all.length} Geography cards mastered.`)}, threshold = ${num(all.length)} WHERE key = 'geo_mastered_all';`,
  ...geo.CONTINENTS.flatMap(ct => {
    const n = contCount(ct), half = Math.floor(n / 2), name = geo.CONTINENT_LABEL[ct]
    return [
      `UPDATE achievement_definitions SET description = ${q(`${half} ${name} cards mastered, half of them.`)}, threshold = ${num(half)} WHERE key = ${q(`geo_continent_${ct}_half`)};`,
      `UPDATE achievement_definitions SET description = ${q(`All ${n} ${name} cards mastered: capitals, flags, shapes, cities, countries found and places pinned.`)}, threshold = ${num(n)} WHERE key = ${q(`geo_continent_${ct}`)};`,
    ]
  }),
].join('\n')

// ── The award function, from 072 ─────────────────────────────────────────────
const m072 = readMig('072_geo_continent_ladders.sql')
const aStart = m072.indexOf('CREATE OR REPLACE FUNCTION award_geo_badges_for')
const aEnd = m072.indexOf('$$;', aStart) + 3
if (aStart < 0 || aEnd < 3) die('award_geo_badges_for not found in 072')
let award = m072.slice(aStart, aEnd)
const steps = geo.CONTINENTS.map(ct => `('${ct}', '25', 25), ('${ct}', 'half', ${num(Math.floor(contCount(ct) / 2))})`).join(',\n                   ')
award = once(award, /\(VALUES \('af', '25', 25\)[\s\S]*?\) AS r\(ct, step, t\)/, `(VALUES ${steps}) AS r(ct, step, t)`, '072 continent steps')
award = once(award, "('cities', ARRAY['city'], 25)) AS r(grp, kinds, t)",
  "('cities', ARRAY['city'], 25), ('find', ARRAY['find'], 25), ('pin', ARRAY['pin'], 25)) AS r(grp, kinds, t)", '072 card-type 25 rungs')
award = once(award, "('cities', ARRAY['city'])) AS r(grp, kinds)",
  "('cities', ARRAY['city']), ('find', ARRAY['find']), ('pin', ARRAY['pin'])) AS r(grp, kinds)", '072 card-type all rungs')

// Geography badges after 074: 069's, 070's and 072's rows, plus these.
const badgeCount = ['069_geography.sql', '070_geography_map.sql', '072_geo_continent_ladders.sql']
  .reduce((s, f) => s + (readMig(f).match(/^\('geo_[a-z0-9_]+', /gm) ?? []).length, 0) + B.length

// ── SQL ──────────────────────────────────────────────────────────────────────
const acc = geo.CONTINENTS.map(c => `(${q(c)}, ${dbl(pin.PIN_ACCURACY[c].bull)}, ${dbl(pin.PIN_ACCURACY[c].zero)})`).join(', ')
const pct = (x: number) => num(Math.round(x * 100))
const sumPts = (cs: { points: number }[]) => cs.reduce((s, c) => s + c.points, 0)

let sql = fs.readFileSync(path.join(here, '074.template.sql'), 'utf8')
  .replace('__ROWS__', rows.join(',\n'))
  .replace('__PLACE_FUNCTION__', () => placeFn)
  .replace('__COUNTRY_FUNCTION__', () => countryFn)
  .replace('__BADGE_ROWS__', badgeRows)
  .replace('__RETOTAL__', retotal)
  .replace('__AWARD_FUNCTION__', () => award)
  .replace('__ACCURACY__', acc)
  .replaceAll('__CONTINENTS__', geo.CONTINENTS.map(q).join(', '))
  .replaceAll('__GREAT_SHARE__', num(pin.PIN_VERDICT_SHARE.great))
  .replaceAll('__CLOSE_SHARE__', num(pin.PIN_VERDICT_SHARE.close))
  .replaceAll('__GREAT_PCT__', pct(pin.PIN_VERDICT_SHARE.great))
  .replaceAll('__CLOSE_PCT__', pct(pin.PIN_VERDICT_SHARE.close))
  .replaceAll('__NOT_ASKED__', [...geo.COUNTRY_NOT_ASKED].join(', '))
  .replaceAll('__NUM__', NUM)
  .replaceAll('__FIND__', num(finds.length))
  .replaceAll('__PIN__', num(pins.length))
  .replaceAll('__POINTS__', num(sf.points))
  .replaceAll('__SECS__', num(sf.targetMs / 1000))
  .replaceAll('__CARDS__', num(all.length))
  .replaceAll('__MAXPTS__', num(sumPts(all)))
  .replaceAll('__OLD_CARDS__', num(old.length))
  .replaceAll('__OLD_MAXPTS__', num(sumPts(old)))
  .replaceAll('__BADGES__', num(badgeCount))

if (/__[A-Z0-9_]+__/.test(sql)) die(`unfilled placeholder ${sql.match(/__[A-Z0-9_]+__/)![0]}`)
if (process.argv.includes('--plant-raw')) sql += "\nSELECT 'planted; raw';\n"
if (process.argv.includes('--plant-nonascii')) sql += '\n-- planted \u{1F30D}\n'

if (/[^\x09\x0a\x20-\x7e]/.test(sql)) {
  const line = sql.split('\n').findIndex(l => /[^\x09\x20-\x7e]/.test(l)) + 1
  die(`non-ASCII character on line ${line}`)
}
// Whole-file literal check, comment lines stripped first.
const code = sql.split('\n').filter(l => !l.trimStart().startsWith('--')).join('\n')
const risky = (code.match(/'(?:[^']|'')*'/g) ?? []).filter(s => RISKY.test(s))
if (risky.length) die(`risky literals ${risky.slice(0, 5).join(' ')}`)

const out = path.join(root, `supabase/migrations/${NUM}_geo_pin_mastery.sql`)
fs.writeFileSync(out, sql)
console.log(`wrote ${path.relative(root, out)}: ${finds.length} find + ${pins.length} pin cards (${sf.points} points, ${sf.targetMs} ms); ` +
  `catalogue ${old.length} -> ${all.length} cards, ${sumPts(old)} -> ${sumPts(all)} Explorer Points; ${B.length} badges (${badgeCount} Geography); ` +
  `continent halves ${geo.CONTINENTS.map(ct => `${ct} ${Math.floor(contCount(ct) / 2)}/${contCount(ct)}`).join(', ')}`)
