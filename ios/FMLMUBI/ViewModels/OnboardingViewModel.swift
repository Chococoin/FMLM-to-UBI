//
//  OnboardingViewModel.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    private let auth: AuthService
    init(auth: AuthService) { self.auth = auth }

    // Registro
    @Published var verificationId: String?
    @Published var smsResendAfter: Int = 30
    @Published var smsExpiresAt: Date = Date().addingTimeInterval(600)
    @Published var smsResendsLeft: Int = 3

    @Published var emailCooldown: Int = 0
    @Published var emailResendsLeft: Int = 3
    
    // MARK: - Wallet (simulator-ready)
    @Published var walletLinked: Bool = false
    @Published var walletAddress: String? = nil
    @Published var kycStatus: KycStatus = .approved
    func setKyc(_ s: KycStatus) { self.kycStatus = s }

    func mockConnectWallet() {
        // Address de ejemplo
        self.walletAddress = "0xA1b2C3D4E5F6a7B8c9D0e1F2a3B4C5D6e7F8A9B0"
        self.walletLinked = true
    }

    func mockDisconnectWallet() {
        self.walletAddress = nil
        self.walletLinked = false
    }

    // Temporizadores "vivos" locales (solo UI)
    private var smsCountdownTask: Task<Void, Never>?
    private var emailCooldownTask: Task<Void, Never>?

    func register(first: String, last: String, email: String, phoneE164: String, country: String, accept: Bool) async throws {
        let payload = RegisterPayload(firstName: first, lastName: last, email: email, phoneE164: phoneE164, country: country, acceptTerms: accept)
        let resp = try await auth.register(payload)
        self.verificationId = resp.verificationId
        self.smsResendAfter = resp.smsResendAfterSeconds
        self.smsResendsLeft = 3
        self.smsExpiresAt = resp.smsExpiresAt
        self.emailCooldown = 0
        self.emailResendsLeft = resp.emailMaxResends
    }

    func kycStart() async throws -> String {
        try await auth.kycStart()
    }

    func kycStatus() async throws -> KycStatus {
        try await auth.kycStatus()
    }
    
    func confirmSms(code5: String) async throws {
        guard let id = verificationId else { throw SmsError.sessionExpired }
        try await auth.confirmSms(verificationId: id, code5: code5)
    }

    func resendSms() async throws -> (resendAfter: Int, remainingResends: Int) {
        guard let id = verificationId else { throw SmsError.sessionExpired }
        let r = try await auth.resendSms(verificationId: id)
        self.smsResendAfter = r.resendAfter
        self.smsResendsLeft = r.remainingResends
        return r
    }

    func confirmEmail(code6: String) async throws {
        guard let id = verificationId else { throw EmailError.sessionExpired }
        try await auth.confirmEmail(verificationId: id, code6: code6)
    }

    func resendEmail() async throws -> (cooldown: Int, remainingResends: Int) {
        guard let id = verificationId else { throw EmailError.sessionExpired }
        let r = try await auth.resendEmail(verificationId: id)
        self.emailCooldown = r.cooldown
        self.emailResendsLeft = r.remainingResends
        startEmailCooldownTimer()
        return r
    }

    func startSmsCountdown(from seconds: Int, onTick: @escaping (Int) -> Void) {
        smsCountdownTask?.cancel()
        smsCountdownTask = Task {
            var remaining = seconds
            while !Task.isCancelled && remaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                remaining -= 1
                await MainActor.run { onTick(remaining) }
            }
        }
    }

    private func startEmailCooldownTimer() {
        emailCooldownTask?.cancel()
        emailCooldownTask = Task {
            while !Task.isCancelled && self.emailCooldown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.emailCooldown -= 1
            }
        }
    }

    deinit {
        smsCountdownTask?.cancel()
        emailCooldownTask?.cancel()
    }
}
