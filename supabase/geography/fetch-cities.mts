// Fetches the raw facts for the curated famous cities (cities-curation.mts)
// from Wikidata (CC0) and writes supabase/geography/cities-snapshot.json.
// Run:
//
//   node supabase/geography/fetch-cities.mts
//
// The snapshot is committed so the build is reproducible and reviewable
// without a network; build-cities.mts turns it into lib/geo-cities.ts.
// Wikidata is CC0 (a public domain dedication), so it can be bundled freely.
// Nothing here comes from GeoNames (CC BY) or OpenStreetMap (ODbL).
//
// Every city is fetched by its PINNED item (QID), never searched by name, so
// a namesake can never slip in (the "New York" label is also the state's).
// Per item: English label, countries (P17, with whether the statement is
// current: no end time P582, not deprecated), coordinates (P625, every
// non-deprecated value) and population (P1082, every non-deprecated value
// with its rank and point in time P585). build-cities.mts chooses among them.
//
// The User-Agent is generic on purpose: no email or personal identifier.

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { CITY_ROWS } from './cities-curation.mts'

const here = path.dirname(fileURLToPath(import.meta.url))

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
  const text = await res.text()
  if (!res.ok) throw new Error(`Wikidata answered ${res.status}: ${text.slice(0, 200)}`)
  return (JSON.parse(text) as { results: { bindings: Binding[] } }).results.bindings
}
const v = (b: Binding, k: string) => b[k]?.value ?? ''
const qid = (uri: string) => uri.replace('http://www.wikidata.org/entity/', '')
const rank = (uri: string) => uri.replace('http://wikiba.se/ontology#', '').replace('Rank', '').toLowerCase()
const point = (wkt: string): [number, number] | null => {     // Point(lon lat) → [lat, lon]
  const m = /^Point\(([-\d.eE]+) ([-\d.eE]+)\)$/.exec(wkt)
  return m ? [Number(m[2]), Number(m[1])] : null
}

const QIDS = CITY_ROWS.map(r => r[3])
const bad = CITY_ROWS.filter(r => !/^Q\d+$/.test(r[3]))
if (bad.length) { console.error('cities without a pinned QID:', bad.map(r => r[0]).join(', ')); process.exit(1) }
const VALUES = `VALUES ?item { ${QIDS.map(q => `wd:${q}`).join(' ')} }`

const labels = await sparql(`SELECT ?item ?label WHERE { ${VALUES} ?item rdfs:label ?label . FILTER(LANG(?label) = "en") }`)
const countries = await sparql(`
SELECT ?item ?c ?iso ?end ?rank WHERE {
  ${VALUES}
  ?item p:P17 ?s . ?s ps:P17 ?c ; wikibase:rank ?rank .
  OPTIONAL { ?s pq:P582 ?end }
  OPTIONAL { ?c wdt:P297 ?iso }
}`)
const coords = await sparql(`
SELECT ?item ?coord ?rank WHERE {
  ${VALUES}
  ?item p:P625 ?s . ?s ps:P625 ?coord ; wikibase:rank ?rank .
  FILTER(?rank != wikibase:DeprecatedRank)
}`)
const pops = await sparql(`
SELECT ?item ?pop ?date ?rank WHERE {
  ${VALUES}
  ?item p:P1082 ?s . ?s ps:P1082 ?pop ; wikibase:rank ?rank .
  FILTER(?rank != wikibase:DeprecatedRank)
  OPTIONAL { ?s pq:P585 ?date }
}`)

const rows = QIDS.map(q => {
  const of = (bs: Binding[]) => bs.filter(b => qid(v(b, 'item')) === q)
  return {
    item: q,
    label: of(labels)[0] ? v(of(labels)[0], 'label') : '',
    countries: of(countries).map(b => ({
      item: qid(v(b, 'c')), iso: v(b, 'iso'),
      current: !v(b, 'end') && rank(v(b, 'rank')) !== 'deprecated',
    })).sort((a, b) => a.item.localeCompare(b.item) || Number(b.current) - Number(a.current))
      .filter((x, i, xs) => xs.findIndex(y => y.item === x.item) === i),
    coords: of(coords).map(b => ({ latlon: point(v(b, 'coord')), rank: rank(v(b, 'rank')) }))
      .filter(x => x.latlon).map(x => ({ lat: x.latlon![0], lon: x.latlon![1], rank: x.rank }))
      .sort((a, b) => a.lat - b.lat || a.lon - b.lon),
    population: of(pops).map(b => ({ n: Number(v(b, 'pop')), date: v(b, 'date').slice(0, 10), rank: rank(v(b, 'rank')) }))
      .sort((a, b) => a.date.localeCompare(b.date) || a.n - b.n),
  }
})

const missing = rows.filter(r => !r.label)
console.log(`${rows.length} cities fetched; without an English label: ${missing.map(r => r.item).join(' ') || 'none'}`)
const out = path.join(here, 'cities-snapshot.json')
fs.writeFileSync(out, JSON.stringify({
  source: 'Wikidata Query Service, https://query.wikidata.org (CC0 1.0)',
  fetched: new Date().toISOString().slice(0, 10),
  rows,
}, null, 1) + '\n')
console.log('wrote', path.relative(process.cwd(), out))
