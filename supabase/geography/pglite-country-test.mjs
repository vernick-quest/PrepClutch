// PGlite run of migration 073 (Pin the map: find the country, places scored
// on each continent's scale, the rescore of old places rounds) on top of
// 062-072, against the same stub of the Supabase schema as
// pglite-map-test.mjs (auth.users, auth.uid(), profiles with is_admin, roles
// anon and authenticated, Supabase's default grants to both on every new
// table and function).
//
// PGlite is not a dependency of the app. Install it OUTSIDE the repo:
//
//   mkdir /tmp/geo-pglite && cd /tmp/geo-pglite && npm i @electric-sql/pglite@0.2
//   cp <repo>/supabase/geography/pglite-country-test.mjs run-country.mjs
//   REPO=<repo> node run-country.mjs          (MIGRATION=073_geo_pin_countries.sql)
//
// Covers: old-style places rounds saved by 070's function, then 073 first
// run and re-run inside BEGIN/COMMIT; the rescore (exact new scores, km/ms
// kept, idempotent, country and Explorer Points untouched); TS-vs-SQL
// parity of the accuracy rule, the ring test, the tiny list and every
// disputed area; new places rounds scored exactly as lib/geo-pin.ts;
// country rounds scored exactly as lib/geo-pin.ts countryHit (hits, misses,
// the sea, give-ups, speed bonus, tiny rings, tiny-on-tiny, disputed land);
// refusals; privileges and RLS; the percentile. Every expected number is
// derived from lib/ or from the data, never typed in.
import { PGlite } from '@electric-sql/pglite'
import fs from 'node:fs'

const REPO = process.env.REPO ?? '/Users/robert/PrepClutch'
const MIG = process.env.MIGRATION ?? '073_geo_pin_countries.sql'
await import(`${REPO}/supabase/geography/ts-resolve.mts`)
const read = f => fs.readFileSync(`${REPO}/supabase/migrations/${f}`, 'utf8')
const SQL = read(MIG)
const geo = await import(`${REPO}/lib/geo.ts`)
const pin = await import(`${REPO}/lib/geo-pin.ts`)
const gm = await import(`${REPO}/lib/geo-map.ts`)
const proj = await import(`${REPO}/lib/geo-projection.ts`)
const shapes = gm.decodeAsset(JSON.parse(fs.readFileSync(`${REPO}/public${gm.MAP_URL}`, 'utf8')))
const codeAt = (lat, lon) => gm.tapCode(gm.shapeAt(shapes, lat, lon))

const A = '11111111-1111-1111-1111-111111111111'   // student
const B = '22222222-2222-2222-2222-222222222222'   // student
const D = '44444444-4444-4444-4444-444444444444'   // admin
const E = '55555555-5555-5555-5555-555555555555'   // played places before 073

let fails = 0
const check = (name, ok, extra = '') => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${extra ? '  ' + extra : ''}`); if (!ok) fails++ }

const db = new PGlite()
await db.exec(`
  CREATE ROLE anon; CREATE ROLE authenticated;
  GRANT USAGE ON SCHEMA public TO anon, authenticated;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO anon, authenticated;
  CREATE SCHEMA auth; CREATE TABLE auth.users(id uuid primary key);
  CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('t.uid', true), '')::uuid $$;
  GRANT USAGE ON SCHEMA auth TO anon, authenticated; GRANT EXECUTE ON FUNCTION auth.uid() TO anon, authenticated;
  CREATE TABLE profiles(id uuid primary key references auth.users(id), display_name text, avatar_color text,
    avatar_url text, class_code text, is_admin boolean not null default false);
  CREATE TABLE achievement_definitions(id serial, key text unique not null, label text not null, description text not null,
    icon_emoji text not null, threshold int not null default 1, lore text not null default '', creature text not null default '',
    rarity text, category text);
  CREATE TABLE user_achievements(user_id uuid not null references profiles(id), achievement_key text not null
    references achievement_definitions(key), earned_at timestamptz not null default now(), primary key (user_id, achievement_key));
  GRANT SELECT ON profiles, achievement_definitions, user_achievements TO authenticated;
  INSERT INTO auth.users VALUES ('${A}'), ('${B}'), ('${D}'), ('${E}');
  INSERT INTO profiles VALUES ('${A}','Ana','#f00',null,'X1',false), ('${B}','Ben','#0f0',null,'X1',false),
                              ('${D}','Dee','#fff',null,'',true), ('${E}','Eve','#ff0',null,'',false);
`)

const as = async (uid, role = 'authenticated') => {
  await db.exec(`RESET ROLE; SELECT set_config('t.uid', '${uid ?? ''}', false); SET ROLE ${role}`)
}
const su = () => db.exec(`RESET ROLE; SELECT set_config('t.uid', '', false)`)
const refused = async (uid, role, sql, params = []) => {
  let err = ''
  try { await as(uid, role); await db.query(sql, params) } catch (e) { err = e.message } finally { await su() }
  return err
}
const call = async (uid, sql, params) => { await as(uid); try { return (await db.query(sql, params)).rows[0] } finally { await su() } }
const placeRound = (u, deck, pins) => call(u, 'SELECT record_geo_pin_round($1, $2::jsonb) AS s', [deck, JSON.stringify(pins)]).then(r => r.s)
const countryRound = (u, deck, pins) => call(u, 'SELECT record_geo_country_round($1, $2::jsonb) AS s', [deck, JSON.stringify(pins)]).then(r => r.s)

// ── 0. 062-072, as live ──────────────────────────────────────────────────────
for (const f of ['062_math_facts', '063_math_facts_badges', '064_math_facts_topics', '065_home_track', '066_flawless_ten',
                 '067_math_facts_ladders', '068_fact_rounds', '069_geography', '070_geography_map', '071_repair_geo_text',
                 '072_geo_continent_ladders']) {
  await db.exec('BEGIN;\n' + read(`${f}.sql`) + '\nCOMMIT;')
}
check('062-072 applied on the stub', true)
await as(A); await db.query(`SELECT record_geo_answer('cap:fr', true, 1500)`); await su()

// ── 1. Places rounds saved under 070's rings ─────────────────────────────────
const PLACES = geo.pinPlaces()
let seedN = 5
const rnd = () => ((seedN = (seedN * 1103515245 + 12345) % 2147483648) / 2147483648)
const jitter = (p, spread) => ({ lat: Math.max(-89, Math.min(89, p.lat + (rnd() - 0.5) * spread)), lon: Math.max(-180, Math.min(180, p.lon + (rnd() - 0.5) * spread)) })
const oldRounds = []
for (const ct of geo.CONTINENTS) {
  for (let k = 0; k < 3; k++) {
    const ps = geo.buildPinRound(ct, 1 + k, rnd)
    const pins = ps.map(p => {
      if (rnd() < 0.1) return { i: p.key, lat: null, lon: null, ms: 4000 }
      return { i: p.key, ...jitter(p, [0.2, 1, 3, 6, 12][Math.floor(rnd() * 5)]), ms: Math.floor(rnd() * 9000) }
    })
    const old = await placeRound(E, `${ct}:${1 + k}`, pins)
    const ts070 = pins.reduce((s, x, j) => s + pin.pinScore070(ps[j], x.lat === null ? null : x, x.ms).points, 0)
    oldRounds.push({ ct, old, ts070 })
  }
}
check(`before 073: ${oldRounds.length} places rounds saved with 070's rings (as lib/geo-pin.ts pinScore070)`, oldRounds.every(r => r.old === r.ts070))
// One more, hand-made, with known km and ms at the rule's edges.
const EDGE = [[0, 2000], [50, 2000], [51, 2000], [264, 5000], [264, 7000], [649, 1000], [650, 1000], [1200, 1000], [null, 4000], [130, 3001]]
const edgeAnswers = EDGE.map(([km, ms], j) => ({ i: `cap:${['fr', 'de', 'es', 'it', 'pl', 'nl', 'be', 'pt', 'at', 'ch'][j]}`, km, ms, p: 7 }))
await db.query(`INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES ($1, 'eu:2', 70, $2::jsonb)`, [E, JSON.stringify(edgeAnswers)])
const edgeExpect = EDGE.map(([km, ms]) => (km === null ? 0 : (() => { const d = pin.distancePoints('eu', km); return d + (d > 0 ? pin.speedBonus(ms) : 0) })()))
const before = (await db.query(`SELECT id, deck, score, answers FROM geo_pin_rounds ORDER BY completed_at, id`)).rows
const histBefore = JSON.stringify((await db.query('SELECT * FROM geo_history ORDER BY user_id, card_key')).rows)

// ── 2. 073, first run and re-run ─────────────────────────────────────────────
let res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
const v1 = res.at(-2).rows[0]
console.log('verification (first run):', JSON.stringify(v1))
const expect = {
  new_functions: 6, tiny_countries: pin.TINY_COUNTRIES.length, disputed_areas: pin.DISPUTED_AREAS.length,
  capitals: PLACES.filter(p => p.kind === 'capital').length, place_rounds: before.length, stale_place_pins: 0, score_mismatches: 0,
  country_callable_by_anon: false, country_callable_by_students: true, percentile_callable_by_anon: false,
  helpers_callable_by_students: false, areas_readable_by_students: false, pin_insert_by_students: false,
}
check('first run: verification as expected', Object.entries(expect).every(([k, v]) => Number.isInteger(v) ? Number(v1[k]) === v : v1[k] === v), JSON.stringify(expect))
const after1 = (await db.query(`SELECT id, deck, score, answers FROM geo_pin_rounds ORDER BY completed_at, id`)).rows
res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
check('re-run: identical verification', JSON.stringify(res.at(-2).rows[0]) === JSON.stringify(v1))
{
  const empty = (await call(A, 'SELECT geo_pin_percentile($1, $2) AS j', ['oc:2:country', 500])).j
  check('percentile: a deck nobody has played says 0 rounds', empty.rounds === 0 && empty.better_than_pct === 0, JSON.stringify(empty))
}
check('re-run: the rescore changed nothing the second time',JSON.stringify((await db.query(`SELECT id, deck, score, answers FROM geo_pin_rounds ORDER BY completed_at, id`)).rows) === JSON.stringify(after1))

// ── 3. The rescore ───────────────────────────────────────────────────────────
{
  let exact = true, kept = true, detail = ''
  for (const [n, b] of before.entries()) {
    const a = after1[n]
    const ct = b.deck.split(':')[0]
    const want = b.answers.map(x => (x.km === null ? 0 : (() => { const d = pin.distancePoints(ct, Number(x.km)); return d + (d > 0 ? pin.speedBonus(x.ms) : 0) })()))
    if (a.score !== want.reduce((s, x) => s + x, 0) || a.answers.some((x, j) => x.p !== want[j])) { exact = false; detail += ` ${b.deck}: ${a.score} vs ${want.reduce((s, x) => s + x, 0)}` }
    if (a.answers.some((x, j) => x.i !== b.answers[j].i || x.km !== b.answers[j].km || x.ms !== b.answers[j].ms)) kept = false
  }
  check(`rescore: all ${before.length} old rounds rescored exactly as lib/geo-pin.ts on their stored km and ms`, exact, detail)
  check('rescore: place, km and ms of every pin kept, in order', kept)
  const edge = after1.find(r => r.deck === 'eu:2' && r.score !== null && r.answers[0].i === 'cap:fr' && r.answers.length === EDGE.length && r.answers[1].km === 50)
  check(`rescore: hand-made edge round = ${edgeExpect.join('+')} = ${edgeExpect.reduce((s, x) => s + x, 0)}`,
    edge && edge.score === edgeExpect.reduce((s, x) => s + x, 0) && edge.answers.every((x, j) => x.p === edgeExpect[j]), JSON.stringify(edge?.answers.map(x => x.p)))
  check('rescore: geo_history untouched', JSON.stringify((await db.query('SELECT * FROM geo_history ORDER BY user_id, card_key')).rows) === histBefore)
  const changed = before.filter((b, n) => b.score !== after1[n].score).length
  console.log(`      (${changed} of ${before.length} old rounds changed score; ${before.filter((b, n) => after1[n].score < b.score).length} went down)`)
}

// ── 4. Parity of the rules ───────────────────────────────────────────────────
{
  const rows = []
  for (const ct of geo.CONTINENTS) for (let km = 0; km <= 1600; km += 3.7) for (const ms of [null, -1, 2500, 3000, 3001, 6000, 6001]) rows.push([ct, km, ms])
  await db.exec(`CREATE TEMP TABLE probe(ct text, km double precision, ms int)`)
  await db.query(`INSERT INTO probe SELECT * FROM jsonb_to_recordset($1::jsonb) AS x(ct text, km double precision, ms int)`, [JSON.stringify(rows.map(([ct, km, ms]) => ({ ct, km, ms })))])
  const sq = (await db.query(`SELECT ct, km, ms, geo_pin_points(ct, km, ms) AS p FROM probe`)).rows
  const bad = sq.filter(r => { const d = pin.distancePoints(r.ct, r.km); return r.p !== d + (d > 0 ? pin.speedBonus(r.ms) : 0) })
  check(`parity: geo_pin_points = lib/geo-pin.ts on ${sq.length} (continent, km, ms) probes`, sq.length === rows.length && !bad.length, JSON.stringify(bad.slice(0, 3)))
  const tiny = (await db.query(`SELECT geo_pin_tiny_isos() AS t`)).rows[0].t
  check(`parity: the ${tiny.length} tiny countries = TINY_COUNTRIES`, JSON.stringify(tiny) === JSON.stringify(pin.TINY_COUNTRIES))
  const areas = (await db.query(`SELECT area_key, name, drawn, claimants, ring FROM geo_disputed_areas ORDER BY area_key`)).rows
  const tsAreas = [...pin.DISPUTED_AREAS].sort((x, y) => (x.key < y.key ? -1 : 1))
    .map(a => ({ area_key: a.key, name: a.name, drawn: a.drawn, claimants: a.claimants, ring: a.ring ?? null }))
  check(`parity: the ${areas.length} disputed areas = DISPUTED_AREAS (key, name, drawn, claimants, ring)`, JSON.stringify(areas) === JSON.stringify(tsAreas))
  // The ring test on random points around every ring.
  const pts = []
  for (const a of pin.DISPUTED_AREAS.filter(a => a.ring)) {
    const xs = a.ring.filter((_, i) => i % 2 === 0), ys = a.ring.filter((_, i) => i % 2 === 1)
    for (let k = 0; k < 60; k++) pts.push({ key: a.key, lon: Math.min(...xs) - 0.5 + rnd() * (Math.max(...xs) - Math.min(...xs) + 1), lat: Math.min(...ys) - 0.5 + rnd() * (Math.max(...ys) - Math.min(...ys) + 1) })
  }
  const ringSq = (await db.query(`SELECT x.key, x.lon, x.lat, geo_in_ring(x.lon, x.lat, a.ring) AS inside
    FROM jsonb_to_recordset($1::jsonb) AS x(key text, lon double precision, lat double precision) JOIN geo_disputed_areas a ON a.area_key = x.key`, [JSON.stringify(pts)])).rows
  const ringBad = ringSq.filter(r => r.inside !== pin.inFlatRing(pin.DISPUTED_AREAS.find(a => a.key === r.key).ring, r.lon, r.lat))
  check(`parity: geo_in_ring = inFlatRing on ${ringSq.length} points (${ringSq.filter(r => r.inside).length} inside)`, ringSq.length === pts.length && !ringBad.length && ringSq.some(r => r.inside) && ringSq.some(r => !r.inside))
}

// ── 5. New places rounds ─────────────────────────────────────────────────────
{
  let ok = true, detail = '', n = 0
  for (const ct of geo.CONTINENTS) for (let k = 0; k < 4; k++) {
    const ps = geo.buildPinRound(ct, 1 + (k % 3), rnd)
    const pins = ps.map(p => (rnd() < 0.1 ? { i: p.key, lat: null, lon: null, ms: 3000 } : { i: p.key, ...jitter(p, [0.2, 1, 3, 6, 12][Math.floor(rnd() * 5)]), ms: Math.floor(rnd() * 9000) }))
    const ts = pins.reduce((s, x, j) => s + pin.pinScore(ct, ps[j], x.lat === null ? null : x, x.ms).points, 0)
    const sq = await placeRound(A, `${ct}:${1 + (k % 3)}`, pins)
    n++
    if (ts !== sq) { ok = false; detail += ` ${ct}: ts ${ts} sql ${sq}` }
  }
  check(`places: SQL score = lib/geo-pin.ts pinScore on ${n} random built rounds`, ok, detail)
  const eu = PLACES.filter(p => p.continent === 'eu').slice(0, 10).map(p => ({ i: p.key, lat: p.lat, lon: p.lon, ms: 2000 }))
  check(`places: ten bullseyes in 2 s = ${pin.MAX_PIN_SCORE}`, (await placeRound(A, 'eu:1', eu)) === pin.MAX_PIN_SCORE)
  check('places: still refuses a pin off the map', (await refused(A, 'authenticated', 'SELECT record_geo_pin_round($1, $2::jsonb)', ['eu:1', JSON.stringify([...eu.slice(0, 9), { ...eu[9], lat: 95 }])])) !== '')
  check('places: still refuses a country deck', /unknown pin deck/.test(await refused(A, 'authenticated', 'SELECT record_geo_pin_round($1, $2::jsonb)', ['eu:1:country', JSON.stringify(eu)])))
}

// ── 6. Country rounds ────────────────────────────────────────────────────────
const cap = iso => { const c = geo.countryByIso(iso); return { iso, lat: c.capitals[0].lat, lon: c.capitals[0].lon } }
const tsCountry = pins => pins.map(p => {
  const how = pin.countryHit(cap(p.iso), p.lat === null ? null : { code: p.tap, lat: p.lat, lon: p.lon })
  return { h: !!how, how, p: pin.countryPoints(how, p.ms) }
})
const stored = async (u, deck) => (await db.query(`SELECT answers, score FROM geo_pin_rounds WHERE user_id = $1 AND deck = $2 ORDER BY completed_at DESC LIMIT 1`, [u, deck])).rows[0]
const tapAt = (iso, lat, lon, ms) => ({ iso, tap: codeAt(lat, lon), lat, lon, ms })
const inEurope = iso => geo.countryByIso(iso).continent === 'eu'

// A hand-made Europe round with every kind of answer, judged by the TS first.
{
  const mc = cap('MC'), mt = cap('MT')
  const pins = [
    { ...tapAt('FR', 48.86, 2.35, 2000) },                       // inside, fast: 110
    { ...tapAt('DE', 52.52, 13.4, 5000) },                       // inside, +5: 105
    { ...tapAt('ES', 38.57, -7.91, 1000) },                      // Evora: Portugal, a miss
    { ...tapAt('IT', 39.0, 18.0, 1000) },                        // the sea: a miss
    { iso: 'PL', tap: null, lat: null, lon: null, ms: 4000 },    // gave up
    { ...tapAt('MC', 43.7, 7.27, 2000) },                        // Nice, France: in Monaco's ring
    { ...tapAt('MT', 35.6, 14.9, 7000) },                        // the sea 40 km off Malta: ring, no bonus
    { ...tapAt('SM', 44.06, 12.57, 2500) },                      // Rimini: in San Marino's ring
    { iso: 'LI', tap: 'CH', lat: 47.14 - 0.1, lon: 9.52, ms: 2000 },   // Switzerland next to Vaduz: ring
    { ...tapAt('UA', 44.95, 34.1, 2000) },                       // Simferopol (drawn as Russia): disputed, right
  ]
  const ts = tsCountry(pins)
  const want = ts.reduce((s, x) => s + x.p, 0)
  const got = await countryRound(A, 'eu:3:country', pins)
  const row = await stored(A, 'eu:3:country')
  check(`country: hand-made Europe round = ${ts.map(x => x.p).join('+')} = ${want} (TS)`, got === want && row.score === want, `sql ${got}`)
  check('country: every pin judged as the TS judges it (inside, ring, shared, misses, sea, give-up)',
    row.answers.every((x, j) => x.h === ts[j].h && x.p === ts[j].p && x.i === pins[j].iso && x.t === pins[j].tap), JSON.stringify(row.answers.map(x => [x.i, x.t, x.p])))
  const kinds = ts.map(x => x.how)
  check('country: the round really has each case', ['inside', 'ring', 'shared', null].every(k => kinds.includes(k)) && pins[3].tap === null && pins[2].tap === 'PT' && pins[9].tap === 'RU' && pins[5].tap === 'FR',
    JSON.stringify(kinds))
  check(`country: ring hits really are within ${pin.COUNTRY_RING_KM} km`, proj.haversineKm(mc, pins[5]) < pin.COUNTRY_RING_KM && proj.haversineKm(mt, pins[6]) < pin.COUNTRY_RING_KM)
  check('country: all ten were Europe', pins.every(p => inEurope(p.iso)))
}
// Tiny-on-tiny: a tap inside another tiny country is a miss even inside the ring.
{
  const pins = ['MC', 'FR', 'DE', 'ES', 'IT', 'PL', 'NL', 'BE', 'PT', 'AT'].map(iso => ({ ...cap(iso), tap: iso, ms: 9000 }))
  const mc = cap('MC')
  pins[0] = { iso: 'MC', tap: 'SM', lat: mc.lat + 0.1, lon: mc.lon, ms: 2000 }           // 11 km off, but "in San Marino"
  pins.forEach(p => { delete p.iso2 })
  const want = tsCountry(pins).reduce((s, x) => s + x.p, 0)
  check(`country: a tap reported in another tiny country is a miss inside the ring (${want} = 9 x 100)`, (await countryRound(B, 'eu:1:country', pins)) === want && want === 900)
}
// Disputed land in Asia: India found in Pakistan-drawn Kashmir; China not in Indian-drawn Srinagar.
{
  const isos = ['IN', 'PK', 'CN', 'JP', 'SY', 'IL', 'ID', 'TH', 'VN', 'KR']
  const pins = isos.map(iso => ({ iso, tap: null, lat: null, lon: null, ms: 1000 }))
  pins[0] = tapAt('IN', 35.92, 74.3, 2000)       // Gilgit, drawn as PK: right
  pins[1] = tapAt('PK', 34.08, 74.8, 2000)       // Srinagar, drawn as IN: right
  pins[2] = tapAt('CN', 34.08, 74.8, 2000)       // Srinagar for China: not a party, a miss
  pins[3] = tapAt('JP', 45.0, 147.9, 4000)       // Iturup, drawn as RU: right
  pins[4] = tapAt('SY', 33.0, 35.75, 7000)       // the Golan, drawn as IL: right, no bonus
  pins[5] = tapAt('IL', 31.9, 35.2, 2000)        // Ramallah, neutral Palestine: right
  pins[6] = tapAt('ID', -2.55, 140.7, 2000)      // New Guinea: inside a multipolygon
  pins[7] = tapAt('TH', 31.55, 74.34, 2000)      // Lahore for Thailand: a miss
  const ts = tsCountry(pins)
  const want = ts.reduce((s, x) => s + x.p, 0)
  check(`country: Asia round with disputed land = ${ts.map(x => x.p).join('+')} = ${want} (TS)`, (await countryRound(B, 'as:1:country', pins)) === want,
    JSON.stringify(ts.map(x => x.how)))
  check('country: the disputed cases are what they claim', pins[0].tap === 'PK' && pins[1].tap === 'IN' && pins[3].tap === 'RU' && pins[4].tap === 'IL' && pins[5].tap === 'PSX' &&
    ts[0].how === 'shared' && ts[2].how === null && ts[5].how === 'shared')
}
// Random country rounds: taps near the capital, scored exactly as the TS.
{
  let ok = true, n = 0, detail = '', hits = 0
  for (const ct of geo.CONTINENTS) for (const l of pin.PIN_LEVELS) {
    const cs = geo.buildCountryRound(ct, l, rnd)
    const pins = cs.map(c => {
      if (rnd() < 0.1) return { iso: c.iso, tap: null, lat: null, lon: null, ms: 2000 }
      const t = jitter(c, [0.05, 0.5, 2, 6][Math.floor(rnd() * 4)])
      return { iso: c.iso, tap: codeAt(t.lat, t.lon), lat: t.lat, lon: t.lon, ms: Math.floor(rnd() * 9000) }
    })
    const ts = tsCountry(pins)
    hits += ts.filter(x => x.h).length
    const sq = await countryRound(A, `${ct}:${l}:country`, pins)
    n++
    if (sq !== ts.reduce((s, x) => s + x.p, 0)) { ok = false; detail += ` ${ct}:${l}` }
  }
  check(`country: SQL = lib/geo-pin.ts on ${n} random built rounds (${hits} finds)`, ok && hits > 0, detail)
}
// Refusals.
{
  const good = ['FR', 'DE', 'ES', 'IT', 'PL', 'NL', 'BE', 'PT', 'AT', 'CH'].map(iso => ({ ...cap(iso), tap: iso, ms: 2000 }))
  const BAD = [
    ['a places deck', 'eu:1', good],
    ['an unknown continent', 'xx:1:country', good],
    ['level 4', 'eu:4:country', good],
    ['9 countries', 'eu:1:country', good.slice(0, 9)],
    ['11 countries', 'eu:1:country', [...good, { ...cap('SE'), tap: 'SE', ms: 1 }]],
    ['a country twice', 'eu:1:country', [...good.slice(0, 9), good[0]]],
    ['a country of another continent', 'eu:1:country', [...good.slice(0, 9), { ...cap('KE'), tap: 'KE', ms: 1 }]],
    ['not a country', 'eu:1:country', [...good.slice(0, 9), { iso: 'XX', tap: 'XX', lat: 0, lon: 0, ms: 1 }]],
    ['a latitude off the map', 'eu:1:country', [...good.slice(0, 9), { ...good[9], lat: 95 }]],
    ['a longitude off the map', 'eu:1:country', [...good.slice(0, 9), { ...good[9], lon: 200 }]],
    ['half a tap', 'eu:1:country', [...good.slice(0, 9), { ...good[9], lon: null }]],
    ['a tapped country with no tap', 'eu:1:country', [...good.slice(0, 9), { ...good[9], lat: null, lon: null }]],
    ['a lower-case tap', 'eu:1:country', [...good.slice(0, 9), { ...good[9], tap: 'ch' }]],
    ['a four-letter tap', 'eu:1:country', [...good.slice(0, 9), { ...good[9], tap: 'CHEE' }]],
    ['not an array', 'eu:1:country', { a: 1 }],
  ]
  const nBefore = (await db.query(`SELECT COUNT(*)::int n FROM geo_pin_rounds`)).rows[0].n
  for (const [what, deck, pins] of BAD) {
    const err = await refused(A, 'authenticated', 'SELECT record_geo_country_round($1, $2::jsonb)', [deck, JSON.stringify(pins)])
    check(`country: refused with ${what}`, err !== '', err.slice(0, 70))
  }
  check('country: the good round itself is accepted (so the refusals are about what changed)', (await countryRound(A, 'eu:1:country', good)) === 1100)
  check('country: refused rounds saved nothing', (await db.query(`SELECT COUNT(*)::int n FROM geo_pin_rounds`)).rows[0].n === nBefore + 1)
  check('country: anon cannot record a round', /permission denied/.test(await refused(null, 'anon', 'SELECT record_geo_country_round($1, $2::jsonb)', ['eu:1:country', JSON.stringify(good)])))
  check('country: signed-out (no uid) cannot record a round', /requires a signed-in user/.test(await refused(null, 'authenticated', 'SELECT record_geo_country_round($1, $2::jsonb)', ['eu:1:country', JSON.stringify(good)])))
  check('country: the app\'s readiness probe gets a refusal, not a missing function', /unknown pin deck/.test(await refused(A, 'authenticated', `SELECT record_geo_country_round('probe', '[]'::jsonb)`)))
}

// ── 7. Privileges ────────────────────────────────────────────────────────────
for (const [what, stmt] of [
  ['insert a round directly', `INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES ('${A}', 'eu:1:country', 1100, '[]')`],
  ['update a round', `UPDATE geo_pin_rounds SET score = 1100`],
  ['read the disputed areas', `SELECT * FROM geo_disputed_areas`],
  ['change a disputed area', `UPDATE geo_disputed_areas SET claimants = ARRAY['FR']`],
  ['call geo_pin_points', `SELECT geo_pin_points('eu', 0, 0)`],
  ['call geo_pin_speed', `SELECT geo_pin_speed(0)`],
  ['call geo_in_ring', `SELECT geo_in_ring(0, 0, ARRAY[0,0,1,0,1,1]::float8[])`],
  ['call geo_pin_tiny_isos', `SELECT geo_pin_tiny_isos()`],
]) check(`student cannot ${what}`, /permission denied/.test(await refused(A, 'authenticated', stmt)), stmt.slice(0, 50))
check('anon cannot call geo_pin_percentile', /permission denied/.test(await refused(null, 'anon', `SELECT geo_pin_percentile('eu:1', 500)`)))
check('anon cannot call geo_pin_points', /permission denied/.test(await refused(null, 'anon', `SELECT geo_pin_points('eu', 0, 0)`)))

// ── 8. Percentile and leaderboard ────────────────────────────────────────────
{
  const deck = 'eu:1:country'
  const scores = (await db.query(`SELECT id, user_id, score, completed_at FROM geo_pin_rounds WHERE deck = $1 ORDER BY completed_at DESC`, [deck])).rows
  const latestA = scores.find(r => r.user_id === A)
  const others = scores.filter(r => r.id !== latestA.id)
  const probe = 950
  const got = (await call(A, 'SELECT geo_pin_percentile($1, $2) AS j', [deck, probe])).j
  const want = { rounds: others.length, better_than_pct: others.length ? Math.floor(100 * others.filter(r => r.score < probe).length / others.length) : 0 }
  check(`percentile: ${JSON.stringify(got)} over the ${others.length} rounds on ${deck} other than A's latest`, got.rounds === want.rounds && got.better_than_pct === want.better_than_pct && others.length > 0, JSON.stringify(want))
  check('percentile: refuses an unknown deck', /unknown pin deck/.test(await refused(A, 'authenticated', `SELECT geo_pin_percentile('zz:1', 1)`)))
  // The admin has played nothing: every round on the deck counts.
  const sa = (await db.query(`SELECT score FROM geo_pin_rounds WHERE deck = 'sa:3'`)).rows
  const dGot = (await call(D, 'SELECT geo_pin_percentile($1, $2) AS j', ['sa:3', 500])).j
  check(`percentile: someone with no round there gets all ${sa.length} rounds`, sa.length > 0 && dGot.rounds === sa.length &&
    dGot.better_than_pct === Math.floor(100 * sa.filter(r => r.score < 500).length / sa.length), JSON.stringify(dGot))
  const lb = (await db.query(`SELECT deck, COUNT(*)::int n FROM geo_pin_leaderboard_view WHERE deck LIKE 'eu:1%' GROUP BY deck ORDER BY deck`)).rows
  check('leaderboard: country decks have their own boards', lb.some(r => r.deck === 'eu:1') && lb.some(r => r.deck === 'eu:1:country'), JSON.stringify(lb))
}

// ── 9. Re-run after play ─────────────────────────────────────────────────────
{
  const snap = async () => JSON.stringify((await db.query(`SELECT id, score, answers FROM geo_pin_rounds ORDER BY id`)).rows)
  const s0 = await snap()
  await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
  check('re-run after play: no round changes (new ones are already on the new rule)', (await snap()) === s0)
}

console.log(fails ? `\n${fails} FAILED` : '\nALL PASSED')
process.exit(fails ? 1 : 0)
