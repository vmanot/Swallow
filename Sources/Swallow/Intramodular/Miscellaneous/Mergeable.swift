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
    public func _opaque_merging<T>(
        _ other: T
    ) throws -> any ThrowingMergeOperatable {
        try merging(try cast(other, to: Self.self))
    }
    
    public mutating func _opaque_mergeInPlace<T>(
        with other: T
    ) throws {
        let other: Self = try cast(other, to: Self.self)
        
        try mergeInPlace(with: other)
    }
}

extension ThrowingMergeOperatable {
    public func mergingInPlace(
        with other: Self
    ) throws -> Self {
        try build(self) {
            try $0.mergeInPlace(with: other)
        }
    }
    
    public func mergingInPlace(
        with other: Self
    ) -> Self where Self: MergeOperatable {
        build(self) {
            $0.mergeInPlace(with: other)
        }
    }
    
    public func merging(
        _ other: Self
    ) throws -> Self {
        try mergingInPlace(with: other)
    }

    public func merging(
        _ other: Self
    ) -> Self where Self: MergeOperatable {
        mergingInPlace(with: other)
    }
}

// MARK: - SwiftUI

#if canImport(SwiftUI)
import SwiftUI

extension PreferenceKey where Value: MergeOperatable {
    public static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = value.mergingInPlace(with: nextValue())
    }
}

extension PreferenceKey where Value: ThrowingMergeOperatable {
    public static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        do {
            value = try value.mergingInPlace(with: nextValue())
        } catch {
            runtimeIssue(error)
        }
    }
}

extension View {
    public func environment<V: MergeOperatable>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        merging value: V
    ) -> some View {
        transformEnvironment(keyPath) {
            $0.mergeInPlace(with: value)
        }
    }
    
    public func environment<V: MergeOperatable>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V?>,
        merging value: V
    ) -> some View {
        transformEnvironment(keyPath) { oldValue in
            if oldValue == nil {
                oldValue = value
            } else {
                oldValue?.mergeInPlace(with: value)
            }
        }
    }
}
#endif
