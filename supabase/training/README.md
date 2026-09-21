# Training question bank — source of truth

`supabase/migrations/060_training_bank.sql` is **generated** from the Python
files here. Edit the content, not the SQL.

```bash
cd supabase/training
python3 -B validate.py    # structure, recomputed answers, balance, notation
python3 -B mutate.py      # proves the validator still catches 6 planted faults
python3 -B generate.py    # writes 060_training_bank.sql + round-trips it
```

Always run with `-B`. A stale bytecode cache once made one planted-fault test
report a *different* test's fault, so a validator that had missed something
looked like it had caught it. `mutate.py` now requires every test to match its
own expected message, which is what exposed that.

## What `validate.py` enforces

- 15 questions per section, 5 per difficulty, walked easiest first
- answers stored as **text**; the index is derived, so nothing can be mis-keyed
- exactly one option's note starts with `Correct.` — and it is the answer
- every quantitative and math answer is **recomputed**, not trusted
- no answer letter above ~27% per section (the original bank put B at 46%)
- no positional references like "Sentence B" — they break if options reorder
- the 053/055 notation conventions: `3²`, `√`, `×`, `÷`

## Running it against real Postgres

There is no local Postgres, so `pglite/` runs the migrations in PGlite —
Postgres compiled to WebAssembly — against a minimal stand-in schema:

```bash
cd /tmp && mkdir pgv && cd pgv && npm init -y && npm install @electric-sql/pglite@0.2
cp ~/PrepClutch/supabase/training/pglite/*.mjs . && node run.mjs && node corrupt.mjs
```

`run.mjs` applies 059 then 060 twice (idempotency). `corrupt.mjs` plants
single-character corruptions and requires `content_intact` to flip to false.

⚠️ PGlite is not Supabase. A checksum using `WITH ORDINALITY AS a(o, n)` passed
here and failed in production with `relation "a" does not exist`. The checksum
is now a single flat expression; prefer plain constructs in verification SQL.
