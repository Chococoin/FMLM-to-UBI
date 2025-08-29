//
//  MockAuthService.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import Foundation

final class MockAuthService: AuthService {
    private struct Session {
        var smsCode = "12345"
        var emailCode = "654321"
        var smsResendsLeft = 3
        var emailResendsLeft = 3
        var emailCooldownActiveUntil: Date? = nil
        var createdAt = Date()
        var ttlMinutes: Int = 10
    }
    private var sessions: [String: Session] = [:]

    func register(_ payload: RegisterPayload) async throws -> RegisterResponse {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        guard payload.acceptTerms,
              payload.email.contains("@"),
              payload.phoneE164.starts(with: "+")
        else { throw RegisterError.invalidInput }

        let id = UUID().uuidString
        sessions[id] = Session()
        let resp = RegisterResponse(
            verificationId: id,
            smsExpiresAt: Date().addingTimeInterval(10*60),
            smsResendAfterSeconds: 30,
            emailResendCooldownSeconds: 120,
            emailMaxResends: 3
        )
        return resp
    }

    func confirmSms(verificationId: String, code5: String) async throws {
        guard let s = sessions[verificationId] else { throw SmsError.sessionExpired }
        if Date().timeIntervalSince(s.createdAt) > Double(s.ttlMinutes * 60) {
            sessions.removeValue(forKey: verificationId)
            throw SmsError.otpExpired
        }
        if code5 == s.smsCode {
            sessions[verificationId] = s
            return
        } else {
            throw SmsError.otpInvalid
        }
    }

    func resendSms(verificationId: String) async throws -> (resendAfter: Int, remainingResends: Int) {
        guard var s = sessions[verificationId] else { throw SmsError.sessionExpired }
        if s.smsResendsLeft <= 0 { throw SmsError.maxResends }
        s.smsResendsLeft -= 1
        sessions[verificationId] = s
        return (30, s.smsResendsLeft)
    }

    func confirmEmail(verificationId: String, code6: String) async throws {
        guard let s = sessions[verificationId] else { throw EmailError.sessionExpired }
        if Date().timeIntervalSince(s.createdAt) > Double(s.ttlMinutes * 60) {
            sessions.removeValue(forKey: verificationId)
            throw EmailError.otpExpired
        }
        if code6 == s.emailCode {
            sessions[verificationId] = s
            return
        } else {
            throw EmailError.otpInvalid
        }
    }

    func resendEmail(verificationId: String) async throws -> (cooldown: Int, remainingResends: Int) {
        guard var s = sessions[verificationId] else { throw EmailError.sessionExpired }
        if let until = s.emailCooldownActiveUntil, Date() < until {
            throw EmailError.resendCooldown
        }
        if s.emailResendsLeft <= 0 { throw EmailError.resendMaxed }
        s.emailResendsLeft -= 1
        s.emailCooldownActiveUntil = Date().addingTimeInterval(120)
        sessions[verificationId] = s
        return (120, s.emailResendsLeft)
    }

    func kycStart() async throws -> String {
        // clientToken simulado
        return "mock-client-token"
    }

    func kycStatus() async throws -> KycStatus {
        // alterna para demo
        return .approved
    }
}
