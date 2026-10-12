// Builds the world map from Natural Earth. Run:
//
//   node supabase/geography/build-map.mts <path>/ne_50m_admin_0_countries.geojson
//   node supabase/geography/validate-map.mts
//
// Source: Natural Earth 1:50m Cultural Vectors, Admin 0 – Countries, v5.1.2
//   https://github.com/nvkelso/natural-earth-vector/blob/v5.1.2/geojson/ne_50m_admin_0_countries.geojson
//   https://www.naturalearthdata.com — public domain ("No permission is
//   needed to use Natural Earth"), so the generated files can be shipped.
// The input is pinned by SHA-256 below; another file is refused unless
// --any-source is passed (then the new hash must be recorded here).
//
// Writes two GENERATED files, never edit them by hand:
//   public/geo/world-50m.json   the shapes the browser draws (fetched, not
//                               bundled), one entry per Natural Earth feature
//   lib/geo-map-data.ts         per UN country: nearest countries (for wrong
//                               answers on "Name that country" cards),
//                               population and land area (for Pin the map
//                               levels). Server-side only, via lib/geo.ts.
//
// Joining Natural Earth to the 193 UN members of lib/geo-data.ts:
//   * by ADM0_A3, NE's own code (ISO_A3 is -99 for France, Norway and some
//     others). Where ADM0_A3 is not the ISO code it is renamed (RENAME).
//   * every direct join is cross-checked against Wikidata: NE's WIKIDATAID
//     must equal the country's Wikidata item from phase 1, or the build stops.
//   * Somaliland and Northern Cyprus are drawn as part of Somalia and Cyprus
//     (MERGE), the UN view and Natural Earth's own US point of view. Every
//     other non-member (Kosovo, Western Sahara, Taiwan, Palestine, Greenland,
//     dependencies) is neutral land: drawn, never highlighted, never asked.
//   * Morocco is cut at Western Sahara's northern border (CLIP_SOUTH_OF).
//   * Antarctica is left out: nothing on it is ever asked, and it would take
//     a fifth of a world view.
//
// A country's "home" is the part a kid would picture: its largest piece and
// the piece with its capital, plus every piece within GAP_DEG of those,
// repeated until nothing more joins. France's home is the mainland and
// Corsica, not French Guiana or Réunion; the USA's is the lower 48. Zooming
// to a country uses its home, so no overseas piece can drag the view across
// an ocean. The whole country is still highlighted.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import crypto from 'node:crypto'
import { fileURLToPath } from 'node:url'

const { COUNTRIES } = await import('../../lib/geo-data.ts')

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')

export const NE_VERSION = '5.1.2'
export const NE_SHA256 = '3e458fc036ad0a66411f2c1e6cac49c5d7bfb81cb1123bc513b22511a2b7fdeb'
const SOURCE = `Natural Earth 1:50m Admin 0 Countries v${NE_VERSION} (public domain)`

const RENAME: Record<string, string> = { SDS: 'SSD' }          // South Sudan
const MERGE: Record<string, string> = { SOL: 'SOM', CYN: 'CYP' } // drawn as part of
const DROP = new Set(['ATA'])                                  // Antarctica
// Where Natural Earth's Wikidata item is a different item for the same
// place: phase 1 asks about the Kingdom of the Netherlands (Q29999), Natural
// Earth's feature is its European part, the country of the Netherlands (Q55).
const SAME_PLACE: Record<string, string> = { Q55: 'Q29999' }
// Natural Earth's Morocco polygon also covers the part of Western Sahara
// west of the berm (the de facto line); NE's "W. Sahara" feature is only the
// strip east of it. Western Sahara is a UN non-self-governing territory,
// drawn as neutral land like the others, so Morocco is cut at the 27°40' N
// line that is Western Sahara's northern border (exactly the northern edge
// of NE's W. Sahara feature) and the part south of it joins W. Sahara.
const CLIP_SOUTH_OF: Record<string, [number, string]> = { MAR: [27.656445, 'SAH'] }

const Q = 100           // stored as integers in hundredths of a degree
const SIMPLIFY = 0.015  // Douglas–Peucker tolerance, degrees
const GAP_DEG = 3       // pieces this close (degrees, longitude scaled) join a home
const SMALL_KM2 = 5000  // at most this big: a country that may be drawn as a ring

type Pt = [number, number]
type Ring = Pt[]
type Poly = Ring[]       // outer ring first, then holes

const file = process.argv[2]
if (!file) { console.error('usage: node supabase/geography/build-map.mts <ne_50m_admin_0_countries.geojson>'); process.exit(1) }
const raw = fs.readFileSync(file)
const sha = crypto.createHash('sha256').update(raw).digest('hex')
if (sha !== NE_SHA256 && !process.argv.includes('--any-source')) {
  console.error(`Refusing: ${file} has SHA-256 ${sha}, expected ${NE_SHA256} (Natural Earth v${NE_VERSION}).`)
  process.exit(1)
}
const gj = JSON.parse(raw.toString('utf8')) as {
  features: { properties: Record<string, string | number | null>; geometry: { type: string; coordinates: unknown } }[]
}

// ── Geometry helpers ─────────────────────────────────────────────────────────

const D2R = Math.PI / 180

function simplify(r: Ring, tol: number): Ring {
  if (r.length <= 4) return r
  const keep = new Uint8Array(r.length)
  keep[0] = keep[r.length - 1] = 1
  const stack: [number, number][] = [[0, r.length - 1]]
  // A closed ring's first and last points coincide: split at the farthest
  // point from the start so the first segment is not degenerate.
  let far = 0, fd = -1
  for (let i = 1; i < r.length - 1; i++) {
    const d = (r[i][0] - r[0][0]) ** 2 + (r[i][1] - r[0][1]) ** 2
    if (d > fd) { fd = d; far = i }
  }
  keep[far] = 1
  stack.length = 0
  stack.push([0, far], [far, r.length - 1])
  while (stack.length) {
    const [a, b] = stack.pop()!
    const [ax, ay] = r[a], [bx, by] = r[b]
    const dx = bx - ax, dy = by - ay, len2 = dx * dx + dy * dy
    let best = -1, bi = -1
    for (let i = a + 1; i < b; i++) {
      const [px, py] = r[i]
      let d: number
      if (len2 === 0) d = (px - ax) ** 2 + (py - ay) ** 2
      else {
        const t = Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / len2))
        d = (px - ax - t * dx) ** 2 + (py - ay - t * dy) ** 2
      }
      if (d > best) { best = d; bi = i }
    }
    if (bi >= 0 && best > tol * tol) { keep[bi] = 1; stack.push([a, bi], [bi, b]) }
  }
  return r.filter((_, i) => keep[i])
}

function quantize(r: Ring): Ring {
  const out: Ring = []
  for (const [x, y] of r) {
    const p: Pt = [Math.round(x * Q), Math.round(y * Q)]
    const last = out[out.length - 1]
    if (!last || last[0] !== p[0] || last[1] !== p[1]) out.push(p)
  }
  // Drop the closing point; the renderer closes every ring.
  if (out.length > 1 && out[0][0] === out.at(-1)![0] && out[0][1] === out.at(-1)![1]) out.pop()
  return out
}

interface Box { w: number; s: number; e: number; n: number }
const boxOf = (rings: Ring[]): Box => {
  const b = { w: Infinity, s: Infinity, e: -Infinity, n: -Infinity }
  for (const r of rings) for (const [x, y] of r) {
    if (x < b.w) b.w = x; if (x > b.e) b.e = x; if (y < b.s) b.s = y; if (y > b.n) b.n = y
  }
  return b
}
const shiftBox = (b: Box, k: number): Box => ({ w: b.w + k, s: b.s, e: b.e + k, n: b.n })
const union = (a: Box, b: Box): Box => ({ w: Math.min(a.w, b.w), s: Math.min(a.s, b.s), e: Math.max(a.e, b.e), n: Math.max(a.n, b.n) })
/** Gap between two boxes in degrees, longitude scaled by latitude. 0 if they touch. */
function gap(a: Box, b: Box): number {
  const lat = Math.max(Math.abs((a.s + a.n) / 2), Math.abs((b.s + b.n) / 2))
  const gx = Math.max(0, b.w - a.e, a.w - b.e) * Math.cos(Math.min(lat, 80) * D2R)
  const gy = Math.max(0, b.s - a.n, a.s - b.n)
  return Math.hypot(gx, gy)
}
/** km², from the shoelace formula on a locally scaled plane. */
function ringArea(r: Ring): number {
  let a = 0
  const lat = r.reduce((s, p) => s + p[1], 0) / r.length
  const k = Math.cos(lat * D2R)
  for (let i = 0, j = r.length - 1; i < r.length; j = i++) a += (r[j][0] * k) * r[i][1] - (r[i][0] * k) * r[j][1]
  return Math.abs(a / 2) * 111.32 * 111.32
}
const polyArea = (p: Poly) => Math.max(0, ringArea(p[0]) - p.slice(1).reduce((s, h) => s + ringArea(h), 0))
function inRing(r: Ring, x: number, y: number): boolean {
  let inside = false
  for (let i = 0, j = r.length - 1; i < r.length; j = i++) {
    const [xi, yi] = r[i], [xj, yj] = r[j]
    if ((yi > y) !== (yj > y) && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi) inside = !inside
  }
  return inside
}
const inPoly = (p: Poly, x: number, y: number) => inRing(p[0], x, y) && !p.slice(1).some(h => inRing(h, x, y))
function hav(a: Pt, b: Pt): number {
  const dLat = (b[1] - a[1]) * D2R, dLon = (b[0] - a[0]) * D2R
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(a[1] * D2R) * Math.cos(b[1] * D2R) * Math.sin(dLon / 2) ** 2
  return 2 * 6371 * Math.asin(Math.min(1, Math.sqrt(h)))
}

/** Keep the part of a ring north (or south) of `lat` (Sutherland–Hodgman,
 *  one edge). */
function clipAt(r: Ring, lat: number, north: boolean): Ring {
  const out: Ring = []
  const keep = (p: Pt) => (north ? p[1] >= lat : p[1] <= lat)
  for (let i = 0; i < r.length; i++) {
    const a = r[i], b = r[(i + 1) % r.length]
    const ina = keep(a), inb = keep(b)
    if (ina) out.push(a)
    if (ina !== inb) out.push([a[0] + ((lat - a[1]) / (b[1] - a[1])) * (b[0] - a[0]), lat])
  }
  if (out.length && (out[0][0] !== out.at(-1)![0] || out[0][1] !== out.at(-1)![1])) out.push(out[0])
  return out
}

// ── Read and join ────────────────────────────────────────────────────────────

const byIso3 = new Map(COUNTRIES.map(c => [c.iso3, c]))
const clipped = new Map<string, Poly[]>()
interface Feat { code: string; un: boolean; polys: Poly[]; pop: number; ne: string[] }
const feats = new Map<string, Feat>()
const problems: string[] = []

for (const f of gj.features) {
  const p = f.properties
  const a3 = String(p.ADM0_A3)
  if (DROP.has(a3)) continue
  const code = MERGE[a3] ?? RENAME[a3] ?? a3
  const country = byIso3.get(code)
  if (country && !MERGE[a3] && (SAME_PLACE[String(p.WIKIDATAID)] ?? p.WIKIDATAID) !== country.wikidata) {
    problems.push(`${a3} → ${code}: Natural Earth Wikidata ${p.WIKIDATAID} is not ${country.wikidata} (${country.name})`)
  }
  const g = f.geometry
  let polys = (g.type === 'Polygon' ? [g.coordinates] : g.coordinates) as Poly[]
  if (CLIP_SOUTH_OF[a3]) {
    const [lat, to] = CLIP_SOUTH_OF[a3]
    const part = (north: boolean) => polys.map(poly => poly.map(r => clipAt(r, lat, north)).filter(r => r.length >= 4)).filter(poly => poly.length)
    clipped.set(to, [...(clipped.get(to) ?? []), ...part(false)])
    polys = part(true)
  }
  const feat = feats.get(code) ?? { code, un: !!country, polys: [], pop: 0, ne: [] }
  feat.polys.push(...polys)
  feat.pop += Number(p.POP_EST) || 0
  feat.ne.push(a3)
  feats.set(code, feat)
}
for (const [to, polys] of clipped) {
  if (!feats.has(to)) problems.push(`clipped land has nowhere to go: ${to}`)
  else feats.get(to)!.polys.push(...polys)
}
for (const c of COUNTRIES) if (!feats.has(c.iso3)) problems.push(`no Natural Earth shape for ${c.iso3} ${c.name}`)
if (problems.length) { console.error('Refusing to write:\n  ' + problems.join('\n  ')); process.exit(1) }

// ── Simplify, measure, find each country's home ──────────────────────────────

interface Out {
  a: string; i?: string; k?: [number, number]; z?: [number, number, number, number]
  ar?: number; r: number[][]
}

const out: Out[] = []
const homes = new Map<string, { box: Box; polys: Poly[] }>()
const area = new Map<string, number>()
let vertices = 0

for (const feat of [...feats.values()].sort((x, y) => (x.code < y.code ? -1 : 1))) {
  const country = byIso3.get(feat.code)
  // Simplify; a ring that collapses keeps its original points if it is part
  // of a UN country (a Pacific atoll is still that country), else is dropped.
  const polys: Poly[] = []
  for (const poly of feat.polys) {
    const rings: Poly = []
    for (const [idx, r] of poly.entries()) {
      let s = quantize(simplify(r, SIMPLIFY))
      if (s.length < 3) {
        if (!country || idx > 0) continue
        s = quantize(r)
        if (s.length < 3) continue
      }
      // Neutral specks under ~0.1° are noise at every zoom we show.
      if (!country) { const b = boxOf([s]); if (Math.max(b.e - b.w, b.n - b.s) < 0.1 * Q) continue }
      rings.push(s)
    }
    if (rings.length) polys.push(rings)
  }
  const deg = (p: Poly): Poly => p.map(r => r.map(([x, y]) => [x / Q, y / Q] as Pt))
  const entry: Out = { a: feat.code, r: polys.flat().map(r => {
    vertices += r.length
    const flat = [r[0][0], r[0][1]]
    for (let i = 1; i < r.length; i++) flat.push(r[i][0] - r[i - 1][0], r[i][1] - r[i - 1][1])
    return flat
  }) }

  if (country) {
    // Measure on the unsimplified shapes.
    const full = feat.polys
    const km2 = Math.round(full.reduce((s, p) => s + polyArea(p), 0))
    area.set(country.iso, km2)
    const cap = country.capitals[0]
    const boxes = full.map(p => boxOf([p[0]]))
    const largest = full.map(polyArea).reduce((bi, a, i, xs) => (a > xs[bi] ? i : bi), 0)
    let capIdx = full.findIndex(p => inPoly(p, cap.lon, cap.lat))
    if (capIdx < 0) {
      const pt = { w: cap.lon, e: cap.lon, s: cap.lat, n: cap.lat }
      capIdx = boxes.map(b => gap(pt, b)).reduce((bi, d, i, xs) => (d < xs[bi] ? i : bi), 0)
    }
    const shiftTo = (cur: Box, b: Box) => [0, -360, 360].map(k => shiftBox(b, k))
      .reduce((best, x) => (gap(cur, x) < gap(cur, best) ? x : best))
    let box = boxes[largest]
    const inHome = new Set([largest])
    if (capIdx !== largest) { box = union(box, shiftTo(box, boxes[capIdx])); inHome.add(capIdx) }
    for (let grew = true; grew;) {
      grew = false
      for (let i = 0; i < full.length; i++) {
        if (inHome.has(i)) continue
        const b = shiftTo(box, boxes[i])
        if (gap(box, b) <= GAP_DEG) { box = union(box, b); inHome.add(i); grew = true }
      }
    }
    homes.set(country.iso, { box, polys: [...inHome].map(i => full[i]) })
    entry.i = country.iso
    entry.k = [cap.lon, cap.lat]
    entry.ar = km2
  }
  out.push(entry)
}

// ── Zoom boxes: the home, padded, big enough to show some neighbours ─────────

const capOf = new Map(COUNTRIES.map(c => [c.iso, c.capitals[0]]))
const r1 = (x: number) => Math.round(x * 10) / 10
for (const e of out) {
  if (!e.i) continue
  const { box } = homes.get(e.i)!
  const cx = (box.w + box.e) / 2, cy = (box.s + box.n) / 2
  const k = Math.cos(Math.min(Math.abs(cy), 70) * D2R)
  // Work in "ground" degrees (longitude scaled) so a box is never a sliver.
  let hw = Math.max(((box.e - box.w) * k) / 2 * 1.3, 6)
  let hh = Math.max((box.n - box.s) / 2 * 1.3, 4.5)
  // Grow until at least three other countries' homes show, so a small
  // island is never a lone dot in an empty ocean.
  const others = () => {
    const view = { w: cx - hw / k, e: cx + hw / k, s: cy - hh, n: cy + hh }
    return COUNTRIES.filter(c => c.iso !== e.i &&
      [0, -360, 360].some(sh => gap(view, shiftBox(homes.get(c.iso)!.box, sh)) === 0)).length
  }
  for (let i = 0; i < 8 && others() < 3; i++) { hw *= 1.3; hh *= 1.3 }
  hh = Math.min(hh, 40)
  const s = Math.max(-85, cy - hh), n = Math.min(85, cy + hh)
  e.z = [r1(cx - hw / k), r1(s), r1(cx + hw / k), r1(n)]
}

// ── Nearest countries, for wrong answers ─────────────────────────────────────
//
// Distance = closest approach of the two homes' outlines (sampled), so a
// neighbour across a border is 0 km. A country whose shape contains another
// country's capital (Italy around the Vatican and San Marino) is never a
// wrong answer for it when it is small enough to be drawn as a ring: the ring
// would sit inside the "wrong" country. (Lesotho, a shape of its own, may
// still be offered South Africa.)

// Closest approach, from every vertex of the home outlines (unsimplified),
// using a 0.5° grid so only nearby vertices are compared. Countries that
// share a border (closer than 2 km) come first, longest shared border first
// (the count of vertices within 2 km of the other country), so France's list
// starts with Spain and Belgium rather than Monaco.
const CELL = 0.5
const cellKey = (x: number, y: number) => `${Math.floor(x / CELL)},${Math.floor(y / CELL)}`  // x in [-180, 180)
const grid = new Map<string, { iso: string; p: Pt }[]>()
const homePts = new Map<string, Pt[]>()
for (const [iso, h] of homes) {
  const pts = h.polys.flatMap(p => p[0]).map(([x, y]) => [proj180(x), y] as Pt)
  homePts.set(iso, pts)
  for (const p of pts) {
    const k = cellKey(p[0], p[1])
    if (!grid.has(k)) grid.set(k, [])
    grid.get(k)!.push({ iso, p })
  }
}
function proj180(x: number): number { return ((((x + 180) % 360) + 360) % 360) - 180 }
const full = new Map(COUNTRIES.map(c => [c.iso, feats.get(c.iso3)!.polys]))
// Farther apart than a grid cell: closest approach of sampled outlines, for
// homes within 25° of each other; beyond that, capital to capital (ranked
// after every nearer country).
const sampled = new Map([...homePts].map(([iso, pts]) => [iso, pts.filter((_, i) => i % Math.max(1, Math.ceil(pts.length / 150)) === 0)]))
const NEIGHBOURS: Record<string, string[]> = {}
const ENCLOSED_BY: Record<string, string[]> = {}
for (const a of COUNTRIES) {
  const cap = capOf.get(a.iso)!
  const enclosers = area.get(a.iso)! > SMALL_KM2 ? [] : COUNTRIES
    .filter(b => b.iso !== a.iso && full.get(b.iso)!.some(p => inRing(p[0], cap.lon, cap.lat))).map(b => b.iso)
  if (enclosers.length) ENCLOSED_BY[a.iso] = enclosers
  const near = new Map<string, { km: number; shared: number }>()
  for (const p of homePts.get(a.iso)!) {
    const cx = Math.floor(p[0] / CELL), cy = Math.floor(p[1] / CELL)
    const best = new Map<string, number>()
    for (let dx = -1; dx <= 1; dx++) for (let dy = -1; dy <= 1; dy++) {
      const wx = ((cx + dx + 180 / CELL) % (360 / CELL) + 360 / CELL) % (360 / CELL) - 180 / CELL
      for (const q of grid.get(`${wx},${cy + dy}`) ?? []) {
        if (q.iso === a.iso) continue
        const km = hav(p, q.p)
        if (km < (best.get(q.iso) ?? Infinity)) best.set(q.iso, km)
      }
    }
    for (const [iso, km] of best) {
      const n = near.get(iso) ?? { km: Infinity, shared: 0 }
      n.km = Math.min(n.km, km)
      if (km < 2) n.shared++
      near.set(iso, n)
    }
  }
  const d = COUNTRIES.filter(b => b.iso !== a.iso && !enclosers.includes(b.iso)).map(b => {
    const n = near.get(b.iso)
    let km: number
    if (n) km = n.km
    else if (Math.min(...[0, -360, 360].map(k => gap(homes.get(a.iso)!.box, shiftBox(homes.get(b.iso)!.box, k)))) <= 25) {
      km = Infinity
      for (const p of sampled.get(a.iso)!) for (const q of sampled.get(b.iso)!) { const x = hav(p, q); if (x < km) km = x }
    } else km = 20000 + hav([cap.lon, cap.lat], [capOf.get(b.iso)!.lon, capOf.get(b.iso)!.lat])
    return { iso: b.iso, km, shared: n?.shared ?? 0 }
  }).sort((x, y) => {
    const bx = x.km < 2, by = y.km < 2
    if (bx !== by) return bx ? -1 : 1
    if (bx) return y.shared - x.shared || (x.iso < y.iso ? -1 : 1)
    return x.km - y.km || (x.iso < y.iso ? -1 : 1)
  })
  NEIGHBOURS[a.iso] = d.slice(0, 8).map(x => x.iso)
}

// ── Write ────────────────────────────────────────────────────────────────────

const asset = { v: 1, src: SOURCE, sha256: NE_SHA256, q: Q, c: out }
const assetPath = path.join(root, 'public/geo/world-50m.json')
fs.writeFileSync(assetPath, JSON.stringify(asset))

const POPULATION = Object.fromEntries(COUNTRIES.map(c => [c.iso, feats.get(c.iso3)!.pop]))
const LAND_KM2 = Object.fromEntries(COUNTRIES.map(c => [c.iso, area.get(c.iso)!]))
const json = (o: unknown) => JSON.stringify(o)
const ts = `// ── Geography map facts, per UN country ──────────────────────────────────────
//
// GENERATED by supabase/geography/build-map.mts from ${SOURCE}.
// Do not edit by hand. Server-side only (imported by lib/geo.ts).
//
//   NEIGHBOURS   the 8 nearest countries, nearest first, by closest approach
//                of their outlines (0 = they share a border). Countries whose
//                shape contains this country's capital are left out.
//   ENCLOSED_BY  those left-out countries (Italy for the Vatican).
//   POPULATION   Natural Earth POP_EST (Somaliland and Northern Cyprus added
//                to Somalia and Cyprus, as on the map).
//   LAND_KM2     area of the country's shapes, km², approximate.
//
// No '@/' imports, so Node can run this file for the generators and checks.

export const MAP_SOURCE = ${json(SOURCE)}
export const NEIGHBOURS: Record<string, string[]> = ${json(NEIGHBOURS)}
export const ENCLOSED_BY: Record<string, string[]> = ${json(ENCLOSED_BY)}
export const POPULATION: Record<string, number> = ${json(POPULATION)}
export const LAND_KM2: Record<string, number> = ${json(LAND_KM2)}
`
fs.writeFileSync(path.join(root, 'lib/geo-map-data.ts'), ts)

const size = fs.statSync(assetPath).size
const gz = (await import('node:zlib')).gzipSync(fs.readFileSync(assetPath), { level: 9 }).length
console.log(`wrote public/geo/world-50m.json: ${out.length} shapes (${out.filter(e => e.i).length} UN), ${vertices} points, ${(size / 1024).toFixed(0)} KB, ${(gz / 1024).toFixed(0)} KB gzipped`)
console.log('wrote lib/geo-map-data.ts')
