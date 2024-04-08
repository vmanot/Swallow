/*//
// Copyright (c) Vatsal Manot
//

import Foundation

public actor _AsyncNSCache<Key: Codable & Hashable, Value: Codable> {
    private let cache = NSCache<WrappedKey<Key>, Entry>()
    private var keys: [Key] = []
    private let fileURL: URL?
    private let coder: AnyTopLevelCoder<Data>
    
    public init<Coder: TopLevelDataCoder>(
        fileURL: URL? = nil,
        coder: Coder
    ) {
        self.fileURL = fileURL
        self.coder = AnyTopLevelCoder(erasing: coder)
        
        if let fileURL = fileURL {
            Task {
                await load(from: fileURL)
            }
        }
    }
    
    public func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        cache.setObject(entry, forKey: WrappedKey(key))
        if !keys.contains(key) {
            keys.append(key)
        }
        Task {
            await save()
        }
    }
    
    public func value(forKey key: Key) -> Value? {
        let entry = cache.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    public func removeValue(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
        keys.removeAll(where: { $0 == key })
        Task {
            await save()
        }
    }
    
    public func removeAll() {
        cache.removeAllObjects()
        keys.removeAll()
        Task {
            await save()
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            value(forKey: key)
        } set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            insert(value, forKey: key)
        }
    }
    
    private func save() async {
        guard let fileURL = fileURL else {
            return
        }
        let data = try? JSONEncoder().encode(keys)
        try? data?.write(to: fileURL, options: [.atomic])
    }
    
    private func load(from fileURL: URL) async {
        guard let data = try? Data(contentsOf: fileURL),
              let loadedKeys = try? JSONDecoder().decode([Key].self, from: data) else {
            return
        }
        keys = loadedKeys
        for key in keys {
            if let value = await value(forKey: key) {
                insert(value, forKey: key)
            }
        }
    }
}

private extension _AsyncNSCache {
    final class WrappedKey<Key: Codable & Hashable>: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
    
    final class Entry {
        let value: Value
        
        init(value: Value) {
            self.value = value
        }
    }
}
*/
