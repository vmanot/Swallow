//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type with an associated name.
public protocol Named {
    associatedtype Name: CustomStringConvertible
    
    var name: Name { get }
}

/// A type with an associated mutable name.
public protocol MutableNamed: Named {
    var name: Name { get set }
}

// MARK: - Implemented Conformances

extension Named where Self: CustomStringConvertible {
    public var description: String {
        name.description
    }
}
