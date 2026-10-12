// Checks lib/geo-cities.ts, the city cards lib/geo.ts builds from it, and the
// cities' Pin the map places. Run:
//
//   node supabase/geography/validate-cities.mts
//
// Like validate-data.mts and validate-map.mts, every check is then run on a
// deliberately broken copy that MUST fail (a positive control: a check that
// cannot fail proves nothing). Exits non-zero if the real data has a problem
// or a control passes.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import type { City } from '../../lib/geo-cities.ts'
import type { MapAsset, MapShape } from '../../lib/geo-map.ts'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const { COUNTRIES } = await import('../../lib/geo-data.ts')
const { CITIES } = await import('../../lib/geo-cities.ts')
const geo = await import('../../lib/geo.ts')
const pin = await import('../../lib/geo-pin.ts')
const gm = await import('../../lib/geo-map.ts')
const proj = await import('../../lib/geo-projection.ts')
const { inShape, nearestKm } = await import('./map-geom.mts')
const { normName } = await import('./normalize.mts')
const { slug } = { slug: (n: string) => normName(n).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') }

const shapes = gm.decodeAsset(JSON.parse(fs.readFileSync(path.join(root, 'public', gm.MAP_URL), 'utf8')) as MapAsset)
const shapeOf = new Map(shapes.filter(s => s.iso).map(s => [s.iso!, s] as [string, MapShape]))
const byIso = new Map(COUNTRIES.map(c => [c.iso, c]))

/** How far a city may sit outside its own country's 1:50m outline (coastal
 *  cities on a simplified coast; Hong Kong is drawn as its own neutral land
 *  beside China). */
const COAST_KM = 25
/** Non-member land Natural Earth draws apart from the UN member it belongs
 *  to. A city inside it counts as inside that member: Hong Kong is drawn as
 *  its own (neutral, never asked) shape beside China. */
const PART_OF: Record<string, string> = { HKG: 'CN', MAC: 'CN' }
/** Closer than this to a capital, or to another city, is the same place. */
const SAME_PLACE_KM = 10

let fails = 0
const report = (name: string, problems: string[]) => {
  console.log(`${problems.length ? 'FAIL' : 'PASS'}  ${name}${problems.length ? '\n        ' + problems.slice(0, 10).join('\n        ') : ''}`)
  if (problems.length) fails++
}
// A control counts only problems the real data does not already have.
const baseline = new Set<string>()
const control = (name: string, all: string[]) => {
  const problems = all.filter(x => !baseline.has(x))
  console.log(`${problems.length ? 'PASS' : 'FAIL'}  control: ${name} is caught${problems.length ? ` (${problems[0].slice(0, 100)})` : ' — NOT CAUGHT'}`)
  if (!problems.length) fails++
}

// ── 1. Each city is well formed and joins to a UN member ─────────────────────
function checkJoin(cs: City[]): string[] {
  const p: string[] = []
  const dup = (xs: string[], what: string) => {
    const seen = new Set<string>()
    for (const x of xs) { if (seen.has(x)) p.push(`duplicate ${what}: ${x}`); seen.add(x) }
  }
  dup(cs.map(c => c.id), 'id')
  dup(cs.map(c => normName(c.name)), 'name')
  dup(cs.map(c => c.wikidata), 'Wikidata item')
  const countryNames = new Set(COUNTRIES.map(c => normName(c.name)))
  for (const c of cs) {
    const k = byIso.get(c.iso)
    if (!k) { p.push(`${c.name}: ${c.iso} is not one of the 193 UN members`); continue }
    if (c.continent !== k.continent) p.push(`${c.name}: continent ${c.continent}, but ${k.name} is ${k.continent}`)
    if (![1, 2, 3].includes(c.tier)) p.push(`${c.name}: tier ${c.tier}`)
    if (c.id !== slug(c.name)) p.push(`${c.name}: id ${c.id} is not its slug`)
    if (!/^[a-z0-9-]+$/.test(c.id)) p.push(`${c.name}: id ${c.id} is not URL-safe`)
    if (!c.name.trim()) p.push(`${c.id}: empty name`)
    if (countryNames.has(normName(c.name))) p.push(`${c.name}: is also a country's name`)
    if (!(Number.isFinite(c.lat) && Math.abs(c.lat) <= 90)) p.push(`${c.name}: latitude ${c.lat}`)
    if (!(Number.isFinite(c.lon) && Math.abs(c.lon) <= 180)) p.push(`${c.name}: longitude ${c.lon}`)
    if (Math.round(c.lat * 100) / 100 !== c.lat || Math.round(c.lon * 100) / 100 !== c.lon) p.push(`${c.name}: coordinates not at 2 decimal places`)
    if (!/^Q\d+$/.test(c.wikidata)) p.push(`${c.name}: Wikidata item ${c.wikidata}`)
    if (!(Number.isInteger(c.population) && c.population > 0)) p.push(`${c.name}: population ${c.population}`)
    for (const x of c.notWrong ?? []) if (!byIso.has(x) || x === c.iso) p.push(`${c.name}: notWrong ${x}`)
  }
  return p
}
report(`${CITIES.length} cities: unique ids, names and items, each joined to a UN member and its continent, tier 1-3`, checkJoin(CITIES))

// ── 2. Not a capital ─────────────────────────────────────────────────────────
function checkNotCapital(cs: City[]): string[] {
  const p: string[] = []
  const caps = COUNTRIES.flatMap(k => k.capitals.map(cap => ({ ...cap, of: k.name })))
  for (const c of cs) {
    for (const cap of caps) {
      if (normName(cap.name) === normName(c.name)) p.push(`${c.name}: is a capital of ${cap.of}`)
      else if (proj.haversineKm(cap, c) < SAME_PLACE_KM) p.push(`${c.name}: ${proj.haversineKm(cap, c).toFixed(1)} km from ${cap.name}, a capital of ${cap.of}`)
    }
  }
  return p
}
report(`no city is any capital of any country (by name, or within ${SAME_PLACE_KM} km of one)`, checkNotCapital(CITIES))

// ── 3. Inside its own country on the map ─────────────────────────────────────
let worst = { km: 0, name: '' }
function checkInside(cs: City[]): string[] {
  const p: string[] = []
  for (const c of cs) {
    const own = shapeOf.get(c.iso)
    if (!own) { p.push(`${c.name}: no shape for ${c.iso}`); continue }
    const part = shapes.find(s => !s.iso && PART_OF[s.a3] === c.iso && inShape(s, c.lon, c.lat))
    const km = part ? 0 : nearestKm(own, c.lon, c.lat)
    if (km > worst.km && cs === CITIES) worst = { km, name: c.name }
    if (km > COAST_KM) p.push(`${c.name}: ${km.toFixed(0)} km outside ${byIso.get(c.iso)!.name}`)
    for (const s of shapes) if (s.iso && s.iso !== c.iso && inShape(s, c.lon, c.lat)) p.push(`${c.name}: inside ${s.iso}, not ${c.iso}`)
  }
  return p
}
const inside = checkInside(CITIES)
report(`every city lies in its own country on the Natural Earth map (≤ ${COAST_KM} km off a coast; worst ${worst.name} ${worst.km.toFixed(1)} km; Hong Kong in China's HKG piece) and in no other`, inside)

// ── 4. Spot checks, written from an atlas independently of Wikidata ──────────
const SPOTS: [string, string, number, number][] = [
  ['New York', 'US', 40.71, -74.01], ['Rio de Janeiro', 'BR', -22.91, -43.17], ['Sydney', 'AU', -33.87, 151.21],
  ['Mumbai', 'IN', 19.08, 72.88], ['Istanbul', 'TR', 41.01, 28.98], ['Los Angeles', 'US', 34.05, -118.24],
  ['Chicago', 'US', 41.88, -87.63], ['Toronto', 'CA', 43.65, -79.38], ['São Paulo', 'BR', -23.55, -46.63],
  ['Hong Kong', 'CN', 22.32, 114.17], ['Shanghai', 'CN', 31.23, 121.47], ['Dubai', 'AE', 25.2, 55.27],
  ['Barcelona', 'ES', 41.39, 2.17], ['Venice', 'IT', 45.44, 12.33], ['Munich', 'DE', 48.14, 11.58],
  ['Saint Petersburg', 'RU', 59.93, 30.34], ['Johannesburg', 'ZA', -26.2, 28.05], ['Marrakesh', 'MA', 31.63, -7.99],
  ['Lagos', 'NG', 6.52, 3.38], ['Auckland', 'NZ', -36.85, 174.76], ['Osaka', 'JP', 34.69, 135.5],
  ['Timbuktu', 'ML', 16.77, -3.01], ['Ushuaia', 'AR', -54.8, -68.3], ['Alexandria', 'EG', 31.2, 29.92],
]
function checkSpots(cs: City[]): string[] {
  const p: string[] = []
  for (const [name, iso, lat, lon] of SPOTS) {
    const c = cs.find(x => x.name === name)
    if (!c) { p.push(`${name}: missing`); continue }
    if (c.iso !== iso) p.push(`${name}: in ${c.iso}, expected ${iso}`)
    if (Math.abs(c.lat - lat) > 0.5 || Math.abs(c.lon - lon) > 0.5) p.push(`${name}: at ${c.lat},${c.lon}, expected about ${lat},${lon}`)
  }
  return p
}
report(`${SPOTS.length} hand-asserted cities: right country, within 0.5° of an atlas position`, checkSpots(CITIES))

// ── 5. No two cities are the same place ──────────────────────────────────────
function checkApart(cs: City[]): string[] {
  const p: string[] = []
  for (let i = 0; i < cs.length; i++) for (let j = i + 1; j < cs.length; j++) {
    const km = proj.haversineKm(cs[i], cs[j])
    if (km < SAME_PLACE_KM) p.push(`${cs[i].name} and ${cs[j].name} are ${km.toFixed(1)} km apart`)
  }
  return p
}
report(`no two cities within ${SAME_PLACE_KM} km of each other`, checkApart(CITIES))

// ── 6. Taps on the Pin the map views ─────────────────────────────────────────
function checkTaps(cs: City[]): string[] {
  const p: string[] = []
  for (const c of cs) {
    const v = gm.fitView(gm.REGION_BOX[c.continent], 375 / 420)
    const [x, y] = gm.toSvg(c.lon, c.lat, v.lon0)
    const back = gm.fromSvg(x, y, v.lon0)
    const km = back ? proj.haversineKm(c, back) : Infinity
    if (!(km < 0.5)) p.push(`${c.name}: tapped at its own point reads back ${km.toFixed(2)} km away`)
    if (!(x >= v.x && x <= v.x + v.w && y >= v.y && y <= v.y + v.h)) p.push(`${c.name}: outside the ${c.continent} view`)
  }
  return p
}
report('every city, tapped on its continent view (375×420 phone map), reads back within 0.5 km and is on screen', checkTaps(CITIES))

// ── 7. City cards ────────────────────────────────────────────────────────────
type Card = ReturnType<typeof geo.allGeoCards>[number]
function checkCards(cards: Card[], cs: City[]): string[] {
  const p: string[] = []
  if (cards.length !== cs.length) p.push(`${cards.length} city cards for ${cs.length} cities`)
  for (const card of cards) {
    const c = cs.find(x => `city:${x.id}` === card.key)
    if (!c) { p.push(`${card.key}: no such city`); continue }
    const k = byIso.get(c.iso)!
    const values = card.options.map(o => o.value)
    if (card.kind !== 'city' || card.iso !== c.iso || card.continent !== c.continent) p.push(`${card.key}: kind/iso/continent wrong`)
    if (card.answer !== c.iso || values[0] !== c.iso) p.push(`${card.key}: answer is not ${c.iso}, first`)
    if (card.options.length !== 4 || new Set(values).size !== 4) p.push(`${card.key}: not 4 different options`)
    if (!card.prompt.includes(c.name)) p.push(`${card.key}: prompt does not name ${c.name}`)
    for (const o of card.options.slice(1)) {
      const w = byIso.get(o.value)
      if (!w) { p.push(`${card.key}: option ${o.value} is not a UN member`); continue }
      if (w.continent !== k.continent) p.push(`${card.key}: ${w.name} is not in ${k.continent}`)
      if ((c.notWrong ?? []).includes(o.value)) p.push(`${card.key}: offers ${w.name}, which its notWrong rules out`)
      if (o.label !== w.name) p.push(`${card.key}: option label ${o.label}`)
    }
    if (card.points !== geo.KIND_SCORE.city.points || card.targetMs !== geo.KIND_SCORE.city.targetMs) p.push(`${card.key}: score`)
  }
  const again = geo.parseGeoKey('city:rio-de-janeiro')
  if (!again || JSON.stringify(again.options) !== JSON.stringify(cards.find(x => x.key === 'city:rio-de-janeiro')?.options)) p.push('options are not deterministic')
  return p
}
const cityCards = geo.geoCards(['city'])
report(`${cityCards.length} city cards: 4 different countries, the right one first, wrong ones from the same continent and never a notWrong`, checkCards(cityCards, CITIES))

// ── 8. Pin the map places and rounds ─────────────────────────────────────────
function checkPin(): string[] {
  const p: string[] = []
  const places = geo.pinPlaces()
  if (places.length !== COUNTRIES.length + CITIES.length) p.push(`${places.length} places for ${COUNTRIES.length} capitals + ${CITIES.length} cities`)
  if (new Set(places.map(x => x.key)).size !== places.length) p.push('duplicate place keys')
  let seedN = 11
  const rnd = () => ((seedN = (seedN * 1103515245 + 12345) % 2147483648) / 2147483648)
  for (const ct of geo.CONTINENTS) for (const l of pin.PIN_LEVELS) for (let k = 0; k < 30; k++) {
    const r = geo.buildPinRound(ct, l, rnd)
    if (r.length !== pin.PIN_ROUND || new Set(r.map(x => x.key)).size !== r.length) { p.push(`${ct}:${l}: ${r.length} places, or a repeat`); break }
    if (r.some(x => x.continent !== ct)) { p.push(`${ct}:${l}: a place from another continent`); break }
    const cities = r.filter(x => x.kind === 'city').length
    const tierCities = places.filter(x => x.continent === ct && x.kind === 'city' && x.tier === l).length
    // Over the share only when the level's own tier is short of capitals
    // (then a same-tier city beats a capital from an easier or harder tier).
    const tierCaps = places.filter(x => x.continent === ct && x.kind === 'capital' && x.tier === l).length
    if (cities > pin.PIN_CITY_SHARE && tierCaps >= pin.PIN_ROUND - pin.PIN_CITY_SHARE) { p.push(`${ct}:${l}: ${cities} cities`); break }
    if (tierCities > 0 && cities === 0) { p.push(`${ct}:${l}: no city although tier ${l} has ${tierCities}`); break }
    if (r.some(x => !x.where || !x.name)) { p.push(`${ct}:${l}: a place without a name or hint`); break }
  }
  return p
}
report('pin places = 193 capitals + every city, unique keys; 30 seeded rounds per continent and level: 10 different places, right continent, cities mixed in', checkPin())

// ── Positive controls ────────────────────────────────────────────────────────
console.log('\nPositive controls (each MUST be caught):')
for (const x of [...checkJoin(CITIES), ...checkNotCapital(CITIES), ...checkInside(CITIES), ...checkSpots(CITIES), ...checkApart(CITIES),
  ...checkTaps(CITIES), ...checkCards(cityCards, CITIES)]) baseline.add(x)
const copy = () => JSON.parse(JSON.stringify(CITIES)) as City[]
const edit = (cs: City[], name: string, f: (c: City) => void) => { f(cs.find(c => c.name === name)!); return cs }
const capeTown: City = { id: 'cape-town', name: 'Cape Town', iso: 'ZA', continent: 'af', tier: 1, lat: -33.93, lon: 18.42, population: 4772846, wikidata: 'Q5465' }
control('a capital (Cape Town) sneaked into the city list', checkNotCapital([...copy(), capeTown]))
control('a capital renamed (Cape Town as "Kaapstad")', checkNotCapital([...copy(), { ...capeTown, id: 'kaapstad', name: 'Kaapstad' }]))
control('New York put in Canada', checkInside(edit(copy(), 'New York', c => { c.iso = 'CA' })))
control('New York put in Canada (spot check)', checkSpots(edit(copy(), 'New York', c => { c.iso = 'CA' })))
control('Hong Kong put in Vietnam (China\'s HKG piece must not excuse it)', checkInside(edit(copy(), 'Hong Kong', c => { c.iso = 'VN' })))
control('Rio de Janeiro coordinates swapped', checkInside(edit(copy(), 'Rio de Janeiro', c => { [c.lat, c.lon] = [c.lon, c.lat] })))
control('Venice listed twice', checkJoin([...copy(), CITIES.find(c => c.name === 'Venice')!]))
control('Venice listed twice under another name', checkApart([...copy(), { ...CITIES.find(c => c.name === 'Venice')!, id: 'venezia', name: 'Venezia', wikidata: 'Q1' }]))
control('New York drifted to the state item (43.00,-75.00)', checkSpots(edit(copy(), 'New York', c => { c.lat = 43; c.lon = -75 })))
control('a tier 4 city', checkJoin(edit(copy(), 'Sydney', c => { c.tier = 4 as never })))
control('a city on the wrong continent', checkJoin(edit(copy(), 'Istanbul', c => { c.continent = 'eu' })))
control('a city off its continent view (Honolulu as a US city)', checkTaps([...copy(), { ...capeTown, id: 'honolulu', name: 'Honolulu', iso: 'US', continent: 'na', lat: 21.31, lon: -157.86 }]))
{
  const cards = JSON.parse(JSON.stringify(cityCards)) as Card[]
  const q = cards.find(c => c.key === 'city:queenstown')!
  q.options[3] = { value: 'AU', label: 'Australia' }
  control('Australia offered as WRONG for Queenstown (a Tasmanian Queenstown exists)', checkCards(cards, CITIES))
}
{
  const cards = JSON.parse(JSON.stringify(cityCards)) as Card[]
  cards.find(c => c.key === 'city:rio-de-janeiro')!.options[2] = { value: 'PT', label: 'Portugal' }
  control('Portugal (Europe) offered for Rio de Janeiro', checkCards(cards, CITIES))
}

console.log(fails ? `\n${fails} FAILED` : '\nALL PASSED')
process.exit(fails ? 1 : 0)
