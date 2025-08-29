//
//  EmailVerifyView.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

struct EmailVerifyView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @EnvironmentObject var coordinator: OnboardingCoordinator

    let verificationId: String
    @State private var code = ""
    @State private var cooldown = 0
    @State private var resendsLeft = 3
    @State private var isSubmitting = false
    @State private var isResending = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Verifica tu correo electrónico")
                .font(.title2.bold())
            Text("Abre tu e-mail en este iPhone. Copia el código de 6 cifras y escríbelo aquí. Revisa también Spam/Promociones.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            OTPField(code: $code, digits: 6, isEnabled: true)
                .padding(.vertical, 8)

            Button {
                Task { await confirm() }
            } label: {
                if isSubmitting { ProgressView() } else { Text("Verificar código") }
            }
            .disabled(code.count != 6 || isSubmitting)

            if resendsLeft > 0 {
                Button {
                    Task { await resend() }
                } label: {
                    if isResending { ProgressView() }
                    else {
                        Text(cooldown > 0 ? "Reenviar e-mail disponible en 00:\(String(format: "%02d", cooldown))" : "Reenviar e-mail (\(resendsLeft) restantes)")
                    }
                }
                .disabled(cooldown > 0 || isResending)
            } else {
                Text("Has alcanzado el máximo de reenvíos. Intenta nuevamente en 24 horas.")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            cooldown = vm.emailCooldown
            resendsLeft = vm.emailResendsLeft
        }
        .onChange(of: vm.emailCooldown) { _, new in
            cooldown = new
        }
        .onChange(of: vm.emailResendsLeft) { _, new in
            resendsLeft = new
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        } message: {
            Text(alertMessage)
        }
    }

    private func confirm() async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await vm.confirmEmail(code6: code)
            coordinator.goToKycIntro()
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func resend() async {
        isResending = true
        defer { isResending = false }
        do {
            _ = try await vm.resendEmail()
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
