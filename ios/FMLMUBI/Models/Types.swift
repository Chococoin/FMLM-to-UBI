//
//  Types.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import Foundation

enum KycStatus: String, Codable {
    case pending, approved, rejected, requiredNotAvailable
}

struct RegisterPayload: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phoneE164: String
    let country: String
    let acceptTerms: Bool
}

struct RegisterResponse: Codable {
    let verificationId: String
    let smsExpiresAt: Date
    let smsResendAfterSeconds: Int
    let emailResendCooldownSeconds: Int
    let emailMaxResends: Int
}

enum RegisterError: LocalizedError {
    case invalidInput, emailTaken, phoneTaken, rateLimit, unknown
    var errorDescription: String? {
        switch self {
        case .invalidInput: return "Datos inválidos."
        case .emailTaken: return "Este e-mail ya está registrado."
        case .phoneTaken: return "Este teléfono ya está registrado."
        case .rateLimit: return "Demasiadas solicitudes. Intenta más tarde."
        case .unknown: return "Error desconocido."
        }
    }
}

enum SmsError: LocalizedError {
    case otpInvalid, otpExpired, maxResends, sessionExpired, unknown
    var errorDescription: String? {
        switch self {
        case .otpInvalid: return "Código SMS incorrecto."
        case .otpExpired: return "El código SMS expiró."
        case .maxResends: return "Límite de reenvíos alcanzado."
        case .sessionExpired: return "La sesión expiró."
        case .unknown: return "Error desconocido."
        }
    }
}

enum EmailError: LocalizedError {
    case otpInvalid, otpExpired, resendCooldown, resendMaxed, sessionExpired, unknown
    var errorDescription: String? {
        switch self {
        case .otpInvalid: return "Código de e-mail incorrecto."
        case .otpExpired: return "El código de e-mail expiró."
        case .resendCooldown: return "Aún no puedes reenviar el e-mail."
        case .resendMaxed: return "Has alcanzado el máximo de reenvíos. Intenta en 24h."
        case .sessionExpired: return "La sesión expiró."
        case .unknown: return "Error desconocido."
        }
    }
}
