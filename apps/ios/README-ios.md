# FMLM → UBI • App iOS (SwiftUI)

Prototipo funcional de la app iOS para el onboarding de usuarios: registro, verificación por SMS/Email, KYC (mock) y estado de wallet (MetaMask en simulador con mock).

> **Estado:** MVP en simulador (sin SDKs externos).  
> **iOS mínimo:** 16.0  
> **UI:** SwiftUI  
> **Dependencias:** SPM (sin paquetes aún)

---

## 🧰 Requisitos

- macOS + Xcode 15 o superior
- iOS Simulator (incluido en Xcode)
- **Sin** SDKs externos en esta fase (KYC y MetaMask son mocks)

---

---

## ▶️ Cómo abrir y correr

1. Abre **Xcode** → **File → Open…** → selecciona `ios/FMLMUBI/FMLMUBI.xcodeproj`.
2. En el “scheme” superior elige un simulador (p. ej. **iPhone 16 Pro**).
3. Pulsa **Run (⌘R)**.

Si todo está OK verás: **Splash → Welcome → Registro → SMS → Email → KYC → Home**.

---

## 🧪 Flujos y comportamientos (MVP)

### Registro
- Datos: Nombre, Apellido, Email, Teléfono (E.164), País (ISO), Aceptación de Términos.
- Al tocar **Registrar** el mock simula el envío de **SMS** y **Email**.

### Verificación por SMS
- **Simulador:** el autofill de iOS no existe; habilitamos **modo simulador**:
  - El campo se habilita de inmediato y se muestra una pista.
  - **Código mock:** `12345`
- **Dispositivo real (futuro):** espera estricta 30s, reenvío del **mismo OTP**, TTL ~10 min.

### Verificación por Email
- **Código mock:** `654321`
- Reenvío **del mismo código** con:
  - Cooldown: **2 min**
  - Máximo: **3** reenvíos
  - Si se agota el límite → bloqueo 24h (reiniciar registro)

### KYC (mock)
- `KycIntroView` → inicia verificación (mock) → `KycStatusView`.
- En **Home** hay un **Dev Menu (solo simulador)** para forzar estados:
  - **KYC → pending / approved / rejected**

### Wallet (MetaMask)
- En simulador mostramos **conectar/desconectar mock**:
  - Dirección ejemplo: `0xA1b2…A9B0`
- En dispositivo real se integrará **MetaMask Mobile SDK** (pendiente).

---

## 🔐 Política de UX de verificación

- **SMS:** Debe llegar al **mismo iPhone** donde se realiza el onboarding.  
  No permitimos ingresar el código si el SMS llegó a otro dispositivo.
- **Email:** El usuario **debe** escribir el código de 6 dígitos;  
  permite reenvío con cooldown y máximo de intentos (mismo código).

---

## ⚙️ Ajustes de proyecto (recomendados)

- Target → **iOS Deployment Target**: 16.0
- **Info.plist** (cuando se pruebe en dispositivo real con MetaMask/KYC):
  - `LSApplicationQueriesSchemes`: agregar `metamask`
  - `CFBundleURLTypes`: agregar tu URL scheme (p. ej. `fmlmubi`) para callbacks
- **Team/Signing**: solo necesario si instalas en iPhone físico (no para simulador).

---

## 🧩 Códigos mock

- **SMS**: `12345`
- **Email**: `654321`

> **Nota:** Los reenvíos (SMS/Email) **no generan nuevos códigos** en el mock;  
> replican la política de “mismo OTP” hasta expirar TTL o agotar intentos.

---

## 🐞 Troubleshooting

- **No compila después de mover carpetas**  
  - Verifica **Target Membership**: selecciona cada archivo → panel derecho → marca el target **FMLMUBI**.
- **El simulador no “autofill” del SMS**  
  - Es correcto; en simulador no hay autofill. Usa el modo simulador y teclea **12345**.
- **No veo los botones KYC Dev**  
  - Solo aparecen en simulador (`#if targetEnvironment(simulator)`).
- **Alerta no aparece**  
  - Se usa `.alert(isPresented:)` con `showAlert` + `alertMessage` (no `item:` con `String`).

---

## 📜 Convenciones

- **Rutas y navegación**: `OnboardingCoordinator` con `NavigationStack`.
- **ViewModel**: `OnboardingViewModel` expone métodos async para registro/verificaciones/kyc (mock).
- **Errores tipados**: `RegisterError`, `SmsError`, `EmailError` con mensajes de usuario.
- **Sin persistencia local de PII** (solo estados de UI). Tokens/sesión vendrán luego (Keychain).

---

## 🔜 Próximos pasos (cuando tengamos backend/SDKs)

1. **OpenAPI v1** de:
   - `POST /v1/register`
   - `POST /v1/verify/sms/confirm`, `POST /v1/verify/sms/resend`
   - `POST /v1/verify/email/confirm`, `POST /v1/verify/email/resend`
   - `POST /v1/kyc/start`, `GET /v1/kyc/status`
   - `POST /v1/wallet/link`
2. **KYC SDK** (Persona/Veriff/Onfido/Trulioo): abrir SDK con `clientToken` y manejar webhooks/estados.
3. **MetaMask Mobile SDK**: deep links, callback vía `fmlmubi://`, chain Base (8453).
4. **Keychain**: manejo de sesión/jwt + bloqueo con Face ID/Touch ID para reingreso.
5. **i18n**: `Localizable.strings` (es/en) + accesibilidad (Dynamic Type/VoiceOver).
6. **CI/CD**: GitHub Actions + TestFlight (cuando tengamos cuenta de desarrollador).

