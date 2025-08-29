//
//  SmsVerifyView.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

struct SmsVerifyView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @EnvironmentObject var coordinator: OnboardingCoordinator

    let verificationId: String
    @State private var code = ""
    @State private var countdown = 30
    @State private var canManualInput = false
    @State private var remainingResends = 3
    @State private var isResending = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Verifica tu número de teléfono")
                .font(.title2.bold())
            Text("El SMS debe llegar a este iPhone. Espera unos segundos.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            OTPField(code: $code, digits: 5, isEnabled: true)
                .padding(.vertical, 8)
                .onChange(of: code) { old, new in
                    // Bloqueo manual hasta que termine el timer:
                    if !canManualInput && new.count < 5 {
                        // Usuario intentando teclear 1 a 1 → bloqueamos
                        code = ""
                        return
                    }
                    if new.count == 5 {
                        Task { await confirm() }
                    }
                }

            Text(countdown > 0 ? "Reenviar SMS en 00:\(String(format: "%02d", countdown))" : "Puedes reenviar el SMS")
                .foregroundStyle(.secondary)

            Button {
                Task { await resend() }
            } label: {
                if isResending { ProgressView() } else { Text("Reenviar SMS (\(remainingResends) restantes)") }
            }
            .disabled(countdown > 0 || remainingResends <= 0 || isResending)

            Spacer()
        }
        .padding()
        .onAppear {
            remainingResends = vm.smsResendsLeft
            countdown = vm.smsResendAfter
            vm.startSmsCountdown(from: countdown) { new in
                countdown = new
                if new == 0 { canManualInput = true }
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        } message: {
            Text(alertMessage)
        }
    }

    private func confirm() async {
        do {
            try await vm.confirmSms(code5: code)
            coordinator.goToEmailVerify(verificationId)
        } catch {
            code = ""
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func resend() async {
        isResending = true
        defer { isResending = false }
        do {
            let r = try await vm.resendSms()
            remainingResends = r.remainingResends
            countdown = r.resendAfter
            canManualInput = false
            vm.startSmsCountdown(from: countdown) { new in
                countdown = new
                if new == 0 { canManualInput = true }
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
