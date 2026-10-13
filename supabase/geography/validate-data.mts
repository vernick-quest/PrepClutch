// Checks lib/geo-data.ts and every card lib/geo.ts builds from it. Run:
//
//   node supabase/geography/validate-data.mts
//
// Then runs the same checks on deliberately corrupted copies, each of which
// MUST fail (a positive control: a validator that cannot fail proves nothing).
// Exits non-zero if the real data has a problem or any corruption slips by.

import './ts-resolve.mts'
import type { Country } from '../../lib/geo-data.ts'

const { COUNTRIES, LOOKALIKE_FLAGS } = await import('../../lib/geo-data.ts')
const geo = await import('../../lib/geo.ts')
const md = await import('../../lib/geo-map-data.ts')

const lc = (s: string) => s.toLowerCase()

/** Facts asserted by hand, independently of Wikidata. */
const SPOT: { iso: string; capital?: string; capitals?: string[]; language?: string; currency?: string;
              short?: string; continent?: string; iso3?: string; coord?: [number, number] }[] = [
  { iso: 'AU', capital: 'Canberra', currency: 'AUD', continent: 'oc', iso3: 'AUS', coord: [-35.28, 149.13] },
  { iso: 'CA', capital: 'Ottawa', language: 'French', currency: 'CAD', iso3: 'CAN', coord: [45.42, -75.70] },
  { iso: 'KE', capital: 'Nairobi', language: 'Swahili', currency: 'KES', coord: [-1.29, 36.82] },
  { iso: 'BR', capital: 'Brasília', language: 'Portuguese', currency: 'BRL', short: 'Real', continent: 'sa', iso3: 'BRA' },
  { iso: 'JP', capital: 'Tokyo', language: 'Japanese', currency: 'JPY', short: 'Yen', continent: 'as' },
  { iso: 'CH', capital: 'Bern', currency: 'CHF', short: 'Franc', language: 'Romansh' },
  { iso: 'ZA', capitals: ['Pretoria', 'Cape Town', 'Bloemfontein'], currency: 'ZAR', language: 'Zulu', iso3: 'ZAF' },
  { iso: 'BO', capitals: ['Sucre', 'La Paz'], currency: 'BOB', language: 'Quechua' },
  { iso: 'FR', capital: 'Paris', language: 'French', currency: 'EUR', continent: 'eu', iso3: 'FRA' },
  { iso: 'DE', capital: 'Berlin', language: 'German', currency: 'EUR', iso3: 'DEU' },
  { iso: 'GB', capital: 'London', language: 'English', currency: 'GBP', iso3: 'GBR' },
  { iso: 'US', capital: 'Washington, D.C.', language: 'English', currency: 'USD', continent: 'na', iso3: 'USA' },
  { iso: 'MX', capital: 'Mexico City', language: 'Spanish', currency: 'MXN', short: 'Peso' },
  { iso: 'IN', capital: 'New Delhi', language: 'Hindi', currency: 'INR', short: 'Rupee' },
  { iso: 'CN', capital: 'Beijing', language: 'Chinese', currency: 'CNY' },
  { iso: 'EG', capital: 'Cairo', language: 'Arabic', currency: 'EGP', continent: 'af' },
  { iso: 'RU', capital: 'Moscow', language: 'Russian', currency: 'RUB', continent: 'eu' },
  { iso: 'NZ', capital: 'Wellington', language: 'Māori', currency: 'NZD' },
  { iso: 'AR', capital: 'Buenos Aires', language: 'Spanish', currency: 'ARS' },
  { iso: 'IT', capital: 'Rome', language: 'Italian', currency: 'EUR' },
  { iso: 'ES', capital: 'Madrid', language: 'Spanish', currency: 'EUR' },
  { iso: 'KR', capital: 'Seoul', language: 'Korean', currency: 'KRW', short: 'Won' },
  { iso: 'NG', capital: 'Abuja', language: 'English', currency: 'NGN' },
  { iso: 'BG', capital: 'Sofia', currency: 'EUR' },                  // euro since 1 Jan 2026
  { iso: 'TR', capital: 'Ankara', currency: 'TRY', continent: 'as' },
]

const CONTINENT_COUNTS: Record<string, number> = { af: 54, as: 47, eu: 43, na: 23, sa: 12, oc: 14 }

function validateCountries(cs: Country[]): string[] {
  const p: string[] = []
  if (cs.length !== 193) p.push(`expected 193 countries, found ${cs.length}`)
  const dup = (xs: string[], what: string) => {
    const seen = new Set<string>()
    for (const x of xs) { if (seen.has(x)) p.push(`duplicate ${what}: ${x}`); seen.add(x) }
  }
  dup(cs.map(c => c.iso), 'ISO alpha-2')
  dup(cs.map(c => c.iso3), 'ISO alpha-3')
  dup(cs.map(c => lc(c.name)), 'name')
  dup(cs.map(c => lc(c.capitals[0]?.name ?? '')), 'asked capital')

  const empty = (s: unknown, where: string) => {
    if (typeof s !== 'string' || s.trim() === '') p.push(`empty string: ${where}`)
  }
  for (const c of cs) {
    const at = c.iso || '(no iso)'
    empty(c.iso, `${at}.iso`); empty(c.iso3, `${at}.iso3`); empty(c.name, `${at}.name`)
    if (!/^[A-Z]{2}$/.test(c.iso)) p.push(`${at}: alpha-2 is not 2 capital letters`)
    if (!/^[A-Z]{3}$/.test(c.iso3)) p.push(`${at}: alpha-3 ${c.iso3} is not 3 capital letters`)
    if (!['af', 'as', 'eu', 'na', 'sa', 'oc'].includes(c.continent)) p.push(`${at}: bad continent ${c.continent}`)
    if (!c.capitals.length) p.push(`${at}: no capital`)
    for (const cap of c.capitals) {
      empty(cap.name, `${at} capital`)
      if (!(Number.isFinite(cap.lat) && cap.lat >= -90 && cap.lat <= 90)) p.push(`${at}: ${cap.name} latitude ${cap.lat}`)
      if (!(Number.isFinite(cap.lon) && cap.lon >= -180 && cap.lon <= 180)) p.push(`${at}: ${cap.name} longitude ${cap.lon}`)
    }
    if (!c.languages.length) p.push(`${at}: no official language`)
    c.languages.forEach(l => empty(l, `${at} language`))
    c.notWrong.forEach(l => empty(l, `${at} notWrong`))
    if (c.notWrong.some(l => c.languages.some(o => lc(o) === lc(l)))) p.push(`${at}: a language is both official and notWrong`)
    if (!c.currencies.length) p.push(`${at}: no currency`)
    for (const cur of c.currencies) {
      empty(cur.short, `${at} currency short`); empty(cur.name, `${at} currency name`)
      if (!/^[A-Z]{3}$/.test(cur.code)) p.push(`${at}: currency code ${cur.code}`)
    }
  }
  for (const [k, n] of Object.entries(CONTINENT_COUNTS)) {
    const got = cs.filter(c => c.continent === k).length
    if (got !== n) p.push(`continent ${k}: ${got} countries, expected ${n}`)
  }

  // Hand-asserted facts.
  const by = new Map(cs.map(c => [c.iso, c]))
  for (const s of SPOT) {
    const c = by.get(s.iso)
    if (!c) { p.push(`spot ${s.iso}: missing`); continue }
    const caps = c.capitals.map(x => x.name)
    if (s.capital && caps[0] !== s.capital) p.push(`spot ${s.iso}: capital ${caps[0]}, expected ${s.capital}`)
    if (s.capitals && (caps.length !== s.capitals.length || s.capitals.some(x => !caps.includes(x))))
      p.push(`spot ${s.iso}: capitals ${caps.join('/')}, expected ${s.capitals.join('/')}`)
    if (s.language && !c.languages.includes(s.language)) p.push(`spot ${s.iso}: ${s.language} not official`)
    if (s.currency && c.currencies[0].code !== s.currency) p.push(`spot ${s.iso}: currency ${c.currencies[0].code}, expected ${s.currency}`)
    if (s.short && c.currencies[0].short !== s.short) p.push(`spot ${s.iso}: currency name ${c.currencies[0].short}, expected ${s.short}`)
    if (s.continent && c.continent !== s.continent) p.push(`spot ${s.iso}: continent ${c.continent}, expected ${s.continent}`)
    if (s.iso3 && c.iso3 !== s.iso3) p.push(`spot ${s.iso}: alpha-3 ${c.iso3}, expected ${s.iso3}`)
    if (s.coord) {
      const [lat, lon] = s.coord
      if (Math.abs(c.capitals[0].lat - lat) > 0.5 || Math.abs(c.capitals[0].lon - lon) > 0.5)
        p.push(`spot ${s.iso}: ${caps[0]} at ${c.capitals[0].lat},${c.capitals[0].lon}, expected about ${lat},${lon}`)
    }
  }
  return p
}

/** Every card the app can show: 4 distinct options, exactly one right, and
 *  no wrong option that is actually right (or unfairly close). */
function validateCards(): string[] {
  const p: string[] = []
  const live = geo.allGeoCards()
  if (live.length !== geo.geoCardCount()) p.push(`expected ${geo.geoCardCount()} cards, built ${live.length}`)
  // Expert kinds (currency, language) are not in the catalogue but are still
  // checked, so they are ready to switch on and their controls still bite.
  const cards = [...live, ...geo.expertGeoCards()]
  if (geo.expertGeoCards().length !== COUNTRIES.length * geo.EXPERT_KINDS.length) p.push('expert cards missing')
  const keys = new Set<string>()
  const pinKeys = new Set(geo.pinPlaces().map(x => geo.pinCardKey(x.key)))
  const askable = COUNTRIES.filter(x => !geo.COUNTRY_NOT_ASKED.has(x.iso)).length
  if (live.filter(x => x.kind === 'find').length !== askable) p.push(`expected ${askable} find cards`)
  if (live.filter(x => x.kind === 'pin').length !== pinKeys.size) p.push(`expected ${pinKeys.size} pin cards`)
  for (const card of cards) {
    if (keys.has(card.key)) p.push(`duplicate card key ${card.key}`)
    keys.add(card.key)
    const c = geo.countryByIso(card.iso)!
    // Pin the map's cards (074) have no options: one find card per country
    // Find the country asks, one pin card per Pin the map place.
    if (geo.PIN_KINDS.includes(card.kind)) {
      if (card.options.length) p.push(`${card.key}: a ${card.kind} card has options`)
      if (card.kind === 'find' && (card.key !== geo.geoKey('find', c.iso) || geo.COUNTRY_NOT_ASKED.has(c.iso))) p.push(`${card.key}: not a find card of an asked country`)
      if (card.kind === 'pin' && !pinKeys.has(card.key)) p.push(`${card.key}: not a Pin the map place`)
      continue
    }
    const values = card.options.map(o => o.value)
    const labels = card.options.map(o => lc(o.label))
    if (card.options.length !== 4) p.push(`${card.key}: ${card.options.length} options`)
    if (new Set(values).size !== values.length || new Set(labels).size !== labels.length) p.push(`${card.key}: repeated option`)
    if (values.filter(v => v === card.answer).length !== 1) p.push(`${card.key}: answer is not exactly one option`)
    if (values[0] !== card.answer) p.push(`${card.key}: answer is not the first option`)
    if (card.options.some(o => !o.label.trim())) p.push(`${card.key}: empty option`)
    const wrong = card.options.slice(1)
    switch (card.kind) {
      case 'cap':
        for (const o of wrong) if (c.capitals.some(x => lc(x.name) === lc(o.label))) p.push(`${card.key}: ${o.label} is a capital of ${c.name}`)
        break
      case 'flag': case 'flagr':
        for (const o of wrong) if (LOOKALIKE_FLAGS.some(([a, b]) => (a === c.iso && b === o.value) || (b === c.iso && a === o.value)))
          p.push(`${card.key}: lookalike flag ${o.value}`)
        break
      case 'cur': {
        const fam = new Set(c.currencies.map(x => geo.currencyFamily(x.short)))
        for (const o of wrong) {
          if (c.currencies.some(x => x.code === o.value)) p.push(`${card.key}: ${o.value} is used in ${c.name}`)
          if (fam.has(geo.currencyFamily(o.label))) p.push(`${card.key}: ${o.label} sounds like ${c.name}'s currency`)
        }
        if (new Set(card.options.map(o => geo.currencyFamily(o.label))).size !== 4) p.push(`${card.key}: two options of one currency family`)
        break
      }
      case 'lang': {
        const never = new Set([...c.languages, ...c.notWrong].map(lc))
        for (const o of wrong) if (never.has(lc(o.value))) p.push(`${card.key}: ${o.value} is official or recognised in ${c.name}`)
        break
      }
      case 'shape':
        if (geo.SHAPE_DISPUTED.has(c.iso)) p.push(`${card.key}: ${c.name}'s outline is disputed, it must have no shape card`)
        for (const o of wrong) if ((md.ENCLOSED_BY[c.iso] ?? []).includes(o.value)) p.push(`${card.key}: ${o.value} surrounds ${c.name} on the map`)
        if (card.map !== c.iso) p.push(`${card.key}: map shows ${card.map}`)
        break
      case 'cont':
        for (const o of wrong) if (o.value === c.continent || (c.alsoContinent ?? []).includes(o.value as never))
          p.push(`${card.key}: ${o.value} is a continent ${c.name} is in`)
        break
    }
  }
  // Same card, same wrong options, every time (stable difficulty).
  const again = geo.parseGeoKey('cap:fr')!
  if (JSON.stringify(again.options) !== JSON.stringify(cards.find(x => x.key === 'cap:fr')!.options)) p.push('options are not deterministic')
  return p
}

// ── Run on the real data ─────────────────────────────────────────────────────
const real = [...validateCountries(COUNTRIES), ...validateCards()]
console.log(`real data: ${COUNTRIES.length} countries, ${geo.allGeoCards().length} cards, max ${geo.maxGeoPoints()} Explorer Points`)
if (real.length) {
  console.error(`FAIL: ${real.length} problem(s)`)
  real.forEach(x => console.error('  ' + x))
} else {
  console.log('PASS: no problems')
}

// ── Positive control: corrupted copies must fail ─────────────────────────────
const copy = (): Country[] => JSON.parse(JSON.stringify(COUNTRIES))
const set = (cs: Country[], iso: string, f: (c: Country) => void) => { f(cs.find(c => c.iso === iso)!); return cs }
const CORRUPTIONS: [string, () => Country[]][] = [
  ['Australia capital → Sydney',          () => set(copy(), 'AU', c => { c.capitals[0].name = 'Sydney' })],
  ['Japan currency → CNY',                () => set(copy(), 'JP', c => { c.currencies[0].code = 'CNY' })],
  ['drop a country',                      () => copy().slice(1)],
  ['duplicate ISO (Austria → AU)',        () => set(copy(), 'AT', c => { c.iso = 'AU' })],
  ['empty language',                      () => set(copy(), 'PE', c => { c.languages[1] = '' })],
  ['no currency',                         () => set(copy(), 'GH', c => { c.currencies = [] })],
  ['Nairobi coordinates swapped',         () => set(copy(), 'KE', c => { const x = c.capitals[0]; [x.lat, x.lon] = [x.lon, x.lat] })],
  ['latitude out of range',               () => set(copy(), 'NO', c => { c.capitals[0].lat = 95 })],
  ['alpha-3 lower case',                  () => set(copy(), 'FR', c => { c.iso3 = 'fra' })],
  ['Germany alpha-3 → GER',               () => set(copy(), 'DE', c => { c.iso3 = 'GER' })],
  ['South Africa loses a capital',        () => set(copy(), 'ZA', c => { c.capitals.pop() })],
]
let missed = 0
for (const [name, make] of CORRUPTIONS) {
  const caught = validateCountries(make())
  if (caught.length) console.log(`control caught "${name}": ${caught[0]}`)
  else { missed++; console.error(`CONTROL MISSED "${name}"`) }
}
// Card-level controls: plant a bad option in the real card set, check it is
// caught, put it back.
const CARD_CORRUPTIONS: [string, string, (o: { value: string; label: string }) => void][] = [
  ['French offered as WRONG for Canada', 'lang:ca', o => { o.value = 'French'; o.label = 'French' }],
  ['Chad flag beside Romania',          'flagr:td', o => { o.value = 'RO'; o.label = 'Romania' }],
  ['La Paz offered as WRONG for Bolivia', 'cap:bo', o => { o.value = 'La Paz'; o.label = 'La Paz' }],
  ['Riyal offered for Iran (a rial)',   'cur:ir', o => { o.value = 'SAR'; o.label = 'Riyal' }],
  ['Asia offered as WRONG for Russia',  'cont:ru', o => { o.value = 'as'; o.label = 'Asia' }],
]
for (const [name, key, plant] of CARD_CORRUPTIONS) {
  const card = [...geo.allGeoCards(), ...geo.expertGeoCards()].find(c => c.key === key)!
  const saved = { ...card.options[3] }
  plant(card.options[3])
  const caught = validateCards()
  card.options[3] = saved
  if (caught.length) console.log(`control caught "${name}": ${caught[0]}`)
  else { missed++; console.error(`CONTROL MISSED "${name}"`) }
}
if (validateCards().length) { missed++; console.error('a card control was not restored') }
const total = CORRUPTIONS.length + CARD_CORRUPTIONS.length
console.log(missed ? `FAIL: ${missed} corruption(s) not caught` : `PASS: all ${total} corruptions caught`)
process.exit(real.length || missed ? 1 : 0)
