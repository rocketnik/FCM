extension FCM {
    class Cache {
        private var storage: ThreadSafeDictionary<Key, Any>

        init() {
            self.storage = ThreadSafeDictionary<Key, Any>()
        }

        subscript<T>(_ type: Key) -> T? {
            get { storage[type] as? T }
            set { storage[type] = newValue }
        }

        func delete(_ key: Key) {
            storage.removeValue(forKey: key)
        }
    }

    var cache: Cache {
        get {
            if let existing = application.storage[CacheKey.self] {
                return existing
            }
            let new = Cache()
            application.storage[CacheKey.self] = new
            return new
        }
        nonmutating set {
            application.storage[CacheKey.self] = newValue
        }
    }
}

extension FCM.Cache {
    enum Key: String, Hashable {
        case configuration
        case jwt
        case accessToken
        case gAuth
    }
}
