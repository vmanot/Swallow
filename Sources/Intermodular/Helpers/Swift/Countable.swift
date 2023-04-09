//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type with an integer count.
public protocol Countable<Count> {
    /// A type that can represent the count of the conforming type.
    associatedtype Count: BinaryInteger = Int

    /// The count of this value.
    var count: Count { get }
}

// MARK: - Helpers

extension Sequence where Element: Countable {
    public func elementOfLeastCount() -> Element? {
        return sorted(by: { $0.count < $1.count }).first
    }

    public func elementOfGreatestCount() -> Element? {
        return sorted(by: { $0.count < $1.count }).last
    }
}
