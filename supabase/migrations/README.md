# Migration numbers

Migrations are applied **by hand** in the Supabase SQL editor — a pushed
migration is not a live one.

**Numbers are never reused, including by throwaway diagnostic queries.** Robert
names each Supabase SQL tab after the leading `-- NNN — Title` comment so he can
find it later, so a diagnostic labelled `010` and a migration labelled `010` are
indistinguishable to him. That exact collision once caused a read-only query to
be run in place of a migration, and the resulting "it didn't work" took three
rounds to diagnose.

**Before writing a new script — migration OR diagnostic — take the next number
from this ledger and add a row.** The files in this directory are not the
authority; numbers burned on diagnostics leave no file behind.

| # | Title | Kind | Applied |
|---|---|---|---|
| 001 | Initial schema | migration | ✅ |
| 002 | Badges | migration | ✅ |
| 003 | Classes | migration | ✅ |
| 004 | Class names | migration | ✅ |
| 005 | Leaderboard avatar_url | migration | ✅ |
| 006 | Engine refactor | migration | ✅ |
| 007 | Cumulative scoring | migration | ✅ |
| 008 | Backfill question history | migration | ✅ |
| 009 | Adopt sample reading questions | migration | ❌ superseded by 014 |
| 010 | Reading backfill diagnostic | diagnostic | ✅ read-only |
| 011 | Identify duplicate accounts | diagnostic | ✅ read-only |
| 012 | Remove duplicate account | migration | ✅ |
| 013 | Is the new reading flow live | diagnostic | ✅ read-only |
| 014 | Adopt legacy reading questions | migration | ✅ |
| 015 | Confirm answers map to live questions | diagnostic | ✅ read-only |
| 016 | Confirm legacy answers credited | diagnostic | ❌ not run |
| 017 | Fix double-escaped quotes in options | migration | ✅ |
| 018 | Fix defects found by the question-bank audit | migration | ✅ |
| 019 | Rebalance answer positions | migration | ✅ |
| 020 | Add 114 reading questions | migration | ✅ |
| 021 | Add 75 verbal questions | migration | ✅ |
| 022 | Add 72 quantitative questions | migration | ✅ |
| 023 | Add 57 math questions | migration | ✅ |
| 024 | Add 55 language questions | migration | ✅ |

| 025 | Spot-check 018 landed | diagnostic | ✅ read-only |

| 026 | Admin email lookup (get_admin_user_directory) | migration | ✅ |
| 027 | Check 026 function exists | diagnostic | ✅ read-only |

| 028 | Restore answer text in historical attempts | migration | ✅ |
| 029 | Section mastery badges (growing bicep) | migration | ✅ |

| 030 | Real titles for reading passages | migration | ✅ |
| 031 | Lengthen passages too short for their questions | migration | ⬜ pending |

Next free number: **032**

## Rules

- Lead every script with `-- NNN — Title`.
- End every migration with a verification `SELECT` so a failed or partial apply
  is visible rather than silent.
- Use deterministic ids (`md5(<stable-key>)::UUID`) for inserted rows so a
  re-run is a no-op instead of a duplicate.
- **Never** re-run `seed_questions.sql` to add content: it opens with
  `delete from questions;` and regenerates every id, which orphans
  `user_question_history` and zeroes every student's mastery.
- Deliver SQL as a `.txt` file or an inline code block — never via the
  clipboard, which the next copied snippet silently overwrites.
