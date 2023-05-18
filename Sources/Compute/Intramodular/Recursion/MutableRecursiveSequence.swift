//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol MutableRecursiveSequence: MutableSequence, RecursiveSequence {
    associatedtype RecursiveNestResult = Void
    associatedtype RecursiveFlattenResult = Void
    
    @discardableResult mutating func nest() -> RecursiveNestResult
    @discardableResult mutating func flatten() -> RecursiveFlattenResult
    @discardableResult mutating func flattenToUnitIfNecessary() -> RecursiveFlattenResult
}

// MARK: - Implementation

extension MutableRecursiveSequence where Self: SequenceInitiableRecursiveSequence, RecursiveNestResult == Void, RecursiveFlattenResult == Void {
    public mutating func nest() {
        self = .init([.init(rightValue: self)])
    }
    
    public mutating func flatten() {
        var elements: [Unit] = []
        recursiveForEach({ elements += $0 })
        self = .init(elements)
    }
    
    public mutating func flattenToUnitIfNecessary() {
        guard !isEmpty && !isUnit else {
            return
        }
        
        if SequenceToCollection(self).count == 1 {
            self = first!.reduce(Self.init(unit:), Self.init)
            flattenToUnitIfNecessary()
        }
    }
}

// MARK: - Extensions

extension MutableRecursiveSequence {
    public func nesting() -> Self {
        build(self, with: { $0.nest() })
    }
    
    public func flattening() -> Self {
        build(self, with: { $0.flatten() })
    }
    
    public func flatteningToUnitIfNecessary() -> Self {
        build(self, with: { $0.flattenToUnitIfNecessary() })
    }
}
