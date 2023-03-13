public struct FCMApnsOptions: Codable {
    /// Label associated with the message's analytics data.
    public var analyticsLabel: String?

    /// Contains the URL of an image that is going to be displayed in a notification. If present, it will override google.firebase.fcm.v1.Notification.image.
    public var image: String?

    enum CodingKeys: String, CodingKey {
        case analyticsLabel = "analytics_label"
        case image
    }

    public init(
        analyticsLabel: String? = nil,
        image: String? = nil
    ) {
        self.analyticsLabel = analyticsLabel
        self.image = image
    }
}
