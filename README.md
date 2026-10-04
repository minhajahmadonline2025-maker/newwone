# Usthad Feedback System

Student feedback collection (star rating + written comment per Usthad/subject) with an admin panel for staff, classes, limits, reports (PDF) and shared documents.

**Stack:** React 18 · TypeScript · Vite · Tailwind CSS · Supabase (Postgres, Auth, Storage)

## Project structure

```
src/
  components/         Student panel + shared UI (StarRating)
    admin/            Admin panel screens
  services/           Supabase queries (feedbackService.ts)
  lib/supabase.ts     Supabase client (reads env vars)
  types/database.ts   Table row types
supabase/migrations/  SQL schema, seed data, storage (run in order)
```

Imports use the `@/` alias (maps to `src/`).

## Setup

1. Create a project at https://supabase.com.
2. Run the files in `supabase/migrations/` in filename order (SQL Editor, or `supabase db push` with the CLI).
3. In Supabase → Authentication → Users, create the admin user (email/password).
4. `cp .env.example .env` and fill in the project URL and anon key.
5. `npm install && npm run dev`

Admin panel: open the app and add `#admin` to the URL.

## Scripts

`npm run dev` · `npm run build` · `npm run typecheck` · `npm run lint`

## Deploy

Build output is `dist/`. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in your host's environment variables (Netlify/Vercel/etc).
