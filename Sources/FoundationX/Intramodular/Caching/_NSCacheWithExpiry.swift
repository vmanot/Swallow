//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct _NSCacheWithExpiry<Key: Hashable, Value>: @unchecked Sendable {
    private let base: NSCache<CacheKey, CachedObject>
    private let expiryInterval: TimeInterval
    
    public init(
        expiryInterval: TimeInterval
    ) {
        self.base = NSCache<CacheKey, CachedObject>()
        self.expiryInterval = expiryInterval
    }
    
    public init() {
        self.init(expiryInterval: .maximum)
    }
}

extension _NSCacheWithExpiry {
    public func cache(
        _ value: Value,
        forKey key: Key
    ) {
        base.setObject(
            CachedObject(
                timestamp: Date().timeIntervalSinceReferenceDate,
                expiryInterval: expiryInterval,
                value: value
            ),
            forKey: CacheKey(key: key)
        )
    }
    
    public func retrieveValue(forKey key: Key) -> Value? {
        guard let object = base.object(forKey: CacheKey(key: key)) else {
            return nil
        }
        
        let cachedObject = try! cast(object, to: CachedObject.self)
        
        guard cachedObject.hasExpired else {
            return nil
        }
        
        return cachedObject.value
    }
    
    public func retrieveInMemoryValue(forKey key: Key) -> Value? {
        retrieveValue(forKey: key)
    }
    
    public func removeCachedValue(forKey key: Key) {
        base.removeObject(forKey: CacheKey(key: key))
    }
    
    public func removeAllCachedValues() {
        base.removeAllObjects()
    }
}

extension _NSCacheWithExpiry {
    private class CacheKey: NSObject {
        let key: Key
        
        override var hash: Int {
            key.hashValue
        }
        
        init(key: Key) {
            self.key = key
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? CacheKey else {
                return false
            }
            
            return key == other.key
        }
    }
    
    private class CachedObject {
        let timestamp: TimeInterval
        let expiryInterval: TimeInterval
        let value: Value
        
        var hasExpired: Bool {
            let expiryDate = timestamp + expiryInterval
            
            return expiryDate > Date().timeIntervalSinceReferenceDate
        }
        
        init(timestamp: TimeInterval, expiryInterval: TimeInterval, value: Value) {
            self.timestamp = timestamp
            self.expiryInterval = expiryInterval
            self.value = value
        }
    }
}
