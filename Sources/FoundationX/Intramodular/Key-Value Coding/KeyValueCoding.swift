//
// Copyright (c) Vatsal Manot
//

import Foundation

public protocol KeyValueCoding {
    func value(forKey key: String) -> Any?
    func setValue(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
}

// MARK: - Implementation

extension KeyValueCoding {
    public func removeObject(forKey key: String) {
        setValue(nil, forKey: key)
    }
}

// MARK: - Conformances

#if canImport(CloudKit)

import CloudKit

extension CKRecord: KeyValueCoding {
    
}

#endif

#if canImport(CoreData)

import CoreData

extension NSManagedObject: KeyValueCoding {
    
}

#endif

extension UserDefaults: KeyValueCoding {
    
}
