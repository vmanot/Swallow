//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol CopyOnWrite {
    var isUniquelyReferenced: Bool { mutating get }

    mutating func makeUniquelyReferenced()
    mutating func ensureIsUniquelyReferenced()
}

// MARK: - Implementation

extension CopyOnWrite {
    public mutating func ensureIsUniquelyReferenced() {
        if !isUniquelyReferenced {
            makeUniquelyReferenced()
        }
        
        assert(isUniquelyReferenced == true)
    }
}

// MARK: - Extensions

extension CopyOnWrite {
    public mutating func withCopyingIfNeeded<T>(_ closure: ((inout Self) throws -> T)) rethrows -> T {
        ensureIsUniquelyReferenced()
        
        return try closure(&self)
    }
}
