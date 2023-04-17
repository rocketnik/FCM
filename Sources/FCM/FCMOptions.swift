public struct FCMOptions: Codable {
    /// Label associated with the message's analytics data.
    public var analyticsLabel: String?

    enum CodingKeys: String, CodingKey {
        case analyticsLabel = "analytics_label"
    }

    public init(
        analyticsLabel: String? = nil
    ) {
        self.analyticsLabel = analyticsLabel
    }
}
