# 📄 ADR 0003 – Frontend y estrategia Web3 con foco en SEO

**Título**: Astro.js para contenido/SEO + wagmi (React) dentro de islas para funcionalidades Web3  
**Fecha**: 2025-08-28  
**Estado**: Aprobado  

## Contexto
SEO alto (whitepaper/blog/adquisición) + performance y funcionalidades Web3 (Base).

## Decisión
- **Astro** como base de contenido/SEO (SSG/SSR + islas).
- **wagmi + viem** en **islas React** solo donde sea necesario (conectar wallet, claim).
- Coherente con ADR-0001 y ADR-0002.

## Alternativas
Next.js + wagmi (más JS), SPA React (SEO pobre), SvelteKit (ecosistema Web3 menos maduro).

## Consecuencias
+ SEO/performance top; + aislar complejidad Web3; – curva de integración Astro↔React/wagmi.

## Próximos pasos
Layout i18n, isla “Conectar wallet”, componente `ClaimUBI`, medir CWV y documentar patrón de islas.
