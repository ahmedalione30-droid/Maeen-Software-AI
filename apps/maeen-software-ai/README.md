# Maeen Software Ai

المرحلة 0 من منصة خدمة عملاء واتساب متعددة العملاء.

## المتطلبات

- Node.js 20+
- pnpm
- Docker مع Docker Compose
- `DATABASE_URL`
- `RLS_TEST_DATABASE_URL` للاختبار المحلي فقط
- `ENCRYPTION_KEY`
- `POSTGRES_PASSWORD` عند تشغيل PostgreSQL المحلي

لا تضع أي قيمة سرية في المستودع. استخدم Replit Secrets أو بيئة تشغيل آمنة.

## تشغيل PostgreSQL محلياً

```bash
export POSTGRES_PASSWORD='ضع قيمة من مخزن الأسرار'
docker compose -f apps/maeen-software-ai/docker-compose.yml up -d
```

الصورة المستخدمة هي `pgvector/pgvector:pg16`.

بعد تشغيل القاعدة، عيّن `DATABASE_URL` و`RLS_TEST_DATABASE_URL` إلى قاعدة التطوير المحلية ثم نفّذ:

```bash
pnpm --filter @workspace/maeen-software-ai run db:generate
pnpm --filter @workspace/maeen-software-ai run db:migrate:dev
pnpm --filter @workspace/maeen-software-ai run test
```

اختبار RLS موجود في:

```text
tests/rls/isolation.test.ts
```

إذا لم تكن `RLS_TEST_DATABASE_URL` موجودة، يتم تخطي اختبار العزل بدلاً من استخدام قاعدة مُدارة أو إنتاجية.

## تشغيل التطبيق

```bash
pnpm --filter @workspace/maeen-software-ai run dev
```

## حدود المرحلة 0

- لا توجد مصادقة أو تسجيل مستخدمين بعد.
- لا توجد تكاملات WhatsApp أو AI أو Stripe بعد.
- `WhatsAppAccount.accessToken` موجود كنص في schema للتأسيس فقط؛ يجب تشفيره AES-256-GCM قبل إدخال أي رقم حقيقي في المرحلة 2.
- كل وصول Tenant-scoped في التطبيق يجب أن يستخدم `createTenantClient(tenantId)`.