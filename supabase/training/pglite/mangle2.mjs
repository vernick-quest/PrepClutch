import { PGlite } from '@electric-sql/pglite'
import { readFileSync } from 'fs'
const M = '/Users/robert/PrepClutch/supabase/migrations/'
const sql = readFileSync(M + '060_training_bank.sql', 'utf8')

async function fresh() {
  const db = new PGlite()
  await db.exec(`CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS 'SELECT gen_random_uuid()';
    CREATE TYPE section_type AS ENUM ('verbal','quantitative','reading','math','language');
    CREATE TABLE questions (id uuid PRIMARY KEY DEFAULT uuid_generate_v4(), section section_type);
    INSERT INTO questions (section) SELECT 'verbal' FROM generate_series(1,1500);`)
  await db.exec(readFileSync(M + '059_training_questions.sql', 'utf8'))
  return db
}

const strategies = {
  'as-is (whole script)':        s => [s],
  'split on every ;':            s => s.split(';'),
  'split on ; at end of line':   s => s.split(/;\s*\n/),
  'strip -- comments naively':   s => [s.replace(/--.*$/gm, '')],
  'strip -- then split on ;':    s => s.replace(/--.*$/gm, '').split(';'),
}
let allOk = true
for (const [name, fn] of Object.entries(strategies)) {
  const db = await fresh(); let err = null, last = null
  for (const frag of fn(sql).map(x => x.trim()).filter(Boolean)) {
    try { const r = await db.exec(frag); if (r.length && r[r.length-1].rows.length) last = r[r.length-1].rows }
    catch (e) { err = e.message.split('\n')[0]; break }
  }
  const ok = !err && last && last.length === 5 && last.every(r => r.content_intact && r.questions === 15)
  allOk &&= ok
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name.padEnd(28)} ${err ? 'error: ' + err.slice(0, 70) : `${last.length} sections, content_intact all true`}`)
}
console.log(allOk ? '\nsurvives every preprocessing strategy' : '\nSTILL FRAGILE')
