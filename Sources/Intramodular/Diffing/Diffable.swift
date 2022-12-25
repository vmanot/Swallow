//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Diffable {
    associatedtype Difference
    
    /// Returns the difference needed to produce the receiver from the given instance.
    func difference(from _: Self) -> Difference
    
    /// Applies the given difference to the receiver.
    ///
    /// - Returns An instance representing the state of the receiver with the difference applied, or nil if the difference is incompatible with the receiver’s state.
    func applying(_: Difference) -> Self?
    
    mutating func applyUnconditionally(_: Difference) throws
}

public enum _ReplaceOrApplyDifference<T: Diffable> {
    case replace(T)
    case apply(difference: T.Difference)
}

// MARK: - Implementation -

extension Diffable {
    public mutating func applyUnconditionally(_ difference: Difference) throws {
        self = try applying(difference).unwrap() // FIXME
    }
}
