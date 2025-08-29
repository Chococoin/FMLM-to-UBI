import SwiftUI

struct KycIntroView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @EnvironmentObject var coordinator: OnboardingCoordinator

    @State private var agree = false
    @State private var isStarting = false

    // Nuevo: manejo de alerta compatible con SwiftUI
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Verificación de identidad (KYC)")
                .font(.title2.bold())

            Text("Para mantener la plataforma segura, verificaremos tu identidad con nuestro socio. Tus datos se protegen de acuerdo con la ley.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Toggle("Acepto iniciar la verificación", isOn: $agree)

            Button {
                Task { await start() }
            } label: {
                if isStarting { ProgressView() } else { Text("Iniciar verificación") }
            }
            .disabled(!agree || isStarting)

            Spacer()
        }
        .padding()
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        } message: {
            Text(alertMessage)
        }
    }

    private func start() async {
        isStarting = true
        defer { isStarting = false }
        do {
            _ = try await vm.kycStart()
            let status = try await vm.kycStatus()
            coordinator.goToKycStatus(status)
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
