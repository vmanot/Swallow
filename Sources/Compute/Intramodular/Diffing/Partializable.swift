//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol Partializable {
    associatedtype Partial
    
    mutating func coalesceInPlace(with partial: Partial) throws
    mutating func coalesceInPlace<S: Sequence>(withContentsOf partials: S) throws where S.Element == Partial
    
    static func coalesce<S: Sequence>(_ partials: S) throws -> Self where S.Element == Partial
    static func coalesce<C: Collection>(_ partials: C) throws -> Self where C.Element == Partial
}

// MARK: - Implementation

extension Partializable {
    public mutating func coalesceInPlace<S: Sequence>(withContentsOf partials: S) throws where S.Element == Partial {
        for partial in partials {
            try coalesceInPlace(with: partial)
        }
    }
}

extension Partializable where Self: Initiable {
    public static func coalesce<S: Sequence>(_ partials: S) throws -> Self where S.Element == Partial {
        try partials.reduce(into: Self(), { try $0.coalesceInPlace(with: $1) })
    }
}

// MARK: - API

public struct PartialOf<T: Partializable> {
    public let value: T.Partial
    
    public init(_ value: T.Partial) {
        self.value = value
    }
}
