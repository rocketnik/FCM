public struct FCMNotification: Codable {
    /// The notification's title.
    var title: String
    
    /// The notification's body text.
    var body: String

    /// Contains the URL of an image that is going to be downloaded on the device and displayed in a notification. JPEG, PNG, BMP have full support across platforms. Animated GIF and video only work on iOS. WebP and HEIF have varying levels of support across platforms and platform versions. Android has 1MB image size limit. Quota usage and implications/costs for hosting image on Firebase Storage: https://firebase.google.com/pricing
    var image: String?
    
    /// - parameters:
    ///     - title: The notification's title.
    ///     - body: The notification's body text.
    public init(
        title: String,
        body: String,
        image: String?
    ) {
        self.title = title
        self.body = body
        self.image = image
    }
}
