FROM oven/bun:1.0 AS base

WORKDIR /app

FROM base AS deps
COPY bun.lockb ./
COPY package.json ./
COPY apps/web/package.json ./apps/web/
COPY apps/api/package.json ./apps/api/
COPY packages/db/package.json ./packages/db/
COPY packages/ui/package.json ./packages/ui/
COPY packages/eslint-config-custom/package.json ./packages/eslint-config-custom/
RUN bun install --frozen-lockfile --production=false

FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN bun run build

FROM base AS runner
WORKDIR /app/apps/web
COPY --from=builder /app/apps/web/build ./build
COPY --from=builder /app/apps/web/public ./public
COPY --from=builder /app/apps/web/package.json .
RUN bun install --production

EXPOSE 5173
ENV NODE_ENV=production

CMD ["bun", "run", "dev"]
