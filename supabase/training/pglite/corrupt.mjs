import { PGlite } from '@electric-sql/pglite'
import { readFileSync } from 'fs'
const M = '/Users/robert/PrepClutch/supabase/migrations/'
const clean = readFileSync(M + '060_training_bank.sql', 'utf8')

async function run(sql) {
  const db = new PGlite()
  await db.exec(`CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS 'SELECT gen_random_uuid()';
    CREATE TYPE section_type AS ENUM ('verbal','quantitative','reading','math','language');
    CREATE TABLE questions (id uuid PRIMARY KEY DEFAULT uuid_generate_v4(), section section_type);`)
  await db.exec(readFileSync(M + '059_training_questions.sql', 'utf8'))
  const r = await db.exec(sql)
  return r[r.length - 1].rows
}

// Each corruption changes ONE thing a student would read, and nothing the
// counts can see — the exact class of error a bad copy and paste produces.
const cases = [
  ['one digit in a math note',      s => s.replace('4 × 3 = 12. Then add: 6 + 12 = 18', '4 × 3 = 12. Then add: 6 + 12 = 19')],
  ['one letter in a reading answer', s => s.replace('how far away the flowers are', 'how far away the flowers were')],
  ['a swapped answer key',          s => s.replace("\"Candid\"", "\"Candid\"") /* placeholder, replaced below */],
]
cases[2][1] = s => {
  // Re-key the CANDID question: move correct_index from frank (1) to secretive (0).
  const i = s.indexOf('CANDID most nearly means')
  const j = s.indexOf('::JSONB, 1, 2,', i)
  return s.slice(0, j) + '::JSONB, 0, 2,' + s.slice(j + '::JSONB, 1, 2,'.length)
}

console.log('clean      →', (await run(clean)).every(r => r.content_intact) ? 'content_intact TRUE' : 'FALSE?!')
for (const [label, f] of cases) {
  const bad = f(clean)
  if (bad === clean) { console.log(`${label.padEnd(32)} → PATCH DID NOT APPLY`); continue }
  const rows = await run(bad)
  const intact = rows.every(r => r.content_intact)
  const counts = rows.every(r => r.questions === 15 && r.notes_ok && r.labelled === 15)
  console.log(`${label.padEnd(32)} → content_intact ${intact ? 'TRUE — MISSED' : 'false — caught'}  (counts still look fine: ${counts})`)
}
