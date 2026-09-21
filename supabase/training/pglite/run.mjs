import { PGlite } from '@electric-sql/pglite'
import { readFileSync } from 'fs'

const M = '/Users/robert/PrepClutch/supabase/migrations/'
const db = new PGlite()

// Minimal stand-in for the production schema these migrations touch.
await db.exec(`
  CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS 'SELECT gen_random_uuid()';
  CREATE TYPE section_type AS ENUM ('verbal','quantitative','reading','math','language');
  CREATE TABLE questions (id uuid PRIMARY KEY DEFAULT uuid_generate_v4(), section section_type NOT NULL);
  INSERT INTO questions (section)
    SELECT (ARRAY['verbal','quantitative','reading','math','language'])[1 + (g % 5)]::section_type
    FROM generate_series(1, 1500) g;
`)

const last = r => r[r.length - 1].rows
const r059 = await db.exec(readFileSync(M + '059_training_questions.sql', 'utf8'))
console.log('059 verification:', JSON.stringify(last(r059)[0]))

const sql060 = readFileSync(M + '060_training_bank.sql', 'utf8')
const first = last(await db.exec(sql060))
console.log('\n060 verification (first run):')
console.table(first)

// Idempotency: deterministic ids + DELETE/INSERT should make a re-run identical.
const second = last(await db.exec(sql060))
console.log('re-run identical:', JSON.stringify(first) === JSON.stringify(second))

const n = (await db.query(`SELECT COUNT(*)::int AS n FROM training_questions`)).rows[0].n
console.log('rows after two runs:', n, '(expect 75, not 150)')
