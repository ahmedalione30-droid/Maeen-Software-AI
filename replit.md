# Maeen Software Ai

منصة SaaS متعددة العملاء لخدمة عملاء واتساب بالعربية باستخدام الذكاء الاصطناعي.

## Run & Operate

- `pnpm --filter @workspace/maeen-software-ai run dev` — run the Next.js app
- `pnpm --filter @workspace/maeen-software-ai run typecheck` — typecheck the app
- `pnpm --filter @workspace/maeen-software-ai run build` — build the app
- `pnpm --filter @workspace/maeen-software-ai run test` — run stage tests
- `docker compose -f apps/maeen-software-ai/docker-compose.yml up -d` — start local PostgreSQL + pgvector
- `pnpm --filter @workspace/maeen-software-ai run db:migrate:dev` — apply local Prisma migrations
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- Required env: `DATABASE_URL`, `ENCRYPTION_KEY`

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- Web: Next.js 15 App Router, React 19, TypeScript strict
- DB: PostgreSQL 16 + pgvector + Prisma ORM
- Styling: TailwindCSS
- API scaffold: Express 5 (existing shared service)

## Where things live

- `apps/maeen-software-ai/app/` — Next.js application routes and root UI
- `apps/maeen-software-ai/prisma/schema.prisma` — source of truth for the application schema
- `apps/maeen-software-ai/prisma/migrations/` — SQL migrations, including pgvector and RLS
- `apps/maeen-software-ai/src/lib/db.ts` — Prisma client and tenant transaction boundary
- `apps/maeen-software-ai/tests/rls/isolation.test.ts` — PostgreSQL tenant isolation tests

## Architecture decisions

- Tenant-scoped database access uses `createTenantClient(tenantId)` and sets `app.tenant_id` with `SET LOCAL` inside a transaction.
- PostgreSQL RLS is defense in depth; application queries must still carry the tenant filter.
- Super Admin users have `role = SUPER_ADMIN` and `tenant_id = NULL`, enforced by a database CHECK constraint.
- WhatsApp tokens are placeholder text only in stage 0; real tokens must be encrypted before stage 2.

## Product

تأسيس منصة عزل بيانات متعددة العملاء لخدمة عملاء واتساب، مع تجهيز قاعدة البيانات للمعرفة والاشتراكات وسجل التدقيق.

## User preferences

- لا تستخدم Replit DB أو Replit Auth.
- لا تنتقل بين المراحل قبل موافقة المستخدم الصريحة.
- لا تضف مكتبات أو جداول خارج النطاق المعتمد دون ADR وموافقة.

## Gotchas

- لا تشغل اختبارات RLS قبل تشغيل PostgreSQL وتطبيق migration.
- لا تستخدم Prisma client مباشرة لاستعلامات Tenant-scoped؛ استخدم `createTenantClient(tenantId)`.

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
