import Foundation

struct AccessToken {
    let value: String
    let expiresAt: Date

    var hasExpired: Bool {
        let now = Date().timeIntervalSince1970
        return now >= expiresAt.timeIntervalSince1970 - (5 * 60)
    }
}
