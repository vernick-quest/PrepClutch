// Generates supabase/migrations/070_geography_map.sql (Geography phase 2:
// Name that country, famous cities, Pin the map) from lib/geo.ts (with
// lib/geo-cities.ts), lib/geo-pin.ts, the
// already generated 069 migration (for the award function, copied exactly)
// and 070.template.sql. Run:
//
//   node supabase/geography/map-cards.mts               writes 070_geography_map.sql
//   node supabase/geography/map-cards.mts --number 070  writes 070_geography_map.sql
//
// Refuses to write a file whose string literals contain ; $ or -- because
// the Supabase SQL editor misparses those (see migration 060). Positive
// controls: `--plant-semicolon` plants one in a badge's lore and MUST be
// refused at q(); `--plant-raw` appends a raw literal that skips q() and
// MUST be refused by the whole-file scan.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const geo = await import('../../lib/geo.ts')
const pin = await import('../../lib/geo-pin.ts')

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const ni = process.argv.indexOf('--number')
const NUM = ni > 0 ? process.argv[ni + 1] : '070'
if (!/^(NNN|\d{3})$/.test(NUM)) { console.error(`bad --number ${NUM}`); process.exit(1) }

const RISKY = /;|\$|--/
function q(s: string): string {
  if (RISKY.test(s)) {
    console.error(`Refusing to write: risky characters in literal: ${s.slice(0, 80)}`)
    process.exit(1)
  }
  return `'${s.replace(/'/g, "''")}'`
}

// ── Cards ────────────────────────────────────────────────────────────────────
const NEW_KINDS = geo.KINDS.filter(k => !geo.KINDS_069.includes(k))
if (NEW_KINDS.join() !== 'shape,city') { console.error(`expected exactly the shape and city kinds to be new, found ${NEW_KINDS}`); process.exit(1) }
const shapes = geo.geoCards(['shape'])
const cities = geo.geoCards(['city'])
const all = geo.allGeoCards()
const phase1 = geo.geoCards(geo.KINDS_069)
const fresh = geo.geoCards(NEW_KINDS)
if (phase1.length + fresh.length !== all.length) { console.error('the catalogue is not 069 cards + new cards'); process.exit(1) }
// Phase-1 badge count, read from the generated 069 so it can't drift.
const P1_BADGES = (fs.readFileSync(path.join(root, 'supabase/migrations/069_geography.sql'), 'utf8')
  .match(/^\('geo_[a-z0-9_]+', /gm) ?? []).length
const rows = fresh.map(c => `(${[q(c.key), q(c.iso), q(c.kind), q(c.continent), c.points, c.targetMs].join(', ')})`)

// ── Badges ───────────────────────────────────────────────────────────────────
// [key, label, emoji, description, rarity, creature, lore, threshold]
type Badge = [string, string, string, string, string, string, string, number]
const B: Badge[] = [
  ['geo_shapes_25', 'Shape Spotter', '🧩', '25 Name that country cards mastered.', 'Uncommon', 'Shape Spotter',
   'Twenty-five countries named from their outline alone. The Spotter sees a boot and says Italy, sees a long thin ribbon and says Chile, and is now looking suspiciously at clouds.', 25],
  ['geo_shapes_all', 'Map Master', '🗺️👑', `All ${shapes.length} Name that country cards mastered.`, 'Legendary', 'Map Master',
   'Every country on Earth, named from its shape on the map, from Russia down to Tuvalu. The Map Master could draw the world from memory and would only argue a little about the borders.', shapes.length],
  ['geo_cities_25', 'City Hopper', '🏙️', '25 city cards mastered.', 'Uncommon', 'City Hopper',
   'Twenty-five famous cities, each put in the right country. The Hopper has ridden a gondola in Venice, a tram in Melbourne and a cable car in San Francisco, all before lunch.', 25],
  ['geo_cities_all', 'Globetrotter', '🏙️👑', `All ${cities.length} city cards mastered.`, 'Epic', 'Globetrotter',
   'Every famous city on the list, from New York to Timbuktu, put in the right country. The Globetrotter has a suitcase covered in stickers and still wants to visit them all again.', cities.length],
]
if (process.argv.includes('--plant-semicolon')) B[0][6] += ' Planted; on purpose.'
const badgeRows = B.map(([k, l, e, d, r, c, lo, t]) =>
  `(${q(k)}, ${q(l)}, ${q(e)}, ${q(d)}, ${q(r)}, ${q(c)}, ${q('Geography')},\n ${q(lo)}, ${t})`).join(',\n\n')

// The every-card badges of 069, with the new totals (same wording as 069).
const retotal = [
  `UPDATE achievement_definitions SET description = ${q(`Every one of the ${all.length} Geography cards mastered.`)}, threshold = ${all.length} WHERE key = 'geo_mastered_all';`,
  ...geo.CONTINENTS.map(ct => {
    const n = all.filter(c => c.continent === ct).length
    return `UPDATE achievement_definitions SET description = ${q(`All ${n} ${geo.CONTINENT_LABEL[ct]} cards mastered.`)}, threshold = ${n} WHERE key = ${q(`geo_continent_${ct}`)};`
  }),
].join('\n')

// ── Award function: 069's, exactly, plus the shapes and cities rungs ─────────
const sql069 = fs.readFileSync(path.join(root, 'supabase/migrations/069_geography.sql'), 'utf8')
const start = sql069.indexOf('CREATE OR REPLACE FUNCTION award_geo_badges_for(')
const endMark = 'REVOKE ALL ON FUNCTION award_geo_badges_for(UUID, BOOLEAN) FROM PUBLIC, anon, authenticated;'
const end = sql069.indexOf(endMark)
if (start < 0 || end < 0) { console.error('award_geo_badges_for not found in 069'); process.exit(1) }
export const AWARD_069 = sql069.slice(start, end + endMark.length)
const steps069 = "('continents', ARRAY['cont'], 25)) AS r(grp, kinds, t)"
const all069 = "('continents', ARRAY['cont'])) AS r(grp, kinds)"
for (const s of [steps069, all069]) {
  if (AWARD_069.split(s).length !== 2) { console.error(`069 award function: expected "${s}" exactly once`); process.exit(1) }
}
const award = AWARD_069
  .replace(steps069, "('continents', ARRAY['cont'], 25), ('shapes', ARRAY['shape'], 25), ('cities', ARRAY['city'], 25)) AS r(grp, kinds, t)")
  .replace(all069, "('continents', ARRAY['cont']), ('shapes', ARRAY['shape']), ('cities', ARRAY['city'])) AS r(grp, kinds)")

// ── Pin places ───────────────────────────────────────────────────────────────
const places = geo.pinPlaces()
const pinRows = places.map(p =>
  `(${[q(p.key), q(p.kind), q(p.name), q(p.iso), q(p.continent), p.tier, p.lat, p.lon].join(', ')})`)
const ringCase = pin.PIN_RINGS.map(([km, p]) => `WHEN km <= ${km} THEN ${p}`).join(' ')
const speedCase = pin.PIN_SPEED.map(([ms, p]) => `WHEN r.ms BETWEEN 0 AND ${ms} THEN ${p}`).join(' ')

const p1points = phase1.reduce((s, c) => s + c.points, 0)
const maxPts = all.reduce((s, c) => s + c.points, 0)
const shapeScore = geo.KIND_SCORE.shape
const cityScore = geo.KIND_SCORE.city

let sql = fs.readFileSync(path.join(here, '070.template.sql'), 'utf8')
  .replace('__ROWS__', rows.join(',\n'))
  .replace('__BADGE_ROWS__', badgeRows)
  .replace('__RETOTAL__', retotal)
  .replace('__AWARD_FUNCTION__', () => award)
  .replace('__PIN_ROWS__', pinRows.join(',\n'))
  .replace('__CONTINENTS__', geo.CONTINENTS.map(q).join(', '))
  .replace('__RING_CASE__', ringCase)
  .replace('__SPEED_CASE__', speedCase)
  .replace('__RINGS_COMMENT__', pin.PIN_RINGS.map(([km, p]) => `${p} within ${km} km`).join(', '))
  .replace('__SPEED_COMMENT__', pin.PIN_SPEED.map(([ms, p]) => `${p} for ${ms / 1000} s`).join(' or '))
  .replaceAll('__NUM__', NUM)
  .replaceAll('__ROUND__', String(pin.PIN_ROUND))
  .replaceAll('__MAX_PIN__', String(pin.MAX_PIN_SCORE))
  .replaceAll('__SHAPES__', String(shapes.length))
  .replaceAll('__SHAPE_POINTS__', String(shapeScore.points))
  .replaceAll('__SHAPE_SECS__', String(shapeScore.targetMs / 1000))
  .replaceAll('__CITIES__', String(cities.length))
  .replaceAll('__CITY_POINTS__', String(cityScore.points))
  .replaceAll('__CITY_SECS__', String(cityScore.targetMs / 1000))
  .replaceAll('__NEW_KINDS__', NEW_KINDS.map(q).join(', '))
  .replaceAll('__PIN_CAPITALS__', String(places.filter(p => p.kind === 'capital').length))
  .replaceAll('__PIN_CITIES__', String(places.filter(p => p.kind === 'city').length))
  .replaceAll('__PINS__', String(pinRows.length))
  .replaceAll('__CARDS__', String(all.length))
  .replaceAll('__P1CARDS__', String(phase1.length))
  .replaceAll('__P1POINTS__', String(p1points))
  .replaceAll('__MAXPTS__', String(maxPts))
  .replaceAll('__BADGES__', String(P1_BADGES + B.length))

if (/__[A-Z0-9_]+__/.test(sql)) { console.error('unfilled placeholder', sql.match(/__[A-Z0-9_]+__/)![0]); process.exit(1) }
if (process.argv.includes('--plant-raw')) sql += "\nSELECT 'planted; raw';\n"

// Whole-file literal check, comments stripped first.
const code = sql.split('\n').filter(l => !l.trimStart().startsWith('--')).join('\n')
const risky = (code.match(/'(?:[^']|'')*'/g) ?? []).filter(s => RISKY.test(s))
if (risky.length) {
  console.error('Refusing to write: risky literals', risky.slice(0, 5))
  process.exit(1)
}

const out = path.join(root, `supabase/migrations/${NUM}_geography_map.sql`)
fs.writeFileSync(out, sql)
console.log(`wrote ${path.relative(root, out)}: ${shapes.length} shape cards (${shapeScore.points} points, ${shapeScore.targetMs} ms), ${cities.length} city cards (${cityScore.points} points, ${cityScore.targetMs} ms), ${B.length} badges, ${pinRows.length} pin places (${places.filter(p => p.kind === 'city').length} cities); catalogue ${all.length} cards, max ${maxPts} Explorer Points (phase 1 ${phase1.length} cards, ${p1points})`)
