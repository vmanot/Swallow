//
// Copyright (c) Vatsal Manot
//

import Swift

/// A reference type (or a wrapper of one).
public protocol ReferenceType {
    var isUniquelyReferenced: Bool { mutating get }
}

// MARK: - Implementation

extension ReferenceType where Self: AnyObject {
    public var isUniquelyReferenced: Bool {
        mutating get {
            return isKnownUniquelyReferenced(&self)
        }
    }
}
