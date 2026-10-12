// Fetches the raw facts for the 193 UN member states from Wikidata (CC0) and
// writes supabase/geography/wikidata-snapshot.json. Run:
//
//   node supabase/geography/fetch-wikidata.mts
//
// The snapshot is committed so the build is reproducible and reviewable
// without a network. build-data.mts then checks every curated fact against it.
//
// Wikidata is CC0 (a public domain dedication), so it can be bundled freely.
// Nothing here comes from ODbL datasets such as mledoze/countries.
//
// Three queries:
//   1. per country: English label, ISO alpha-3 (P298), official languages
//      (P37), currencies (P38) with their ISO 4217 code (P498), continents
//      (P30). Statements with an end time (P582) or deprecated rank are
//      history and are left out.
//   2. every capital statement (P36), current AND former, with its end date
//      and the capital's coordinates (P625). Former capitals are kept so a
//      curated "also accepted" capital such as Abidjan can be matched.
//   3. capitals the curation names that Wikidata does not record as a
//      capital of that country (Antigua and Barbuda has no P36 at all):
//      looked up by English label among places in that country (P17).

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { ROWS, CAPITAL_ALIASES, CAPITAL_ITEMS } from './curation.mts'
import { normName } from './normalize.mts'

const here = path.dirname(fileURLToPath(import.meta.url))
const ISOS = ROWS.map(r => r[0])

type Binding = Record<string, { value: string } | undefined>

async function sparql(query: string): Promise<Binding[]> {
  const res = await fetch('https://query.wikidata.org/sparql', {
    method: 'POST',
    headers: {
      Accept: 'application/sparql-results+json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'PrepClutchGeoBuilder/1.0 (educational quiz data build)',
    },
    body: new URLSearchParams({ query }),
  })
  if (!res.ok) throw new Error(`Wikidata answered ${res.status}: ${(await res.text()).slice(0, 200)}`)
  return ((await res.json()) as { results: { bindings: Binding[] } }).results.bindings
}

const v = (b: Binding, k: string) => b[k]?.value ?? ''
const qid = (uri: string) => uri.replace('http://www.wikidata.org/entity/', '')
const split = (s: string) => (s ? s.split('|').filter(Boolean).sort() : [])
const VALUES = `VALUES ?iso { ${ISOS.map(i => `"${i}"`).join(' ')} }`
// The sovereign-state item for each code. Denmark is the one exception: its
// UN seat and sovereign-state typing sit on the Kingdom of Denmark item,
// which has no ISO code, so Denmark proper (Q35) is named directly.
const COUNTRY = `?c wdt:P297 ?iso . { ?c wdt:P31 wd:Q3624078 } UNION { VALUES ?c { wd:Q35 } }`
// Point(lon lat) → [lat, lon]
const point = (wkt: string): [number, number] | null => {
  const m = /^Point\(([-\d.eE]+) ([-\d.eE]+)\)$/.exec(wkt)
  return m ? [Number(m[2]), Number(m[1])] : null
}

// ── 1. Country facts ─────────────────────────────────────────────────────────
const facts = await sparql(`
SELECT ?iso ?c ?label
  (GROUP_CONCAT(DISTINCT ?iso3; separator="|") AS ?iso3s)
  (GROUP_CONCAT(DISTINCT ?langL; separator="|") AS ?langs)
  (GROUP_CONCAT(DISTINCT CONCAT(?curL, "#", COALESCE(?curCode, "")); separator="|") AS ?curs)
  (GROUP_CONCAT(DISTINCT ?contL; separator="|") AS ?conts)
WHERE {
  ${VALUES}
  ${COUNTRY}
  ?c rdfs:label ?label . FILTER(LANG(?label) = "en")
  OPTIONAL { ?c wdt:P298 ?iso3 }
  OPTIONAL { ?c p:P37 ?ls . ?ls ps:P37 ?lang . FILTER NOT EXISTS { ?ls pq:P582 ?e2 }
             ?ls wikibase:rank ?r2 . FILTER(?r2 != wikibase:DeprecatedRank)
             ?lang rdfs:label ?langL . FILTER(LANG(?langL) = "en") }
  OPTIONAL { ?c p:P38 ?ks . ?ks ps:P38 ?cur . FILTER NOT EXISTS { ?ks pq:P582 ?e3 }
             ?ks wikibase:rank ?r3 . FILTER(?r3 != wikibase:DeprecatedRank)
             ?cur rdfs:label ?curL . FILTER(LANG(?curL) = "en")
             OPTIONAL { ?cur wdt:P498 ?curCode } }
  OPTIONAL { ?c wdt:P30 ?cont . ?cont rdfs:label ?contL . FILTER(LANG(?contL) = "en") }
}
GROUP BY ?iso ?c ?label`)

// ── 2. Capital statements, current and former ────────────────────────────────
const caps = await sparql(`
SELECT ?iso ?cap ?capL ?coord ?end ?rank WHERE {
  ${VALUES}
  ${COUNTRY}
  ?c p:P36 ?s . ?s ps:P36 ?cap ; wikibase:rank ?rank .
  OPTIONAL { ?s pq:P582 ?end }
  ?cap rdfs:label ?capL . FILTER(LANG(?capL) = "en")
  OPTIONAL { ?cap wdt:P625 ?coord }
}`)

interface Capital { name: string; item: string; lat: number | null; lon: number | null; current: boolean; via: string }
const capitals = new Map<string, Capital[]>()
const addCap = (iso: string, c: Capital) => {
  const list = capitals.get(iso) ?? []
  const same = list.find(x => x.item === c.item)
  if (same) { same.current ||= c.current; if (same.lat === null) { same.lat = c.lat; same.lon = c.lon } }
  else list.push(c)
  capitals.set(iso, list)
}
for (const b of caps) {
  const p = point(v(b, 'coord'))
  addCap(v(b, 'iso'), {
    name: v(b, 'capL'), item: qid(v(b, 'cap')), lat: p?.[0] ?? null, lon: p?.[1] ?? null,
    current: !v(b, 'end') && !v(b, 'rank').endsWith('DeprecatedRank'), via: 'P36',
  })
}

// ── 3. Curated capitals Wikidata does not list as capitals ───────────────────
const wanted = ROWS.flatMap(([iso, , , cs]) => cs.map(name => ({ iso, name: CAPITAL_ALIASES[`${iso}:${name}`] ?? name })))
const missing = wanted.filter(w => !(capitals.get(w.iso) ?? []).some(c => normName(c.name) === normName(w.name)))
const pinned = missing.filter(m => CAPITAL_ITEMS[`${m.iso}:${m.name}`])
if (pinned.length) {
  const got = await sparql(`
SELECT ?cap ?coord WHERE {
  VALUES ?cap { ${pinned.map(m => `wd:${CAPITAL_ITEMS[`${m.iso}:${m.name}`]}`).join(' ')} }
  ?cap wdt:P625 ?coord .
}`)
  for (const m of pinned) {
    const item = CAPITAL_ITEMS[`${m.iso}:${m.name}`]
    const b = got.find(x => qid(v(x, 'cap')) === item)
    const p = b ? point(v(b, 'coord')) : null
    addCap(m.iso, { name: m.name, item, lat: p?.[0] ?? null, lon: p?.[1] ?? null, current: false, via: 'pinned' })
  }
}
const unpinned = missing.filter(m => !CAPITAL_ITEMS[`${m.iso}:${m.name}`])
if (unpinned.length) {
  const missing = unpinned
  const looked = await sparql(`
SELECT ?iso ?name ?cap ?coord WHERE {
  VALUES (?iso ?name) { ${missing.map(m => `("${m.iso}" "${m.name.replace(/"/g, '\\"')}"@en)`).join(' ')} }
  ${COUNTRY}
  ?cap rdfs:label ?name ; wdt:P17 ?c ; wdt:P625 ?coord .
}`)
  // Several items can share a label (a city and its district). Take the
  // lowest Q number: the long-standing main item.
  const best = new Map<string, Binding>()
  for (const b of looked) {
    const k = `${v(b, 'iso')}:${v(b, 'name')}`
    const prev = best.get(k)
    if (!prev || Number(qid(v(b, 'cap')).slice(1)) < Number(qid(v(prev, 'cap')).slice(1))) best.set(k, b)
  }
  for (const b of best.values()) {
    const p = point(v(b, 'coord'))
    addCap(v(b, 'iso'), { name: v(b, 'name'), item: qid(v(b, 'cap')), lat: p?.[0] ?? null, lon: p?.[1] ?? null, current: false, via: 'label' })
  }
}

const rows = facts.map(b => ({
  iso:        v(b, 'iso'),
  item:       qid(v(b, 'c')),
  label:      v(b, 'label'),
  iso3:       split(v(b, 'iso3s')),
  languages:  split(v(b, 'langs')),
  currencies: split(v(b, 'curs')),
  continents: split(v(b, 'conts')),
  capitals:   (capitals.get(v(b, 'iso')) ?? []).sort((x, y) => x.item.localeCompare(y.item)),
})).sort((x, y) => x.iso.localeCompare(y.iso))

const absent = ISOS.filter(i => !rows.some(r => r.iso === i))
const dup = rows.filter((r, i) => rows.findIndex(x => x.iso === r.iso) !== i)
console.log(`${rows.length} countries for ${ISOS.length} members. missing: ${absent.join(' ') || 'none'}, duplicated: ${dup.map(d => d.iso).join(' ') || 'none'}`)

const out = path.join(here, 'wikidata-snapshot.json')
fs.writeFileSync(out, JSON.stringify({
  source: 'Wikidata Query Service, https://query.wikidata.org (CC0 1.0)',
  fetched: new Date().toISOString().slice(0, 10),
  rows,
}, null, 1) + '\n')
console.log('wrote', path.relative(process.cwd(), out))
