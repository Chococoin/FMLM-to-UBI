# 📄 ADR 0004 – Proveedor de email transaccional

**Título:** SendGrid para emails transaccionales (web/app/bot)  
**Fecha:** 2025-08-28  
**Estado:** Aprobado  

## Contexto
Necesitamos notificaciones confiables (leads, registro, KYC, pagos, UBI).

## Decisión
Usar **SendGrid** vía microservicio `notifier`; frontend no envía emails directos; eventos por NATS `email.send`.

## Alternativas
SES, Postmark, Mailgun.

## Consecuencias
+ Arranque rápido con templates y webhooks; – coste superior a SES.

## Próximos pasos
SPF/DKIM/DMARC; templates i18n; webhook `/webhooks/sendgrid`; supresiones.

## Variables
SENDGRID_API_KEY, SENDGRID_FROM, SENDGRID_REPLY_TO, SENDGRID_WEBHOOK_SECRET.
