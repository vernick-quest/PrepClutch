// Builds lib/geo-data.ts from the curated table (curation.mts) and the
// Wikidata snapshot (wikidata-snapshot.json, CC0). Run:
//
//   node supabase/geography/build-data.mts
//
// Refuses to write when a curated fact disagrees with Wikidata and has no
// written reason in REASONS, or when a reason no longer explains anything.
// So the data is Wikidata's except where a reason says otherwise.
//
// What comes from Wikidata directly: ISO alpha-3 codes, capital coordinates,
// and the languages added to each country's never-a-wrong-answer list.

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import {
  ROWS, REASONS, ALSO_CONTINENT, LOOKALIKE_FLAGS, LANGUAGE_ALIASES, CAPITAL_ALIASES,
} from './curation.mts'
import type { Continent } from './curation.mts'
import { normName } from './normalize.mts'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')

interface SnapCap { name: string; item: string; lat: number | null; lon: number | null; current: boolean; via: string }
interface SnapRow {
  iso: string; item: string; label: string; iso3: string[]
  languages: string[]; currencies: string[]; continents: string[]; capitals: SnapCap[]
}
const snap = JSON.parse(fs.readFileSync(path.join(here, 'wikidata-snapshot.json'), 'utf8')) as
  { source: string; fetched: string; rows: SnapRow[] }
const byIso = new Map(snap.rows.map(r => [r.iso, r]))

const WD_CONTINENT: Record<string, Continent[]> = {
  'Africa': ['af'], 'Asia': ['as'], 'Europe': ['eu'], 'North America': ['na'], 'South America': ['sa'],
  'Oceania': ['oc'], 'Insular Oceania': ['oc'], 'Australian continent': ['oc'], 'Eurasia': ['eu', 'as'],
  'Afro-Eurasia': ['af', 'eu', 'as'], 'Americas': ['na', 'sa'],
}

const problems: string[] = []
const used = new Set<string>()
const info: string[] = []

/** A disagreement with Wikidata: fine only with a written reason. */
function differs(key: string, what: string) {
  if (REASONS[key]) used.add(key)
  else problems.push(`${key}: ${what}, and no entry in REASONS`)
}

const langName = (l: string) => LANGUAGE_ALIASES[l] ?? l.replace(/ language$/, '')
const round = (n: number) => Math.round(n * 100) / 100

const countries = ROWS.map(([iso, name, continent, capitals, official, recognised, currencies]) => {
  const w = byIso.get(iso)
  if (!w) { problems.push(`${iso}: not in the Wikidata snapshot`); return null }

  // ISO alpha-3, straight from Wikidata.
  if (w.iso3.length !== 1) problems.push(`${iso}: Wikidata has ${w.iso3.length} alpha-3 codes (${w.iso3.join(' ')})`)

  // Capitals: each must be a place Wikidata knows, with coordinates. A
  // capital that is not a CURRENT Wikidata capital needs a reason.
  const caps = capitals.map(c => {
    const label = CAPITAL_ALIASES[`${iso}:${c}`] ?? c
    const m = w.capitals.find(x => normName(x.name) === normName(label))
    if (!m) { problems.push(`${iso}: capital ${c} not found in Wikidata`); return { name: c, lat: NaN, lon: NaN } }
    if (!m.current) differs(`${iso}:capital:${c}`, `${c} is not a current Wikidata capital (${m.via})`)
    if (m.lat === null || m.lon === null) problems.push(`${iso}: capital ${c} has no coordinates`)
    return { name: c, lat: round(m.lat ?? NaN), lon: round(m.lon ?? NaN) }
  })
  for (const x of w.capitals.filter(x => x.current)) {
    if (!capitals.some(c => normName(CAPITAL_ALIASES[`${iso}:${c}`] ?? c) === normName(x.name)))
      info.push(`${iso}: Wikidata also lists ${x.name} as a current capital, not used`)
  }

  // Languages: every official language we ASK about must be official in
  // Wikidata or have a reason. Wikidata's whole list joins the
  // never-a-wrong-answer list.
  const wdLangs = w.languages.map(langName)
  for (const l of official) {
    if (!wdLangs.some(x => x.toLowerCase() === l.toLowerCase()))
      differs(`${iso}:language:${l}`, `${l} is not an official language in Wikidata (${wdLangs.join(', ') || 'none'})`)
  }
  const notWrong = [...new Set([...recognised, ...wdLangs])]
    .filter(l => !official.some(o => o.toLowerCase() === l.toLowerCase()))
    .sort()

  // Currencies: the code must be a current Wikidata currency, or reasoned.
  const wdCodes = w.currencies.map(c => c.split('#')[1]).filter(Boolean)
  for (const [code] of currencies) {
    if (!wdCodes.includes(code)) differs(`${iso}:currency:${code}`, `${code} is not a current Wikidata currency (${wdCodes.join(' ') || 'none'})`)
  }

  // Continent: the M49 assignment, checked against Wikidata's continents.
  const wdCont = new Set(w.continents.flatMap(c => WD_CONTINENT[c] ?? []))
  if (wdCont.size && !wdCont.has(continent)) differs(`${iso}:continent`, `M49 says ${continent}, Wikidata says ${w.continents.join('/')}`)

  return {
    iso, iso3: w.iso3[0] ?? '', name, continent, capitals: caps,
    languages: official, notWrong,
    currencies: currencies.map(([code, short, full]) => ({ code, short, name: full })),
    ...(ALSO_CONTINENT[iso] ? { alsoContinent: ALSO_CONTINENT[iso] } : {}),
    wikidata: w.item,
  }
})

for (const k of Object.keys(REASONS)) if (!used.has(k)) problems.push(`REASONS['${k}'] explains nothing: remove it`)

info.forEach(l => console.log('info', l))
if (problems.length) {
  console.error(`Refusing to write lib/geo-data.ts, ${problems.length} problem(s):`)
  problems.forEach(p => console.error('  ' + p))
  process.exit(1)
}

const list = countries.filter(c => c !== null)
const out = `// ── Geography data: the 193 UN member states ─────────────────────────────────
//
// GENERATED by supabase/geography/build-data.mts. Do not edit by hand: change
// supabase/geography/curation.mts, then run
//   node supabase/geography/build-data.mts
//   node supabase/geography/validate-data.mts
//
// Source: ${snap.source}, fetched ${snap.fetched}.
// Wikidata is CC0, so this file can be bundled freely. Every curated value
// that differs from Wikidata has a written reason in curation.mts (the build
// refuses otherwise). Nothing here comes from ODbL datasets.
//
// Hard cases, decided once:
//   Several capitals  capitals[0] is asked (the commonly taught one). Any
//                     capital is accepted, and none of them is ever offered
//                     as a wrong answer. South Africa has three, Bolivia two.
//   Shared currencies Only country → currency is asked, never "which country
//                     uses the euro?". currencies[0] is asked, the rest are
//                     also in use and never offered as wrong answers.
//   Languages         Asked as "which is an official language of X?". Every
//                     official language is right. notWrong (regional,
//                     recognised, Wikidata-listed, or near-identical) is never
//                     offered as a wrong answer.
//   Continents        UN M49 regions, Americas split North (with Central
//                     America and the Caribbean) and South. Russia is Europe,
//                     Turkey and the Caucasus are Asia. alsoContinent is never
//                     offered as a wrong answer.
//   Names             Plain names kids use (official short names with the familiar one in brackets where they differ): China, Ivory Coast, Czechia (Czech Republic), Türkiye (Turkey),
//                     Turkey, Micronesia, Bahamas, Gambia. Sentences add
//                     "the" where English needs it (lib/geo.ts THE).
//
// Capital coordinates (Wikidata P625 of the capital item, 2 decimal places)
// and ISO alpha-3 codes are stored for a later map phase.
//
// No '@/' imports, so Node can run this file for the generators and checks.

export type Continent = 'af' | 'as' | 'eu' | 'na' | 'sa' | 'oc'

export interface Capital { name: string; lat: number; lon: number }
export interface Currency { code: string; short: string; name: string }
export interface Country {
  iso:            string
  iso3:           string
  name:           string
  continent:      Continent
  capitals:       Capital[]
  languages:      string[]
  notWrong:       string[]
  currencies:     Currency[]
  alsoContinent?: Continent[]
  wikidata:       string
}

export const LOOKALIKE_FLAGS: [string, string][] = ${JSON.stringify(LOOKALIKE_FLAGS)}

export const COUNTRIES: Country[] = [
${list.map(c => '  ' + JSON.stringify(c)).join(',\n')},
]
`
fs.writeFileSync(path.join(root, 'lib/geo-data.ts'), out)
console.log(`wrote lib/geo-data.ts: ${list.length} countries, ${Object.keys(REASONS).length} reasoned differences from Wikidata`)
