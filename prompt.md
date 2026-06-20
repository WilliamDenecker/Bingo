# Build Prompt: Multiplayer Bingo Webapp

Paste this whole document into Claude Code (or another AI coding agent) as the initial instruction.

## Goal

A mobile-first webapp where each logged-in user has a personal 5x5 bingo grid (shared challenge template across all users, but each user marks their own copy independently). Users can view their own grid, mark squares as done, see their score update automatically, and view other users' grids and scores read-only on a leaderboard.

## Tech stack (do not substitute without asking)

- Next.js 14+ (App Router, TypeScript)
- shadcn/ui + Tailwind CSS for all UI components
- Supabase (Postgres + Auth) — use `@supabase/ssr` for server/client auth helpers
- Deployment target: Vercel (so use Server Actions / Route Handlers, not a separate backend process)
- No Docker, no custom server — everything runs as Next.js serverless/edge functions

## Data model (Supabase Postgres)

```sql
-- Auth is handled by Supabase Auth (auth.users). Add a profile table:
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz default now()
);

-- One shared bingo card template (25 squares, same content for everyone)
create table bingo_squares (
  id serial primary key,
  position integer not null unique check (position >= 0 and position <= 24), -- row-major, 0-24
  label text not null
);

-- Per-user completion state for each square
create table user_squares (
  user_id uuid references profiles(id) on delete cascade,
  square_id integer references bingo_squares(id) on delete cascade,
  is_done boolean default false,
  completed_at timestamptz,
  primary key (user_id, square_id)
);
```

### Row Level Security (critical — enforce in Postgres, not just app code)

- `profiles`: anyone authenticated can `select` all rows (needed for leaderboard); a user can only `update` their own row.
- `bingo_squares`: anyone authenticated can `select` (read-only reference data, no insert/update from clients).
- `user_squares`: anyone authenticated can `select` all rows (so others' grids are viewable); a user can only `insert`/`update` rows where `user_id = auth.uid()`.

Write the RLS policies explicitly as SQL migrations, don't just describe them.

## Scoring logic

5x5 grid = 25 squares, 12 possible lines (5 rows, 5 columns, 2 diagonals).

- +2 points per square marked done (max 50 from squares)
- +10 points per fully completed line (max 120 from lines)
- Max possible score per user: 170

Calculate score server-side (in a Postgres function or in the Server Action that reads grid state), never trust a client-submitted score. Recalculate on every square toggle. Implement line-completion detection as a pure function operating on the 25-element done/not-done array, with unit tests for at least: empty grid, one row complete, one diagonal complete, full grid complete.

## Pages / routes

1. `/login` — Supabase Auth email/password (or magic link) sign in/sign up, shadcn `Card` + `Form` components.
2. `/` (or `/my-grid`) — the logged-in user's own 5x5 grid. Tapping a square toggles `is_done`. Show current score prominently at top. This is the primary mobile view — design for a single-column phone layout, grid should fit on screen without horizontal scroll on a 375px-wide viewport.
3. `/leaderboard` — list of all users ranked by score (descending), using shadcn `Table` or `Card` list.
4. `/users/[userId]` — read-only view of another user's grid (no tap-to-mark interaction), same visual grid component as `/my-grid` but disabled.

## Component requirements

- Build one shared `<BingoGrid>` component that takes `squares`, `onToggle?` (optional — omit for read-only mode), and renders a CSS grid (`grid-cols-5`) of square cards. Marked squares get a distinct visual state (filled background + checkmark icon from `lucide-react`).
- Use shadcn `Avatar`, `Badge`, `Table`, `Card`, `Button`, `Tabs` where appropriate — don't hand-roll components shadcn already provides.
- Bottom nav bar (shadcn-style, fixed on mobile) with three tabs: My Grid / Leaderboard / (optional) Profile.
- All layouts must work down to a 375px viewport width without horizontal scrolling. Test against iPhone SE dimensions as the minimum target.

## Auth flow

- Use Supabase Auth with `@supabase/ssr` middleware to protect all routes except `/login`.
- On first login, auto-create a `profiles` row if one doesn't exist (use a Postgres trigger on `auth.users` insert, or do it in a Server Action on first authenticated request).

## Deployment

- Repo on GitHub, connected to Vercel for auto-deploy on push to `main` (preview deployments for other branches/PRs).
- Environment variables (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` if needed server-side) configured in Vercel project settings, not committed to the repo.
- Include a `.env.local.example` file listing required variables.
- Include the SQL migration files in a `/supabase/migrations` folder so the schema is reproducible.

## Seed data

Include a seed script or SQL insert for 25 placeholder bingo square labels (e.g. "Drank 2L of water today", "Read 10 pages", etc. — generic enough to be replaced) so the app is testable immediately after setup.

## What to deliver

1. Working Next.js app with the routes/components above.
2. SQL migrations (schema + RLS policies + seed data) under `/supabase/migrations`.
3. `README.md` covering: local setup, Supabase project creation steps, environment variables, and how to connect the repo to Vercel for auto-deploy.
4. Basic unit tests for the scoring/line-completion logic.

## Open questions to confirm with me before/while building

- Should the 25 square labels be admin-editable in-app, or hardcoded/seeded only? -> easily editable by developer no in app changes needed/developer users
- Magic link or password auth (or both)? usernames and pincode to be made by developer
- Any branding/color preferences, or default shadcn theme is fine? no branding needed just say made by Vettebokbeer
