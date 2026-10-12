// Copies one 4x3 flag SVG per UN member state from the MIT-licensed
// flag-icons package into public/flags/. The package is NOT a dependency of
// the app: install it anywhere outside the repo and pass its folder.
//
//   mkdir /tmp/flags && cd /tmp/flags && npm i flag-icons@7.5.0
//   node supabase/geography/copy-flags.mts /tmp/flags/node_modules/flag-icons
//
// Bundled SVGs rather than flag emoji: Windows renders flag emoji as two
// letters, which would make every flag card unanswerable there.

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { ROWS } from './curation.mts'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '../..')
const pkg = process.argv[2]
if (!pkg) { console.error('usage: node supabase/geography/copy-flags.mts <path to flag-icons>'); process.exit(1) }

const version = JSON.parse(fs.readFileSync(path.join(pkg, 'package.json'), 'utf8')).version
const out = path.join(root, 'public/flags')
fs.mkdirSync(out, { recursive: true })
for (const [iso] of ROWS) {
  const f = `${iso.toLowerCase()}.svg`
  fs.copyFileSync(path.join(pkg, 'flags/4x3', f), path.join(out, f))
}
fs.writeFileSync(path.join(out, 'LICENSE.txt'),
  `Flag SVGs in this folder are copied unmodified from the flag-icons npm package,\n` +
  `version ${version} (https://github.com/lipis/flag-icons), 4x3 set, one file per UN member state.\n` +
  `Copied by supabase/geography/copy-flags.mts.\n\n` + fs.readFileSync(path.join(pkg, 'LICENSE'), 'utf8'))
console.log(`copied ${ROWS.length} flags from flag-icons ${version}`)
