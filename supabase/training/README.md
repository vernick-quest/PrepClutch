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
