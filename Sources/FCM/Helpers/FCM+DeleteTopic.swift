import Foundation
import Vapor

extension FCM {
    func makeHeaders() -> HTTPHeaders {
        guard let serverKey = configuration.serverKey else {
            fatalError("FCM: DeleteTopic: Server Key is missing.")
        }
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "key=\(serverKey)")
        return headers
    }
}
extension FCM {
    public func deleteTopic(_ name: String, tokens: String...) async throws {
        try await deleteTopic(name, tokens: tokens)
    }

    public func deleteTopic(_ name: String, tokens: [String]) async throws {
        try await _deleteTopic(name, tokens: tokens)
    }

    private func _deleteTopic(_ name: String, tokens: [String]) async throws {
        let headers = makeHeaders()
        let url = self.iidURL + "batchRemove"
        
        _ = try await self.client.post(URI(string: url), headers: headers) { (req) in
            struct Payload: Content {
                let to: String
                let registration_tokens: [String]

                init(to: String, registration_tokens: [String]) {
                    self.to = "/topics/\(to)"
                    self.registration_tokens = registration_tokens
                }
            }
            let payload = Payload(to: name, registration_tokens: tokens)
            try req.content.encode(payload)
        }.validate()
    }
}
