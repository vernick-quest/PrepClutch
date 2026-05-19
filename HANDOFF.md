# PrepClutch — Handoff Summary

**Last updated:** May 2026  
**Repo:** https://github.com/vernick-quest/PrepClutch  
**Deployed:** Vercel (auto-deploys on push to `main`)  
**Stack:** Next.js 16.2.6 · React 19 · Supabase (`@supabase/ssr` 0.10.3) · Tailwind CSS

---

## What the App Does

PrepClutch is an HSPT (High School Placement Test) prep platform for students. Users sign in with Google, take timed 10-question quizzes across 5 sections, earn Clutch Points for correct + fast answers, and compete on class and global leaderboards.

---

## Scoring System

### Clutch Points — per question

| Outcome | Points |
|---|---|
| Wrong or timed out | 0 |
| Correct, under benchmark | `base + ceil(base × (1 − timeTaken/benchmark))` |
| Correct, over benchmark | `ceil(base × 0.2)` floor |

All values are whole integers (`Math.ceil` — never fractional).

**Base points by difficulty:**
- Easy = 10, Medium = 20, Hard = 35

**Time benchmarks per section (ms):**
- Verbal: 16,000 · Quantitative: 34,000 · Reading: 24,000 · Math: 42,000 · Language: 25,000

### Leaderboard total (Clutch Points on dashboard)

`SUM of MAX(score per section)` — only your **personal best** per section counts.  
Maximum possible: **500 pts × 5 sections = 2,500 pts total**.

Full-quiz attempts (`section = 'full'`) are **excluded** from leaderboard totals.

### Source files
- `lib/scoring.ts` — `scoreQuestion()` and `classifyTiming()` 
- `lib/constants.ts` — `SECTION_BENCHMARKS_MS`, `DIFFICULTY_BASE_POINTS`, `MAX_SECTION_XP = 500`

---

## Database

### Supabase project
Environment variables in `.env.local`:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

### Migration files (`supabase/migrations/`)

| File | What it does |
|---|---|
| `001_initial.sql` | Core tables: `profiles`, `questions`, `quiz_attempts`, `user_achievements`, `achievement_definitions` |
| `002_badges.sql` | Badge/achievement system |
| `003_classes.sql` | `classes` table, `class_code` on profiles |
| `004_class_names.sql` | `name` column on classes |
| `005_leaderboard_avatar_url.sql` | Added `avatar_url` to leaderboard view |
| `006_engine_refactor.sql` | Smart deduplication, passage batching, leaderboard view rebuild (see below) |

### Key tables

**`profiles`** — one row per user  
`id, display_name, avatar_color, avatar_url, class_code, is_admin`

**`questions`**  
`id, section, prompt, options (jsonb), correct_index, difficulty (1/2/3), explanation, passage, passage_id`

**`quiz_attempts`**  
`id, user_id, section, score, total_questions, total_xp, answers (jsonb), completed_at`

**`user_question_history`** — per-user per-question tracking  
`(user_id, question_id) PK, last_answered_at, times_seen, times_correct, times_wrong`

**`user_achievements`**  
`user_id, achievement_key, earned_at`

### Key RPCs

**`upsert_question_history(p_user_id, p_question_id, p_correct)`**  
Atomic ON CONFLICT upsert. Called after every quiz for each answer.

**`get_section_coverage(p_user_id)`**  
Returns `(section, correct, seen, total)`:
- `correct` = questions answered correctly at least once
- `seen` = questions attempted at least once
- `total` = total questions in DB for that section

### `leaderboard_view`
Aggregates best scores per user per section:
```sql
WITH best AS (
  SELECT user_id, section, MAX(total_xp) AS best_xp
  FROM quiz_attempts
  WHERE completed_at IS NOT NULL AND section != 'full'
  GROUP BY user_id, section
)
SELECT p.id AS user_id, p.display_name, p.avatar_color, p.avatar_url, p.class_code,
  COALESCE(SUM(b.best_xp), 0) AS aggregate_score,
  MAX(CASE WHEN b.section='verbal'       THEN b.best_xp END) AS verbal_score,
  MAX(CASE WHEN b.section='quantitative' THEN b.best_xp END) AS quantitative_score,
  MAX(CASE WHEN b.section='reading'      THEN b.best_xp END) AS reading_score,
  MAX(CASE WHEN b.section='math'         THEN b.best_xp END) AS math_score,
  MAX(CASE WHEN b.section='language'     THEN b.best_xp END) AS language_score,
  COALESCE((SELECT SUM(total_xp) FROM quiz_attempts WHERE user_id=p.id ...), 0) AS total_xp
FROM profiles p LEFT JOIN best b ON b.user_id = p.id
GROUP BY p.id, ...
```

---

## Key Files

### App routes (`app/`)

| Route | File | Notes |
|---|---|---|
| `/` | `app/page.tsx` | Dashboard — leaderboard, progress panel, start practice |
| `/login` | `app/login/page.tsx` | Google OAuth button (browser-side) |
| `/auth/callback` | `app/auth/callback/page.tsx` | PKCE exchange handler (client component, **not** a route handler) |
| `/quiz/[section]` | `app/quiz/[section]/page.tsx` | Smart question selection; passes questions to QuizClient |
| `/results` | `app/results/page.tsx` | Post-quiz summary; reads from `sessionStorage('quiz_result')` |
| `/profile` | `app/profile/page.tsx` | Own profile with Clutch Points + mastery bars |
| `/profile/[id]` | `app/profile/[id]/page.tsx` | Public profile (any logged-in user can view) |
| `/admin` | `app/admin/page.tsx` | Admin-only; class management |
| `/bestiary` | `app/bestiary/page.tsx` | Achievement/badge gallery |

### Components

| File | Role |
|---|---|
| `components/quiz/QuizClient.tsx` | Full quiz UI + timer + scoring + saves `quiz_attempts` + upserts `user_question_history` |
| `components/ui/Footer.tsx` | Shared footer |

### Library

| File | Role |
|---|---|
| `lib/scoring.ts` | `scoreQuestion()`, `classifyTiming()`, `FLAG_LABELS` |
| `lib/constants.ts` | All numeric constants and section config |
| `lib/badges.ts` | Achievement/badge logic |
| `lib/supabase/client.ts` | `createClient()` for browser components |
| `lib/supabase/server.ts` | `createClient()` for server components |

### Infrastructure

| File | Role |
|---|---|
| `proxy.ts` | Next.js middleware (session refresh on every request) |
| `types/database.ts` | TypeScript types: `Question`, `QuizAnswer`, `UserQuestionHistory`, `Section` |

---

## Auth — Important Notes

**OAuth flow uses PKCE.** This is fragile — do not change it without understanding the following:

1. Login button calls `supabase.auth.signInWithOAuth({ provider: 'google', redirectTo: '/auth/callback' })` — **browser-side only**, in `app/login/page.tsx`
2. Google redirects to `/auth/callback?code=xxx`
3. `app/auth/callback/page.tsx` (a **client component**, not a route handler) calls `exchangeCodeForSession(code)`
4. The client is created with **`detectSessionInUrl: false`** — this is critical. Without it, the SDK auto-exchanges the code on init, consuming the PKCE verifier before the manual call, causing "code verifier not found" errors.
5. `proxy.ts` **excludes `/auth/callback`** from the middleware matcher for the same reason — middleware calling `getUser()` can clobber the verifier cookie.

---

## Question Selection (`app/quiz/[section]/page.tsx`)

Smart deduplication priority order:
1. **Unseen** questions (never attempted)
2. **Previously wrong** questions
3. **Previously correct** questions (max 1 recycled per session — `MAX_CORRECT_RECYCLED = 1`)

For `reading` section: `batchByPassage()` groups questions by `passage_id` so consecutive questions share the same passage without re-rendering.

For `full` quiz: runs per-section selection (10 per section) and concatenates all 5 sections.

---

## Dashboard Progress Panel

**Overall card:** aggregate Clutch Points / 2,500 with amber progress bar.

**Per-section cards** (in "Your Progress" right panel):
- Header: `section emoji + name` | `score / 500 pts`
- **Clutch Points bar** (thick, `h-3`, section color) — fill = `score / 500`
- **Questions mastered bar** (thin, `h-1.5`, 50% opacity) — fill = `correct / total` from `get_section_coverage`
- Label: `Questions mastered: X / Y`

---

## Results Page

Reads from `sessionStorage('quiz_result')` — no extra DB fetch for question data.

**Clutch Points display logic:**
- **Single section + new personal best** → shows `+X 🏆 New Personal Best` in amber
- **Single section + didn't beat best** → shows muted `X pts this run / Best: Y pts`
- **Full quiz** → no Clutch Points shown (full attempts excluded from leaderboard)

**Review Answers** (auto-expanded):
Each question card shows:
- Topline: ✅/❌/⏰ · difficulty dots · time chip (green ≤ benchmark, yellow ≤ 125%, red > 125%) · target time
- Body: question prompt → your answer → correct answer (if wrong) → rationale (always)

**Timing flags** (from `classifyTiming()` in `lib/scoring.ts`):
- `time_sink` — wrong + took > 1.5× benchmark
- `rushed_error` — wrong + took < 0.3× benchmark  
- `speed_demon` — correct + took < 0.5× benchmark

---

## Leaderboard

- **Class leaderboard:** filtered by `profile.class_code`
- **Global leaderboard:** top 50 by `aggregate_score`
- All names are clickable links → own profile or `/profile/[id]`
- Mini section bars per entry normalized to `MAX_SECTION_XP = 500`
- Scores displayed as `pts` — never `%`

---

## Known Design Decisions / Future Considerations

- **Cumulative vs. best-per-section:** Currently best-per-section (deliberate choice). Could change to cumulative in `leaderboard_view` SQL.
- **Full quiz scores don't count:** Full-quiz `quiz_attempts` rows exist in DB but leaderboard view filters `section != 'full'`. Could be changed to split full-quiz scores into per-section bests.
- **`user_question_history` upsert:** Called in a loop per answer after each quiz. If a quiz has 50 questions (full), this is 50 sequential RPCs. Could be batched.
- **`MAX_CORRECT_RECYCLED = 1`:** One previously-correct question may appear per session. Increase in `lib/constants.ts` to allow more repetition.
- **500 pt section cap:** `MAX_SECTION_XP` in `lib/constants.ts`. Change here to adjust bar normalization and the displayed max.
- **Passage batching:** `passage_id` column backfilled from matching `passage` text. New questions with passages need `passage_id` set manually or via trigger.

---

## Running Locally

```bash
cd /Users/robert/PrepClutch
npm install
npm run dev        # http://localhost:3000
npm run build      # production build check
```

Deploy: `git push origin main` → Vercel auto-deploys.

New migrations: paste SQL directly into Supabase SQL editor (Studio → SQL Editor → New Query). Migration files in `supabase/migrations/` are for reference only — they are not applied automatically.
