import Foundation
import Vapor

struct Payload<APNSPayload: FCMApnsPayloadProtocol & Codable>: Content {
    let message: FCMMessage<APNSPayload>
}

struct Result: Decodable {
    let name: String
}

extension FCM {
    public func send<APNSPayload: FCMApnsPayloadProtocol & Codable>(
        _ message: FCMMessage<APNSPayload>
    ) async throws -> String {
        try await _send(message)
    }
    
    private func _send<APNSPayload: FCMApnsPayloadProtocol & Codable>(
        _ message: FCMMessage<APNSPayload>
    ) async throws -> String {
        if message.android == nil,
            let androidDefaultConfig = androidDefaultConfig {
            message.android = androidDefaultConfig
        }
        if message.webpush == nil,
            let webpushDefaultConfig = webpushDefaultConfig {
            message.webpush = webpushDefaultConfig
        }

        let url = actionsBaseURL + configuration.projectId + "/messages:send"
        let accessToken = try await getAccessToken()
        var headers = HTTPHeaders()
        headers.bearerAuthorization = .init(token: accessToken)

        let res = try await self.client.post(URI(string: url), headers: headers) { (req) in
            let payload = Payload(message: message)
            try req.content.encode(payload)
        }.validate()
        
        let result = try res.content.decode(Result.self)
        return result.name
    }
}
