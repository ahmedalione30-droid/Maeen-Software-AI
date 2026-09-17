---
name: Stage 0 verification boundary
description: Local RLS verification must never use the managed database connection.
---

RLS fixture tests require an explicitly local `RLS_TEST_DATABASE_URL`; they must not fall back to `DATABASE_URL`.

**Why:** The managed connection may point to a protected or production database, and the isolation fixture creates and deletes test tenants.

**How to apply:** Run the fixture only after starting the local pgvector Compose service and applying the development migration.