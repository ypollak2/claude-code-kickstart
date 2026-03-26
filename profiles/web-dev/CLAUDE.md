# Project Instructions

## Stack
TypeScript, React, Next.js, Tailwind CSS, PostgreSQL, Prisma

## Commands
- `npm run dev` — start dev server
- `npm test` — run tests (vitest)
- `npm run build` — production build
- `npm run lint` — ESLint check
- `npm run db:push` — push Prisma schema changes
- `npm run db:studio` — open Prisma Studio

## Architecture
- `app/` — Next.js App Router pages and layouts
- `components/` — React components (PascalCase.tsx)
- `lib/` — shared utilities and helpers
- `server/` — server-side logic (API routes, actions)
- `prisma/` — database schema and migrations
- `public/` — static assets

## Critical Constraints
- Use server actions for mutations, not API routes
- Never import server code in client components ('use client')
- All database writes must use Prisma transactions
- Validate all API inputs with zod schemas
- Use Tailwind classes, never inline styles
