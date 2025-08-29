.PHONY: up down api web fmt test

up:
\tdocker compose -f infra/compose/dev.yml up -d

down:
\tdocker compose -f infra/compose/dev.yml down

api:
\tcd services/gateway && cargo run

web:
\tcd apps/web-astro && pnpm dev

fmt:
\tcargo fmt --all || true

test:
\tcargo test --workspace || true
