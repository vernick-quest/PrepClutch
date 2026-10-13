// Checks the pure parts of Pin the map (lib/geo-pin.ts, lib/geo-map.ts,
// lib/geo.ts buildCountryRound) against the real map. Run:
//
//   node supabase/geography/pin-country-check.mts
//
// Covers: the per-continent accuracy radii re-derived from the map boxes;
// distance points and verdicts; TINY_COUNTRIES re-derived from the map;
// which shape a tap lands in (holes, multipolygons, islands, the sea, the
// 180th meridian); every disputed area found where the map draws it, and
// not found next door; the hit rules (tiny rings, disputed land); country
// rounds (ten different countries of the level's tier, disputed countries
// included); the shades (no neighbours alike); the Pin the map view box.
// Every rule is also tried on a case that MUST fail it (a check that cannot
// fail proves nothing). Exits non-zero on any failure.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import type { MapAsset } from '../../lib/geo-map.ts'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const gm = await import('../../lib/geo-map.ts')
const pin = await import('../../lib/geo-pin.ts')
const geo = await import('../../lib/geo.ts')
const proj = await import('../../lib/geo-projection.ts')

const shapes = gm.decodeAsset(JSON.parse(fs.readFileSync(path.join(root, 'public', gm.MAP_URL), 'utf8')) as MapAsset)
let fails = 0
const check = (name: string, ok: boolean, extra = '') => {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${extra ? '  ' + extra : ''}`)
  if (!ok) fails++
}
const code = (lon: number, lat: number) => gm.tapCode(gm.shapeAt(shapes, lat, lon))
const C = (iso: string) => geo.countryByIso(iso)!
const cap = (iso: string) => ({ iso, lat: C(iso).capitals[0].lat, lon: C(iso).capitals[0].lon })

// ── 1. Accuracy radii, from the map boxes ────────────────────────────────────
{
  const bad: string[] = []
  for (const ct of geo.CONTINENTS) {
    const b = gm.REGION_BOX[ct]
    const diag = proj.haversineKm({ lat: b.s, lon: b.w }, { lat: b.n, lon: b.e })
    const bull = Math.round(diag * pin.PIN_BULL_SHARE / 10) * 10
    const zero = Math.round(diag * pin.PIN_ZERO_SHARE / 50) * 50
    if (pin.PIN_ACCURACY[ct].bull !== bull || pin.PIN_ACCURACY[ct].zero !== zero) bad.push(`${ct}: ${bull}/${zero} from a ${Math.round(diag)} km box`)
  }
  check('PIN_ACCURACY = 0.9% / 11.5% of each region box diagonal (rounded)', !bad.length, bad.join('; '))
}

// ── 2. Distance points and verdicts ──────────────────────────────────────────
{
  const P = (iso: string) => cap(iso)
  const km = (a: string, b: string) => proj.haversineKm(P(a), P(b))
  const ex = [
    ['eu', 'FR', 'BE', 41], ['eu', 'DE', 'CZ', 38], ['eu', 'ES', 'PT', 6], ['af', 'KE', 'UG', 48],
    ['as', 'NP', 'IN', 26], ['sa', 'AR', 'UY', 75], ['na', 'CA', 'US', 8],
  ] as const
  for (const [ct, a, b, want] of ex) {
    const got = pin.distancePoints(ct, km(a, b))
    check(`${C(a).capitals[0].name} pinned on ${C(b).capitals[0].name} (${Math.round(km(a, b))} km, ${ct}) scores ${want}`, got === want, `got ${got}`)
  }
  let mono = true
  for (const ct of geo.CONTINENTS) {
    let last = 101
    for (let k = 0; k <= 2000; k += 5) { const p = pin.distancePoints(ct, k); if (p > last || p < 0 || p > 100) mono = false; last = p }
    const { bull, zero } = pin.PIN_ACCURACY[ct]
    if (pin.distancePoints(ct, bull) !== 100 || pin.distancePoints(ct, bull + 20) >= 100 || pin.distancePoints(ct, zero) !== 0 || pin.distancePoints(ct, zero - 1) !== 0 && pin.distancePoints(ct, zero - 1) > 1) mono = false
  }
  check('points fall from 100 at the bullseye radius to 0 at the zero radius, never rising', mono)
  check('speed bonus only on a scoring pin', pin.pinScore('eu', P('FR'), P('ES'), 1000).points === 0 && pin.pinScore('eu', P('FR'), P('FR'), 1000).points === 110)
  check('verdicts: bullseye, great, close, off, way off, skipped',
    pin.pinVerdict('eu', 10) === 'bull' && pin.pinVerdict('eu', 100) === 'great' && pin.pinVerdict('eu', 200) === 'close' &&
    pin.pinVerdict('eu', 400) === 'off' && pin.pinVerdict('eu', 700) === 'way' && pin.pinVerdict('eu', null) === 'skip')
  check('stars: 499 none, 500 one, 750 two, 900 three', pin.pinStars(499) === 0 && pin.pinStars(500) === 1 && pin.pinStars(750) === 2 && pin.pinStars(900) === 3 && pin.pinStars(1100) === 3)
  check('control: a wrong expected value is caught', pin.distancePoints('eu', km('FR', 'BE')) !== 64)
}

// ── 3. Tiny countries, from the map ──────────────────────────────────────────
{
  const derived = shapes.filter(s => s.iso && s.km2 < pin.TINY_COUNTRY_KM2).map(s => s.iso!).sort()
  check(`TINY_COUNTRIES = the ${derived.length} UN members under ${pin.TINY_COUNTRY_KM2} km2 on the map`, JSON.stringify(derived) === JSON.stringify([...pin.TINY_COUNTRIES].sort()),
    `map: ${derived.join(' ')}`)
  check('control: a planted extra tiny country would be caught', JSON.stringify(derived) !== JSON.stringify([...pin.TINY_COUNTRIES, 'FR'].sort()))
}

// ── 4. Which shape a tap lands in ────────────────────────────────────────────
{
  const SPOTS: [string, number, number, string | null][] = [
    ['Nairobi', 36.82, -1.29, 'KE'],
    ['Maseru, in the hole in South Africa', 27.48, -29.31, 'LS'],
    ['Johannesburg', 28.05, -26.2, 'ZA'],
    ['Jakarta, Java (Indonesia, many islands)', 106.85, -6.2, 'ID'],
    ['Makassar, Sulawesi', 119.43, -5.15, 'ID'],
    ['Jayapura, New Guinea', 140.7, -2.55, 'ID'],
    ['Port Moresby, the other half of New Guinea', 147.18, -9.44, 'PG'],
    ['Anchorage, Alaska', -149.9, 61.22, 'US'],
    ['Reykjavik (an island)', -21.9, 64.13, 'IS'],
    ['Valletta, Malta (tiny island)', 14.51, 35.9, 'MT'],
    ['Palermo, Sicily', 13.36, 38.12, 'IT'],
    ['the Mediterranean', 18, 35, null],
    ['the Atlantic', -30, 30, null],
    ['Chukotka, Russia, west of 180', -175, 66, 'RU'],
    ['Chukotka given as 185 E', 185, 66, 'RU'],
    ['Suva, Fiji', 178.44, -18.14, 'FJ'],
    ['Suva given as -181.56', 178.44 - 360, -18.14, 'FJ'],
    ['Pristina (neutral Kosovo)', 21.17, 42.67, 'KOS'],
    ['inland Greenland (neutral)', -40, 72, 'GRL'],
  ]
  const bad = SPOTS.filter(([, lon, lat, want]) => code(lon, lat) !== want).map(([n, lon, lat, want]) => `${n}: ${code(lon, lat)} not ${want}`)
  check(`shapeAt: ${SPOTS.length} taps land in the right shape (holes, islands, sea, the 180th meridian)`, !bad.length, bad.join('; '))
  check('control: Maseru is not South Africa, the Mediterranean is not Italy', code(27.48, -29.31) !== 'ZA' && code(18, 35) !== 'IT')
}

// ── 5. Disputed areas, where the map draws them ──────────────────────────────
{
  const isos = new Set(geo.COUNTRIES.map(c => c.iso))
  const a3s = new Set(shapes.map(s => s.a3))
  const shapeCodes = new Set(shapes.map(s => s.iso ?? s.a3))
  const badDef = pin.DISPUTED_AREAS.filter(a => !a.claimants.every(c => isos.has(c)) || !shapeCodes.has(a.drawn) ||
    (!isos.has(a.drawn) && !a3s.has(a.drawn)) || (isos.has(a.drawn) && !a.ring) || (a.ring && a.ring.length % 2))
  check('every area: real claimants, drawn on a real shape, a ring for areas inside a UN member', !badDef.length, badDef.map(a => a.key).join(' '))
  // [area, lon, lat]: a place in each, which must be drawn as the area says.
  const IN: [string, number, number][] = [
    ['crimea', 34.1, 44.95], ['crimea', 33.52, 44.6], ['crimea', 36.47, 45.36],
    ['donbas', 37.8, 48.0], ['donbas', 39.3, 48.57], ['zaporizhzhia-kherson', 35.37, 46.85], ['zaporizhzhia-kherson', 32.6, 46.65],
    ['kurils', 147.9, 45.0], ['kurils', 146.7, 43.8], ['golan', 35.75, 33.0], ['palestine', 35.2, 31.9], ['palestine', 34.45, 31.5],
    ['kashmir-in', 74.8, 34.08], ['kashmir-in', 77.58, 34.16], ['kashmir-pk', 73.47, 34.37], ['kashmir-pk', 74.3, 35.92],
    ['kashmir-siachen', 77.1, 35.4], ['aksai-chin', 79.5, 35.2], ['aksai-chin', 76.5, 36.0], ['arunachal', 93.6, 27.1], ['arunachal', 91.86, 27.59],
    ['taiwan', 121.56, 25.03], ['kosovo', 21.17, 42.67], ['western-sahara', -13.2, 27.15], ['essequibo', -59.0, 6.0],
    ['abyei', 28.4, 9.6], ['halaib', 35.8, 22.4], ['falklands', -59.0, -51.7],
  ]
  // Places next door that are NOT in any area: the rings must not swallow them.
  const OUT: [string, number, number][] = [
    ['Moscow', 37.62, 55.75], ['Taman, Russia', 36.72, 45.21], ['Kyiv', 30.52, 50.45], ['Odesa', 30.73, 46.48], ['Kharkiv', 36.23, 49.99],
    ['Sakhalin', 142.7, 46.9], ['Tel Aviv', 34.78, 32.08], ['Tiberias', 35.53, 32.79], ['New Delhi', 77.21, 28.61], ['Pathankot', 75.65, 32.27],
    ['Lahore', 74.34, 31.55], ['Kaghan', 73.6, 34.8], ['Abbottabad', 73.21, 34.17], ['Sialkot', 74.53, 32.49], ['Chitral', 71.8, 35.85], ['Kashgar', 75.99, 39.47], ['Lhasa', 91.11, 29.65],
    ['Guwahati', 91.74, 26.14], ['Georgetown', -58.16, 6.8], ['Cairo', 31.24, 30.04], ['Aswan', 32.9, 24.09], ['Khartoum', 32.53, 15.5],
    ['Belgrade', 20.46, 44.79], ['Rabat', -6.84, 34.02], ['Beijing', 116.4, 39.9], ['Juba', 31.58, 4.85],
  ]
  const missIn = IN.filter(([k, lon, lat]) => pin.disputedAreaAt(code(lon, lat), lat, lon)?.key !== k)
    .map(([k, lon, lat]) => `${k} @${lon},${lat}: map ${code(lon, lat)}, found ${pin.disputedAreaAt(code(lon, lat), lat, lon)?.key ?? 'none'}`)
  check(`${IN.length} places inside disputed areas are found there`, !missIn.length, missIn.join('; '))
  const missOut = OUT.filter(([, lon, lat]) => pin.disputedAreaAt(code(lon, lat), lat, lon)).map(([n]) => n)
  check(`${OUT.length} places next door are in no area`, !missOut.length, missOut.join(', '))
  const tested = new Set(IN.map(x => x[0]))
  const untested = pin.DISPUTED_AREAS.filter(a => !tested.has(a.key) && a.ring).map(a => a.key)
  check('every area drawn inside a UN member has a place tested in it', !untested.length, untested.join(' '))
}

// ── 6. The hit rules ─────────────────────────────────────────────────────────
{
  const tap = (lon: number, lat: number) => ({ code: code(lon, lat), lat, lon })
  const H: [string, string, ReturnType<typeof tap> | null, string | null][] = [
    ['Kenya, tap in Nairobi', 'KE', tap(36.82, -1.29), 'inside'],
    ['Kenya, tap in Tanzania', 'KE', tap(34.9, -6.2), null],
    ['Kenya, tap in the sea', 'KE', tap(45, -5), null],
    ['Kenya, gave up', 'KE', null, null],
    ['Lesotho, tap in Maseru', 'LS', tap(27.48, -29.31), 'inside'],
    ['South Africa, tap in Maseru', 'ZA', tap(27.48, -29.31), null],
    ['Indonesia, tap on New Guinea', 'ID', tap(140.7, -2.55), 'inside'],
    ['Monaco, tap in Nice (France, 15 km)', 'MC', tap(7.27, 43.7), 'ring'],
    ['Monaco, tap in the sea off it', 'MC', tap(7.5, 43.6), 'ring'],
    ['Monaco, tap in Marseille (150 km)', 'MC', tap(5.37, 43.3), null],
    ['Malta, tap in the sea 40 km off', 'MT', tap(14.9, 35.6), 'ring'],
    ['San Marino, tap in Rimini', 'SM', tap(12.57, 44.06), 'ring'],
    ['Italy, tap in Rimini', 'IT', tap(12.57, 44.06), 'inside'],
    ['India, tap in Gilgit (drawn as Pakistan)', 'IN', tap(74.3, 35.92), 'shared'],
    ['India, tap in Aksai Chin (drawn as China)', 'IN', tap(79.5, 35.2), 'shared'],
    ['India, tap on the Siachen (neutral)', 'IN', tap(77.1, 35.4), 'shared'],
    ['Pakistan, tap in Srinagar (drawn as India)', 'PK', tap(74.8, 34.08), 'shared'],
    ['China, tap in Srinagar: not a party there', 'CN', tap(74.8, 34.08), null],
    ['China, tap in Itanagar (drawn as India)', 'CN', tap(93.6, 27.1), 'shared'],
    ['China, tap in New Delhi', 'CN', tap(77.21, 28.61), null],
    ['China, tap in Taipei', 'CN', tap(121.56, 25.03), 'shared'],
    ['Ukraine, tap in Simferopol (drawn as Russia)', 'UA', tap(34.1, 44.95), 'shared'],
    ['Russia, tap in Simferopol', 'RU', tap(34.1, 44.95), 'inside'],
    ['Russia, tap in Donetsk (drawn as Ukraine)', 'RU', tap(37.8, 48.0), 'shared'],
    ['Russia, tap in Kyiv', 'RU', tap(30.52, 50.45), null],
    ['Ukraine, tap on Taman (Russia, over the strait)', 'UA', tap(36.72, 45.21), null],
    ['Poland, tap in Simferopol', 'PL', tap(34.1, 44.95), null],
    ['Japan, tap on Iturup', 'JP', tap(147.9, 45.0), 'shared'],
    ['Syria, tap on the Golan', 'SY', tap(35.75, 33.0), 'shared'],
    ['Syria, tap in Tel Aviv', 'SY', tap(34.78, 32.08), null],
    ['Israel, tap in Ramallah', 'IL', tap(35.2, 31.9), 'shared'],
    ['Jordan, tap in Ramallah', 'JO', tap(35.2, 31.9), null],
    ['Serbia, tap in Pristina', 'RS', tap(21.17, 42.67), 'shared'],
    ['Albania, tap in Pristina', 'AL', tap(21.17, 42.67), null],
    ['Morocco, tap in Laayoune', 'MA', tap(-13.2, 27.15), 'shared'],
    ['Mauritania, tap in Laayoune', 'MR', tap(-13.2, 27.15), null],
    ['Venezuela, tap in Essequibo', 'VE', tap(-59.0, 6.0), 'shared'],
    ['Venezuela, tap in Georgetown', 'VE', tap(-58.16, 6.8), null],
    ['South Sudan, tap in Abyei', 'SS', tap(28.4, 9.6), 'shared'],
    ['Sudan, tap in the Halaib Triangle', 'SD', tap(35.8, 22.4), 'shared'],
    ['Argentina, tap on the Falklands', 'AR', tap(-59.0, -51.7), 'shared'],
    ['Chile, tap on the Falklands', 'CL', tap(-59.0, -51.7), null],
  ]
  const bad = H.filter(([, iso, t, want]) => pin.countryHit(cap(iso), t) !== want)
    .map(([n, iso, t, want]) => `${n}: ${pin.countryHit(cap(iso), t)} not ${want} (map ${t?.code})`)
  check(`${H.length} taps judged right (inside, tiny ring, disputed land, misses)`, !bad.length, bad.join('; '))

  // A tap inside ANOTHER tiny country never counts for a tiny one, ring or not:
  // find a St Vincent island within the ring of Grenada's capital.
  const gd = cap('GD'), vc = shapes.find(s => s.iso === 'VC')!
  let inner: { lat: number; lon: number } | null = null
  for (const r of vc.rings) {
    let x = 0, y = 0
    for (let i = 0; i < r.length; i += 2) { x += r[i]; y += r[i + 1] }
    const c = { lon: x / (r.length / 2), lat: y / (r.length / 2) }
    if (code(c.lon, c.lat) === 'VC' && proj.haversineKm(gd, c) <= pin.COUNTRY_RING_KM) inner = c
  }
  if (inner) {
    check(`Grenada, tap on a St Vincent island ${Math.round(proj.haversineKm(gd, inner))} km away: a miss`, pin.countryHit(gd, { code: 'VC', ...inner }) === null)
    check('control: the same spot as open sea would be in the ring', pin.countryHit(gd, { code: null, ...inner }) === 'ring')
  } else {
    // The map has no St Vincent island that close: check the rule itself.
    const near = { lat: gd.lat + 0.25, lon: gd.lon }
    check('Grenada, a tap reported in St Vincent 28 km away: a miss; the same spot as sea: the ring',
      pin.countryHit(gd, { code: 'VC', ...near }) === null && pin.countryHit(gd, { code: null, ...near }) === 'ring')
  }
  check('points: a find is 100 + speed, a miss 0', pin.countryPoints('inside', 2000) === 110 && pin.countryPoints('shared', 5000) === 105 && pin.countryPoints(null, 1000) === 0)
}

// ── 7. Country rounds ────────────────────────────────────────────────────────
{
  let seedN = 11
  const rnd = () => ((seedN = (seedN * 1103515245 + 12345) % 2147483648) / 2147483648)
  const tiers = geo.pinTiers()
  const problems: string[] = []
  const seen = new Set<string>()
  for (const ct of geo.CONTINENTS) {
    const all = geo.COUNTRIES.filter(c => c.continent === ct && !geo.COUNTRY_NOT_ASKED.has(c.iso))
    for (const l of pin.PIN_LEVELS) {
      for (let k = 0; k < 40; k++) {
        const r = geo.buildCountryRound(ct, l, rnd)
        r.forEach(c => seen.add(c.iso))
        if (r.length !== pin.PIN_ROUND) problems.push(`${ct}:${l} has ${r.length}`)
        if (new Set(r.map(c => c.iso)).size !== r.length) problems.push(`${ct}:${l} repeats a country`)
        if (r.some(c => c.continent !== ct)) problems.push(`${ct}:${l} asks another continent`)
        const own = all.filter(c => tiers.get(c.iso) === l).length
        const mine = r.filter(c => c.tier === l).length
        if (mine !== Math.min(own, pin.PIN_ROUND)) problems.push(`${ct}:${l} asks ${mine} of its own tier, ${own} exist`)
        if (r.some(c => c.tiny !== pin.isTinyCountry(c.iso))) problems.push('tiny flag wrong')
      }
    }
  }
  check('country rounds: 10 different countries of the continent, the level\'s tier first, never repeated', !problems.length, problems.slice(0, 5).join('; '))
  const askable = (i: string) => !geo.COUNTRY_NOT_ASKED.has(i)
  const shouldSee = [...geo.SHAPE_DISPUTED].filter(askable)
  const disputed = shouldSee.filter(i => seen.has(i))
  check(`disputed-border countries are asked too (${disputed.length} of ${shouldSee.length} seen in 720 rounds)`, disputed.length === shouldSee.length, shouldSee.filter(i => !seen.has(i)).join(' '))
  const members = geo.COUNTRIES.filter(c => askable(c.iso)).length
  check(`every UN member but COUNTRY_NOT_ASKED is asked somewhere (${seen.size} of ${members})`, seen.size === members)
  check(`COUNTRY_NOT_ASKED (${[...geo.COUNTRY_NOT_ASKED].join(' ')}) is never asked`, [...geo.COUNTRY_NOT_ASKED].every(i => !seen.has(i)))
}

// ── 8. Shades ────────────────────────────────────────────────────────────────
{
  const adj = gm.shapeNeighbours(shapes)
  const shade = gm.landShades(shapes)
  const clash: string[] = []
  for (const [a, ns] of adj) for (const b of ns) if (a < b && shade.get(a) === shade.get(b)) clash.push(`${a}/${b}`)
  const sizes = (a3: string) => adj.get(a3)?.size ?? 0
  check(`shades: no two of ${adj.size} countries that share a border alike, ${new Set(shade.values()).size} tones`, !clash.length && shade.size === adj.size, clash.join(' '))
  check('neighbours found from shared borders (France 10, Germany 9, Lesotho 1)', sizes('FRA') === 10 && sizes('DEU') === 9 && sizes('LSO') === 1 && adj.get('LSO')!.has('ZAF'))
  const again = gm.landShades(gm.decodeAsset(JSON.parse(fs.readFileSync(path.join(root, 'public', gm.MAP_URL), 'utf8')) as MapAsset))
  check('shades deterministic (same tones from a fresh load)', [...shade].every(([a, s]) => again.get(a) === s))
  check('shades distinct from the neutral fill', !gm.LAND_SHADES.includes(gm.NEUTRAL_FILL))
}

// ── 9. The view box ──────────────────────────────────────────────────────────
{
  const inside = (b: { w: number; s: number; e: number; n: number }, p: { lat: number; lon: number }) => {
    const lon = b.w + ((((p.lon - b.w) % 360) + 360) % 360)
    return lon >= b.w && lon <= b.e && p.lat >= b.s && p.lat <= b.n
  }
  const bad: string[] = []
  for (const ct of geo.CONTINENTS) {
    const R = gm.REGION_BOX[ct]
    for (const l of pin.PIN_LEVELS) for (let k = 0; k < 10; k++) {
      for (const pts of [geo.buildCountryRound(ct, l), geo.buildPinRound(ct, l)]) {
        const b = gm.pinViewBox(ct, pts)
        if (b.w < R.w || b.e > R.e || b.s < R.s || b.n > R.n) bad.push(`${ct}: box past the region`)
        for (const p of pts) if (!inside(b, p)) bad.push(`${ct}: ${p.lat},${p.lon} outside the view`)
      }
    }
  }
  check('Pin the map opens on a box that shows every asked place and stays inside the region', !bad.length, [...new Set(bad)].slice(0, 5).join('; '))
  const eu = gm.pinViewBox('eu', [cap('FR'), cap('DE')])
  check('Europe opens tighter than its region when the round allows', eu.e - eu.w < gm.REGION_BOX.eu.e - gm.REGION_BOX.eu.w)
}

// ── Coastlines: a tap just off a coast is that coast ────────────────────────
{
  // A tap on every asked country's capital finds it, even the ones the
  // 1:50m coastline leaves in the sea (Lisbon, Stockholm, Dakar ...).
  const askable = geo.COUNTRIES.filter(c => !geo.COUNTRY_NOT_ASKED.has(c.iso))
  const offshore = askable.filter(c => !gm.shapeAt(shapes, cap(c.iso).lat, cap(c.iso).lon))
  const lost = askable.filter(c => {
    const t = cap(c.iso)
    const code = gm.tapCode(gm.shapeNear(shapes, t.lat, t.lon, c.iso))
    return !pin.countryHit({ iso: c.iso, lat: t.lat, lon: t.lon }, { code, lat: t.lat, lon: t.lon })
  })
  check(`a tap on the capital finds every asked country (${offshore.length} capitals are off the drawn coast)`, !lost.length, lost.map(c => c.iso).join(' '))
  const near = (lat: number, lon: number, prefer?: string) => gm.tapCode(gm.shapeNear(shapes, lat, lon, prefer))
  check('a sea tap 10 km off Lisbon is Portugal', near(38.72, -9.25, 'PT') === 'PT')
  check('a sea tap 10 km off Lisbon is Portugal even when asked for Spain', near(38.72, -9.25, 'ES') === 'PT')
  check('a tap 60 km out to sea off Lisbon is the sea', near(38.72, -9.85, 'PT') === null)
  check('the middle of the Atlantic is the sea', near(30, -40, 'PT') === null)
  check('a tap on land is that land whatever was asked', near(48.86, 2.35, 'DE') === 'FR')
}

console.log(fails ? `\n${fails} FAILED` : '\nall passed')
process.exit(fails ? 1 : 0)
