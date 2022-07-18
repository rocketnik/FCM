import class Foundation.DispatchQueue

class ThreadSafeDictionary<K: Hashable, V>: Collection {

    private var dictionary: [K: V]
    private let concurrentQueue = DispatchQueue(label: "Barrier Queue", attributes: .concurrent)

    var startIndex: Dictionary<K, V>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<K, V>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }

    init(dict: [K: V] = [K: V]()) {
        self.dictionary = dict
    }

    func index(after i: Dictionary<K, V>.Index) -> Dictionary<K, V>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }

    subscript(key: K) -> V? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    subscript(index: Dictionary<K, V>.Index) -> Dictionary<K, V>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }

    func removeValue(forKey key: K) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }

}
