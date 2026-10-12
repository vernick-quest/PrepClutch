// Generates supabase/migrations/NNN_geography.sql from lib/geo.ts (the one
// definition of the card set) and NNN.template.sql. Run:
//
//   node supabase/geography/cards.mts
//
// Refuses to write a file whose string literals contain ; $ or -- because
// the Supabase SQL editor misparses those (see migration 060). Positive
// control: `node supabase/geography/cards.mts --plant-semicolon` plants a
// semicolon in one badge's lore and MUST refuse (exit 1, nothing written)
// at q(). `--plant-raw` appends a raw literal that skips q() and MUST be
// refused by the whole-file scan.

import './ts-resolve.mts'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const geo = await import('../../lib/geo.ts')

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const plant = process.argv.includes('--plant-semicolon')

const RISKY = /;|\$|--/

// ── Badges ───────────────────────────────────────────────────────────────────
// [key, label, emoji, description, rarity, creature, lore, threshold]
type Badge = [string, string, string, string, string, string, string, number]
const CAT = 'Geography'
const ALL = geo.GEO_CARD_COUNT
const B: Badge[] = []

// The Globe Turtle grows a bigger shell with every card mastered.
const LADDER: [number, string, string, string][] = [
  [10, 'Turtle Hatchling', 'Common',
   'A Globe Turtle hatches knowing nothing about the world except that the beach is sandy. Ten cards in, it can already name a capital or two and has started drawing maps on its own shell.'],
  [50, 'Turtle Paddler', 'Uncommon',
   'Fifty cards. The Paddler has left the beach and can tell a flag from a beach towel, which is harder than it sounds.'],
  [100, 'Turtle Navigator', 'Rare',
   'One hundred cards mastered. The Navigator no longer gets lost. It occasionally pretends to, so the other turtles do not feel bad.'],
  [250, 'Turtle Voyager', 'Epic',
   'Two hundred and fifty cards. The Voyager has crossed three oceans and collected a souvenir from each. Its shell is now mostly stickers.'],
  [500, 'Turtle Admiral', 'Legendary',
   'Five hundred cards. Ships ask the Admiral for directions. The Admiral answers in the local language and quotes the price in the local currency.'],
]
for (const [n, label, rarity, lore] of LADDER) {
  B.push([`geo_mastered_${n}`, label, '🐢', `${n} Geography cards mastered.`, rarity, 'Globe Turtle', lore, n])
}
B.push(['geo_mastered_all', 'World Turtle', '🐢🌍', `Every one of the ${ALL} Geography cards mastered.`, 'Ascendant', 'Globe Turtle',
  'Every capital, every flag, every currency, every language, all 193 countries. The World Turtle is so big now that some people think the world is sitting on its back. It does not correct them.', ALL])

// One per continent: every card for every country there.
const CONTINENT_BADGES: Record<string, [string, string, string, string]> = {
  af: ['Lion of Africa', '🦁', 'Legendary', 'All 54 countries, from Algeria to Zimbabwe. The Lion roars the capitals in alphabetical order every morning, which the zebras find very helpful and slightly loud.'],
  as: ['Panda of Asia', '🐼', 'Legendary', 'From Tokyo to Tehran to Tashkent. The Panda knows every flag in the biggest continent on Earth and still has time for a nap and some bamboo.'],
  eu: ['Hedgehog of Europe', '🦔', 'Legendary', 'Forty-three countries packed close together. The Hedgehog rolls from Lisbon to Moscow without needing a map and never mixes up Slovakia and Slovenia. Well, almost never.'],
  na: ['Eagle of North America', '🦅', 'Epic', 'Canada to Panama and every island in the Caribbean. The Eagle has seen them all from above and knows which ones use the East Caribbean dollar.'],
  sa: ['Llama of South America', '🦙', 'Rare', 'Twelve countries, two Bolivian capitals and one very long Chile. The Llama knows them all and hums the anthem of Paraguay when it is happy.'],
  oc: ['Kangaroo of Oceania', '🦘', 'Rare', 'Fourteen countries spread over the biggest ocean on Earth. The Kangaroo could not hop between them, so it learned all their flags instead.'],
}
for (const ct of geo.CONTINENTS) {
  const [label, emoji, rarity, lore] = CONTINENT_BADGES[ct]
  const n = geo.allGeoCards().filter(c => c.continent === ct).length
  B.push([`geo_continent_${ct}`, label, emoji, `All ${n} ${geo.CONTINENT_LABEL[ct]} cards mastered.`, rarity, label.split(' of ')[0], lore, n])
}

// Card types: a first step at 25, then all of them.
const GROUP_BADGES: [string, string, [string, string, string, string, string], [string, string, string, string, string]][] = [
  ['capitals', 'capital',
   ['Capital Cub', '🏛️', 'Uncommon', 'Capital Cub', 'Twenty-five capitals. The Cub has started saying Ouagadougou just because it is fun to say.'],
   ['Capital Crown', '🏛️👑', 'Legendary', 'Capital Crown', 'Every capital, both ways round. Ask the Crown about Ngerulmud and it will tell you, then ask why you wanted to know.']],
  ['flags', 'flag',
   ['Flag Spotter', '🚩', 'Uncommon', 'Flag Spotter', 'Twenty-five flags spotted. The Spotter now waves at every flagpole it passes and the flags, being polite, wave back.'],
   ['Banner Baron', '🚩👑', 'Legendary', 'Banner Baron', 'Every flag, both ways round. The Baron can tell Chad from Romania in the dark and has never once confused Monaco with Indonesia.']],
  ['money', 'currency',
   ['Coin Collector', '🪙', 'Uncommon', 'Coin Collector', 'Twenty-five currencies. The Collector keeps a pocket for each one and jingles quite a lot when it walks.'],
   ['Money Mogul', '💰', 'Epic', 'Money Mogul', 'Every currency of every country. The Mogul knows a won from a yen from a yuan and will happily explain the difference at great length.']],
  ['languages', 'language',
   ['Hello Hatchling', '💬', 'Uncommon', 'Hello Hatchling', 'Twenty-five official languages. The Hatchling can now say hello in more ways than it has friends, and is working on the friends.'],
   ['Polyglot Parrot', '🦜', 'Epic', 'Polyglot Parrot', 'An official language for every country. The Parrot repeats everything, but now it repeats it in Swahili, Tagalog and Icelandic.']],
  ['continents', 'continent',
   ['Map Mouse', '🗺️', 'Common', 'Map Mouse', 'Twenty-five countries placed on the right continent. The Mouse has a very small map and a very big sense of direction.'],
   ['Continent Captain', '🧭', 'Rare', 'Continent Captain', 'Every country on its continent. The Captain knows Russia is in Europe and Asia at once and is not even slightly confused by it.']],
]
for (const [grp, word, first, last] of GROUP_BADGES) {
  const kinds = geo.GROUP_KINDS[grp as keyof typeof geo.GROUP_KINDS]
  const total = geo.COUNTRIES.length * kinds.length
  const both = kinds.length > 1 ? ', both ways round' : ''
  B.push([`geo_${grp}_25`, first[0], first[1], `25 ${word} cards mastered.`, first[2], first[3], first[4], 25])
  B.push([`geo_${grp}_all`, last[0], last[1], `All ${total} ${word} cards mastered${both}.`, last[2], last[3], last[4], total])
}

B.push(['geo_perfect_round', 'Perfect Passport', '🎯', 'A 10-card Geography round with every card right, and every one fast enough to master.', 'Rare',
  'Perfect Passport', 'Ten questions, ten right answers, not one of them slow. The Passport gets a stamp for that and is running out of pages.', 10])

if (plant) B[0][6] = B[0][6] + ' Planted; on purpose.'

// ── SQL ──────────────────────────────────────────────────────────────────────

function q(s: string): string {
  if (RISKY.test(s)) {
    console.error(`Refusing to write: risky characters in literal: ${s.slice(0, 80)}`)
    process.exit(1)
  }
  return `'${s.replace(/'/g, "''")}'`
}

const keys = B.map(b => b[0])
if (new Set(keys).size !== keys.length) { console.error('duplicate badge keys'); process.exit(1) }

const badgeRows = B.map(([k, l, e, d, r, c, lo, t]) =>
  `(${q(k)}, ${q(l)}, ${q(e)}, ${q(d)}, ${q(r)}, ${q(c)}, ${q(CAT)},\n ${q(lo)}, ${t})`).join(',\n\n')

const cards = geo.allGeoCards()
const rows = cards.map(c => `(${[q(c.key), q(c.iso), q(c.kind), q(c.continent), c.points, c.targetMs].join(', ')})`)

const arr = (xs: string[]) => `ARRAY[${xs.map(q).join(', ')}]`
let sql = fs.readFileSync(path.join(here, 'NNN.template.sql'), 'utf8')
  .replace('__ROWS__', rows.join(',\n'))
  .replace('__BADGE_ROWS__', badgeRows)
  .replace('__LADDER__', LADDER.map(l => l[0]).join(', '))
  .replace('__CONTINENTS__', geo.CONTINENTS.map(q).join(', '))
  .replace('__GROUP_STEPS__', GROUP_BADGES.map(([g]) => `(${q(g)}, ${arr(geo.GROUP_KINDS[g as keyof typeof geo.GROUP_KINDS])}, 25)`).join(', '))
  .replace('__GROUP_ALL__', GROUP_BADGES.map(([g]) => `(${q(g)}, ${arr(geo.GROUP_KINDS[g as keyof typeof geo.GROUP_KINDS])})`).join(', '))
  .replaceAll('__CARDS__', String(cards.length))
  .replaceAll('__MAXPTS__', String(geo.MAX_GEO_POINTS))
  .replaceAll('__BADGES__', String(B.length))

if (/__[A-Z_]+__/.test(sql)) { console.error('unfilled placeholder', sql.match(/__[A-Z_]+__/)![0]); process.exit(1) }

// Second control: a literal that bypasses q(), to prove the whole-file scan
// below catches what q() would have.
if (process.argv.includes('--plant-raw')) sql += "\nSELECT 'planted; raw';\n"

// Whole-file literal check, comments stripped first so an apostrophe in a
// comment does not throw the scanner off.
const code = sql.split('\n').filter(l => !l.trimStart().startsWith('--')).join('\n')
const risky = (code.match(/'(?:[^']|'')*'/g) ?? []).filter(s => RISKY.test(s))
if (risky.length) {
  console.error('Refusing to write: risky literals', risky.slice(0, 5))
  process.exit(1)
}

const out = path.join(root, 'supabase/migrations/NNN_geography.sql')
fs.writeFileSync(out, sql)
console.log(`wrote ${path.relative(root, out)}: ${cards.length} cards, ${B.length} badges, max ${geo.MAX_GEO_POINTS} Explorer Points`)
