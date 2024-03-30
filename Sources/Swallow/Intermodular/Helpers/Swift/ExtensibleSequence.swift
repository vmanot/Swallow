//
// Copyright (c) Vatsal Manot
//

import Swift

/// An extensible sequence.
public protocol ExtensibleSequence: Sequence {
    associatedtype ElementInsertResult = Void
    associatedtype ElementsInsertResult = Void
    associatedtype ElementAppendResult = Void
    associatedtype ElementsAppendResult = Void

    /// Inserts a new element into this sequence.
    @discardableResult
    mutating func insert(_: Element) -> ElementInsertResult

    /// Adds the elements of a sequence to the start of this sequence.
    @discardableResult
    mutating func insert<S: Sequence>(contentsOf _: S) -> ElementsInsertResult where S.Element == Element

    /// Adds the elements of a collection to the start of this sequence.
    @discardableResult
    mutating func insert<C: Collection>(contentsOf _: C) -> ElementsInsertResult where C.Element == Element

    /// Adds the elements of a collection to the start of this sequence.
    @discardableResult
    mutating func insert<C: BidirectionalCollection>(contentsOf _: C) -> ElementsInsertResult where C.Element == Element

    /// Adds the elements of a collection to the start of this sequence.
    @discardableResult
    mutating func insert<C: RandomAccessCollection>(contentsOf _: C) -> ElementsInsertResult where C.Element == Element

    /// Adds a new element at the end of this sequence.
    @discardableResult
    mutating func append(_: Element) -> ElementAppendResult

    /// Adds the elements of a sequence to the end of this sequence.
    @discardableResult
    mutating func append<S: Sequence>(contentsOf _: S) -> ElementsAppendResult where S.Element == Element

    /// Adds the elements of a collection to the end of this sequence.
    @discardableResult
    mutating func append<C: Collection>(contentsOf _: C) -> ElementsAppendResult where C.Element == Element

    /// Adds the elements of a collection to the end of this sequence.
    @discardableResult
    mutating func append<C: BidirectionalCollection>(contentsOf _: C) -> ElementsAppendResult where C.Element == Element

    /// Adds the elements of a collection to the end of this sequence.
    @discardableResult
    mutating func append<C: RandomAccessCollection>(contentsOf _: C) -> ElementsAppendResult where C.Element == Element
}

/// An extensible collection.
public protocol ExtensibleCollection: Collection, ExtensibleSequence {
    
}

/// An extensible collection.
public protocol ExtensibleRangeReplaceableCollection: ExtensibleCollection, RangeReplaceableCollection {
    
}

// MARK: - Implementation

extension ExtensibleSequence where ElementsAppendResult == Void {
    public mutating func append<S: Sequence>(
        contentsOf newElements: S
    ) where S.Element == Element {
        newElements.forEach({ self.append($0) })
    }
}

extension ExtensibleSequence where ElementsInsertResult == Void {
    public mutating func insert<S: Sequence>(
        contentsOf newElements: S
    ) where S.Element == Element {
        newElements.reversed().forEach({ self.insert($0) })
    }
    
    public mutating func insert<C: Collection>(
        contentsOf newElements: C
    ) where C.Element == Element {
        newElements.reversed().forEach({ self.insert($0) })
    }
    
    public mutating func insert<C: Collection>(
        contentsOf newElements: C
    ) where C.Element == Element, C.Index: Strideable {
        newElements.reversed().forEach({ self.insert($0) })
    }
}

extension ExtensibleRangeReplaceableCollection where ElementInsertResult == Void {
    public mutating func insert(_ newElement: Element) {
        insert(newElement, at: startIndex)
    }
}

// MARK: - Extensions

extension ExtensibleSequence {
    public func inserting(_ newElement: Element) -> Self {
        return build(self, with: { $0.insert(newElement) })
    }
    
    public func inserting<S: Sequence>(contentsOf newElements: S) -> Self where S.Element == Element {
        return build(self, with: { $0.insert(contentsOf: newElements) })
    }
    
    public func appending(_ newElement: Element) -> Self {
        return build(self, with: { $0.append(newElement) })
    }
    
    public func appending<S: Sequence>(contentsOf newElements: S) -> Self where S.Element == Element {
        return build(self, with: { $0.append(contentsOf: newElements) })
    }
}

extension ExtensibleSequence where Self: RangeReplaceableCollection {
    public func inserting(
        _ newElement: Element
    ) -> Self {
        return build(self, with: { $0.insert(newElement) })
    }
    
    public func inserting<S: Sequence>(
        contentsOf newElements: S
    ) -> Self where S.Element == Element {
        return build(self, with: { $0.insert(contentsOf: newElements) })
    }
    
    public func appending(
        _ newElement: Element
    ) -> Self {
        return build(self, with: { $0.append(newElement) })
    }
    
    public func appending<S: Sequence>(
        contentsOf newElements: S
    ) -> Self where S.Element == Element {
        return build(self, with: { $0.append(contentsOf: newElements) })
    }
}

// MARK: - Helpers

extension ExtensibleSequence {
    public static func + (lhs: Element, rhs: Self) -> Self {
        return rhs.inserting(lhs)
    }
    
    public static func + <S: Sequence>(lhs: S, rhs: Self) -> Self where S.Element == Element {
        return rhs.inserting(contentsOf: lhs)
    }
    
    public static func + (lhs: Self, rhs: Element) -> Self {
        return lhs.appending(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Element) {
        lhs.append(rhs)
    }
    
    @_disfavoredOverload
    public static func + <S: Sequence>(lhs: Self, rhs: S) -> Self where S.Element == Element {
        return lhs.appending(contentsOf: rhs)
    }
    
    @_disfavoredOverload
    public static func += <S: Sequence>(lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.append(contentsOf: rhs)
    }
    
    @_disfavoredOverload
    public static func + <S: ExtensibleSequence>(lhs: Self, rhs: S) -> Self where S.Element == Element {
        return lhs.appending(contentsOf: rhs)
    }
    
    @_disfavoredOverload
    public static func += <S: ExtensibleSequence>(lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.append(contentsOf: rhs)
    }
}

extension ExtensibleRangeReplaceableCollection {
    public static func + (lhs: Element, rhs: Self) -> Self {
        return rhs.inserting(lhs)
    }
    
    public static func + <S: Sequence>(lhs: S, rhs: Self) -> Self where S.Element == Element {
        return rhs.inserting(contentsOf: lhs)
    }
    
    public static func + (lhs: Self, rhs: Element) -> Self {
        return lhs.appending(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Element) {
        lhs.append(rhs)
    }
    
    public static func + <S: Sequence>(lhs: Self, rhs: S) -> Self where S.Element == Element {
        return lhs.appending(contentsOf: rhs)
    }
    
    public static func += <S: Sequence>(lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.append(contentsOf: rhs)
    }
    
    public static func + <S: ExtensibleRangeReplaceableCollection>(lhs: Self, rhs: S) -> Self where S.Element == Element {
        return lhs.appending(contentsOf: rhs)
    }
    
    public static func += <S: ExtensibleRangeReplaceableCollection>(lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.append(contentsOf: rhs)
    }
}
