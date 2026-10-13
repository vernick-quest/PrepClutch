// PGlite run of migration 074 (Pin the map masters cards) on top of 062-073,
// against the same stub of the Supabase schema as pglite-country-test.mjs
// (auth.users, auth.uid(), profiles with is_admin, roles anon and
// authenticated, Supabase's default grants to both on every new table and
// function).
//
// PGlite is not a dependency of the app. Install it OUTSIDE the repo:
//
//   mkdir /tmp/geo-pglite && cd /tmp/geo-pglite && npm i @electric-sql/pglite@0.2
//   cp <repo>/supabase/geography/pglite-mastery-test.mjs run-mastery.mjs
//   REPO=<repo> node run-mastery.mjs          (MIGRATION=074_geo_pin_mastery.sql)
//
// Covers: rounds of both shapes saved BEFORE 074 (by 073's functions, and
// hand-made 070-style rows with whole km), then 074 first run and re-run
// inside BEGIN/COMMIT; the catalogue (find and pin rows = lib/geo.ts, no
// older card touched); the backfill (every find/pin history row equal to a
// replay of the student's rounds in lib/geo-pin.ts terms, idempotent, other
// history untouched); badges (awarded after the backfill exactly as a JS
// mirror of the rules predicts, old-rule badges awarded FIRST and kept); live
// rounds after 074 (fast hit/pin masters, slow or Close is right but not
// mastered, misses and give-ups lower nothing, a mastered card stays
// mastered after a miss); Explorer Points in geo_leaderboard_view include the
// new cards; 073's scoring, refusals and function text otherwise unchanged;
// grade parity with lib/geo-pin.ts pinVerdict; privileges. Every expected
// number is derived from lib/ or from the data, never typed in.
import { PGlite } from '@electric-sql/pglite'
import fs from 'node:fs'

const REPO = process.env.REPO ?? '/Users/robert/PrepClutch'
const MIG = process.env.MIGRATION ?? '074_geo_pin_mastery.sql'
await import(`${REPO}/supabase/geography/ts-resolve.mts`)
const read = f => fs.readFileSync(`${REPO}/supabase/migrations/${f}`, 'utf8')
const SQL = read(MIG)
const geo = await import(`${REPO}/lib/geo.ts`)
const pin = await import(`${REPO}/lib/geo-pin.ts`)
const gm = await import(`${REPO}/lib/geo-map.ts`)
const shapes = gm.decodeAsset(JSON.parse(fs.readFileSync(`${REPO}/public${gm.MAP_URL}`, 'utf8')))
const codeAt = (lat, lon) => gm.tapCode(gm.shapeAt(shapes, lat, lon))

const A = '11111111-1111-1111-1111-111111111111'   // quiz only
const B = '22222222-2222-2222-2222-222222222222'   // plays after 074
const D = '44444444-4444-4444-4444-444444444444'   // admin
const E = '55555555-5555-5555-5555-555555555555'   // played both modes before 074
const F = '66666666-6666-6666-6666-666666666666'   // found every country and pinned every place before 074
const G = '77777777-7777-7777-7777-777777777777'   // qualified for badges under 072's rules, never awarded
const H = '88888888-8888-8888-8888-888888888888'   // only two hand-made 070-style places rows (whole km)

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
  INSERT INTO auth.users VALUES ('${A}'), ('${B}'), ('${D}'), ('${E}'), ('${F}'), ('${G}'), ('${H}');
  INSERT INTO profiles VALUES ('${A}','Ana','#f00',null,'X1',false), ('${B}','Ben','#0f0',null,'X1',false),
                              ('${D}','Dee','#fff',null,'',true), ('${E}','Eve','#ff0',null,'',false),
                              ('${F}','Fay','#0ff',null,'X1',false), ('${G}','Gus','#f0f',null,'',false),
                              ('${H}','Hal','#888',null,'',false);
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
const q = async (sql, params) => (await db.query(sql, params)).rows

// ── The rules, in lib/ terms ─────────────────────────────────────────────────
const CARDS = new Map(geo.allGeoCards().map(c => [c.key, c]))
const TARGET = { find: geo.KIND_SCORE.find.targetMs, pin: geo.KIND_SCORE.pin.targetMs }
/** 2 = Bullseye or Great, 1 = Close, 0 = anything else (lib/geo-pin.ts pinVerdict). */
const grade = (ct, km) => { const v = pin.pinVerdict(ct, km); return v === 'bull' || v === 'great' ? 2 : v === 'close' ? 1 : 0 }
const fast = (g, ms, target) => g === 2 && ms !== null && ms >= 200 && ms <= target
/** A stored round's answers as card taps: { key, correct, fast, ms }. */
function taps(deck, answers) {
  const d = pin.parsePinDeck(deck)
  return answers.map(a => {
    const key = d.mode === 'country' ? geo.geoKey('find', a.i) : geo.pinCardKey(a.i)
    const g = d.mode === 'country' ? (a.h ? 2 : 0) : grade(d.continent, a.km === null ? null : Number(a.km))
    const kind = d.mode === 'country' ? 'find' : 'pin'
    return { key, correct: g > 0, fast: fast(g, a.ms, TARGET[kind]), ms: a.ms }
  }).filter(t => CARDS.has(t.key))
}
/** record_geo_answer's rules over rounds in order: what geo_history should hold. */
function replay(rounds) {
  const h = new Map()
  for (const r of rounds) for (const t of taps(r.deck, r.answers)) {
    const at = new Date(r.completed_at).getTime()
    const o = h.get(t.key) ?? { tc: 0, tw: 0, best: null, last: null, fluent: null, lastAt: 0 }
    if (t.correct) o.tc++; else o.tw++
    if (t.correct && t.ms !== null && t.ms >= 200) o.best = o.best === null ? t.ms : Math.min(o.best, t.ms)
    o.last = t.ms
    if (t.fast && o.fluent === null) o.fluent = at
    o.lastAt = Math.max(o.lastAt, at)
    h.set(t.key, o)
  }
  return h
}
const histOf = async (u, kinds = ['find', 'pin']) => new Map((await q(
  `SELECT h.* FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key WHERE h.user_id = $1 AND c.kind = ANY ($2) ORDER BY h.card_key`, [u, kinds]))
  .map(r => [r.card_key, r]))
function sameHistory(got, want) {
  const bad = []
  for (const [k, w] of want) {
    const g = got.get(k)
    const ok = g && g.times_correct === w.tc && g.times_wrong === w.tw && g.best_ms === w.best && g.last_ms === w.last &&
      (g.fluent_at === null ? w.fluent === null : g.fluent_at.getTime() === w.fluent) && g.last_answered_at.getTime() === w.lastAt
    if (!ok) bad.push(`${k}: got ${JSON.stringify(g)} want ${JSON.stringify(w)}`)
  }
  for (const k of got.keys()) if (!want.has(k)) bad.push(`${k}: unexpected row`)
  return bad
}
/** The Geography badges a set of mastered cards earns, mirroring
 *  award_geo_badges_for as 074 means it (keys with a definition only). */
function expectedBadges(fluent, defs) {
  const all = geo.allGeoCards()
  const is = c => fluent.has(c.key)
  const out = new Set()
  const n = all.filter(is).length
  for (const t of [10, 50, 100, 250, 500]) if (n >= t) out.add(`geo_mastered_${t}`)
  if (all.every(is)) out.add('geo_mastered_all')
  for (const ct of geo.CONTINENTS) {
    const cs = all.filter(c => c.continent === ct && c.kind !== 'cont')
    const m = cs.filter(is).length
    if (m === cs.length) out.add(`geo_continent_${ct}`)
    if (m >= 25) out.add(`geo_continent_${ct}_25`)
    if (m >= Math.floor(cs.length / 2)) out.add(`geo_continent_${ct}_half`)
  }
  for (const [grp, kinds] of [['capitals', ['cap', 'capr']], ['flags', ['flag', 'flagr']], ['continents', ['cont']], ['shapes', ['shape']],
    ['cities', ['city']], ['find', ['find']], ['pin', ['pin']]]) {
    const cs = all.filter(c => kinds.includes(c.kind))
    if (cs.filter(is).length >= 25) out.add(`geo_${grp}_25`)
    if (cs.every(is)) out.add(`geo_${grp}_all`)
  }
  return new Set([...out].filter(k => defs.has(k)))
}
const badgesOf = async u => new Set((await q(`SELECT achievement_key FROM user_achievements WHERE user_id = $1 AND achievement_key LIKE 'geo_%'`, [u])).map(r => r.achievement_key))
const fluentOf = async u => new Set((await q(`SELECT card_key FROM geo_history WHERE user_id = $1 AND fluent_at IS NOT NULL`, [u])).map(r => r.card_key))
const eqSet = (a, b) => a.size === b.size && [...a].every(x => b.has(x))

// Deterministic randomness.
let seedN = 7
const rnd = () => ((seedN = (seedN * 1103515245 + 12345) % 2147483648) / 2147483648)
const KM_PER_DEG = 6371 * Math.PI / 180
/** A tap `km` due north (or south near the pole) of a place. */
const offset = (p, km) => ({ lat: p.lat + (p.lat > 80 ? -1 : 1) * km / KM_PER_DEG, lon: p.lon })
const cap = iso => { const c = geo.countryByIso(iso); return { iso, lat: c.capitals[0].lat, lon: c.capitals[0].lon } }
/** A tap that finds the country (lib/geo-pin.ts countryHit on the real map):
 *  its capital if that works, else the nearest grid point around it that does.
 *  (Some capitals sit just off their country's drawn coast.) */
function inside(iso) {
  const c = cap(iso)
  for (let r = 0; r <= 40; r++) for (let dy = -r; dy <= r; dy++) for (let dx = -r; dx <= r; dx++) {
    if (Math.max(Math.abs(dx), Math.abs(dy)) !== r) continue
    const lat = c.lat + dy * 0.1, lon = c.lon + dx * 0.1
    const tap = codeAt(lat, lon)
    if (pin.countryHit(c, { code: tap, lat, lon })) return { iso, tap, lat: Math.round(lat * 1e4) / 1e4, lon: Math.round(lon * 1e4) / 1e4 }
  }
  throw new Error(`no tap finds ${iso}`)
}

// ── 0. 062-073, as live ──────────────────────────────────────────────────────
for (const f of ['062_math_facts', '063_math_facts_badges', '064_math_facts_topics', '065_home_track', '066_flawless_ten',
                 '067_math_facts_ladders', '068_fact_rounds', '069_geography', '070_geography_map', '071_repair_geo_text',
                 '072_geo_continent_ladders', '073_geo_pin_countries']) {
  await db.exec('BEGIN;\n' + read(`${f}.sql`) + '\nCOMMIT;')
}
check('062-073 applied on the stub', true)
await as(A); await db.query(`SELECT record_geo_answer('cap:fr', true, 1500)`); await db.query(`SELECT award_geo_badges()`); await su()
check('before 074: the catalogue has no find or pin card (what the app probes)', (await q(`SELECT COUNT(*)::int n FROM geo_cards WHERE kind IN ('find', 'pin')`))[0].n === 0)

// ── 1. Rounds saved before 074 ───────────────────────────────────────────────
// E: random places and country rounds through 073's functions.
for (const ct of geo.CONTINENTS) for (const l of pin.PIN_LEVELS) {
  const ps = geo.buildPinRound(ct, l, rnd)
  await placeRound(E, pin.pinDeckId(ct, l), ps.map(p => rnd() < 0.15 ? { i: p.key, lat: null, lon: null, ms: 3000 }
    : { i: p.key, ...offset(p, [0, 20, 80, 150, 300, 700][Math.floor(rnd() * 6)]), ms: [150, 2000, 5000, 8000, 8001, 12000][Math.floor(rnd() * 6)] }))
  const cs = geo.buildCountryRound(ct, l, rnd)
  await countryRound(E, pin.countryDeckId(ct, l), cs.map(c => {
    if (rnd() < 0.15) return { iso: c.iso, tap: null, lat: null, lon: null, ms: 2000 }
    const t = offset(c, [0, 0, 30, 200][Math.floor(rnd() * 4)])
    return { iso: c.iso, tap: codeAt(t.lat, t.lon), lat: t.lat, lon: t.lon, ms: [150, 2500, 7900, 9000][Math.floor(rnd() * 4)] }
  }))
}
// H: two 070-style rows (whole km), the second a replay with different taps.
const EU = geo.pinPlaces().filter(p => p.continent === 'eu').slice(0, 10)
for (const [kms, mss] of [[[0, 50, 130, 131, 260, 261, 649, null, 10, 5], [2000, 7999, 2000, 2000, 2000, 2000, 2000, 4000, 199, 8000]],
                          [[400, 0, 0, 0, 0, 0, 0, 0, 0, 0], [2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000]]]) {
  const answers = EU.map((p, j) => ({ i: p.key, km: kms[j], ms: mss[j], p: 0 }))
  await db.query(`INSERT INTO geo_pin_rounds (user_id, deck, score, answers, completed_at) VALUES ($1, 'eu:3', 0, $2::jsonb, now() - $3::interval)`,
    [H, JSON.stringify(answers), kms[0] === 0 ? '2 hours' : '1 hour'])
}
// F: every asked country found fast, every place pinned fast, through 073's functions.
for (const ct of geo.CONTINENTS) {
  const cs = geo.COUNTRIES.filter(c => c.continent === ct && !geo.COUNTRY_NOT_ASKED.has(c.iso))
  for (let i = 0; i < cs.length; i += 10) {
    const chunk = cs.slice(i, i + 10)
    for (const c of cs) if (chunk.length < 10 && !chunk.includes(c)) chunk.push(c)
    await countryRound(F, pin.countryDeckId(ct, 1), chunk.map(c => ({ ...inside(c.iso), ms: 2500 })))
  }
  const ps = geo.pinPlaces().filter(p => p.continent === ct)
  for (let i = 0; i < ps.length; i += 10) {
    const chunk = ps.slice(i, i + 10)
    for (const p of ps) if (chunk.length < 10 && !chunk.includes(p)) chunk.push(p)
    await placeRound(F, pin.pinDeckId(ct, 2), chunk.map(p => ({ i: p.key, lat: p.lat, lon: p.lon, ms: 2500 })))
  }
}
// G: mastered under 072's rules (history written directly, never awarded):
// every South America card a continent badge counted, and Africa's old half.
const old072 = geo.geoCards(geo.KINDS_070).filter(c => c.kind !== 'cont')
const oldHalfAf = (await q(`SELECT threshold FROM achievement_definitions WHERE key = 'geo_continent_af_half'`))[0].threshold
const gKeys = [...old072.filter(c => c.continent === 'sa'), ...old072.filter(c => c.continent === 'af').slice(0, oldHalfAf)].map(c => c.key)
await db.query(`INSERT INTO geo_history (user_id, card_key, times_correct, fluent_at) SELECT $1, k, 1, now() FROM unnest($2::text[]) AS k`, [G, gKeys])
check(`G: qualifies under 072 for geo_continent_sa and geo_continent_af_half (${oldHalfAf}) but holds no badge yet`, (await badgesOf(G)).size === 0)

const roundsBefore = await q(`SELECT id, user_id, deck, answers, completed_at FROM geo_pin_rounds ORDER BY completed_at, id`)
const otherHistBefore = JSON.stringify(await q(`SELECT h.* FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key ORDER BY user_id, card_key`))
const cardsBefore = JSON.stringify(await q(`SELECT * FROM geo_cards ORDER BY card_key`))
const fnText = async name => (await q(`SELECT prosrc FROM pg_proc WHERE proname = $1`, [name]))[0].prosrc
const src073 = { place: await fnText('record_geo_pin_round'), country: await fnText('record_geo_country_round') }
const badgesBefore = JSON.stringify(await q(`SELECT user_id, achievement_key FROM user_achievements ORDER BY 1, 2`))
check(`before 074: ${roundsBefore.length} rounds saved (E ${roundsBefore.filter(r => r.user_id === E).length}, F ${roundsBefore.filter(r => r.user_id === F).length}) and no find/pin history`,
  roundsBefore.length > 0 && (await q(`SELECT COUNT(*)::int n FROM geo_history WHERE card_key LIKE 'find:%' OR card_key LIKE 'pin:%'`))[0].n === 0)

// ── 2. 074, first run and re-run ─────────────────────────────────────────────
let res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
const v1 = res.at(-2).rows[0]
console.log('verification (first run):', JSON.stringify(v1))
const ALL = geo.allGeoCards()
const finds = geo.geoCards(['find']), pins = geo.geoCards(['pin'])
const fpHist = await q(`SELECT h.fluent_at FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key WHERE c.kind IN ('find', 'pin')`)
const geoBadgeDefs = ['069_geography.sql', '070_geography_map.sql', '072_geo_continent_ladders.sql']
  .reduce((s, f) => s + (read(f).match(/^\('geo_[a-z0-9_]+', /gm) ?? []).length, 0) + (SQL.match(/^\('geo_[a-z0-9_]+', /gm) ?? []).length
const expect = {
  find_cards: finds.length, pin_cards: pins.length, cards: ALL.length, max_points: geo.maxGeoPoints(),
  pin_cards_without_place: 0, places_without_pin_card: 0, orphan_history: 0, geo_badges: geoBadgeDefs, unfed_rounds: 0,
  find_pin_history: fpHist.length, find_pin_mastered: fpHist.filter(r => r.fluent_at).length,
  helpers_callable_by_students: false, master_callable_by_anon: false, rounds_callable_by_anon: false,
  rounds_callable_by_students: true, history_insert_by_students: false,
}
check('first run: verification as expected (counts derived from lib/geo.ts and the data)',
  Object.entries(expect).every(([k, v]) => typeof v === 'number' ? Number(v1[k]) === v : v1[k] === v), JSON.stringify(expect))
check(`header comment states the derived numbers (${finds.length} find, ${pins.length} pin, ${ALL.length} cards, ${geo.maxGeoPoints()} points)`,
  SQL.includes(`find_cards ${finds.length}, pin_cards ${pins.length}, cards ${ALL.length}, max_points ${geo.maxGeoPoints()}`) && SQL.startsWith('-- 074 - Geography: Pin the map masters cards\n'))
const snapAll = async (badges = true) => JSON.stringify([await q(`SELECT * FROM geo_cards ORDER BY card_key`), await q(`SELECT * FROM geo_history ORDER BY user_id, card_key`),
  badges ? await q(`SELECT user_id, achievement_key FROM user_achievements ORDER BY 1, 2`) : null, await q(`SELECT id, score, answers, mastery_at FROM geo_pin_rounds ORDER BY id`),
  await q(`SELECT key, description, threshold FROM achievement_definitions ORDER BY key`)])
const s1 = await snapAll()
res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
check('re-run: identical verification', JSON.stringify(res.at(-2).rows[0]) === JSON.stringify(v1))
check('re-run: cards, history, badges, rounds and definitions unchanged (the backfill is idempotent)', (await snapAll()) === s1)

// ── 3. The catalogue ─────────────────────────────────────────────────────────
{
  const sq = await q(`SELECT card_key, iso, kind, continent, points, target_ms FROM geo_cards WHERE kind IN ('find', 'pin') ORDER BY card_key`)
  const ts = [...finds, ...pins].map(c => ({ card_key: c.key, iso: c.iso, kind: c.kind, continent: c.continent, points: c.points, target_ms: c.targetMs }))
    .sort((x, y) => (x.card_key < y.card_key ? -1 : 1))
  check(`parity: the ${sq.length} find and pin rows = lib/geo.ts (key, iso, kind, continent, points, target)`, JSON.stringify(sq) === JSON.stringify(ts))
  const whole = (await q(`SELECT card_key FROM geo_cards ORDER BY card_key`)).map(r => r.card_key)
  check(`parity: the whole catalogue (${whole.length}) = allGeoCards`, JSON.stringify(whole) === JSON.stringify(ALL.map(c => c.key).sort()))
  const older = JSON.stringify((JSON.parse(cardsBefore)))
  check('no older card changed', JSON.stringify(await q(`SELECT * FROM geo_cards WHERE kind NOT IN ('find', 'pin') ORDER BY card_key`)) === older)
  check(`find cards: one per UN member but ${[...geo.COUNTRY_NOT_ASKED]}, and none for it`,
    finds.length === geo.COUNTRIES.length - geo.COUNTRY_NOT_ASKED.size && [...geo.COUNTRY_NOT_ASKED].every(i => !CARDS.has(geo.geoKey('find', i))))
  check(`pin cards: one per Pin the map place (${geo.pinPlaces().length})`, pins.length === geo.pinPlaces().length)
  check('the probe the app uses now finds both kinds (anon may read geo_cards)',
    (await refused(null, 'anon', `SELECT 1 FROM geo_cards WHERE kind = 'find' LIMIT 1`)) === '' &&
    (await q(`SELECT COUNT(DISTINCT kind)::int n FROM geo_cards WHERE kind IN ('find', 'pin')`))[0].n === 2)
}

// ── 4. The backfill ──────────────────────────────────────────────────────────
{
  for (const [u, name] of [[E, 'E (random rounds of both modes)'], [F, 'F (every country and place)'], [H, 'H (070-style whole-km rows)']]) {
    const want = replay(roundsBefore.filter(r => r.user_id === u))
    const bad = sameHistory(await histOf(u), want)
    check(`backfill: ${name}: ${want.size} find/pin rows = a replay of the rounds by lib/geo-pin.ts rules`, bad.length === 0 && want.size > 0, bad.slice(0, 3).join(' | '))
  }
  const eh = replay(roundsBefore.filter(r => r.user_id === E))
  const vals = [...eh.values()]
  check('backfill: E covers every case (mastered, right but not mastered, wrong)',
    vals.some(o => o.fluent) && vals.some(o => !o.fluent && o.tc > 0) && vals.some(o => o.tw > 0 && o.tc === 0), JSON.stringify({ n: vals.length }))
  // The whole-km rows, card by card: verdict edges at 50 (bull), 130 (great), 260 (close) km in Europe.
  const e0 = await histOf(H, ['pin'])
  const k = j => geo.pinCardKey(EU[j].key)
  // Round 1 alone: what the first row did to each card.
  const first = replay(roundsBefore.filter(r => r.user_id === H).slice(0, 1))
  const g1 = j => { const o = first.get(k(j)); return o.fluent ? 'M' : o.tc ? 'R' : 'W' }
  check('whole-km round 1: 0, 50 (7999 ms), 130 km master, 131 and 260 km are Close, 261 and 649 km wrong, give-up wrong, 199 ms right, 8000 ms masters',
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(g1).join('') === 'MMMRRWWWRM', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(g1).join(''))
  check('whole-km rows: the give-up, the Close and the 199 ms cards master in round 2; best_ms ignores 199 ms',
    e0.get(k(7)).times_wrong === 1 && e0.get(k(7)).fluent_at && e0.get(k(3)).fluent_at && e0.get(k(3)).times_correct === 2 &&
    e0.get(k(8)).fluent_at && e0.get(k(8)).best_ms === 2000)
  check('whole-km rows: a mastered card stays mastered after a later 400 km miss', e0.get(k(0)).fluent_at && e0.get(k(0)).times_wrong === 1)
  check('backfill: every round is marked', (await q(`SELECT COUNT(*)::int n FROM geo_pin_rounds WHERE mastery_at IS NULL`))[0].n === 0)
  check('backfill: every other history row untouched (A\'s cap:fr, G\'s rows)',
    JSON.stringify(await q(`SELECT h.* FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key WHERE c.kind NOT IN ('find', 'pin') ORDER BY user_id, card_key`)) === otherHistBefore)
  check('backfill: round scores and answers untouched',
    JSON.stringify(await q(`SELECT id, user_id, deck, answers, completed_at FROM geo_pin_rounds ORDER BY completed_at, id`)) === JSON.stringify(roundsBefore))
  const ff = await fluentOf(F)
  const fExpect = new Set([...replay(roundsBefore.filter(r => r.user_id === F))].filter(([, o]) => o.fluent).map(([k]) => k))
  check(`backfill: F mastered ${ff.size} cards (${[...ff].filter(x => x.startsWith('find:')).length} finds of ${finds.length}, ${[...ff].filter(x => x.startsWith('pin:')).length} pins of ${pins.length})`,
    eqSet(ff, fExpect) && [...ff].filter(x => x.startsWith('pin:')).length === pins.length)
}

// ── 5. Badges ────────────────────────────────────────────────────────────────
{
  const defs = new Set((await q(`SELECT key FROM achievement_definitions WHERE category = 'Geography'`)).map(r => r.key))
  check('four new badges defined: geo_find_25, geo_find_all, geo_pin_25, geo_pin_all',
    ['geo_find_25', 'geo_find_all', 'geo_pin_25', 'geo_pin_all'].every(k => defs.has(k)))
  const th = new Map((await q(`SELECT key, threshold, description FROM achievement_definitions WHERE category = 'Geography'`)).map(r => [r.key, r]))
  const badTh = []
  for (const ct of geo.CONTINENTS) {
    const n = ALL.filter(c => c.continent === ct && c.kind !== 'cont').length
    if (th.get(`geo_continent_${ct}`).threshold !== n || !th.get(`geo_continent_${ct}`).description.startsWith(`All ${n} `)) badTh.push(`${ct} full`)
    if (th.get(`geo_continent_${ct}_half`).threshold !== Math.floor(n / 2) || !th.get(`geo_continent_${ct}_half`).description.startsWith(`${Math.floor(n / 2)} `)) badTh.push(`${ct} half`)
    if (th.get(`geo_continent_${ct}_25`).threshold !== 25) badTh.push(`${ct} 25`)
  }
  if (th.get('geo_mastered_all').threshold !== ALL.length) badTh.push('mastered_all')
  if (th.get('geo_find_all').threshold !== finds.length || th.get('geo_pin_all').threshold !== pins.length) badTh.push('find/pin all')
  check('badge thresholds and descriptions = the catalogue (continent full = every non-continent card incl. find and pin, half = floor(n/2))', badTh.length === 0, badTh.join(', '))
  const fb = await badgesOf(F)
  const fWant = expectedBadges(await fluentOf(F), defs)
  check(`F: after the backfill holds exactly the ${fWant.size} badges the rules give (${[...fWant].sort().join(' ')})`, eqSet(fb, fWant), [...fb].sort().join(' '))
  check('F: the find and pin ladders and the continent cubs are among them, no half rung',
    ['geo_find_25', 'geo_find_all', 'geo_pin_25', 'geo_pin_all', ...geo.CONTINENTS.map(ct => `geo_continent_${ct}_25`)].every(k => fb.has(k)) &&
    geo.CONTINENTS.every(ct => !fb.has(`geo_continent_${ct}_half`)))
  const eb = await badgesOf(E)
  check(`E: badges = the rules on E's mastered cards (${[...eb].sort().join(' ') || 'none'})`, eqSet(eb, expectedBadges(await fluentOf(E), defs)))
  // G qualified under 072's rules: awarded first, kept under 074's.
  const gb = await badgesOf(G)
  const gNew = expectedBadges(await fluentOf(G), defs)
  check('G: geo_continent_sa and geo_continent_af_half awarded under the old rules before they changed',
    gb.has('geo_continent_sa') && gb.has('geo_continent_af_half'), [...gb].sort().join(' '))
  check('G: ...which 074\'s rules alone would not give (so they really came first)', !gNew.has('geo_continent_sa') && !gNew.has('geo_continent_af_half'))
  await db.query(`SELECT award_geo_badges_for($1, FALSE)`, [G])
  check('G: awarding again under the new rules removes nothing', eqSet(await badgesOf(G), new Set([...gb, ...gNew])))
  const before = JSON.parse(badgesBefore)
  const now = await q(`SELECT user_id, achievement_key FROM user_achievements`)
  check(`no badge held before 074 was removed (${before.length})`, before.every(b => now.some(n => n.user_id === b.user_id && n.achievement_key === b.achievement_key)))
}

// ── 6. Rounds after 074 ──────────────────────────────────────────────────────
const hist = async (u, key) => (await q(`SELECT * FROM geo_history WHERE user_id = $1 AND card_key = $2`, [u, key]))[0]
{
  // Places: one tap of every kind, judged by lib/geo-pin.ts first.
  const ps = geo.buildPinRound('eu', 1, rnd)
  const plan = [[0, 2000], [0.15, 2500], [0.3, 2000], [0.6, 2000], [1.1, 2000], [null, 3000], [0.1, 9000], [0, 150], [0, 8000], [0, 8001]]
  const zero = pin.PIN_ACCURACY.eu.zero
  const pins1 = ps.map((p, j) => { const [f, ms] = plan[j]; return f === null ? { i: p.key, lat: null, lon: null, ms } : { i: p.key, ...offset(p, f * zero), ms } })
  const want = pins1.reduce((s, x, j) => s + pin.pinScore('eu', ps[j], x.lat === null ? null : x, x.ms).points, 0)
  const got = await placeRound(B, 'eu:1', pins1)
  check(`places: still returns the score as an INT, = lib/geo-pin.ts (${want})`, typeof got === 'number' && got === want)
  const v = pins1.map((x, j) => pin.pinVerdict('eu', x.lat === null ? null : pin.pinScore('eu', ps[j], x, x.ms).km))
  check('places: the round really has every verdict', ['bull', 'great', 'close', 'off', 'way', 'skip'].every(k => v.includes(k)), v.join(' '))
  const h = await Promise.all(ps.map(p => hist(B, geo.pinCardKey(p.key))))
  const state = h.map(r => (r.fluent_at ? 'M' : r.times_correct ? 'R' : 'W'))
  const wantState = pins1.map((x, j) => { const g = v[j] === 'bull' || v[j] === 'great' ? 2 : v[j] === 'close' ? 1 : 0; return fast(g, x.ms, TARGET.pin) ? 'M' : g ? 'R' : 'W' })
  check(`places: mastered/right/wrong per pin = ${wantState.join('')} (fast Bullseye or Great masters, Close or slow is right, the rest wrong)`,
    state.join('') === wantState.join('') && wantState.join('') === 'MMRWWWRRMR', state.join(''))
  check('places: a 150 ms pin is right but sets no best time', h[7].times_correct === 1 && h[7].best_ms === null && h[7].last_ms === 150)
  // Again: the mastered card given up stays mastered, the Close one pinned well masters.
  const pins2 = ps.map((p, j) => (j === 0 ? { i: p.key, lat: null, lon: null, ms: 1000 } : { i: p.key, lat: p.lat, lon: p.lon, ms: 3000 }))
  const fluentAt0 = h[0].fluent_at.getTime()
  await placeRound(B, 'eu:1', pins2)
  const h2 = await Promise.all(ps.map(p => hist(B, geo.pinCardKey(p.key))))
  check('places again: the mastered card given up keeps its fluent_at, one more wrong', h2[0].fluent_at.getTime() === fluentAt0 && h2[0].times_wrong === 1 && h2[0].times_correct === 1)
  check('places again: the Close, the slow and the 150 ms cards are now mastered', [2, 6, 7].every(j => h2[j].fluent_at) && h2[2].times_correct === 2)
  check('places again: best_ms only improves', h2[1].best_ms === 2500 && h2[3].best_ms === 3000)
}
{
  // Countries: fast find, slow find, a miss, a give-up, the sea, too fast.
  const cs = geo.buildCountryRound('eu', 1, rnd)
  const other = cs[3]
  const plan = ['fast', 'slow', 'miss', 'skip', 'sea', 'tooFast', 'fast', 'fast', 'fast', 'fast']
  const pins1 = cs.map((c, j) => {
    if (plan[j] === 'skip') return { iso: c.iso, tap: null, lat: null, lon: null, ms: 2000 }
    if (plan[j] === 'sea') return { iso: c.iso, tap: codeAt(45, -20), lat: 45, lon: -20, ms: 2000 }
    if (plan[j] === 'miss') return { ...inside(other.iso), iso: c.iso, ms: 2000 }
    return { ...inside(c.iso), ms: plan[j] === 'slow' ? 9000 : plan[j] === 'tooFast' ? 150 : 2500 }
  })
  const hit = pins1.map(p => pin.countryHit(cap(p.iso), p.lat === null ? null : { code: p.tap, lat: p.lat, lon: p.lon }))
  const want = pins1.reduce((s, p, j) => s + pin.countryPoints(hit[j], p.ms), 0)
  const got = await countryRound(B, 'eu:1:country', pins1)
  check(`countries: still returns the score as an INT, = lib/geo-pin.ts (${want})`, typeof got === 'number' && got === want)
  const h = await Promise.all(cs.map(c => hist(B, geo.geoKey('find', c.iso))))
  const state = h.map(r => (r.fluent_at ? 'M' : r.times_correct ? 'R' : 'W'))
  const wantState = pins1.map((p, j) => (hit[j] && p.ms >= 200 && p.ms <= TARGET.find ? 'M' : hit[j] ? 'R' : 'W'))
  check(`countries: mastered/right/wrong per tap = ${wantState.join('')} (a find within ${TARGET.find / 1000} s masters, a slow or 150 ms find is right, misses wrong)`,
    state.join('') === wantState.join('') && wantState.join('') === 'MRWWWRMMMM', state.join(''))
  // Again: miss the mastered one.
  const pins2 = cs.map((c, j) => (j === 0 ? { iso: c.iso, tap: null, lat: null, lon: null, ms: 2000 } : { ...inside(c.iso), ms: 2500 }))
  const f0 = h[0].fluent_at.getTime()
  await countryRound(B, 'eu:1:country', pins2)
  const h2 = await Promise.all(cs.map(c => hist(B, geo.geoKey('find', c.iso))))
  check('countries again: the mastered country given up stays mastered', h2[0].fluent_at.getTime() === f0 && h2[0].times_wrong === 1)
  check('countries again: the slow find is now mastered', h2[1].fluent_at !== null && h2[1].times_correct === 2)
  check('countries: every new round is marked as fed', (await q(`SELECT COUNT(*)::int n FROM geo_pin_rounds WHERE user_id = $1 AND mastery_at IS NULL`, [B]))[0].n === 0)
}
{
  // geo_pin_master's own count of newly mastered cards, and its refusals.
  const ps = geo.pinPlaces().filter(p => p.continent === 'oc').slice(0, 3)
  const ans = ps.map(p => ({ i: p.key, km: 0, ms: 2000 }))
  const n1 = (await q(`SELECT geo_pin_master($1, 'oc', 'place', $2::jsonb, now()) AS n`, [B, JSON.stringify(ans)]))[0].n
  const n2 = (await q(`SELECT geo_pin_master($1, 'oc', 'place', $2::jsonb, now()) AS n`, [B, JSON.stringify(ans)]))[0].n
  check('geo_pin_master: counts 3 newly mastered, then 0 for the same taps', n1 === 3 && n2 === 0, `${n1} ${n2}`)
  const n3 = (await q(`SELECT geo_pin_master($1, 'oc', 'place', $2::jsonb, now()) AS n`, [B, JSON.stringify([{ i: 'cap:zz', km: 0, ms: 2000 }, { i: ps[0].key, km: 0, ms: 2000 }, { i: ps[0].key, km: 0, ms: 2000 }])]))[0].n
  check('geo_pin_master: an unknown place is skipped and a repeated tap counts once', n3 === 0 && (await hist(B, 'pin:cap:zz')) === undefined && (await hist(B, geo.pinCardKey(ps[0].key))).times_correct === 3)
  const n4 = (await q(`SELECT geo_pin_master($1, 'oc', 'quiz', '[]'::jsonb, now()) + geo_pin_master($1, 'oc', 'place', '{}'::jsonb, now()) AS n`, [B]))[0].n
  check('geo_pin_master: an unknown mode or a non-array writes nothing', n4 === 0)
}

// ── 7. Explorer Points ───────────────────────────────────────────────────────
{
  for (const u of [B, F, E]) {
    const fl = await fluentOf(u)
    const want = [...fl].reduce((s, k) => s + (CARDS.get(k)?.points ?? 0), 0)
    const row = (await call(A, `SELECT points, fluent FROM geo_leaderboard_view WHERE user_id = $1`, [u]))
    const fp = [...fl].filter(k => /^(find|pin):/.test(k)).length
    check(`Explorer Points: ${u === B ? 'B' : u === F ? 'F' : 'E'} = ${want} over ${fl.size} mastered cards (${fp} find/pin), as the leaderboard says`,
      row.points === want && row.fluent === fl.size && fp > 0, JSON.stringify(row))
  }
}

// ── 8. 073's rules are otherwise unchanged ───────────────────────────────────
{
  const from = '  INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES (uid, p_deck, total, scored);\n  RETURN total;'
  const to = mode => `  INSERT INTO geo_pin_rounds (user_id, deck, score, answers, mastery_at) VALUES (uid, p_deck, total, scored, now());\n  PERFORM geo_pin_master(uid, cont, '${mode}', scored, now());\n  RETURN total;`
  check('record_geo_pin_round: 073\'s text with only the save line changed', (await fnText('record_geo_pin_round')) === src073.place.replace(from, to('place')) && src073.place.includes(from))
  check('record_geo_country_round: 073\'s text with only the save line changed', (await fnText('record_geo_country_round')) === src073.country.replace(from, to('country')) && src073.country.includes(from))
  let ok = true, n = 0
  for (const ct of geo.CONTINENTS) for (const l of pin.PIN_LEVELS) {
    const ps = geo.buildPinRound(ct, l, rnd)
    const pins = ps.map(p => (rnd() < 0.1 ? { i: p.key, lat: null, lon: null, ms: 3000 } : { i: p.key, ...offset(p, rnd() * 900), ms: Math.floor(rnd() * 9000) }))
    const ts = pins.reduce((s, x, j) => s + pin.pinScore(ct, ps[j], x.lat === null ? null : x, x.ms).points, 0)
    if ((await placeRound(D, pin.pinDeckId(ct, l), pins)) !== ts) ok = false
    const cs = geo.buildCountryRound(ct, l, rnd)
    const cp = cs.map(c => { const t = offset(c, rnd() * 300); return { iso: c.iso, tap: codeAt(t.lat, t.lon), lat: t.lat, lon: t.lon, ms: Math.floor(rnd() * 9000) } })
    const tc = cp.reduce((s, p) => s + pin.countryPoints(pin.countryHit(cap(p.iso), { code: p.tap, lat: p.lat, lon: p.lon }), p.ms), 0)
    if ((await countryRound(D, pin.countryDeckId(ct, l), cp)) !== tc) ok = false
    n += 2
  }
  check(`scores: SQL = lib/geo-pin.ts on ${n} random rounds of both modes after 074`, ok)
  const good = ['FR', 'DE', 'ES', 'IT', 'PL', 'NL', 'BE', 'PT', 'AT', 'CH'].map(iso => ({ ...cap(iso), tap: iso, ms: 2000 }))
  const goodP = EU.map(p => ({ i: p.key, lat: p.lat, lon: p.lon, ms: 2000 }))
  const BAD = [
    ['record_geo_country_round', 'a places deck', 'eu:1', good],
    ['record_geo_country_round', '9 countries', 'eu:1:country', good.slice(0, 9)],
    ['record_geo_country_round', 'a country twice', 'eu:1:country', [...good.slice(0, 9), good[0]]],
    ['record_geo_country_round', 'a country of another continent', 'eu:1:country', [...good.slice(0, 9), { ...cap('KE'), tap: 'KE', ms: 1 }]],
    ['record_geo_country_round', 'a lower-case tap', 'eu:1:country', [...good.slice(0, 9), { ...good[9], tap: 'ch' }]],
    ['record_geo_country_round', 'a latitude off the map', 'eu:1:country', [...good.slice(0, 9), { ...good[9], lat: 95 }]],
    ['record_geo_pin_round', 'a country deck', 'eu:1:country', goodP],
    ['record_geo_pin_round', 'a place twice', 'eu:1', [...goodP.slice(0, 9), goodP[0]]],
    ['record_geo_pin_round', 'a place of another continent', 'eu:1', [...goodP.slice(0, 9), { i: 'cap:ke', lat: 0, lon: 0, ms: 1 }]],
    ['record_geo_pin_round', 'a pin off the map', 'eu:1', [...goodP.slice(0, 9), { ...goodP[9], lat: 95 }]],
  ]
  const nR = (await q(`SELECT COUNT(*)::int n FROM geo_pin_rounds`))[0].n
  const hB = JSON.stringify(await q(`SELECT * FROM geo_history ORDER BY user_id, card_key`))
  let allRefused = true
  for (const [fn, what, deck, pins] of BAD) {
    const err = await refused(A, 'authenticated', `SELECT ${fn}($1, $2::jsonb)`, [deck, JSON.stringify(pins)])
    if (!err) { allRefused = false; console.log(`      not refused: ${fn} with ${what}`) }
  }
  check(`refusals: all ${BAD.length} still refused`, allRefused)
  check('refusals: saved no round and wrote no history', (await q(`SELECT COUNT(*)::int n FROM geo_pin_rounds`))[0].n === nR &&
    JSON.stringify(await q(`SELECT * FROM geo_history ORDER BY user_id, card_key`)) === hB)
  check('the good rounds themselves are accepted', (await countryRound(A, 'eu:1:country', good)) === 1100 && (await placeRound(A, 'eu:3', goodP)) === 1100)
  check('the app\'s readiness probe still gets a refusal, not a missing function', /unknown pin deck/.test(await refused(A, 'authenticated', `SELECT record_geo_country_round('probe', '[]'::jsonb)`)))
}

// ── 9. Grade parity ──────────────────────────────────────────────────────────
{
  const rows = []
  for (const ct of geo.CONTINENTS) {
    const { bull, zero } = pin.PIN_ACCURACY[ct]
    const edges = [bull, zero * pin.PIN_VERDICT_SHARE.great, zero * pin.PIN_VERDICT_SHARE.close, zero]
    for (let km = 0; km <= 1600; km += 1.3) rows.push({ ct, km })
    for (const e of edges) for (const d of [-1e-9, 0, 1e-9, -0.5, 0.5]) rows.push({ ct, km: e + d })
    rows.push({ ct, km: null })
  }
  rows.push({ ct: 'xx', km: 0 })
  const sq = await q(`SELECT x.ct, x.km, geo_pin_grade(x.ct, x.km) AS g FROM jsonb_to_recordset($1::jsonb) AS x(ct text, km double precision)`, [JSON.stringify(rows)])
  const bad = sq.filter(r => r.g !== (r.ct === 'xx' ? 0 : grade(r.ct, r.km)))
  check(`parity: geo_pin_grade = lib/geo-pin.ts pinVerdict on ${sq.length} probes, edges included`, sq.length === rows.length && bad.length === 0, JSON.stringify(bad.slice(0, 3)))
}

// ── 10. Privileges ───────────────────────────────────────────────────────────
for (const [what, stmt] of [
  ['call geo_pin_master', `SELECT geo_pin_master('${B}', 'eu', 'place', '[]'::jsonb, now())`],
  ['call geo_pin_grade', `SELECT geo_pin_grade('eu', 0)`],
  ['call award_geo_badges_for', `SELECT award_geo_badges_for('${B}', TRUE)`],
  ['insert history', `INSERT INTO geo_history (user_id, card_key, times_correct, fluent_at) VALUES ('${B}', 'find:fr', 1, now())`],
  ['update history', `UPDATE geo_history SET fluent_at = now()`],
  ['delete history', `DELETE FROM geo_history`],
  ['mark a round', `UPDATE geo_pin_rounds SET mastery_at = NULL`],
  ['insert a round', `INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES ('${B}', 'eu:1', 0, '[]')`],
]) check(`student cannot ${what}`, /permission denied/.test(await refused(B, 'authenticated', stmt)), stmt.slice(0, 60))
for (const [what, stmt] of [
  ['call geo_pin_master', `SELECT geo_pin_master('${B}', 'eu', 'place', '[]'::jsonb, now())`],
  ['call geo_pin_grade', `SELECT geo_pin_grade('eu', 0)`],
  ['call record_geo_pin_round', `SELECT record_geo_pin_round('eu:1', '[]'::jsonb)`],
  ['call record_geo_country_round', `SELECT record_geo_country_round('eu:1:country', '[]'::jsonb)`],
]) check(`anon cannot ${what}`, /permission denied/.test(await refused(null, 'anon', stmt)), stmt.slice(0, 60))
{
  await as(B)
  const seen = (await db.query(`SELECT DISTINCT user_id FROM geo_history`)).rows.map(r => r.user_id)
  await su()
  check('a student reads only their own history (RLS)', seen.length === 1 && seen[0] === B, JSON.stringify(seen))
  await as(D)
  const all = (await db.query(`SELECT COUNT(DISTINCT user_id)::int n FROM geo_history`)).rows[0].n
  await su()
  check('an admin reads every student\'s history', all === (await q(`SELECT COUNT(DISTINCT user_id)::int n FROM geo_history`))[0].n)
}

// ── 11. Re-run after play ────────────────────────────────────────────────────
{
  // Rounds played since were saved through the RPCs (no client asked for
  // badges here), so a re-run may ADD badges they earned, nothing else.
  const s = await snapAll(false)
  const b0 = await q(`SELECT user_id, achievement_key FROM user_achievements`)
  await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
  check('re-run after play: cards, history, rounds unchanged (no round is fed twice)', (await snapAll(false)) === s)
  const b1 = await q(`SELECT user_id, achievement_key FROM user_achievements`)
  const defs = new Set((await q(`SELECT key FROM achievement_definitions WHERE category = 'Geography'`)).map(r => r.key))
  const bWant = expectedBadges(await fluentOf(B), defs)
  check(`re-run after play: badges only added (${b0.length} -> ${b1.length}), B now holds what the rules give`,
    b0.every(x => b1.some(y => y.user_id === x.user_id && y.achievement_key === x.achievement_key)) && [...bWant].every(k => b1.some(y => y.user_id === B && y.achievement_key === k)) && bWant.size > 0)
}

console.log(fails ? `\n${fails} FAILED` : '\nALL PASSED')
process.exit(fails ? 1 : 0)
