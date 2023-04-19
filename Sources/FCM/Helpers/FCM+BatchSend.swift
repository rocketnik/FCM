import Foundation
import Vapor

extension FCM {
    public func batchSend(_ message: FCMMessageDefault, tokens: String...) async throws -> [String] {
        try await _send(message, tokens: tokens)
    }

    public func batchSend(_ message: FCMMessageDefault, tokens: [String]) async throws -> [String] {
        try await _send(message, tokens: tokens)
    }

    private func _send(_ message: FCMMessageDefault, tokens: [String]) async throws -> [String] {
        let urlPath = URI(string: actionsBaseURL + configuration.projectId + "/messages:send").path
        let accessToken = try await getAccessToken()

        let chunks = tokens.chunked(into: 500)

        return try await withThrowingTaskGroup(of: [String].self) { group in
            for chunk in chunks {
                group.addTask {
                    return try await self._sendChunk(
                        message,
                        tokens: chunk,
                        urlPath: urlPath,
                        accessToken: accessToken
                    )
                }
            }

            var results = [String]()

            for try await result in group {
                results.append(contentsOf: result)
            }

            return results
        }
    }

    private func _sendChunk(
        _ message: FCMMessageDefault,
        tokens: [String],
        urlPath: String,
        accessToken: String
    ) async throws -> [String] {
        var body = ByteBufferAllocator().buffer(capacity: 0)
        let boundary = "subrequest_boundary"

        struct Payload: Encodable {
            let message: FCMMessageDefault
        }

        do {
            let parts: [MultipartPart] = try tokens.map { token in
                var partBody = ByteBufferAllocator().buffer(capacity: 0)

                partBody.writeString("""
                    POST \(urlPath)\r
                    Content-Type: application/json\r
                    accept: application/json\r
                    \r

                    """)

                let message = FCMMessageDefault(
                    token: token,
                    notification: message.notification,
                    data: message.data,
                    name: message.name,
                    android: message.android ?? androidDefaultConfig,
                    webpush: message.webpush ?? webpushDefaultConfig,
                    apns: message.apns
                )

                try partBody.writeJSONEncodable(Payload(message: message))

                return MultipartPart(headers: ["Content-Type": "application/http"], body: partBody)
            }

            try MultipartSerializer().serialize(parts: parts, boundary: boundary, into: &body)
        } catch {
            throw error
        }

        var headers = HTTPHeaders()
        headers.contentType = .init(type: "multipart", subType: "mixed", parameters: ["boundary": boundary])
        headers.bearerAuthorization = .init(token: accessToken)

        let res = try await client.post(URI(string: batchURL), headers: headers) { req in
            req.body = body
        }.validate()
        guard let boundary = res.headers.contentType?.parameters["boundary"] else {
            throw Abort(.internalServerError, reason: "FCM: Missing \"boundary\" in batch response headers")
        }
        guard let body = res.body else {
            throw Abort(.internalServerError, reason: "FCM: Missing response body from batch operation")
        }

        struct Result: Decodable {
            let name: String
        }

        let jsonDecoder = JSONDecoder()
        var result: [String] = []

        let parser = MultipartParser(boundary: boundary)
        parser.onBody = { body in
            let bytes = body.readableBytesView
            if let indexOfBodyStart = bytes.firstIndex(of: 0x7B) /* '{' */ {
                body.moveReaderIndex(to: indexOfBodyStart)
                if let name = try? jsonDecoder.decode(Result.self, from: body).name {
                    result.append(name)
                }
            }
        }

        try parser.execute(body)

        return result
    }
}

private extension Collection where Index == Int {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
