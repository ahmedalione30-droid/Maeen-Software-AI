FROM node:20-bookworm-slim AS base

WORKDIR /app
RUN corepack enable

FROM base AS dependencies
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/maeen-software-ai/package.json apps/maeen-software-ai/package.json
RUN pnpm install --frozen-lockfile --filter @workspace/maeen-software-ai...

FROM dependencies AS builder
COPY apps/maeen-software-ai apps/maeen-software-ai
RUN pnpm --filter @workspace/maeen-software-ai run db:generate
RUN pnpm --filter @workspace/maeen-software-ai run build

FROM base AS runner
ENV NODE_ENV=production
ENV PORT=3000
WORKDIR /app
COPY --from=builder /app/apps/maeen-software-ai/.next/standalone ./
COPY --from=builder /app/apps/maeen-software-ai/.next/static ./apps/maeen-software-ai/.next/static
COPY --from=builder /app/apps/maeen-software-ai/public ./apps/maeen-software-ai/public
EXPOSE 3000
CMD ["node", "apps/maeen-software-ai/server.js"]