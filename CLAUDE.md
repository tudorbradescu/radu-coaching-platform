# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Radu Coaching Platform — a private online fitness coaching SPA for Radu Mocuța. Vue 3 frontend with Supabase as the backend (auth, database, edge functions). No server-side rendering.

## Commands

- `npm run dev` — Start Vite dev server
- `npm run build` — Production build
- `npm run preview` — Preview production build locally

No test framework or linter is configured.

**Local setup:** Copy `.env.example` to `.env` and fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`, then `npm install`.

## Architecture

**Stack:** Vue 3 (Composition API, `<script setup>`) + Vite 7 + Tailwind CSS v4 + Supabase + Pinia

**Key pattern:** Components fetch data directly from Supabase (`supabase.from('table').select()`). Security is enforced at the database level via Row-Level Security (RLS) policies, not through a backend API layer. Pinia is used only for auth state — all other data is local to components.

**Auth flow:**
1. `main.js` calls `auth.init()` before mounting the app
2. Supabase auth listener updates the Pinia store on session changes
3. `router.js` beforeEach guard enforces access: unauthenticated → `/login`, non-admin → blocked from `/admin/*`
4. Profile data comes from the `profiles` table with a fallback to JWT `app_metadata` if the DB read fails

**Roles:** Two roles stored in `profiles.role` — `admin` and `client`. Admin status is checked via `auth.isAdmin` (checks both profile and JWT metadata).

**Database (5 tables):**
- `profiles` — extends auth.users, auto-created via trigger on signup
- `modules` / `videos` — training content (videos use Vimeo IDs, including private format `ID/hash`)
- `client_modules` — assignment join table (which client has access to which module)
- `checkins` — weekly client check-in reports with 16+ fields

Admin views use RPC functions: `get_admin_stats()`, `get_recent_checkins()`, `get_clients()`, `get_all_checkins()`.

**Client creation:** Done via a Supabase Edge Function (`/functions/v1/create-client`), called from `AdminClients.vue`.

## Routing

| Path | View | Access |
|------|------|--------|
| `/login` | LoginView | Public |
| `/` | DashboardView | Client |
| `/modul/:id` | ModuleView | Client (+ module access check) |
| `/checkin` | CheckinView | Client |
| `/admin` | AdminDashboard | Admin |
| `/admin/clienti` | AdminClients | Admin |
| `/admin/module` | AdminModules | Admin |
| `/admin/checkins` | AdminCheckins | Admin |

## Conventions

- Import alias: `@/` maps to `src/`
- UI: Dark theme (#0a0a0f base), red accent (#ef4444), orange secondary (#f97316), fonts Bebas Neue (headings) + Inter (body)
- Icons: Lucide Vue Next
- Styling: Tailwind utility classes + scoped CSS in components. Custom theme colors defined in `src/assets/css/main.css`
- Responsive: Mobile-first with bottom tab bar on mobile, top nav on desktop (`AppNav.vue`)
- Score color coding: green (good/5) → yellow (medium/3) → red (bad/1)

## Deployment

GitHub Pages via `.github/workflows/deploy.yml`. On push to `main`:
1. `npm ci` → `npm run build`
2. Copies `index.html` to `404.html` (SPA routing fallback)
3. Deploys `dist/` to GitHub Pages

Base path is `/radu-coaching-platform/` in production (set in `vite.config.js`).

Required GitHub secrets: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`.
