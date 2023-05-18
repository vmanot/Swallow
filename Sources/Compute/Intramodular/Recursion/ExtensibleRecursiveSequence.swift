//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ExtensibleRecursiveSequence: ExtensibleSequence, RecursiveSequence {
    @discardableResult mutating func append(_: Unit) -> ElementAppendResult
    @discardableResult mutating func append<S: Sequence>(_: S) -> ElementsAppendResult where S.Element == Unit
    @discardableResult mutating func append<S: Sequence>(contentsOf _: S) -> ElementsAppendResult where S.Element == Unit
    
    @discardableResult mutating func append(_: Self) -> ElementAppendResult
    @discardableResult mutating func append<S: Sequence>(_: S) -> ElementsAppendResult where S.Element == Self
    @discardableResult mutating func append<S: Sequence>(contentsOf _: S) -> ElementsAppendResult where S.Element == Self
}

// MARK: - Implementation

extension ExtensibleRecursiveSequence {
    public mutating func append(_ element: Unit) {
        self += .init(leftValue: element)
    }
    
    public mutating func append<S: Sequence>(contentsOf sequence: S) where S.Element == Unit {
        self += sequence.lazy.map(Element.init(leftValue:))
    }
    
    public mutating func append(_ element: Self) {
        self += .init(rightValue: element)
    }
    
    public mutating func append<S: Sequence>(contentsOf sequence: S) where S.Element == Self {
        self += sequence.lazy.map(Element.init(rightValue:))
    }
}

extension ExtensibleRecursiveSequence where Self: SequenceInitiableRecursiveSequence {
    public mutating func append<S: Sequence>(_ sequence: S) where S.Element == Unit {
        self += .init(rightValue: .init(sequence))
    }
    
    public mutating func append<S: Sequence>(_ sequence: S) where S.Element == Self {
        self += .init(rightValue: .init(sequence))
    }
}

// MARK: - Extensions

extension ExtensibleRecursiveSequence {
    public func appending(_ element: Unit) -> Self {
        return build(self, with: { $0.append(element) })
    }
    
    public func appending<S: Sequence>(_ sequence: S) -> Self where S.Element == Unit {
        return build(self, with: { $0.append(sequence) })
    }
    
    public func appending<S: Sequence>(contentsOf sequence: S) -> Self where S.Element == Unit {
        return build(self, with: { $0.append(contentsOf: sequence) })
    }
    
    public func appending(_ element: Self) -> Self {
        return build(self, with: { $0.append(element) })
    }
    
    public func appending<S: Sequence>(_ sequence: S) -> Self where S.Element == Self {
        return build(self, with: { $0.append(sequence) })
    }
    
    public func appending<S: Sequence>(contentsOf sequence: S) -> Self where S.Element == Self {
        return build(self, with: { $0.append(contentsOf: sequence) })
    }
}

// MARK: - Helpers

extension ExtensibleRecursiveSequence {
    public static func + (lhs: Self, rhs: Unit) -> Self {
        return lhs.appending(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Unit) {
        lhs.append(rhs)
    }
    
    public static func + <S: Sequence>(lhs: Self, rhs: S) -> Self where S.Element == Unit {
        return lhs.appending(rhs)
    }
    
    public static func += <S: Sequence>(lhs: inout Self, rhs: S) where S.Element == Unit {
        lhs.append(rhs)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.appending(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.append(rhs)
    }
    
    public static func + <S: Sequence>(lhs: Self, rhs: S) -> Self where S.Element == Self {
        return lhs.appending(rhs)
    }
    
    public static func += <S: Sequence>(lhs: inout Self, rhs: S) where S.Element == Self {
        lhs.append(rhs)
    }
}
