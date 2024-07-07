//
// Copyright (c) Vatsal Manot
//

import Foundation

public class _ExpiringCache<Key: Hashable, Value> {
    private let timeout: UInt64
    private var cache = [Key: Entry]()
    private var purgeRestrictionExpirationTimestamp: UInt64 = 0
    
    public init(timeout: UInt64) {
        self.timeout = timeout
    }
    
    public subscript(key: Key) -> Value? {
        get {
            guard let entry = cache[key], !entry.isExpired else {
                remove(key)
                return nil
            }
            return entry.value
        }
        set {
            if let value = newValue {
                insert(key: key, value: value)
            } else {
                remove(key)
            }
        }
    }
    
    private func insert(key: Key, value: Value) {
        purgeExpiredEntries()
        let expirationTimestamp = DispatchTime.now().uptimeNanoseconds + (timeout * NSEC_PER_MSEC)
        let entry = Entry(value: value, expirationTimestamp: expirationTimestamp)
        cache[key] = entry
    }
    
    private func remove(_ key: Key) {
        cache.removeValue(forKey: key)
    }
    
    private func purgeExpiredEntries() {
        guard canPurge else { return }
        
        cache = cache.filter { !$0.value.isExpired }
        updatePurgeRestriction()
    }
    
    private var canPurge: Bool {
        DispatchTime.now().uptimeNanoseconds > purgeRestrictionExpirationTimestamp
    }
    
    private func updatePurgeRestriction() {
        purgeRestrictionExpirationTimestamp = DispatchTime.now().uptimeNanoseconds + (100 * timeout * NSEC_PER_MSEC)
    }
    
    private struct Entry {
        let value: Value
        let expirationTimestamp: UInt64
        
        var isExpired: Bool {
            DispatchTime.now().uptimeNanoseconds > expirationTimestamp
        }
    }
}
