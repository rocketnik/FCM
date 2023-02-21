import Vapor
import Foundation
import JWT

// MARK: Engine

public struct FCM {
    let application: Application
    
    let client: Client
    
    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let audience = "https://www.googleapis.com/oauth2/v4/token"
    let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"
    let iidURL = "https://iid.googleapis.com/iid/v1:"
    let batchURL = "https://fcm.googleapis.com/batch"
    
    // MARK: Default configurations
    
    public var androidDefaultConfig: FCMAndroidConfig? {
        get { configuration?.androidDefaultConfig }
        set { configuration?.androidDefaultConfig = newValue }
    }
    
    public var webpushDefaultConfig: FCMWebpushConfig? {
        get { configuration?.webpushDefaultConfig }
        set { configuration?.webpushDefaultConfig = newValue }
    }
    
    // MARK: Initialization

    init(application: Application, client: Client) {
        self.application = application
        self.client = client
    }

    public init(application: Application) {
        self.init(application: application, client: application.client)
    }

    public init(request: Request) {
        self.init(application: request.application, client: request.client)
    }
}

// MARK: Cache

extension FCM {
    struct CacheKey: StorageKey {
        typealias Value = Cache
    }

    public var configuration: FCMConfiguration? {
        get {
            cache[.configuration]
        }
        nonmutating set {
            cache[.configuration] = newValue
            if let newValue = newValue {
                warmUpCache(with: newValue.email)
            }
        }
    }
    
    private func warmUpCache(with email: String) {
        if gAuth == nil {
            gAuth = GAuthPayload(iss: email, sub: email, scope: scope, aud: audience)
        }
        if jwt == nil {
            do {
                jwt = try generateJWT()
            } catch {
                fatalError("FCM Unable to generate JWT: \(error)")
            }
        }
    }
    
    var jwt: String? {
        get {
            cache[.jwt]
        }
        nonmutating set {
            cache[.jwt] = newValue
        }
    }
    
    var accessToken: String? {
        get {
            cache[.accessToken]
        }
        nonmutating set {
            cache[.accessToken] = newValue
        }
    }

    var gAuth: GAuthPayload? {
        get {
            cache[.gAuth]
        }
        nonmutating set {
            cache[.gAuth] = newValue
        }
    }
}
