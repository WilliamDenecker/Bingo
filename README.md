# Bingo — Multiplayer Bingo Webapp

Made by Vettebokbeer

A mobile-first multiplayer bingo app where each user has their own 5×5 grid, marks squares as done, and competes on a live leaderboard.

---

## Local Setup

### 1. Clone and install dependencies

```bash
git clone <your-repo-url>
cd bingo
npm install
```

### 2. Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and create a new project.
2. Note your **Project URL** and **anon public key** from **Project Settings → API**.

### 3. Run SQL migrations

In your Supabase project, open the **SQL Editor** and run the files in order:

```
supabase/migrations/001_schema.sql   — tables + triggers
supabase/migrations/002_rls.sql      — Row Level Security policies
supabase/migrations/003_seed.sql     — 25 bingo square labels
```

To edit square labels, update `003_seed.sql` before running, or `UPDATE bingo_squares SET label = '...' WHERE position = N;` after.

### 4. Configure environment variables

```bash
cp .env.local.example .env.local
```

Edit `.env.local` and fill in your Supabase URL and anon key:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### 5. Run the development server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

---

## Auth

Users sign up with a **username** (becomes `username@bingo.local` internally) and a **numeric PIN** (minimum 4 digits). No email verification required — developer-created accounts only.

On first sign-up, a `profiles` row and all 25 `user_squares` rows are auto-created by Postgres triggers.

---

## Scoring

| Source | Points |
|---|---|
| Per square marked done | +2 (max 50) |
| Per completed line (row/col/diagonal) | +10 (max 120) |
| **Maximum total** | **170** |

Scoring is calculated server-side on every page load from the raw `is_done` array. No client-submitted scores are trusted.

Run tests:
```bash
npm test
```

---

## Deploying to Vercel

1. Push this repo to GitHub.
2. Go to [vercel.com](https://vercel.com) → **New Project** → import your GitHub repo.
3. Add the following **Environment Variables** in Vercel project settings:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy. Vercel auto-deploys on every push to `main`, and creates preview deployments for PRs.

---

## Project Structure

```
app/
  layout.tsx          — root layout
  page.tsx            — /  (my grid, authenticated)
  actions.ts          — Server Action: toggle square
  MyGridClient.tsx    — client component for optimistic toggling
  login/page.tsx      — /login
  leaderboard/page.tsx — /leaderboard
  profile/page.tsx    — /profile
  users/[userId]/page.tsx — /users/[userId] read-only grid

components/
  BingoGrid.tsx       — shared 5×5 grid component
  BottomNav.tsx       — fixed bottom navigation
  ui/                 — shadcn-style primitives

lib/
  scoring.ts          — pure scoring + line-detection functions
  utils.ts            — cn() helper
  supabase/
    client.ts         — browser Supabase client
    server.ts         — server Supabase client
    types.ts          — database type definitions

supabase/migrations/  — SQL schema, RLS policies, seed data
__tests__/            — unit tests (vitest)
```
# Bingo
