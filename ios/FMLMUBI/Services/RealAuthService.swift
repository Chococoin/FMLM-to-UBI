import Foundation

final class RealAuthService: AuthService {
    private let base = URL(string: "http://localhost:8090")!
    private let session = URLSession(configuration: .default)

    func register(_ payload: RegisterPayload) async throws -> RegisterResponse {
        let url = base.appendingPathComponent("/v1/register")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw RegisterError.unknown }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 400 { throw RegisterError.invalidInput }
            throw RegisterError.unknown
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RegisterResponse.self, from: data)
    }

    func confirmSms(verificationId: String, code5: String) async throws {
        throw SmsError.unknown // TODO: implementar cuando hagamos /verify
    }

    func resendSms(verificationId: String) async throws -> (resendAfter: Int, remainingResends: Int) {
        throw SmsError.unknown // TODO
    }

    func confirmEmail(verificationId: String, code6: String) async throws {
        throw EmailError.unknown // TODO
    }

    func resendEmail(verificationId: String) async throws -> (cooldown: Int, remainingResends: Int) {
        throw EmailError.unknown // TODO
    }

    func kycStart() async throws -> String { "mock-token" }
    func kycStatus() async throws -> KycStatus { .approved }
}