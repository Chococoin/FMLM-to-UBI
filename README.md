# FMLM → UBI (Monorepo)

Monorepo del producto (frontend Astro, backend Rust, contratos, infra).  
El **whitepaper** vive en otro repo y puede montarse aquí como submódulo en `docs/whitepaper/`.

## Estructura
- apps/ … clientes (web, iOS, bot)
- services/ … microservicios en Rust (Axum)
- packages/ … librerías compartidas (Rust/TS)
- contracts/ … OpenAPI/AsyncAPI/ABI
- infra/ … entorno local (Mongo + NATS)
- docs/adr … decisiones de arquitectura

## Desarrollo local
```bash
make up       # Mongo & NATS
make api      # gateway en :8080
# en otra terminal
make web      # placeholder web
