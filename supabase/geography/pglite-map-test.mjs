// PGlite run of the Geography map migration (070_geography_map.sql) on top
// of 062-069, against the same stub of the Supabase schema as
// pglite-test.mjs (auth.users, auth.uid(), profiles with is_admin,
// achievement_definitions, user_achievements, roles anon and authenticated,
// Supabase's default grants to both on every new table and function).
//
// PGlite is not a dependency of the app. Install it OUTSIDE the repo:
//
//   mkdir /tmp/geo-pglite && cd /tmp/geo-pglite && npm i @electric-sql/pglite@0.2
//   cp <repo>/supabase/geography/pglite-map-test.mjs run-map.mjs
//   REPO=<repo> node run-map.mjs            (MIGRATION=070_geography_map.sql once numbered)
//
// Covers: 062-069 then the map migration, first run and re-run inside
// BEGIN/COMMIT; 069's cards byte-equal before and after (and a planted 070
// row with a 069 key cannot change one); existing history and badges
// untouched; TS-vs-SQL parity of the whole catalogue (shape and city cards)
// and of every pin place (capitals and cities); shape and city cards scored
// exactly like 069 cards; the award function is 069's plus the shapes and
// cities rungs; new badges with negative cases; Pin the map scoring parity
// with lib/geo-pin.ts on real mixed capital/city rounds, refusals,
// privileges and RLS. Every expected count is derived from lib/ or the
// generated SQL, never typed in.
import { PGlite } from '@electric-sql/pglite'
import fs from 'node:fs'

const REPO = process.env.REPO ?? '/Users/robert/PrepClutch'
const MIG = process.env.MIGRATION ?? '070_geography_map.sql'
await import(`${REPO}/supabase/geography/ts-resolve.mts`)
const read = f => fs.readFileSync(`${REPO}/supabase/migrations/${f}`, 'utf8')
const SQL = read(MIG)
const geo = await import(`${REPO}/lib/geo.ts`)
const pin = await import(`${REPO}/lib/geo-pin.ts`)

const A = '11111111-1111-1111-1111-111111111111'   // student
const B = '22222222-2222-2222-2222-222222222222'   // student who masters everything
const C = '33333333-3333-3333-3333-333333333333'   // had phase-1 history and badges before the map migration
const D = '44444444-4444-4444-4444-444444444444'   // admin

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
  INSERT INTO auth.users VALUES ('${A}'), ('${B}'), ('${C}'), ('${D}');
  INSERT INTO profiles VALUES ('${A}','Ana','#f00',null,'X1',false), ('${B}','Ben','#0f0',null,'X1',false),
                              ('${C}','Cal','#00f',null,'',false),   ('${D}','Dee','#fff',null,'',true);
`)

const as = async (uid, role = 'authenticated') => {
  await db.exec(`RESET ROLE; SELECT set_config('t.uid', '${uid ?? ''}', false); SET ROLE ${role}`)
}
const su = () => db.exec(`RESET ROLE; SELECT set_config('t.uid', '', false)`)
const answer = async (uid, key, correct, ms) => {
  await as(uid)
  try { return (await db.query('SELECT record_geo_answer($1, $2, $3) AS r', [key, correct, ms])).rows[0].r }
  finally { await su() }
}
const held = async u => (await db.query(`SELECT achievement_key k FROM user_achievements WHERE user_id = $1 AND achievement_key LIKE 'geo_%' ORDER BY 1`, [u])).rows.map(x => x.k)
const award = async (u, perfect = false) => {
  await as(u)
  try { return (await db.query('SELECT * FROM award_geo_badges($1)', [perfect])).rows.map(x => Object.values(x)[0]) }
  finally { await su() }
}
const refused = async (uid, role, sql, params = []) => {
  let err = ''
  try { await as(uid, role); await db.query(sql, params) } catch (e) { err = e.message } finally { await su() }
  return err
}

// ── 0. 062-069, as live ──────────────────────────────────────────────────────
for (const f of ['062_math_facts', '063_math_facts_badges', '064_math_facts_topics', '065_home_track',
                 '066_flawless_ten', '067_math_facts_ladders', '068_fact_rounds', '069_geography']) {
  await db.exec('BEGIN;\n' + read(`${f}.sql`) + '\nCOMMIT;')
}
check('062-069 applied on the stub', true)

// Phase-1 life before the map migration: C masters every South America card.
const phase1 = geo.geoCards(geo.KINDS_069)
for (const c of phase1.filter(c => c.continent === 'sa')) await answer(C, c.key, true, 1500)
await answer(A, 'cap:fr', true, 1500)
await answer(A, 'flag:fr', false, 3000)
await award(C)
const cBadges = await held(C)
check('before: C holds the Llama of South America', cBadges.includes('geo_continent_sa'), cBadges.join(' '))
const inList = ks => ks.map(k => `'${k}'`).join(', ')
const snapCards = async () => JSON.stringify((await db.query(`SELECT * FROM geo_cards WHERE kind IN (${inList(geo.KINDS_069)}) ORDER BY card_key`)).rows)
const snapHistory = async () => JSON.stringify((await db.query(`SELECT * FROM geo_history ORDER BY user_id, card_key`)).rows)
const cardsBefore = await snapCards()
const historyBefore = await snapHistory()
const prosrc = async () => (await db.query(`SELECT prosrc FROM pg_proc WHERE proname = 'award_geo_badges_for'`)).rows[0].prosrc
const award069 = await prosrc()
const recordSrc069 = (await db.query(`SELECT prosrc FROM pg_proc WHERE proname = 'record_geo_answer'`)).rows[0].prosrc

// ── 1. First run and re-run, wrapped like the Supabase editor ────────────────
let res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
const v1 = res.at(-2).rows[0]
console.log('verification (first run):', JSON.stringify(v1))
const P1_CARDS = phase1.length, P1_POINTS = geo.maxGeoPoints(geo.KINDS_069)
const ALL_CARDS = geo.allGeoCards().length, ALL_POINTS = geo.maxGeoPoints()
const P1_BADGES = (fs.readFileSync(`${REPO}/supabase/migrations/069_geography.sql`, 'utf8').match(/^\('geo_[a-z0-9_]+', /gm) ?? []).length
const ALL_BADGES = P1_BADGES + (SQL.match(/^\('geo_[a-z0-9_]+', /gm) ?? []).length
const SHAPES = geo.geoCards(['shape']).length, CITIES = geo.geoCards(['city']).length
const PLACES = geo.pinPlaces(), PIN_CITIES = PLACES.filter(p => p.kind === 'city').length
const expect = { cards: ALL_CARDS, shape_cards: SHAPES, city_cards: CITIES, phase1_cards: P1_CARDS, phase1_points: P1_POINTS, max_points: ALL_POINTS, orphan_history: 0,
  geo_badges: ALL_BADGES, pin_places: PLACES.length, pin_cities: PIN_CITIES, pin_rounds_table: 1, helper_callable_by_students: false, pin_record_callable_by_anon: false, pin_insert_by_students: false }
check(`derived: ${SHAPES} shapes, ${CITIES} cities (= ${geo.CITIES.length} in lib/geo-cities.ts), ${PLACES.length} pin places`, CITIES === geo.CITIES.length && PIN_CITIES === CITIES && SHAPES === geo.COUNTRIES.length && CITIES > 0)
check('first run: verification as expected', Object.entries(expect).every(([k, v]) => v1[k] === v), JSON.stringify(expect))
res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
check('re-run: identical verification', JSON.stringify(res.at(-2).rows[0]) === JSON.stringify(v1))

// ── 2. Nothing of 069's changed ──────────────────────────────────────────────
check(`069's ${P1_CARDS} cards byte-equal before and after (keys, points, targets)`, (await snapCards()) === cardsBefore)
check('existing geo_history untouched', (await snapHistory()) === historyBefore)
check('C keeps exactly the badges it had', JSON.stringify(await held(C)) === JSON.stringify(cBadges))
check('record_geo_answer unchanged', (await db.query(`SELECT prosrc FROM pg_proc WHERE proname = 'record_geo_answer'`)).rows[0].prosrc === recordSrc069)
const awardNow = await prosrc()
const rebuilt = awardNow
  .replace(", ('shapes', ARRAY['shape'], 25), ('cities', ARRAY['city'], 25)) AS r(grp, kinds, t)", ") AS r(grp, kinds, t)")
  .replace(", ('shapes', ARRAY['shape']), ('cities', ARRAY['city'])) AS r(grp, kinds)", ") AS r(grp, kinds)")
check("award_geo_badges_for = 069's text plus exactly the shapes and cities rungs", rebuilt === award069 && awardNow !== award069)

// The catalogue upsert's WHERE guard: a 070 whose rows included a 069 key
// (here cap:fr, re-pointed at 999 points) must leave that card alone.
{
  const firstCity = geo.geoCards(['city'])[0]
  const row = `('${firstCity.key}', '${firstCity.iso}', 'city', '${firstCity.continent}', ${firstCity.points}, ${firstCity.targetMs})`
  if (SQL.split(row).length !== 2) throw new Error('could not find the first city row to plant over')
  const planted = SQL.replace(row, `${row},\n('cap:fr', 'FR', 'city', 'eu', 999, 1)`)
  await db.exec('BEGIN;\n' + planted)
  const fr = (await db.query(`SELECT kind, points, target_ms FROM geo_cards WHERE card_key = 'cap:fr'`)).rows[0]
  await db.exec('ROLLBACK')
  check('a planted 070 row with a 069 key (cap:fr) cannot change that card', fr.kind === 'cap' && fr.points === 15 && fr.target_ms === 7000, JSON.stringify(fr))
  check('…and the rollback left 069 byte-equal', (await snapCards()) === cardsBefore)
}

// ── 3. Parity: the whole catalogue against lib/geo.ts ────────────────────────
const sqlCards = (await db.query('SELECT card_key, iso, kind, continent, points, target_ms FROM geo_cards ORDER BY card_key')).rows
const tsCards = geo.allGeoCards().map(c => ({ card_key: c.key, iso: c.iso, kind: c.kind, continent: c.continent, points: c.points, target_ms: c.targetMs }))
  .sort((x, y) => (x.card_key < y.card_key ? -1 : 1))
check(`parity: ${ALL_CARDS} cards, same keys, points and targets as lib/geo.ts`, JSON.stringify(sqlCards) === JSON.stringify(tsCards), `${sqlCards.length} vs ${tsCards.length}`)
const pinSql = (await db.query('SELECT place_key, kind, name, iso, continent, tier, lat, lon FROM geo_pin_places ORDER BY place_key')).rows
const pinTs = PLACES.map(p => ({ place_key: p.key, kind: p.kind, name: p.name, iso: p.iso, continent: p.continent, tier: p.tier, lat: p.lat, lon: p.lon }))
  .sort((x, y) => (x.place_key < y.place_key ? -1 : 1))
check(`parity: ${PLACES.length} pin places (${PIN_CITIES} cities), same key, kind, name, country, continent, level and coordinates as lib/geo.ts`, JSON.stringify(pinSql) === JSON.stringify(pinTs), `${pinSql.length} vs ${pinTs.length}`)
const tiers = geo.pinTiers()
check('pin capitals keep their population levels', PLACES.filter(p => p.kind === 'capital').every(p => p.tier === tiers.get(p.iso)))

// ── 4. Shape cards score exactly like 069 cards ──────────────────────────────
const fl = async (u, k) => (await db.query('SELECT fluent_at, times_correct, times_wrong, best_ms FROM geo_history WHERE user_id=$1 AND card_key=$2', [u, k])).rows[0]
check('shape: slow (8001ms on an 8s card) does not master', (await answer(A, 'shape:fr', true, 8001)) === false && (await fl(A, 'shape:fr')).fluent_at === null)
check('shape: too fast (150ms) does not master', (await answer(A, 'shape:fr', true, 150)) === false && (await fl(A, 'shape:fr')).fluent_at === null)
check('shape: exactly at target (8000ms) masters, returns true', (await answer(A, 'shape:fr', true, 8000)) === true)
const f1 = (await fl(A, 'shape:fr')).fluent_at
check('shape: repeat returns false', (await answer(A, 'shape:fr', true, 1000)) === false)
check('shape: wrong after mastery keeps mastery', (await answer(A, 'shape:fr', false, 2000)) === false && String((await fl(A, 'shape:fr')).fluent_at) === String(f1))
// City cards: the same rules at the city card's own target.
const rio = geo.geoCards(['city']).find(c => c.key === 'city:rio-de-janeiro')
const T = rio.targetMs
check(`city: slow (${T + 1}ms on a ${T / 1000}s card) does not master`, (await answer(A, rio.key, true, T + 1)) === false && (await fl(A, rio.key)).fluent_at === null)
check('city: too fast (150ms) does not master', (await answer(A, rio.key, true, 150)) === false && (await fl(A, rio.key)).fluent_at === null)
check('city: wrong does not master', (await answer(A, rio.key, false, 1000)) === false && (await fl(A, rio.key)).fluent_at === null)
check(`city: exactly at target (${T}ms) masters, returns true`, (await answer(A, rio.key, true, T)) === true)
const r1 = (await fl(A, rio.key)).fluent_at
check('city: repeat returns false', (await answer(A, rio.key, true, 1000)) === false)
check('city: wrong after mastery keeps mastery', (await answer(A, rio.key, false, 2000)) === false && String((await fl(A, rio.key)).fluent_at) === String(r1))
const hA = await fl(A, rio.key)
check('city: history counts 4 right, 2 wrong, best 1000ms (150ms is not a best)', hA.times_correct === 4 && hA.times_wrong === 2 && hA.best_ms === 1000, JSON.stringify(hA))
const lbA = (await db.query('SELECT points, fluent FROM geo_leaderboard_view WHERE user_id = $1', [A])).rows[0]
const want = 15 + geo.KIND_SCORE.shape.points + rio.points
check(`leaderboard: A = cap:fr 15 + shape:fr ${geo.KIND_SCORE.shape.points} + ${rio.key} ${rio.points} = ${want} points, 3 fluent`, lbA.points === want && lbA.fluent === 3, JSON.stringify(lbA))
check('unknown shape key refused', /unknown geography card/.test(await refused(A, 'authenticated', `SELECT record_geo_answer('shape:xx', true, 1000)`)))
check('unknown city key refused', /unknown geography card/.test(await refused(A, 'authenticated', `SELECT record_geo_answer('city:atlantis', true, 1000)`)))
check('a capital is not a city card (city:cape-town refused)', /unknown geography card/.test(await refused(A, 'authenticated', `SELECT record_geo_answer('city:cape-town', true, 1000)`)))

// ── 5. Badges ────────────────────────────────────────────────────────────────
const shapes = geo.geoCards(['shape'])
const cities = geo.geoCards(['city'])
for (const c of shapes.slice(0, 24)) await answer(B, c.key, true, 1500)
let got = await award(B)
check('24 shapes: no Shape Spotter', !got.includes('geo_shapes_25'), got.join(' '))
await answer(B, shapes[24].key, true, 1500)
got = await award(B)
check('25 shapes: Shape Spotter', got.includes('geo_shapes_25'), got.join(' '))
for (const c of cities.slice(0, 24)) await answer(B, c.key, true, 1500)
await answer(B, cities[24].key, true, cities[24].targetMs + 1)          // right but slow: not mastered
got = await award(B)
check('24 cities mastered + 1 right but slow: no City Hopper', !got.includes('geo_cities_25'), got.join(' '))
await answer(B, cities[24].key, true, 1500)
got = await award(B)
check('25 cities: City Hopper', got.includes('geo_cities_25'), got.join(' '))
for (const c of phase1) await answer(B, c.key, true, 1500)
for (const c of shapes.slice(25, -1)) await answer(B, c.key, true, 1500)
for (const c of cities.slice(25, -1)) await answer(B, c.key, true, 1500)
got = await award(B)
check('every card but one shape and one city: no Map Master, no Globetrotter, no World Turtle',
  !got.includes('geo_shapes_all') && !got.includes('geo_cities_all') && !(await held(B)).includes('geo_mastered_all'), got.join(' '))
const heldB = await held(B)
check('…but the phase-1 type badges are all there', ['geo_capitals_all', 'geo_flags_all', 'geo_continents_all'].every(k => heldB.includes(k)))
const lastShapeCt = shapes.at(-1).continent, lastCityCt = cities.at(-1).continent
check(`…and the continents missing a card (${lastShapeCt}, ${lastCityCt}) are not awarded`,
  !heldB.includes(`geo_continent_${lastShapeCt}`) && !heldB.includes(`geo_continent_${lastCityCt}`))
const otherCts = geo.CONTINENTS.filter(ct => ct !== lastShapeCt && ct !== lastCityCt)
check(`…while every complete continent is (${otherCts.join(' ')})`, otherCts.every(ct => heldB.includes(`geo_continent_${ct}`)))
await answer(B, shapes.at(-1).key, true, 1500)
got = await award(B)
check('last shape: Map Master, but no World Turtle and no Globetrotter (a city is missing)',
  got.includes('geo_shapes_all') && !got.includes('geo_mastered_all') && !got.includes('geo_cities_all'), got.join(' '))
check(`…and ${lastShapeCt} only if its cities are all done too`, got.includes(`geo_continent_${lastShapeCt}`) === (lastShapeCt !== lastCityCt), got.join(' '))
await answer(B, cities.at(-1).key, true, 1500)
got = await award(B)
check(`last city (${cities.at(-1).key}): Globetrotter, World Turtle and ${lastCityCt}`, ['geo_cities_all', 'geo_mastered_all', `geo_continent_${lastCityCt}`].every(k => got.includes(k)), got.join(' '))
check(`B holds all ${ALL_BADGES} Geography badges but Perfect Passport (${ALL_BADGES - 1})`, (await held(B)).length === ALL_BADGES - 1, String((await held(B)).length))
const defs = (await db.query(`SELECT key, threshold, category FROM achievement_definitions WHERE key = 'geo_mastered_all' OR key ~ '^geo_(continent_[a-z]{2}|shapes_|cities_)' ORDER BY key`)).rows
const wantDefs = [
  ['geo_cities_25', 25], ['geo_cities_all', CITIES],
  ...geo.CONTINENTS.map(ct => [`geo_continent_${ct}`, geo.allGeoCards().filter(c => c.continent === ct).length]),
  ['geo_mastered_all', ALL_CARDS], ['geo_shapes_25', 25], ['geo_shapes_all', SHAPES],
]
wantDefs.sort((x, y) => (x[0] < y[0] ? -1 : 1))
check('every-card, continent, shape and city badge thresholds = the catalogue (cities included)',
  JSON.stringify(defs.map(d => [d.key, d.threshold])) === JSON.stringify(wantDefs) && defs.every(d => d.category === 'Geography'), JSON.stringify(defs))
const descs = (await db.query(`SELECT key, description FROM achievement_definitions WHERE key ~ '^geo_continent_[a-z]{2}$' OR key = 'geo_mastered_all'`)).rows
check('…and their descriptions state the same totals', descs.every(d => {
  const ct = d.key.replace('geo_continent_', '')
  const n = d.key === 'geo_mastered_all' ? ALL_CARDS : geo.allGeoCards().filter(c => c.continent === ct).length
  return d.description.includes(` ${n} `)
}), JSON.stringify(descs))
check('award_geo_badges_for refused under SET ROLE authenticated', /permission denied/.test(await refused(A, 'authenticated', `SELECT * FROM award_geo_badges_for('${A}', true)`)))
check('award_geo_badges refused for anon', /permission denied/.test(await refused(null, 'anon', `SELECT * FROM award_geo_badges(true)`)))
check('C still holds exactly its badges', JSON.stringify(await held(C)) === JSON.stringify(cBadges))

// ── 6. Pin the map ───────────────────────────────────────────────────────────
const places = ct => PLACES.filter(p => p.continent === ct).map(p => ({ i: p.key, lat: p.lat, lon: p.lon }))
const cityPlaces = ct => PLACES.filter(p => p.continent === ct && p.kind === 'city').map(p => ({ i: p.key, lat: p.lat, lon: p.lon }))
const round = async (u, deck, pins) => {
  await as(u)
  try { return (await db.query('SELECT record_geo_pin_round($1, $2::jsonb) AS s', [deck, JSON.stringify(pins)])).rows[0].s }
  finally { await su() }
}
const eu = places('eu').slice(0, 10)
check(`pin: ten capitals, bullseyes in 2 s each = ${pin.MAX_PIN_SCORE}`, (await round(A, 'eu:1', eu.map(p => ({ ...p, ms: 2000 })))) === pin.MAX_PIN_SCORE)
const naCities = cityPlaces('na').slice(0, 10)
check(`pin: ten cities, bullseyes in 2 s each = ${pin.MAX_PIN_SCORE}`, (await round(A, 'na:1', naCities.map(p => ({ ...p, ms: 2000 })))) === pin.MAX_PIN_SCORE)
// A city pinned on its own country's capital scores what the TS says, not a bullseye.
const ny = PLACES.find(p => p.key === 'city:new-york'), dc = PLACES.find(p => p.key === 'cap:us')
const nyOnDc = [{ i: ny.key, lat: dc.lat, lon: dc.lon, ms: 2000 }, ...naCities.filter(p => p.i !== ny.key).slice(0, 9).map(p => ({ ...p, ms: 2000 }))]
const nyTs = pin.pinScore(ny, dc, 2000).points + 9 * pin.MAX_PIN_SCORE / pin.PIN_ROUND
check(`pin: New York tapped on Washington scores ${pin.pinScore(ny, dc, 2000).points} (${Math.round(pin.pinScore(ny, dc, 2000).km)} km), as lib/geo-pin.ts`, (await round(A, 'na:1', nyOnDc)) === nyTs)

// Parity with lib/geo-pin.ts on random taps (seeded), all continents.
let seedN = 7
const rnd = () => ((seedN = (seedN * 1103515245 + 12345) % 2147483648) / 2147483648)
let parityOk = true, rounds = 3, detail = '', citiesPinned = 0
for (const ct of geo.CONTINENTS) {
  for (let k = 0; k < 6; k++) {
    // A real round, as the page builds it (capitals and cities mixed).
    const ps = geo.buildPinRound(ct, 1 + (k % 3), rnd).map(p => ({ i: p.key, lat: p.lat, lon: p.lon }))
    citiesPinned += ps.filter(p => p.i.startsWith('city:')).length
    const pins = ps.map(p => {
      if (rnd() < 0.1) return { i: p.i, lat: null, lon: null, ms: 4000 }
      const spread = [0.3, 2, 6, 12, 20][Math.floor(rnd() * 5)]
      return { i: p.i, lat: Math.max(-89, Math.min(89, p.lat + (rnd() - 0.5) * spread)), lon: Math.max(-180, Math.min(180, p.lon + (rnd() - 0.5) * spread)), ms: Math.floor(rnd() * 9000) }
    })
    const ts = pins.reduce((s, x, j) => s + pin.pinScore(ps[j], x.lat === null ? null : x, x.ms).points, 0)
    const sq = await round(A, `${ct}:${1 + (k % 3)}`, pins)
    rounds++
    if (ts !== sq) { parityOk = false; detail += ` ${ct}: ts ${ts} sql ${sq}` }
  }
}
check(`pin: SQL score = lib/geo-pin.ts score on ${rounds - 3} random built rounds (${citiesPinned} city pins)`, parityOk && citiesPinned > 0, detail)
const stored = (await db.query(`SELECT answers FROM geo_pin_rounds WHERE user_id = $1 AND deck = 'na:1' ORDER BY completed_at LIMIT 1`, [A])).rows[0].answers
check('pin: answers stored with place key, km and points per place', stored.length === 10 && stored[0].i === naCities[0].i && stored[0].km === 0 && stored[0].p === 110, JSON.stringify(stored[0]))

const bad = [
  ['9 places', 'eu:1', eu.slice(0, 9)],
  ['a repeated place', 'eu:1', [...eu.slice(0, 9), eu[0]]],
  ['a place from another continent', 'eu:1', [...eu.slice(0, 9), places('af')[0]]],
  ['an unknown place', 'eu:1', [...eu.slice(0, 9), { i: 'city:atlantis', lat: 0, lon: 0 }]],
  ['a bare country code (the old place format)', 'eu:1', [...eu.slice(0, 9), { i: 'FR', lat: 48.86, lon: 2.35 }]],
  ['a city of another continent', 'eu:1', [...eu.slice(0, 9), { ...cityPlaces('na')[0] }]],
  ['a city twice', 'na:1', [...naCities.slice(0, 9), naCities[0]]],
  ['a card key instead of a place key', 'eu:1', [...eu.slice(0, 9), { i: 'shape:fr', lat: 48.86, lon: 2.35 }]],
  ['a pin off the map', 'eu:1', [...eu.slice(0, 9), { ...eu[9], lat: 95 }]],
  ['half a pin', 'eu:1', [...eu.slice(0, 9), { ...eu[9], lon: null }]],
  ['an unknown deck', 'eu:4', eu],
  ['a deck with a regex in it', "eu:1' OR 'x", eu],
]
for (const [what, deck, pins] of bad) {
  const err = await refused(A, 'authenticated', 'SELECT record_geo_pin_round($1, $2::jsonb)', [deck, JSON.stringify(pins.map(p => ({ ms: 1000, ...p })))])
  check(`pin: refused with ${what}`, err !== '', err)
}
const nA = (await db.query(`SELECT COUNT(*)::int n FROM geo_pin_rounds WHERE user_id = $1`, [A])).rows[0].n
check('pin: refused rounds saved nothing', nA === rounds)
check('pin: anon cannot record a round', /permission denied/.test(await refused(null, 'anon', 'SELECT record_geo_pin_round($1, $2::jsonb)', ['eu:1', JSON.stringify(eu)])))
check('pin: signed-out (no uid) cannot record a round', /requires a signed-in user/.test(await refused(null, 'authenticated', 'SELECT record_geo_pin_round($1, $2::jsonb)', ['eu:1', JSON.stringify(eu)])))
for (const [what, stmt] of [
  ['insert its own round directly (score 1100)', `INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES ('${A}', 'eu:1', 1100, '[]')`],
  ['insert a round as someone else', `INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES ('${B}', 'eu:1', 1100, '[]')`],
  ['update a round', `UPDATE geo_pin_rounds SET score = 1100`],
  ['delete rounds', `DELETE FROM geo_pin_rounds`],
  ['change a pin place', `UPDATE geo_pin_places SET lat = 0`],
  ['add a pin place', `INSERT INTO geo_pin_places VALUES ('city:here', 'city', 'Here', 'FR', 'eu', 1, 48.86, 2.35)`],
]) check(`pin: student cannot ${what}`, /permission denied/.test(await refused(A, 'authenticated', stmt)), stmt.slice(0, 40))

await round(B, 'eu:1', eu.map(p => ({ ...p, lat: p.lat + 2, ms: 5000 })))
const seen = async (u, role, sql) => { await as(u, role); try { return (await db.query(sql)).rows } finally { await su() } }
const rA = await seen(A, 'authenticated', 'SELECT DISTINCT user_id FROM geo_pin_rounds')
check('pin: student reads only own rounds', rA.length === 1 && rA[0].user_id === A, JSON.stringify(rA))
const rD = await seen(D, 'authenticated', 'SELECT DISTINCT user_id FROM geo_pin_rounds ORDER BY 1')
check('pin: admin reads every round', rD.length === 2)
const lb = await seen(A, 'authenticated', `SELECT user_id, best, rounds FROM geo_pin_leaderboard_view WHERE deck = 'eu:1' ORDER BY best DESC`)
check('pin: leaderboard shows each student\'s best per deck', lb.length === 2 && lb[0].user_id === A && lb[0].best === 1100, JSON.stringify(lb))
check('pin: anon cannot read the leaderboard', /permission denied/.test(await refused(null, 'anon', 'SELECT * FROM geo_pin_leaderboard_view')))
check('pin: anon cannot read rounds', /permission denied/.test(await refused(null, 'anon', 'SELECT * FROM geo_pin_rounds')))
check('pin: rounds never touched geo_history', (await db.query(`SELECT COUNT(*)::int n FROM geo_history WHERE user_id = $1`, [A])).rows[0].n === 4)

// ── 7. Re-run after all that is still harmless ───────────────────────────────
const lbBefore = JSON.stringify((await db.query('SELECT * FROM geo_leaderboard_view ORDER BY user_id')).rows)
const pinBefore = JSON.stringify((await db.query('SELECT * FROM geo_pin_leaderboard_view ORDER BY user_id, deck')).rows)
await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
check('re-run after play: leaderboards unchanged', JSON.stringify((await db.query('SELECT * FROM geo_leaderboard_view ORDER BY user_id')).rows) === lbBefore &&
  JSON.stringify((await db.query('SELECT * FROM geo_pin_leaderboard_view ORDER BY user_id, deck')).rows) === pinBefore)
check(`re-run after play: B keeps ${ALL_BADGES - 1} badges`, (await held(B)).length === ALL_BADGES - 1)

console.log(fails ? `\n${fails} FAILED` : '\nALL PASSED')
process.exit(fails ? 1 : 0)
