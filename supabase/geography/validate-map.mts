// Checks the generated world map and the projection. Run:
//
//   node supabase/geography/validate-map.mts
//
// Like validate-data.mts, every check is then run on a deliberately broken
// copy that MUST fail (a positive control: a check that cannot fail proves
// nothing). Exits non-zero if the real map has a problem or a control passes.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import zlib from 'node:zlib'
import { fileURLToPath } from 'node:url'
import type { MapAsset, MapShape } from '../../lib/geo-map.ts'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const { COUNTRIES } = await import('../../lib/geo-data.ts')
const proj = await import('../../lib/geo-projection.ts')
const gm = await import('../../lib/geo-map.ts')
const md = await import('../../lib/geo-map-data.ts')

const assetFile = path.join(root, 'public', gm.MAP_URL)
const asset = JSON.parse(fs.readFileSync(assetFile, 'utf8')) as MapAsset
let fails = 0
const report = (name: string, problems: string[]) => {
  console.log(`${problems.length ? 'FAIL' : 'PASS'}  ${name}${problems.length ? '\n        ' + problems.slice(0, 8).join('\n        ') : ''}`)
  if (problems.length) fails++
}
const control = (name: string, problems: string[]) => {
  console.log(`${problems.length ? 'PASS' : 'FAIL'}  control: ${name} is caught${problems.length ? ` (${problems[0].slice(0, 90)})` : ' — NOT CAUGHT'}`)
  if (!problems.length) fails++
}

// ── Point in shape (shared with validate-cities.mts) ─────────────────────────

const { inShape, nearestKm } = await import('./map-geom.mts')

// ── 1. Every UN member resolves ──────────────────────────────────────────────

function checkJoin(a: MapAsset): string[] {
  const p: string[] = []
  const shapes = gm.decodeAsset(a)
  const byIso = new Map<string, MapShape>()
  for (const s of shapes) {
    if (!s.iso) continue
    if (byIso.has(s.iso)) p.push(`duplicate shape for ${s.iso}`)
    byIso.set(s.iso, s)
  }
  for (const c of COUNTRIES) {
    const s = byIso.get(c.iso)
    if (!s) { p.push(`${c.iso} ${c.name}: no shape`); continue }
    if (s.a3 !== c.iso3) p.push(`${c.iso}: keyed ${s.a3}, expected ${c.iso3}`)
    const cap = c.capitals[0]
    if (!s.cap || Math.abs(s.cap.lat - cap.lat) > 1e-9 || Math.abs(s.cap.lon - cap.lon) > 1e-9) p.push(`${c.iso}: capital point is not ${cap.name}`)
    // Resolvable = has land to draw, OR is small enough to be drawn as a ring.
    if (s.rings.length === 0 && s.km2 > 5000) p.push(`${c.iso}: no rings and not tiny`)
    // The join check that matters: the asked capital lies in (or within
    // 30 km of, for coastal capitals at 1:50m) the country's own shape.
    const km = nearestKm(s, cap.lon, cap.lat)
    if (km > 30) p.push(`${c.iso} ${c.name}: ${cap.name} is ${km.toFixed(0)} km from its own shape`)
  }
  if (byIso.size !== 193) p.push(`expected 193 UN shapes, found ${byIso.size}`)
  return p
}
report('all 193 UN members have a shape (or are tiny), keyed by ISO alpha-3, capital inside', checkJoin(asset))

// ── 2. Bounds ────────────────────────────────────────────────────────────────

function checkBounds(a: MapAsset): string[] {
  const p: string[] = []
  for (const s of gm.decodeAsset(a)) {
    for (const r of s.rings) {
      if (r.length < 6) p.push(`${s.a3}: ring with ${r.length / 2} points`)
      for (let i = 0; i < r.length; i += 2) {
        if (!(r[i] >= -180.001 && r[i] <= 180.001 && r[i + 1] >= -90 && r[i + 1] <= 90)) { p.push(`${s.a3}: point ${r[i]},${r[i + 1]} out of range`); break }
      }
    }
    if (s.iso) {
      const z = s.zoom
      if (!z || !(z.w < z.e && z.s < z.n && z.e - z.w <= 360 && z.s >= -90 && z.n <= 90)) p.push(`${s.a3}: bad zoom box`)
      else {
        const lon = s.cap!.lon, mid = (z.w + z.e) / 2
        const rel = proj.wrapLon(lon - mid)
        if (Math.abs(rel) > (z.e - z.w) / 2 || s.cap!.lat < z.s || s.cap!.lat > z.n) p.push(`${s.a3}: capital outside its zoom box`)
      }
    }
  }
  return p
}
report('every point in range, every zoom box sane and around the capital', checkBounds(asset))

// ── 3. Spot checks: the right shapes ─────────────────────────────────────────
//
// [place, lon, lat, inside (ISO2 or '-' for neutral land), not inside...]
// Written from atlas knowledge, independently of the data.
const SPOTS: [string, number, number, string, ...string[]][] = [
  ['Santiago, Chile', -70.67, -33.45, 'CL', 'AR'],
  ['Tierra del Fuego, Chilean side', -69.6, -53.8, 'CL', 'AR'],
  ['Coyhaique, Chile', -72.07, -45.57, 'CL', 'AR'],
  ['Milan, Italy', 9.19, 45.46, 'IT', 'CH'],
  ['Palermo, Sicily', 13.36, 38.12, 'IT'],
  ['Sapporo, Japan', 141.35, 43.06, 'JP', 'RU'],
  ['Antananarivo, Madagascar', 47.52, -18.88, 'MG'],
  ['Karasjok, northern Norway', 25.51, 69.47, 'NO', 'SE', 'FI'],
  ['Lyon, France', 4.84, 45.76, 'FR'],
  ['Ajaccio, Corsica', 8.74, 41.93, 'FR', 'IT'],
  ['Cayenne, French Guiana (part of France)', -52.33, 4.94, 'FR', 'SR', 'BR'],
  ['Juba, South Sudan', 31.58, 4.85, 'SS', 'SD'],
  ['Khartoum, Sudan', 32.53, 15.5, 'SD', 'SS'],
  ['Mbabane, Eswatini', 31.13, -26.32, 'SZ', 'ZA'],
  ['Maseru, Lesotho', 27.48, -29.31, 'LS', 'ZA'],
  ['Johannesburg, South Africa', 28.05, -26.2, 'ZA', 'LS'],
  ['Farafenni, the Gambia', -15.6, 13.57, 'GM', 'SN'],
  ['Kaolack, Senegal', -16.07, 14.15, 'SN', 'GM'],
  ['Pristina, Kosovo (neutral land)', 21.17, 42.67, '-', 'RS', 'AL', 'MK'],
  ['Belgrade, Serbia', 20.46, 44.79, 'RS'],
  ['Laayoune, Western Sahara (neutral)', -13.2, 27.15, '-', 'MA'],
  ['Hargeisa, Somaliland (drawn as Somalia)', 44.06, 9.56, 'SO'],
  ['North Nicosia (drawn as Cyprus)', 33.36, 35.2, 'CY', 'TR'],
  ['Taipei (neutral land)', 121.56, 25.03, '-', 'CN'],
  ['Inland Greenland (neutral land)', -40, 72, '-', 'DK'],
  ['Tan-Tan, Morocco', -11.1, 28.44, 'MA'],
  ['Kaliningrad, Russia', 20.51, 54.71, 'RU', 'LT', 'PL'],
  ['Anchorage, USA', -149.9, 61.22, 'US', 'CA'],
  ['Kuala Lumpur, Malaysia', 101.69, 3.14, 'MY'],
  ['Kuching, Malaysia (Borneo)', 110.35, 1.55, 'MY', 'ID'],
  ['Sarajevo, Bosnia', 18.41, 43.86, 'BA', 'HR'],
  ['La Paz, Bolivia', -68.15, -16.5, 'BO', 'PE'],
]
function checkSpots(a: MapAsset): string[] {
  const p: string[] = []
  const shapes = gm.decodeAsset(a)
  const byIso = new Map(shapes.filter(s => s.iso).map(s => [s.iso!, s]))
  for (const [name, lon, lat, inside, ...not] of SPOTS) {
    const holders = shapes.filter(s => inShape(s, lon, lat))
    if (inside === '-') {
      if (holders.some(s => s.iso)) p.push(`${name}: inside UN member ${holders.find(s => s.iso)!.iso}`)
      if (!holders.length) p.push(`${name}: not on any land`)
    } else if (!inShape(byIso.get(inside)!, lon, lat)) p.push(`${name}: not inside ${inside}`)
    for (const n of not) if (inShape(byIso.get(n)!, lon, lat)) p.push(`${name}: wrongly inside ${n}`)
  }
  // Zoom boxes show the home, not overseas pieces.
  const z = (iso: string) => byIso.get(iso)!.zoom!
  if (z('FR').w < -10 || z('FR').s < 35) p.push(`France zoom box reaches overseas: ${JSON.stringify(z('FR'))}`)
  if (z('US').w < -140) p.push(`USA zoom box reaches Alaska/Hawaii: ${JSON.stringify(z('US'))}`)
  if (z('NO').n > 75) p.push(`Norway zoom box reaches Svalbard: ${JSON.stringify(z('NO'))}`)
  if (z('ES').s < 30) p.push(`Spain zoom box reaches the Canaries: ${JSON.stringify(z('ES'))}`)
  if (z('CL').w < -85) p.push(`Chile zoom box reaches Easter Island: ${JSON.stringify(z('CL'))}`)
  // Non-members are never answerable.
  for (const s of shapes) if (['KOS', 'SAH', 'TWN', 'PSX', 'GRL', 'SOL', 'CYN', 'VAT'].includes(s.a3) && s.iso) p.push(`${s.a3} is answerable`)
  return p
}
report(`${SPOTS.length} places land in the right country; overseas parts stay out of zoom boxes; non-members never answerable`, checkSpots(asset))

// ── 4. Tiny countries ────────────────────────────────────────────────────────
const tiny = gm.decodeAsset(asset).filter(s => s.iso && s.km2 <= 5000).map(s => s.iso!).sort()
console.log(`      drawn as a ring when under ${gm.TINY_PX}px wide; ${tiny.length} countries are under 5000 km²: ${tiny.join(' ')}`)
report('the expected microstates are small enough to get rings',
  ['MC', 'SM', 'LI', 'AD', 'MT', 'NR', 'TV', 'MV', 'SG', 'BH', 'KN', 'AG', 'GD', 'VC', 'LC', 'DM', 'BB', 'SC', 'PW', 'MH']
    .filter(i => !tiny.includes(i)).map(i => `${i} is not tiny`))

// ── 5. Neighbours for wrong answers ──────────────────────────────────────────
function checkNeighbours(n: Record<string, string[]>): string[] {
  const p: string[] = []
  const isos = new Set(COUNTRIES.map(c => c.iso))
  for (const c of COUNTRIES) {
    const xs = n[c.iso] ?? []
    if (xs.length < 3) p.push(`${c.iso}: only ${xs.length} neighbours`)
    if (xs.includes(c.iso)) p.push(`${c.iso}: is its own neighbour`)
    for (const x of xs) if (!isos.has(x)) p.push(`${c.iso}: neighbour ${x} is not a UN member`)
    for (const x of md.ENCLOSED_BY[c.iso] ?? []) if (xs.includes(x)) p.push(`${c.iso}: offered ${x}, which surrounds it`)
  }
  const must: [string, string][] = [['FR', 'ES'], ['FR', 'DE'], ['LS', 'ZA'], ['GM', 'SN'], ['SS', 'SD'], ['CL', 'AR'], ['NO', 'SE'], ['KE', 'TZ']]
  for (const [a, b] of must) if (!(n[a] ?? []).slice(0, 5).includes(b)) p.push(`${a}: ${b} not among its 5 nearest`)
  return p
}
report('every country has 8 UN neighbours; known borders are nearest; enclosers never offered', checkNeighbours(md.NEIGHBOURS))

// ── 6. Projection round trip ─────────────────────────────────────────────────
const SAMPLES: [number, number, number][] = [   // lon, lat, view centre
  [0, 0, 0], [2.35, 48.86, 15], [-70.67, -33.45, -58], [139.69, 35.69, 87.5], [36.82, -1.29, 17],
  [-171.77, -13.83, 151], [179.2, -8.52, 151], [-175.2, -21.14, 151], [172.98, 1.33, 151], [-149.9, 61.22, -92.5],
  [-21.94, 64.15, 10], [37.62, 55.76, 10], [151.21, -33.87, 151], [-43.2, -22.9, -58], [77.21, 28.61, 87.5],
  [-99.13, 19.43, -92.5], [12.45, 41.9, 10], [-179.9, 70, 0], [179.9, -70, 0], [0, 89.5, 0],
]
type Inv = (x: number, y: number, lon0: number) => { lat: number; lon: number } | null
function checkRoundTrip(inv: Inv): string[] {
  const p: string[] = []
  for (const [lon, lat, lon0] of SAMPLES) {
    const [x, y] = proj.project(lon, lat, lon0)
    const back = inv(x, y, lon0)
    if (!back) { p.push(`${lon},${lat}: inverse returned nothing`); continue }
    const err = Math.max(Math.abs(back.lat - lat), Math.abs(proj.wrapLon(back.lon - lon)))
    if (!(err < 0.1)) p.push(`${lon},${lat} (lon0 ${lon0}): error ${err.toFixed(4)}°`)
  }
  return p
}
const rt = checkRoundTrip(proj.invert)
let worst = 0
for (const [lon, lat, lon0] of SAMPLES) {
  const [x, y] = proj.project(lon, lat, lon0); const b = proj.invert(x, y, lon0)!
  worst = Math.max(worst, Math.abs(b.lat - lat), Math.abs(proj.wrapLon(b.lon - lon)))
}
report(`projection round trip at ${SAMPLES.length} points under 0.1° (worst ${worst.toExponential(1)}°)`, rt)

// Taps through SVG units: a capital's projected point, read back, is ≈ 0 km.
function checkTaps(): string[] {
  const p: string[] = []
  for (const region of Object.keys(gm.REGION_BOX) as (keyof typeof gm.REGION_BOX)[]) {
    const v = gm.fitView(gm.REGION_BOX[region], 375 / 420)
    for (const c of COUNTRIES.filter(c => region === 'world' || c.continent === region)) {
      const cap = c.capitals[0]
      const [x, y] = gm.toSvg(cap.lon, cap.lat, v.lon0)
      const back = gm.fromSvg(x, y, v.lon0)
      const km = back ? proj.haversineKm(cap, back) : Infinity
      if (!(km < 0.5)) p.push(`${region} ${cap.name}: ${km.toFixed(2)} km`)
      if (region !== 'world' && !(x >= v.x && x <= v.x + v.w && y >= v.y && y <= v.y + v.h)) p.push(`${region}: ${cap.name} is outside the ${region} view`)
    }
  }
  return p
}
report('every capital, tapped on its continent view (375×420 phone map), reads back within 0.5 km and is on screen', checkTaps())

// ── Positive controls ────────────────────────────────────────────────────────
console.log('\nPositive controls (each MUST be caught):')
const copy = () => JSON.parse(JSON.stringify(asset)) as MapAsset
{ // two countries' shapes swapped
  const a = copy(); const fr = a.c.find(e => e.a === 'FRA')!, de = a.c.find(e => e.a === 'DEU')!
  ;[fr.r, de.r] = [de.r, fr.r]; control('France and Germany shapes swapped', checkJoin(a))
}
{ const a = copy(); a.c = a.c.filter(e => e.a !== 'KEN'); control('Kenya missing', checkJoin(a)) }
{ const a = copy(); a.c.find(e => e.a === 'KOS')!.i = 'XK'; control('Kosovo made answerable', checkSpots(a)) }
{ const a = copy(); const s = a.c.find(e => e.a === 'LSO')!; a.c.find(e => e.a === 'ZAF')!.r.push(...s.r.map(r => [...r])); control('Lesotho painted over South Africa (no hole)', checkSpots(a)) }
{ const a = copy(); a.c.find(e => e.a === 'FRA')!.z = [-60, 0, 10, 52]; control('France zoom box stretched to French Guiana', checkSpots(a)) }
{ const a = copy(); a.c.find(e => e.a === 'JPN')!.r[0][0] = 99999; control('a point out of range', checkBounds(a)) }
{ const n = structuredClone(md.NEIGHBOURS); n.SM = ['IT', ...n.SM]; control('Italy offered for San Marino', checkNeighbours(n)) }
control('an inverse with a single Newton step and a constant-width longitude', checkRoundTrip((x, y, lon0) => ({
  lat: (y / 1.007226) * 180 / Math.PI, lon: proj.wrapLon((x / 0.8707) * 180 / Math.PI + lon0) })))
control('an inverse that forgets the view centre', checkRoundTrip((x, y) => proj.invert(x, y, 0)))

const raw = fs.readFileSync(assetFile)
console.log(`\nasset: ${(raw.length / 1024).toFixed(0)} KB, ${(zlib.gzipSync(raw, { level: 9 }).length / 1024).toFixed(0)} KB gzipped (what a map page downloads, once)`)
console.log(fails ? `\n${fails} FAILED` : '\nALL PASSED')
process.exit(fails ? 1 : 0)
