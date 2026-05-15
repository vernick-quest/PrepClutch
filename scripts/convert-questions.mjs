/**
 * Converts hspt-question-bank.jsx question data into SQL INSERT statements.
 * Run with: node scripts/convert-questions.mjs
 */
import { readFileSync, writeFileSync } from 'fs'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const inputPath = join(__dirname, '../../Downloads/hspt-question-bank.jsx')
const outputPath = join(__dirname, '../supabase/seed_questions.sql')

const raw = readFileSync(inputPath, 'utf8')

// Extract the questions array literal from the JSX file
const match = raw.match(/const questions = (\[[\s\S]*?\]);/)
if (!match) throw new Error('Could not find questions array in file')

// Evaluate the array safely (strip JSX/module syntax first)
const arraySource = match[1]
  .replace(/correctedAnswer:/g, 'correctedAnswer_IGNORE:') // temp rename

let questions
try {
  questions = eval(arraySource)  // safe — local file we trust
} catch (e) {
  console.error('Parse error:', e.message)
  process.exit(1)
}

const sectionMap = {
  'Verbal': 'verbal',
  'Quantitative': 'quantitative',
  'Reading': 'reading',
  'Mathematics': 'math',
  'Language': 'language',
}

const letterToIndex = { A: 0, B: 1, C: 2, D: 3 }

function escape(str) {
  if (!str) return ''
  return str.replace(/'/g, "''")
}

function stripPrefix(choice) {
  // Remove "A. ", "B. ", etc.
  return choice.replace(/^[A-D]\.\s*/, '')
}

const rows = []
let skipped = 0

for (const q of questions) {
  const section = sectionMap[q.section]
  if (!section) {
    console.warn(`Skipping unknown section: ${q.section} (id ${q.id})`)
    skipped++
    continue
  }

  // Use correctedAnswer if present (some questions had annotation errors)
  const answerLetter = q.correctedAnswer_IGNORE || q.answer
  const correctIndex = letterToIndex[answerLetter]
  if (correctIndex === undefined) {
    console.warn(`Skipping bad answer "${answerLetter}" on id ${q.id}`)
    skipped++
    continue
  }

  const options = (q.choices || []).map(stripPrefix)
  const optionsJson = JSON.stringify(options).replace(/'/g, "''")

  const difficulty = q.difficulty === 'Easy' ? 1 : q.difficulty === 'Medium' ? 2 : 3
  const passage = q.passage ? `'${escape(q.passage)}'` : 'NULL'
  const explanation = q.explanation ? `'${escape(q.explanation)}'` : 'NULL'

  rows.push(
    `('${section}', '${escape(q.question)}', ${passage}, '${optionsJson}'::jsonb, ${correctIndex}, ${difficulty}, ${explanation})`
  )
}

const sql = `-- Auto-generated from hspt-question-bank.jsx — ${rows.length} questions, ${skipped} skipped
-- Run this AFTER 001_initial.sql. It replaces the manually seeded questions.

-- Clear existing questions (keep achievements)
delete from questions;

insert into questions (section, prompt, passage, options, correct_index, difficulty, explanation) values
${rows.join(',\n')};

select count(*) as total_questions_imported from questions;
`

writeFileSync(outputPath, sql)
console.log(`✅ Written ${rows.length} questions to supabase/seed_questions.sql`)
if (skipped > 0) console.warn(`⚠️  Skipped ${skipped} questions — check warnings above`)
