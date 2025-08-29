import SwiftUI

struct KycStatusView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    let status: KycStatus

    var body: some View {
        VStack(spacing: 16) {
            switch status {
            case .pending:
                ProgressView()
                Text("Estamos revisando tus documentos…")
                Button("Ir al inicio") { coordinator.goToHome() }

            case .approved:
                Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(.green)
                Text("¡Tu identidad fue verificada!")
                Button("Continuar") { coordinator.goToHome() }

            case .rejected:
                Image(systemName: "xmark.seal.fill").font(.largeTitle).foregroundStyle(.red)
                Text("No pudimos verificar tu identidad.")
                Button("Reintentar verificación") { coordinator.goToKycIntro() }

            case .requiredNotAvailable:
                Text("KYC no disponible en tu país. Tendrás capacidades limitadas.")
                Button("Ir al inicio") { coordinator.goToHome() }
            }
            Spacer()
        }
        .padding()
    }
}
