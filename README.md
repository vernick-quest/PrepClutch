# HSPT Prep — Gamified Test Practice

A full-stack HSPT (High School Placement Test) preparation app built with Next.js 16 (App Router), Supabase, and Tailwind CSS. Features class leaderboards, XP rewards, timed quizzes, achievements, and 50 hand-crafted questions across all 5 HSPT sections.

## Features

- **Google OAuth** via Supabase Auth
- **5 Sections**: Verbal, Quantitative, Reading, Math, Language
- **Timed quizzes** (60s per question) with speed bonuses
- **Class leaderboard** — compete with classmates via a shared code
- **XP + Achievements** system (10 badges to earn)
- **Dark gamified UI** with section accent colors
- **Full Practice Test** mode (all 50 questions)
- Mobile-responsive

---

## Prerequisites

- Node.js 18+
- A [Supabase](https://supabase.com) account (free tier works)

---

## 1. Supabase Project Setup

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Note your **Project URL** and **anon public** key from **Settings → API**

### Run the Database Migration

In the Supabase dashboard, go to **SQL Editor** and run the contents of:

```
supabase/migrations/001_initial.sql
```

This creates all tables, RLS policies, and the leaderboard view.

### Seed Questions & Achievements

In the SQL Editor, run the contents of:

```
supabase/seed.sql
```

This seeds 50 HSPT-style questions (10 per section) and all achievement definitions.

---

## 2. Enable Google OAuth in Supabase

1. In Supabase dashboard → **Authentication → Providers → Google**
2. Enable the Google provider
3. Go to [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services → Credentials → Create OAuth 2.0 Client ID**
   - Application type: **Web application**
   - Authorized redirect URIs: `https://<your-supabase-project-ref>.supabase.co/auth/v1/callback`
4. Copy the **Client ID** and **Client Secret** back into the Supabase Google provider settings
5. Save

---

## 3. Local Development

### Install Dependencies

```bash
npm install
```

### Configure Environment

Copy the placeholder env file and fill in your values:

```bash
cp .env.local .env.local.bak   # optional backup
```

Edit `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://<your-project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

For local OAuth redirect to work, add `http://localhost:3000/auth/callback` to your Google OAuth **Authorized redirect URIs** in Google Cloud Console.

Also update Supabase → **Authentication → URL Configuration**:
- Site URL: `http://localhost:3000`
- Redirect URLs: add `http://localhost:3000/auth/callback`

### Start the Dev Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## 4. Project Structure

```
hspt-prep/
├── app/
│   ├── page.tsx              # Dashboard (leaderboard + practice CTA)
│   ├── login/page.tsx        # Google sign-in
│   ├── onboarding/page.tsx   # First-login profile setup
│   ├── quiz/[section]/       # Quiz interface (timed, A/B/C/D)
│   ├── results/page.tsx      # Post-quiz score summary
│   ├── profile/page.tsx      # Personal stats & achievement history
│   └── auth/callback/        # OAuth callback handler
├── components/
│   ├── quiz/QuizClient.tsx   # Client-side quiz engine + achievement check
│   └── ui/SignOutButton.tsx
├── lib/
│   ├── constants.ts          # Section colors, XP config
│   └── supabase/             # Browser + server Supabase clients
├── types/database.ts         # TypeScript types
├── supabase/
│   ├── migrations/001_initial.sql
│   └── seed.sql
└── proxy.ts                  # Auth guard (replaces middleware in Next.js 16)
```

---

## 5. Deploy to Vercel

1. Push your repo to GitHub
2. Go to [vercel.com](https://vercel.com) → **New Project** → import your repo
3. In **Environment Variables**, add:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy!

After deployment:
- Update Supabase **Authentication → URL Configuration**:
  - Site URL: `https://your-app.vercel.app`
  - Add redirect: `https://your-app.vercel.app/auth/callback`
- Update Google OAuth **Authorized redirect URIs** to include the Supabase callback URL (already set in step 2 — no change needed for OAuth flow)

---

## Sections & Scoring

| Section | Questions | Color |
|---|---|---|
| Verbal Skills | 10 | Amber |
| Quantitative Skills | 10 | Cyan |
| Reading Comprehension | 10 | Emerald |
| Mathematics | 10 | Rose |
| Language Skills | 10 | Violet |

- **Correct answer**: +10 XP
- **Speed bonus** (under 15s): +5 XP  
- **Aggregate score**: weighted average of best attempt per section

## Achievements

| Badge | Condition |
|---|---|
| 🩸 First Blood | Complete first quiz |
| 🎯 Sharp Shooter | Score 100% on any section |
| ⚡ Speed Demon | 5 consecutive answers under 10s |
| 🌟 All-Rounder | Complete all 5 sections |
| 👑 Top of the Class | Reach #1 on leaderboard |
| 📚 Verbal Ace | 90%+ on Verbal |
| ➕ Math Ace | 90%+ on Math |
| 📖 Reading Ace | 90%+ on Reading |
| 🔢 Quant Ace | 90%+ on Quantitative |
| ✏️ Language Ace | 90%+ on Language |
