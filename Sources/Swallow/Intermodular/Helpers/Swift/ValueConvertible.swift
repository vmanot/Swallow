//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type with an associated value.
public protocol ValueConvertible {
    /// The type that can be used to represent all values of the conforming
    /// type.
    associatedtype Value
    
    var value: Value { get }
}

/// A type with an associated mutable value.
public protocol MutableValueConvertible: ValueConvertible {
    var value: Value { get set }
}

// MARK: - Extensions

extension ValueConvertible {
    public func map<T: Wrapper>(_ f: ((Value) throws -> T.Value)) rethrows -> T {
        return .init(try f(value))
    }
}
