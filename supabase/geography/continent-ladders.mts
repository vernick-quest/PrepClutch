// Generates migration 072: a three-step animal ladder per continent.
// Run: node supabase/geography/continent-ladders.mts
//
//   25 cards  the young animal (Lion Cub)
//   half      growing up (Young Lion)
//   all       the existing badge (Lion of Africa)
//
// Every rung counts only cards a student can earn INSIDE that continent's
// tab: continent rounds never ask "which continent?" (it answers itself), so
// 'cont' cards are left out of continent badges. Nobody held a continent
// badge when this changed (Geography had not been played yet).
//
// The award function is 070's, copied from the applied 070 file and changed
// only in its continent rung, so nothing else can drift. The output is pure
// ASCII (emoji travel as base64) because a non-UTF-8 clipboard garbled
// 069/070's emoji once already.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const geo = await import('../../lib/geo.ts')

type Ct = 'af' | 'as' | 'eu' | 'na' | 'sa' | 'oc'
const CTS: Ct[] = ['af', 'as', 'eu', 'na', 'sa', 'oc']

// [young label, emoji, rarity, lore] then [growing label, emoji, rarity, lore]
const RUNGS: Record<Ct, [[string, string, string, string], [string, string, string, string]]> = {
  af: [['Lion Cub', '🦁', 'Common', 'A tiny lion with a very big roar for its size. Twenty-five African cards and it already knows where the savanna ends.'],
       ['Young Lion', '🦁', 'Rare', 'Half of Africa learned. The mane is coming in and the roar now echoes from Cairo to Cape Town.']],
  as: [['Panda Cub', '🐼', 'Common', 'Twenty-five Asian cards. The cub mostly naps on a map of Asia, which counts as studying if you ask it.'],
       ['Young Panda', '🐼', 'Rare', 'Halfway across the biggest continent. The panda knows Tokyo from Tashkent and has run out of bamboo to celebrate with.']],
  eu: [['Hoglet', '🦔', 'Common', 'A baby hedgehog, small and spiky. Twenty-five European cards and it can already roll from Lisbon to Oslo.'],
       ['Young Hedgehog', '🦔', 'Rare', 'Half of Europe learned. Its spikes are sharp and so is its memory for flags with stripes.']],
  na: [['Eaglet', '🦅', 'Common', 'Not flying yet, but it has seen twenty-five North American cards from the nest and remembered every one.'],
       ['Young Eagle', '🦅', 'Rare', 'Halfway there and soaring. From up here it can spot Ottawa, Havana and Panama City without squinting.']],
  sa: [['Cria', '🦙', 'Common', 'A cria is a baby llama. This one has learned twenty-five South American cards and hums about them in the Andes.'],
       ['Young Llama', '🦙', 'Rare', 'Half of South America learned. It strides from Bogota to Buenos Aires and only stops to show off.']],
  oc: [['Joey', '🦘', 'Common', 'A joey peeking out of the pouch, already pointing at twenty-five Oceania cards on the map.'],
       ['Young Kangaroo', '🦘', 'Rare', 'Half of Oceania learned. It bounds from Sydney to Suva and lands every jump.']],
}

const countOf = (ct: Ct) => geo.allGeoCards().filter((c: any) => c.continent === ct && c.kind !== 'cont').length
const q = (s: string) => {
  if (/[;$]|--/.test(s)) { console.error('risky characters in literal:', s.slice(0, 60)); process.exit(1) }
  return `'${s.replace(/'/g, "''")}'`
}
const b64 = (s: string) => `convert_from(decode('${Buffer.from(s, 'utf8').toString('base64')}', 'base64'), 'UTF8')`

const rows: string[] = []
const steps: string[] = []
const fullUpdates: string[] = []
for (const ct of CTS) {
  const n = countOf(ct), half = Math.floor(n / 2), name = geo.CONTINENT_LABEL[ct]
  const [[l1, e1, r1, lore1], [l2, e2, r2, lore2]] = RUNGS[ct]
  rows.push(`(${q(`geo_continent_${ct}_25`)}, ${q(l1)}, ${b64(e1)}, ${q(`25 ${name} cards mastered.`)}, ${q(r1)}, ${q(l1)}, 'Geography',\n ${q(lore1)}, 25)`)
  rows.push(`(${q(`geo_continent_${ct}_half`)}, ${q(l2)}, ${b64(e2)}, ${q(`${half} ${name} cards mastered, half of them.`)}, ${q(r2)}, ${q(l2)}, 'Geography',\n ${q(lore2)}, ${half})`)
  steps.push(`('${ct}', '25', 25), ('${ct}', 'half', ${half})`)
  fullUpdates.push(`UPDATE achievement_definitions SET description = ${q(`All ${n} ${name} cards mastered: capitals, flags, shapes and cities.`)}, threshold = ${n} WHERE key = 'geo_continent_${ct}';`)
}

// 070's award function, verbatim, with only the continent rung replaced.
const m070 = fs.readFileSync(path.join(root, 'supabase/migrations/070_geography_map.sql'), 'utf8')
const start = m070.indexOf('CREATE OR REPLACE FUNCTION award_geo_badges_for')
const end = m070.indexOf('$$;', start) + 3
let fn = m070.slice(start, end)
const oldRung = `    SELECT 'geo_continent_' || ct FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS ct
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE continent = ct AND NOT fluent)`
if (fn.split(oldRung).length !== 2) { console.error('070 continent rung not found exactly once'); process.exit(1) }
fn = fn.replace(oldRung, `    SELECT 'geo_continent_' || ct FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS ct
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE continent = ct AND kind <> 'cont' AND NOT fluent)
    UNION ALL
    SELECT 'geo_continent_' || r.ct || '_' || r.step
      FROM (VALUES ${steps.join(',\n                   ')}) AS r(ct, step, t)
     WHERE (SELECT COUNT(*) FROM g WHERE continent = r.ct AND kind <> 'cont' AND fluent) >= r.t`)

const sql = `-- 072 - Geography: a growing animal ladder for every continent
--
-- Each continent gets two new rungs below its existing badge, the animal
-- growing up as a student learns more of that continent:
--
--   25 cards   Lion Cub, Panda Cub, Hoglet, Eaglet, Cria, Joey
--   half       Young Lion, Young Panda, Young Hedgehog, Young Eagle, Young Llama, Young Kangaroo
--   all        Lion of Africa ... Kangaroo of Oceania (existing)
--
-- All three count only cards a student can earn inside that continent's tab
-- (capitals, flags, shapes, cities). Continent rounds never ask which
-- continent a country is on, so those cards no longer count toward continent
-- badges. The existing six badges get new descriptions and thresholds.
--
-- The award function is 070's with only its continent rung changed; the
-- per-user helper stays revoked from students. Existing qualifiers are
-- awarded at the end. Badges are only ever added. Pure ASCII: emoji travel
-- as base64. Re-runnable.
-- Generated by supabase/geography/continent-ladders.mts


-- 1. The twelve new rungs

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

${rows.join(',\n\n')}

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;


-- 2. The full-continent badges now count the same cards

${fullUpdates.join('\n')}


-- 3. Awarding

${fn}

REVOKE ALL ON FUNCTION award_geo_badges_for(UUID, BOOLEAN) FROM PUBLIC, anon, authenticated;


-- 4. Award what students have already earned

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT DISTINCT user_id FROM geo_history LOOP
    PERFORM award_geo_badges_for(r.user_id, FALSE);
  END LOOP;
END $$;


-- Expected: geo_badges 35, ladder_rungs 12, helper_callable_by_students false

SELECT
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography')   AS geo_badges,
  (SELECT COUNT(*) FROM achievement_definitions
    WHERE key ~ '^geo_continent_[a-z]{2}_(25|half)$')                           AS ladder_rungs,
  has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE')
                                                                              AS helper_callable_by_students;
`
const nonAscii = [...sql].filter(c => c.charCodeAt(0) > 127)
if (nonAscii.length) { console.error('refusing to write: non-ASCII', nonAscii.slice(0, 5)); process.exit(1) }
fs.writeFileSync(path.join(root, 'supabase/migrations/072_geo_continent_ladders.sql'), sql)
console.log(`wrote supabase/migrations/072_geo_continent_ladders.sql: 12 rungs, counts ${CTS.map(c => `${c} ${countOf(c)}`).join(', ')}`)
