//
// Copyright (c) Vatsal Manot
//

import Swift

/// A protocol defining an in-place merge operation for types of the same kind, which may throw errors.
public protocol ThrowingMergeOperatable {
    
    /// Merges the instance with another of the same type in place.
    ///
    /// - Parameter other: An instance of the same type to merge with.
    /// - Throws: An error if the merge operation fails.
    mutating func mergeInPlace(with other: Self) throws
}

/// A protocol that extends `ThrowingMergeOperatable` to provide non-throwing merge operations.
public protocol MergeOperatable: ThrowingMergeOperatable {
    
    /// Merges the instance with another of the same type in place, without throwing errors.
    ///
    /// - Parameter other: An instance of the same type to merge with.
    mutating func mergeInPlace(with other: Self)
    
    /// Produces a new instance by merging the current instance with another of the same type.
    ///
    /// - Parameter other: An instance of the same type to merge with.
    /// - Returns: A new instance resulting from the merge.
    func merging(_ other: Self) -> Self
}

extension ThrowingMergeOperatable {
    public func _opaque_merging(_ other: Any) throws -> any ThrowingMergeOperatable {
        try merging(try cast(other, to: Self.self))
    }
    
    public func merging(
        _ other: Self
    ) throws -> Self {
        try build(self) {
            try $0.mergeInPlace(with: other)
        }
    }
    
    public func merging(
        _ other: Self
    ) -> Self where Self: MergeOperatable {
        build(self) {
            $0.mergeInPlace(with: other)
        }
    }
}
