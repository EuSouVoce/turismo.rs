FROM oven/bun:1.0

WORKDIR /app

COPY package.json bun.lockb ./
COPY apps/api/package.json ./apps/api/
RUN bun install --frozen-lockfile --production=false

COPY apps/api/ ./apps/api/

WORKDIR /app/apps/api

EXPOSE 4000

CMD ["bun", "run", "dev"]
