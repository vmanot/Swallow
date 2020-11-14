//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type with an associated name.
public protocol Named {
    var name: String { get }
}

/// A type with an associated mutable name.
public protocol MutableNamed: Named {
    var name: String { get set }
}

// MARK - Protocol Conformances -

extension Named where Self: CustomStringConvertible {
    public var description: String {
        return name
    }
}
