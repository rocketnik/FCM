import Foundation
import Vapor

extension FCM {
    func getAccessToken() async throws -> String {
        if let token = accessToken, !token.hasExpired {
            return token.value
        }
        let jwt = try await getJWT()
        let response = try await client.post(URI(string: audience)) { (req) in
            try req.content.encode([
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": jwt,
            ])
        }.validate()

        struct Result: Codable {
            let access_token: String
            let expires_in: Int
        }

        let result = try response.content.decode(Result.self, using: JSONDecoder())
        self.accessToken = AccessToken(
            value: result.access_token,
            expiresAt: Date().addingTimeInterval(TimeInterval(result.expires_in))
        )
        return result.access_token
    }
}
