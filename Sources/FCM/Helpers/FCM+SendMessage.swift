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
    ) -> EventLoopFuture<String> {
        _send(message)
    }
    
    public func send<APNSPayload: FCMApnsPayloadProtocol & Codable>(
        _ message: FCMMessage<APNSPayload>,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<String> {
        _send(message).hop(to: eventLoop)
    }
    
    private func _send<APNSPayload: FCMApnsPayloadProtocol & Codable>(
        _ message: FCMMessage<APNSPayload>
    ) -> EventLoopFuture<String> {
        guard let configuration = self.configuration else {
            fatalError("FCM not configured. Use app.fcm.configuration = ...")
        }
        if message.android == nil,
            let androidDefaultConfig = androidDefaultConfig {
            message.android = androidDefaultConfig
        }
        if message.webpush == nil,
            let webpushDefaultConfig = webpushDefaultConfig {
            message.webpush = webpushDefaultConfig
        }

        let url = actionsBaseURL + configuration.projectId + "/messages:send"
        return getAccessToken().flatMap { accessToken -> EventLoopFuture<ClientResponse> in
            var headers = HTTPHeaders()
            headers.bearerAuthorization = .init(token: accessToken)

            return self.client.post(URI(string: url), headers: headers) { (req) in
                let payload = Payload(message: message)
                try req.content.encode(payload)
            }
        }
        .validate()
        .flatMapThrowing { res in
            let result = try res.content.decode(Result.self)
            return result.name
        }
    }
}
