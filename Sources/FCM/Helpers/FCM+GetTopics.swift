import Foundation
import Vapor

extension FCM {
    public func getTopics(token: String) async throws -> [String] {
        return try await _getTopics(token: token)
    }

    private func _getTopics(token: String) async throws -> [String] {
        let headers = makeHeaders()
        let url = self.iidURL + "info/\(token)?details=true"
        let response = try await client.get(URI(string: url), headers: headers).validate()

        let result = try response.content.decode(TopicsResponse.self, using: JSONDecoder())
        guard let topics = result.rel?.topics.keys else {
            return []
        }
        return Array(topics)
    }
}

struct TopicsResponse: Codable {
    let rel: SubscribedTopics?

    struct SubscribedTopics: Codable {
        let topics: [String: Topic]
    }

    struct Topic: Codable {
        let addDate: String
    }
}
