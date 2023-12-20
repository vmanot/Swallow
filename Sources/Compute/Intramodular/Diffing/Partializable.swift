//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

/// A type that can be formed by coalescing its partials.
public protocol Partializable {
    associatedtype Partial
    
    mutating func coalesceInPlace(
        with partial: Partial
    ) throws
    
    mutating func coalesceInPlace<S: Sequence>(
        withContentsOf partials: S
    ) throws where S.Element == Partial
    
    /// Create an instance by coalescing an ordered sequence of partials.
    static func coalesce<S: Sequence>(
        _ partials: S
    ) throws -> Self where S.Element == Partial
    
    /// Create an instance by coalescing an ordered sequence of partials.
    static func coalesce<C: Collection>(
        _ partials: C
    ) throws -> Self where C.Element == Partial
}

// MARK: - Implementation

extension Partializable {
    public mutating func coalesceInPlace<S: Sequence>(
        withContentsOf partials: S
    ) throws where S.Element == Partial {
        for partial in partials {
            try coalesceInPlace(with: partial)
        }
    }

    public static func coalesce<S: Sequence>(
        _ partials: S
    ) throws -> Self where Self: Initiable, S.Element == Partial {
        try partials.reduce(into: Self(), { try $0.coalesceInPlace(with: $1) })
    }
}

// MARK: - Extensions

extension Partializable {
    public func coalescingInPlace(
        with other: Partial
    ) throws -> Self {
        var result = self
        
        try result.coalesceInPlace(with: other)
        
        return result
    }
    
    /// Create an instance by coalescing an ordered sequence of partials.
    public static func coalesce<S: Sequence>(
        _ partials: S
    ) throws -> Self? where S.Element == Optional<Partial> {
        try partials.compactMap({ $0 }).reduce({ try $0.coalescingInPlace(with: $1) })
    }
    
    /// Create an instance by coalescing an ordered sequence of partials.
    public static func coalesce<S: Sequence>(
        _ partials: S
    ) throws -> Self? where S.Element == Optional<Self>, Partial == Self {
        try partials.compactMap({ $0 }).reduce({ try $0.coalescingInPlace(with: $1) })
    }
}

// MARK: - API

public struct PartialOf<T: Partializable> {
    public let value: T.Partial
    
    public init(_ value: T.Partial) {
        self.value = value
    }
}

// MARK: - Error Handling

public enum _PartializableTypeError: Error {
    case coalesceInPlaceUnavailable
    case invalidPartial(Any)
}
