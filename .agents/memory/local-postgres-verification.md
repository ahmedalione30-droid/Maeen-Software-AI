---
name: Local PostgreSQL verification
description: Environment constraint affecting Docker-based PostgreSQL and pgvector validation.
---

The workspace may provide the Docker CLI and Compose while withholding a usable daemon and user namespaces from the unprivileged runner. In that case, local PostgreSQL validation must stop rather than falling back to the managed database or an unmatching database implementation.

**Why:** Tenant-isolation validation is only meaningful against the intended local pgvector image, and using the managed connection would violate the safety boundary.

**How to apply:** Check both Docker daemon reachability and local port availability before running Prisma migrations or RLS tests; report the infrastructure blocker if neither the Compose service nor an equivalent permitted local daemon can start.