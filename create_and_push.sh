#!/usr/bin/env bash
set -euo pipefail
# Script para popular o repositório com o scaffold inicial do monorepo turismo-rs.
# Uso: salve como create_and_push.sh, torne executável e execute dentro da pasta do repo clonado.
#
# Ele:
#  - cria a estrutura de pastas
#  - escreve os arquivos principais (package.json, docker-compose.yml, apps, packages, etc)
#  - faz git add/commit/push para origin/main (cria branch main se necessário)
#
ROOT_DIR="$(pwd)"
echo "Criando estrutura de arquivos em: $ROOT_DIR"

# Função utilitária para escrever arquivos com EOF
write_file() {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<'EOF'
'"$content"'
EOF
}

# --- Abaixo os arquivos serão criados via heredoc (conteúdo substituído automaticamente) ---
# Em vez de usar write_file (que complexifica substituições), vamos criar diretamente cada arquivo com cat.

# package.json (root)
cat > package.json <<'EOF'
{
  "name": "turismo-rs-monorepo",
  "private": true,
  "type": "module",
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "bun --filter web dev",
    "build": "bun run --filter \"./apps/*\" --filter \"./packages/*\" build",
    "db:generate": "bun --filter db exec prisma generate",
    "db:migrate": "bun --filter db exec prisma migrate dev",
    "docker:dev": "docker-compose -f docker-compose.yml up --build",
    "docker:stop": "docker-compose -f docker-compose.yml down"
  },
  "devDependencies": {
    "bun-types": "latest",
    "typescript": "^5.4.5"
  }
}
EOF

# docker-compose.yml
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: ./apps/web/Dockerfile
    container_name: turismo_rs_web
    ports:
      - "5173:5173"
    volumes:
      - .:/app
      - /app/node_modules
      - /app/apps/web/node_modules
      - /app/apps/api/node_modules
      - /app/packages/db/node_modules
      - /app/packages/ui/node_modules
      - /app/packages/eslint-config-custom/node_modules
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - NODE_ENV=development
    depends_on:
      db:
        condition: service_healthy
    command: bun run dev

  api:
    build:
      context: .
      dockerfile: ./apps/api/Dockerfile
    container_name: turismo_rs_api
    ports:
      - "4000:4000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - NODE_ENV=development
    depends_on:
      db:
        condition: service_healthy
    command: bun run dev

  db:
    image: postgres:16-alpine
    container_name: turismo_rs_db
    restart: always
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-password}
      POSTGRES_DB: ${POSTGRES_DB:-turismo_rs}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-user} -d ${POSTGRES_DB:-turismo_rs}"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
EOF

# .dockerignore
cat > .dockerignore <<'EOF'
.DS_Store
node_modules
.env
bun.lockb
apps/*/node_modules
packages/*/node_modules
EOF

# README.md
cat > README.md <<'EOF'
# turismo.rs - Monorepo

Bem-vindo ao monorepo do **turismo.rs**, uma plataforma de turismo state-of-the-art para o Rio Grande do Sul.

## Visão do Projeto

Construir uma plataforma moderna, escalável e completa que unifica roteiros, reservas, experiências personalizadas e informações úteis para viajantes no RS. A arquitetura foi projetada para suportar múltiplos subdomínios (`gramado.turismo.rs`, `sso.turismo.rs`, etc.) e ser altamente escalável.

## Estrutura do Monorepo

Este projeto usa `bun` como gerenciador de pacotes e `workspaces` para organizar o código.

-   `apps/`: Contém as aplicações principais.
    -   `web`: A aplicação front-end principal, construída com **Remix**, **Vite**, **React**, **TailwindCSS** e **DaisyUI**.
    -   `api`: Um placeholder para uma futura API dedicada (e.g., com Hono ou ElysiaJS).
-   `packages/`: Contém pacotes compartilhados.
    -   `db`: Configuração do banco de dados com **Prisma** e schema do PostgreSQL.
    -   `ui`: Componentes React (UI) compartilhados entre as aplicações.
    -   `eslint-config-custom`: Configuração de ESLint centralizada.

## Tech Stack

-   **Runtime/Toolkit**: Bun
-   **Framework Web**: Remix + Vite
-   **Banco de Dados**: PostgreSQL
-   **ORM**: Prisma
-   **Estilização**: TailwindCSS + DaisyUI
-   **Containerização**: Docker e Docker Compose

## Como Começar

### Pré-requisitos

-   Docker e Docker Compose
-   Bun (opcional para local)

### 1. Configurar Variáveis de Ambiente

Copie .env.example para .env e ajuste se necessário.

### 2. Iniciar o ambiente com Docker

bun run docker:dev

### 3. Migrar o banco

bun run db:migrate

### 4. Acessar

http://localhost:5173
EOF

# .env.example
cat > .env.example <<'EOF'
# Variáveis de Ambiente para o Docker Compose

# Banco de Dados PostgreSQL
DATABASE_URL="postgresql://user:password@db:5432/turismo_rs?schema=public"
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=turismo_rs
EOF

# apps/api Dockerfile
mkdir -p apps/api
cat > apps/api/Dockerfile <<'EOF'
FROM oven/bun:1.0

WORKDIR /app

COPY package.json bun.lockb ./
COPY apps/api/package.json ./apps/api/
RUN bun install --frozen-lockfile --production=false

COPY apps/api/ ./apps/api/

WORKDIR /app/apps/api

EXPOSE 4000

CMD ["bun", "run", "dev"]
EOF

# apps/api package.json
cat > apps/api/package.json <<'EOF'
{
  "name": "api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "bun --watch src/index.ts",
    "build": "bun build src/index.ts --outdir ./dist"
  },
  "dependencies": {
    "hono": "^4.3.2"
  },
  "devDependencies": {
    "bun-types": "latest",
    "eslint-config-custom": "workspace:*"
  }
}
EOF

# apps/api src
mkdir -p apps/api/src
cat > apps/api/src/index.ts <<'EOF'
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.json({ message: 'API do turismo.rs está no ar!' })
})

export default {
  port: 4000,
  fetch: app.fetch,
}
EOF

# apps/web Dockerfile
mkdir -p apps/web
cat > apps/web/Dockerfile <<'EOF'
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
EOF

# apps/web package.json
cat > apps/web/package.json <<'EOF'
{
  "name": "web",
  "private": true,
  "sideEffects": false,
  "type": "module",
  "scripts": {
    "build": "remix vite:build",
    "dev": "remix vite:dev --host 0.0.0.0",
    "start": "remix-serve ./build/server/index.js",
    "typecheck": "tsc"
  },
  "dependencies": {
    "@prisma/client": "5.13.0",
    "@remix-run/node": "^2.9.2",
    "@remix-run/react": "^2.9.2",
    "@remix-run/serve": "^2.9.2",
    "daisyui": "^4.11.1",
    "isbot": "^4.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@remix-run/dev": "^2.9.2",
    "@types/react": "^18.2.20",
    "@types/react-dom": "^18.2.7",
    "autoprefixer": "^10.4.19",
    "eslint-config-custom": "workspace:*",
    "postcss": "^8.4.38",
    "tailwindcss": "^3.4.3",
    "typescript": "^5.1.6",
    "vite": "^5.1.0",
    "vite-tsconfig-paths": "^4.2.1"
  }
}
EOF

# apps/web remix.config.js
cat > apps/web/remix.config.js <<'EOF'
/** @type {import('@remix-run/dev').AppConfig} */
export default {
  ignoredRouteFiles: ["**/.*"],
  appDirectory: "app",
  assetsBuildDirectory: "public/build",
  publicPath: "/build/",
  serverBuildPath: "build/server/index.js",
  future: {
    v3_fetcherPersist: true,
    v3_relativeSplatPath: true,
    v3_throwAbortReason: true,
  },
  tailwind: true,
  postcss: true,
};
EOF

# apps/web vite.config.ts
cat > apps/web/vite.config.ts <<'EOF'
import { vitePlugin as remix } from "@remix-run/dev";
import { installGlobals } from "@remix-run/node";
import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";

installGlobals();

export default defineConfig({
  server: {
    port: 5173,
    host: '0.0.0.0'
  },
  plugins: [remix(), tsconfigPaths()],
});
EOF

# apps/web tailwind.config.js
cat > apps/web/tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "../../packages/ui/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["night"],
  },
}
EOF

# apps/web postcss.config.js
cat > apps/web/postcss.config.js <<'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# apps/web tsconfig.json
cat > apps/web/tsconfig.json <<'EOF'
{
  "include": ["remix.env.d.ts", "**/*.ts", "**/*.tsx"],
  "compilerOptions": {
    "lib": ["DOM", "DOM.Iterable", "ES2022"],
    "isolatedModules": true,
    "esModuleInterop": true,
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "target": "ES2022",
    "strict": true,
    "allowJs": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "~/*": ["./app/*"]
    },
    "noEmit": true
  }
}
EOF

# apps/web app files
mkdir -p apps/web/app/routes
mkdir -p apps/web/app/styles

cat > apps/web/app/root.tsx <<'EOF'
import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
} from "@remix-run/react";
import type { LinksFunction } from "@remix-run/node";
import stylesheet from "~/styles/tailwind.css?url";

export const links: LinksFunction = () => [
  { rel: "stylesheet", href: stylesheet },
  { rel: "preconnect", href: "https://fonts.googleapis.com" },
  { rel: "preconnect", href: "https://fonts.gstatic.com", crossOrigin: "anonymous" },
  { rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" },
];

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" data-theme="night" className="scroll-smooth">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
        <style>
          {`
            html { font-family: 'Inter', sans-serif; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; }
            .animate-fade-in { animation: fadeIn 1s ease-in-out; }
            .animate-fade-in-up { animation: fadeInUp 1s ease-in-out; }
            @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
            @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
          `}
        </style>
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

export default function App() {
  return <Outlet />;
}
EOF

cat > apps/web/app/styles/tailwind.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

cat > apps/web/app/routes/_index.tsx <<'EOF'
import type { MetaFunction } from "@remix-run/node";
import { useEffect, useState } from "react";

export const meta: MetaFunction = () => {
  return [
    { title: "turismo.rs — O Futuro do Turismo no Rio Grande do Sul (Em Construção)" },
    { name: "description", content: "Uma nova era para o turismo no Rio Grande do Sul. Em breve, uma plataforma state-of-the-art com roteiros, reservas e experiências personalizadas." },
  ];
};

export default function Index() {
  const [year, setYear] = useState(new Date().getFullYear());

  useEffect(() => {
    setYear(new Date().getFullYear());
  }, []);

  return (
    <div className="bg-slate-900 text-slate-200">
      <div className="absolute inset-0 -z-10 h-full w-full bg-slate-900 bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:14px_24px]"></div>
      <div className="absolute left-0 right-0 top-0 -z-10 m-auto h-[310px] w-[310px] rounded-full bg-emerald-500 opacity-20 blur-[100px]"></div>

      <div className="container mx-auto px-6 py-8 animate-fade-in">
        <header className="flex items-center justify-between">
          <a href="/" className="flex items-center gap-4 group">
            <div className="h-12 w-12 rounded-lg bg-gradient-to-br from-emerald-500 to-teal-400 flex items-center justify-center text-white font-extrabold text-lg shadow-2xl shadow-emerald-500/20 group-hover:scale-105 transition-transform">RS</div>
            <h1 className="text-2xl font-bold tracking-tighter">turismo.rs</h1>
          </a>
          <a href="#notify" className="btn btn-sm btn-ghost hidden md:inline-flex">Seja Notificado</a>
        </header>

        <main className="mt-24 text-center animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
          <span className="badge badge-lg badge-outline border-emerald-400/50 text-emerald-400">Plataforma em Construção</span>
          <h2 className="mt-6 text-4xl md:text-6xl font-extrabold tracking-tighter bg-gradient-to-br from-white to-slate-400 bg-clip-text text-transparent">
            Uma nova era para o turismo no Rio Grande do Sul.
          </h2>
          <p className="mt-6 mx-auto max-w-2xl text-lg text-slate-400">
            Estamos desenvolvendo uma plataforma state-of-the-art para unificar roteiros, reservas e experiências personalizadas. Independente, moderno e focado no viajante.
          </p>

          <div className="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
            <a href="#notify" className="btn btn-primary btn-wide bg-emerald-500 hover:bg-emerald-400 border-none text-slate-900 font-bold">Quero ser o primeiro a saber</a>
            <a href="#about" className="btn btn-ghost">Sobre o projeto</a>
          </div>

          <div className="mt-12 alert alert-warning max-w-3xl mx-auto bg-amber-500/10 border-amber-500/20 text-amber-300">
            <svg xmlns="http://www.w3.org/2000/svg" className="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
            <span><strong>Atenção:</strong> Somos um projeto independente, sem afiliação, vínculo ou patrocínio do Governo do Estado do RS, Secretaria de Turismo ou Cadastur.</span>
          </div>
        </main>

        <section id="about" className="mt-32 scroll-mt-24 animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
          <div className="text-center">
            <h3 className="text-3xl font-bold tracking-tighter">O que estamos construindo?</h3>
            <p className="mt-4 max-w-xl mx-auto text-slate-400">A visão é ambiciosa: uma plataforma completa que integra tudo o que o viajante precisa.</p>
          </div>

          <div className="mt-12 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Roteiros Inteligentes</h4><p>Por região, tema (enoturismo, ecoturismo) e com sugestões baseadas em seu perfil.</p></div></div>
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Reservas e Ingressos</h4><p>Integração direta com parceiros locais para hotéis, passeios e eventos.</p></div></div>
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Mapa Interativo</h4><p>Navegação, transfers, pontos de interesse e planejamento de rotas em tempo real.</p></div></div>
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Módulos Futuros</h4><p>SSO, portais para parceiros, LGPD e subdomínios para cidades específicas.</p></div></div>
          </div>
        </section>

        <section id="notify" className="mt-32 scroll-mt-24 animate-fade-in-up" style={{ animationDelay: '0.6s' }}>
          <div className="card lg:card-side bg-slate-800/50 shadow-xl max-w-4xl mx-auto border border-slate-700/50">
            <div className="card-body">
              <h3 className="card-title text-2xl">Não perca o lançamento!</h3>
              <p>Deixe seu e-mail e seja um dos primeiros a explorar a nova forma de fazer turismo no Rio Grande do Sul.</p>
              <form className="card-actions justify-end mt-4" onSubmit={(e) => { e.preventDefault(); alert('Obrigado! Você será notificado. (Protótipo sem backend)'); }}>
                <input type="email" placeholder="seu-melhor-email@exemplo.com" className="input input-bordered w-full" required />
                <button type="submit" className="btn btn-primary bg-emerald-500 hover:bg-emerald-400 border-none text-slate-900 font-bold">Notifique-me</button>
              </form>
              <p className="text-xs text-slate-500 mt-2">Prometemos não enviar spam. Este formulário é um protótipo sem backend.</p>
            </div>
          </div>
        </section>

        <footer className="footer footer-center p-10 text-slate-400">
          <aside>
            <p className="font-bold text-lg">turismo.rs</p>
            <p>Copyright © {year} - Todos os direitos reservados</p>
            <p className="font-semibold text-amber-400">Projeto independente. Não afiliado ao Governo do RS, SETUR ou Cadastur.</p>
          </aside>
          <nav>
            <div className="grid grid-flow-col gap-4">
              <a href="https://setur.rs.gov.br/inicial" target="_blank" rel="noopener noreferrer" className="link link-hover">SETUR-RS</a>
              <a href="https://www.turismo.rs.gov.br/turismo/" target="_blank" rel="noopener noreferrer" className="link link-hover">Turismo RS (Gov)</a>
              <a href="https://cadastur.turismo.gov.br" target="_blank" rel="noopener noreferrer" className="link link-hover">Cadastur</a>
            </div>
          </nav>
        </footer>
      </div>
    </div>
  );
}
EOF

# packages/db
mkdir -p packages/db/prisma
cat > packages/db/package.json <<'EOF'
{
  "name": "db",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "scripts": {
    "build": "echo 'db build script placeholder'"
  },
  "dependencies": {
    "@prisma/client": "5.13.0"
  },
  "devDependencies": {
    "prisma": "5.13.0"
  },
  "exports": {
    "./client": "./node_modules/.prisma/client/index.js"
  }
}
EOF

cat > packages/db/prisma/schema.prisma <<'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Tenant {
  id        String    @id @default(cuid())
  name      String
  subdomain String?   @unique
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  users     User[]
  partners  Partner[]
}

model User {
  id        String    @id @default(cuid())
  email     String    @unique
  name      String?
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  tenantId  String
  tenant    Tenant    @relation(fields: [tenantId], references: [id])
}

model Partner {
  id          String   @id @default(cuid())
  name        String
  description String?
  type        PartnerType
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  tenantId    String
  tenant      Tenant   @relation(fields: [tenantId], references: [id])

  hotelDetails Hotel?
}

enum PartnerType {
  HOTEL
  RESTAURANT
  TRANSFER
  ATTRACTION
}

model Hotel {
  id        String    @id @default(cuid())
  partnerId String    @unique
  partner   Partner   @relation(fields: [partnerId], references: [id], onDelete: Cascade)
  rooms     Int
  stars     Float
}
EOF

# packages/eslint-config-custom
mkdir -p packages/eslint-config-custom
cat > packages/eslint-config-custom/package.json <<'EOF'
{
  "name": "eslint-config-custom",
  "version": "1.0.0",
  "main": "index.js",
  "license": "MIT",
  "dependencies": {
    "@typescript-eslint/eslint-plugin": "^7.8.0",
    "@typescript-eslint/parser": "^7.8.0",
    "eslint-config-turbo": "^1.13.3",
    "eslint-plugin-react": "7.34.1"
  },
  "publishConfig": {
    "access": "public"
  }
}
EOF

cat > packages/eslint-config-custom/index.js <<'EOF'
module.exports = {
  extends: ["turbo", "eslint:recommended"],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint", "react"],
  rules: {
    "react/jsx-key": "off",
  },
};
EOF

# packages/ui
mkdir -p packages/ui
cat > packages/ui/package.json <<'EOF'
{
  "name": "ui",
  "version": "1.0.0",
  "private": true,
  "main": "./index.tsx",
  "types": "./index.tsx",
  "scripts": {
    "build": "echo 'ui build script placeholder'"
  },
  "dependencies": {
    "react": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.64",
    "eslint-config-custom": "workspace:*",
    "typescript": "^5.4.5"
  }
}
EOF

cat > packages/ui/index.tsx <<'EOF'
import * as React from "react";

export const Button = ({ children }: { children: React.ReactNode }) => {
  return (
    <button className="btn btn-primary">
      {children}
    </button>
  );
};
EOF

# Git: commit and push
git add .
git status --porcelain
if [ -z "$(git status --porcelain)" ]; then
  echo "Nada para commitar."
else
  # Cria branch main se não existir localmente
  if ! git rev-parse --verify main >/dev/null 2>&1; then
    git checkout -b main
  else
    git checkout main || true
  fi

  git add .
  git commit -m "chore: initial monorepo scaffold"
  # push (pode pedir autenticação)
  git push -u origin main
  echo "Arquivos criados, commitados e enviados para origin/main."
fi

echo "Pronto. Se houver erro no push, verifique permissões/remote (git remote -v) e tente manualmente."
EOF