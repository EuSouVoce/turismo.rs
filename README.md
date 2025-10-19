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
