import { PGlite } from '@electric-sql/pglite'
import { readFileSync } from 'fs'
const M = '/Users/robert/PrepClutch/supabase/migrations/'
const clean = readFileSync(M + '060_training_bank.sql', 'utf8')
const enc = s => Buffer.from(s, 'utf8').toString('base64')

async function run(sql) {
  const db = new PGlite()
  await db.exec(`CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS 'SELECT gen_random_uuid()';
    CREATE TYPE section_type AS ENUM ('verbal','quantitative','reading','math','language');
    CREATE TABLE questions (id uuid PRIMARY KEY DEFAULT uuid_generate_v4(), section section_type);`)
  await db.exec(readFileSync(M + '059_training_questions.sql', 'utf8'))
  const r = await db.exec(sql); return r[r.length - 1].rows
}

// Corrupt the ENCODED content: decode every base64 blob, apply the edit to the
// plain text, re-encode. Each case must actually change the file, or it tests
// nothing — the previous version of this script silently patched nothing.
function editDecoded(sql, from, to) {
  let hits = 0
  const out = sql.replace(/decode\('([A-Za-z0-9+/=]*)', 'base64'\)/g, (m, b) => {
    const txt = Buffer.from(b, 'base64').toString('utf8')
    if (!txt.includes(from)) return m
    hits++
    return `decode('${enc(txt.replace(from, to))}', 'base64')`
  })
  return { out, hits }
}

const cases = [
  ['one digit in a math note',       s => editDecoded(s, '6 + 12 = 18', '6 + 12 = 19')],
  ['one letter in a reading answer', s => editDecoded(s, 'how far away the flowers are', 'how far away the flowers were')],
  ['a swapped answer key',           s => {
      const i = s.indexOf(`'train-hspt-verbal-06'`), j = s.indexOf('::JSONB, 1, 2,', i)
      return { out: s.slice(0, j) + '::JSONB, 0, 2,' + s.slice(j + 14), hits: j > i ? 1 : 0 } }],
]

console.log('clean                            →', (await run(clean)).every(r => r.content_intact) ? 'content_intact TRUE' : 'FALSE?!')
let caught = 0
for (const [label, f] of cases) {
  const { out, hits } = f(clean)
  if (!hits || out === clean) { console.log(`${label.padEnd(32)} → PATCH DID NOT APPLY — test is invalid`); continue }
  const rows = await run(out)
  const intact = rows.every(r => r.content_intact)
  if (!intact) caught++
  console.log(`${label.padEnd(32)} → content_intact ${intact ? 'TRUE — MISSED' : 'false — caught'}  (${hits} field changed · counts still fine: ${rows.every(r => r.questions === 15 && r.notes_ok)})`)
}
console.log(`\n${caught}/${cases.length} corruptions caught`)
