//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _DiffableDifferenceType {
    var isEmpty: Bool { get }
}

public protocol Diffable {
    associatedtype Difference: _DiffableDifferenceType = _DefaultDifference<Self>
    
    /// Returns the difference needed to produce the receiver from the given instance.
    ///
    /// i.e. self is the destination, the given instance is the source.
    func difference(from source: Self) -> Difference
    
    /// Applies the given difference to the receiver.
    ///
    /// - Returns An instance representing the state of the receiver with the difference applied, or nil if the difference is incompatible with the receiver’s state.
    func applying(_: Difference) -> Self?
    
    mutating func applyUnconditionally(_: Difference) throws
}

// MARK: - Implementation

extension Diffable {
    public mutating func applyUnconditionally(_ difference: Difference) throws {
        self = try applying(difference).unwrap() // FIXME
    }
}

extension Diffable where Self: Equatable, Difference == _DefaultDifference<Self> {
    public func difference(from source: Self) -> Difference {
        Difference(base: CollectionOfOne(self).difference(from: CollectionOfOne(source)))
    }
    
    public func applying(_ difference: Difference) -> Self? {
        CollectionOfOne(self).applying(difference.base)?.value
    }
}

// MARK: - Auxiliary

public struct _DefaultDifference<Base>: ExpressibleByNilLiteral, _DiffableDifferenceType {
    fileprivate let base: CollectionOfOne<Base>.Difference
    
    public var isEmpty: Bool {
        base.update == nil
    }
    
    public var oldValue: Base? {
        base.update?.oldValue
    }
    
    public var newValue: Base? {
        base.update?.oldValue
    }
    
    fileprivate init(base: CollectionOfOne<Base>.Difference) {
        self.base = base
    }
    
    public init(nilLiteral: ()) {
        self.base = .init(update: nil)
    }
}

extension _DefaultDifference: Equatable where Base: Equatable {
    
}

extension _DefaultDifference: Hashable where Base: Hashable {
    
}

public enum _ReplaceOrApplyDifference<T: Diffable> {
    case replace(T)
    case apply(difference: T.Difference)
}

extension CollectionDifference: _DiffableDifferenceType {
    
}
