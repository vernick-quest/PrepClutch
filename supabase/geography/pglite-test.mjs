// PGlite run of supabase/migrations/069_geography.sql against a stub of the
// Supabase schema it touches (auth.users, auth.uid(), profiles with is_admin,
// achievement_definitions, user_achievements, roles anon and authenticated,
// and Supabase's default grants to both on every new table and function).
//
// PGlite is not a dependency of the app. Install it OUTSIDE the repo and run
// a copy of this file from there:
//
//   mkdir /tmp/geo-pglite && cd /tmp/geo-pglite && npm i @electric-sql/pglite@0.2
//   cp <repo>/supabase/geography/pglite-test.mjs run.mjs
//   REPO=<repo> node run.mjs
//
// Checks 069 alone, so it uses the 069 card kinds (KINDS_069); the map
// migration has its own test, pglite-map-test.mjs.
//
// Covers: first run and re-run inside BEGIN/COMMIT, TS-vs-SQL catalogue
// parity, answer recording (slow, too fast, fast, repeat, wrong after
// mastery), badge awards with negative cases, backfill, privileges and RLS.
import { PGlite } from '@electric-sql/pglite'
import fs from 'node:fs'

const REPO = process.env.REPO ?? '/Users/robert/PrepClutch'
await import(`${REPO}/supabase/geography/ts-resolve.mts`)
const SQL = fs.readFileSync(`${REPO}/supabase/migrations/069_geography.sql`, 'utf8')
const geo = await import(`${REPO}/lib/geo.ts`)

const A = '11111111-1111-1111-1111-111111111111'   // student
const B = '22222222-2222-2222-2222-222222222222'   // student who masters everything
const C = '33333333-3333-3333-3333-333333333333'   // had history before a re-run (backfill)
const D = '44444444-4444-4444-4444-444444444444'   // admin

let fails = 0
const check = (name, ok, extra = '') => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${extra ? '  ' + extra : ''}`); if (!ok) fails++ }

const db = new PGlite()
await db.exec(`
  CREATE ROLE anon; CREATE ROLE authenticated;
  GRANT USAGE ON SCHEMA public TO anon, authenticated;
  -- What Supabase does for every new table and function in public.
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
  -- A Math Facts badge already exists, to prove nothing here touches it.
  INSERT INTO achievement_definitions(key,label,description,icon_emoji,category) VALUES ('facts_mastered_10','x','x','x','Math Facts');
  INSERT INTO user_achievements VALUES ('${A}','facts_mastered_10',now());
`)

const as = async (uid, role = 'authenticated') => {
  await db.exec(`RESET ROLE; SELECT set_config('t.uid', '${uid ?? ''}', false); SET ROLE ${role}`)
}
const su = () => db.exec(`RESET ROLE; SELECT set_config('t.uid', '', false)`)
const answer = async (uid, key, correct, ms) => {
  await as(uid)
  const r = (await db.query('SELECT record_geo_answer($1, $2, $3) AS r', [key, correct, ms])).rows[0].r
  await su()
  return r
}
const held = async u => (await db.query(`SELECT achievement_key k FROM user_achievements WHERE user_id = $1 AND achievement_key LIKE 'geo_%' ORDER BY 1`, [u])).rows.map(x => x.k)
const award = async (u, perfect = false) => {
  await as(u)
  const r = (await db.query('SELECT * FROM award_geo_badges($1)', [perfect])).rows.map(x => Object.values(x)[0])
  await su()
  return r
}

// ── 1. First run, wrapped like the Supabase editor ───────────────────────────
let res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
const v1 = res.at(-2).rows[0]
console.log('verification (first run):', JSON.stringify(v1))
check('first run: 1351 cards, 193 countries, 15440 points, 23 badges',
  v1.cards === 1351 && v1.countries === 193 && v1.max_points === 15440 && v1.geo_badges === 23 && v1.orphan_history === 0)
check('first run: helper not callable by students, record not by anon',
  v1.helper_callable_by_students === false && v1.record_callable_by_anon === false)
check('first run: leaderboard has one row per profile', v1.leaderboard_rows === 4)

// ── 2. Re-run is harmless ────────────────────────────────────────────────────
res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
const v2 = res.at(-2).rows[0]
check('re-run: identical verification', JSON.stringify(v1) === JSON.stringify(v2), JSON.stringify(v2))

// ── 3. TS vs SQL catalogue parity ────────────────────────────────────────────
const sqlCards = (await db.query('SELECT card_key, iso, kind, continent, points, target_ms FROM geo_cards ORDER BY card_key')).rows
const tsCards = geo.geoCards(geo.KINDS_069).map(c => ({ card_key: c.key, iso: c.iso, kind: c.kind, continent: c.continent, points: c.points, target_ms: c.targetMs }))
  .sort((x, y) => (x.card_key < y.card_key ? -1 : 1))
check('parity: same keys, points and targets as lib/geo.ts', JSON.stringify(sqlCards) === JSON.stringify(tsCards), `${sqlCards.length} vs ${tsCards.length}`)

// ── 4. Recording answers ─────────────────────────────────────────────────────
const fluentAt = async (u, k) => (await db.query('SELECT fluent_at, times_correct, times_wrong, best_ms FROM geo_history WHERE user_id=$1 AND card_key=$2', [u, k])).rows[0]
check('slow correct (7001ms on a 7s card) does not master', (await answer(A, 'cap:fr', true, 7001)) === false && (await fluentAt(A, 'cap:fr')).fluent_at === null)
check('too fast (150ms) does not master', (await answer(A, 'cap:fr', true, 150)) === false && (await fluentAt(A, 'cap:fr')).fluent_at === null)
check('fast correct (1500ms) masters, returns true', (await answer(A, 'cap:fr', true, 1500)) === true && (await fluentAt(A, 'cap:fr')).fluent_at !== null)
const before = await fluentAt(A, 'cap:fr')
check('repeat fast answer returns false (already mastered)', (await answer(A, 'cap:fr', true, 1200)) === false)
check('wrong answer after mastery keeps mastery', (await answer(A, 'cap:fr', false, 3000)) === false &&
  String((await fluentAt(A, 'cap:fr')).fluent_at) === String(before.fluent_at))
const row = await fluentAt(A, 'cap:fr')
check('counters: 4 correct, 1 wrong, best 1200ms (150ms ignored)', row.times_correct === 4 && row.times_wrong === 1 && row.best_ms === 1200, JSON.stringify(row))
check('exactly at target (7000ms) masters', (await answer(A, 'capr:fr', true, 7000)) === true)
check('null time never masters', (await answer(A, 'cont:fr', true, null)) === false)
let err = ''
try { await answer(A, 'cap:xx', true, 1000) } catch (e) { err = e.message } finally { await su() }
check('unknown key refused', /unknown geography card/.test(err), err)
err = ''
try { await as(A, 'anon'); await db.query(`SELECT record_geo_answer('cap:de', true, 1000)`) } catch (e) { err = e.message } finally { await su() }
check('anon cannot call record_geo_answer', /permission denied/.test(err), err)
const lbA = (await db.query('SELECT points, fluent, capitals FROM geo_leaderboard_view WHERE user_id = $1', [A])).rows[0]
check('leaderboard: A has 25 points (cap 15 + capr 10), 2 fluent, 2 capitals', lbA.points === 25 && lbA.fluent === 2 && lbA.capitals === 2, JSON.stringify(lbA))

// Students cannot write history or the catalogue directly.
for (const [what, stmt] of [
  ['UPDATE own history (clear fluent_at)', `UPDATE geo_history SET fluent_at = NULL WHERE user_id = '${A}'`],
  ['INSERT history', `INSERT INTO geo_history(user_id, card_key, fluent_at) VALUES ('${A}', 'cap:de', now())`],
  ['DELETE history', `DELETE FROM geo_history WHERE user_id = '${A}'`],
  ['UPDATE catalogue points', `UPDATE geo_cards SET points = 1000`],
]) {
  err = ''
  try { await as(A); await db.query(stmt) } catch (e) { err = e.message } finally { await su() }
  check(`student cannot ${what}`, /permission denied/.test(err), err)
}
check('A still mastered after those attempts', (await fluentAt(A, 'cap:fr')).fluent_at !== null)

// ── 5. Badges ────────────────────────────────────────────────────────────────
const cards = geo.geoCards(geo.KINDS_069)
const oc = cards.filter(c => c.continent === 'oc')
check('Oceania has 98 cards', oc.length === 98)
for (const c of oc.slice(1)) await answer(B, c.key, true, 1500)
let got = await award(B)
check('one card short of Oceania: no continent badge', !got.includes('geo_continent_oc'), got.join(' '))
check('…but ladder 10/50 and capitals/flags 25 are (27 of 28 each), not continents 25 (only 14) nor ladder 100',
  ['geo_mastered_10', 'geo_mastered_50', 'geo_capitals_25', 'geo_flags_25'].every(k => got.includes(k)) &&
  !got.includes('geo_mastered_100') && !got.includes('geo_continents_25'), got.join(' '))
await answer(B, oc[0].key, true, 1500)
got = await award(B)
check('last Oceania card: Kangaroo of Oceania awarded', got.includes('geo_continent_oc'), got.join(' '))
check('award again: nothing new', (await award(B)).length === 0)
check('perfect round reported: Perfect Passport', (await award(B, true)).join() === 'geo_perfect_round')
// Every capital card but one: no Capital Crown.
const caps = cards.filter(c => c.kind === 'cap' || c.kind === 'capr')
for (const c of caps.slice(1)) await answer(B, c.key, true, 1500)
got = await award(B)
check('one capital card short: no Capital Crown', !got.includes('geo_capitals_all') && !(await held(B)).includes('geo_capitals_all'), got.join(' '))
await answer(B, caps[0].key, true, 1500)
check('all capital cards: Capital Crown', (await award(B)).includes('geo_capitals_all'))
for (const c of cards) await answer(B, c.key, true, 1500)
got = await award(B)
check('everything: all remaining badges, World Turtle included', got.includes('geo_mastered_all'), got.length + ' new')
check('B holds all 23 geography badges', (await held(B)).length === 23)
await answer(B, 'cap:fr', false, 9000)
check('a miss after everything removes nothing', (await held(B)).length === 23 &&
  (await db.query(`SELECT points FROM geo_leaderboard_view WHERE user_id = '${B}'`)).rows[0].points === 15440)
check('math badge untouched', (await db.query(`SELECT COUNT(*)::int n FROM user_achievements WHERE achievement_key = 'facts_mastered_10'`)).rows[0].n === 1)

// Helper refused for students, wrapper allowed.
err = ''
try { await as(A); await db.query(`SELECT * FROM award_geo_badges_for('${A}', true)`) } catch (e) { err = e.message } finally { await su() }
check('award_geo_badges_for refused under SET ROLE authenticated', /permission denied/.test(err), err)
err = ''
try { await as(A, 'anon'); await db.query(`SELECT * FROM award_geo_badges(true)`) } catch (e) { err = e.message } finally { await su() }
check('award_geo_badges refused for anon', /permission denied/.test(err), err)

// ── 6. Backfill on (re-)run ──────────────────────────────────────────────────
await db.exec(`INSERT INTO geo_history (user_id, card_key, times_correct, fluent_at)
  SELECT '${C}', card_key, 1, now() FROM geo_cards WHERE continent = 'sa'`)
check('C has no badges before the re-run', (await held(C)).length === 0)
res = await db.exec('BEGIN;\n' + SQL + '\nCOMMIT;')
const c3 = await held(C)
check('re-run backfills C: Llama of South America + ladder', c3.includes('geo_continent_sa') && c3.includes('geo_mastered_50') && !c3.includes('geo_mastered_100'), c3.join(' '))
check('re-run leaves B with 23', (await held(B)).length === 23)

// ── 7. Who can read what ─────────────────────────────────────────────────────
await as(A)
await db.query(`INSERT INTO geo_rounds (user_id, deck, cards, correct, fast, points, answers) VALUES ($1, 'all:all', 10, 9, 8, 50, '[]')`, [A])
await su(); await as(B)
await db.query(`INSERT INTO geo_rounds (user_id, deck, cards, correct, fast, points, answers) VALUES ($1, 'oc:flags', 10, 10, 10, 80, '[]')`, [B])
await su()
err = ''
try { await as(A); await db.query(`INSERT INTO geo_rounds (user_id, deck, cards, correct, fast, points, answers) VALUES ('${B}', 'x', 1, 1, 1, 1, '[]')`) } catch (e) { err = e.message } finally { await su() }
check('A cannot insert a round as B', /row-level security/.test(err), err)
err = ''
try { await as(A); await db.query(`UPDATE geo_rounds SET points = 9999`) } catch (e) { err = e.message } finally { await su() }
check('A cannot update rounds', /permission denied/.test(err), err)

const seen = async (u, sql) => { await as(u); const r = (await db.query(sql)).rows; await su(); return r }
const hA = await seen(A, 'SELECT DISTINCT user_id FROM geo_history')
const rA = await seen(A, 'SELECT DISTINCT user_id FROM geo_rounds')
check('student sees only own geo_history', hA.length === 1 && hA[0].user_id === A, JSON.stringify(hA))
check('student sees only own geo_rounds', rA.length === 1 && rA[0].user_id === A, JSON.stringify(rA))
const hD = await seen(D, 'SELECT DISTINCT user_id FROM geo_history ORDER BY 1')
const rD = await seen(D, 'SELECT DISTINCT user_id FROM geo_rounds ORDER BY 1')
check('admin sees every geo_history', hD.length === 3, JSON.stringify(hD.map(x => x.user_id[0])))
check('admin sees every geo_rounds', rD.length === 2)
err = ''
try { await as(null, 'anon'); await db.query('SELECT * FROM geo_leaderboard_view') } catch (e) { err = e.message } finally { await su() }
check('anon cannot read the leaderboard', /permission denied/.test(err), err)
err = ''
try { await as(null, 'anon'); await db.query('SELECT * FROM geo_history') } catch (e) { err = e.message } finally { await su() }
check('anon cannot read geo_history', /permission denied/.test(err), err)
const lbSeen = await seen(A, 'SELECT user_id, points FROM geo_leaderboard_view ORDER BY points DESC')
check('student reads the whole leaderboard', lbSeen.length === 4 && lbSeen[0].points === 15440)

console.log(fails ? `\n${fails} FAILED` : '\nALL PASSED')
process.exit(fails ? 1 : 0)
