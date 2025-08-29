//
//  AuthService.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import Foundation

protocol AuthService {
    func register(_ payload: RegisterPayload) async throws -> RegisterResponse
    func confirmSms(verificationId: String, code5: String) async throws
    func resendSms(verificationId: String) async throws -> (resendAfter: Int, remainingResends: Int)

    func confirmEmail(verificationId: String, code6: String) async throws
    func resendEmail(verificationId: String) async throws -> (cooldown: Int, remainingResends: Int)

    func kycStart() async throws -> String // clientToken para SDK
    func kycStatus() async throws -> KycStatus
}
