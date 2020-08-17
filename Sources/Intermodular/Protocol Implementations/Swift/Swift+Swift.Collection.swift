//
// Copyright (c) Vatsal Manot
//

import Swift

extension Array: ResizableCollection {

}

public struct CollectionOnly<C: Collection>: Collection2, ImplementationForwardingWrapper {
    public typealias Value = C

    public typealias Element = C.Element
    public typealias Index = C.Index
    public typealias Iterator = C.Iterator
    public typealias SubSequence = C.SubSequence

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct BidirectionalCollectionOnly<C: Collection>: BidirectionalCollection2, ImplementationForwardingWrapper where C.Index: Strideable, C.SubSequence: BidirectionalCollection {
    public typealias Value = C

    public typealias Element = C.Element
    public typealias Index = C.Index
    public typealias Iterator = C.Iterator
    public typealias SubSequence = C.SubSequence

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct MutableCollectionOnly<C: MutableCollection>: ImplementationForwardingMutableWrapper, MutableCollection2 {
    public typealias Value = C

    public typealias Element = C.Element
    public typealias Index = C.Index
    public typealias Iterator = C.Iterator
    public typealias SubSequence = C.SubSequence

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

extension ContiguousArray: ResizableCollection {

}

public struct Join2Collection<C0: Collection, C1: Collection>: Collection2, Wrapper where C0.Index: Strideable, C0.Element == C1.Element, C0.Index == C1.Index {
    public typealias Element = C0.Element
    public typealias Index = C0.Index
    public typealias Iterator = Join2Iterator<C0.Iterator, C1.Iterator>
    public typealias Value = (C0, C1)

    public private(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public func makeIterator() -> Iterator {
        return .init((value.0.makeIterator(), value.1.makeIterator()))
    }
}

extension Join2Collection {
    public var startIndex: Index {
        return value.0.startIndex
    }

    public var endIndex: Index {
        return value.0.endIndex.advanced(by: value.1.stride)
    }

    public subscript(index: Index) -> Element {
        if index >= value.0.endIndex {
            return value.1[index.advanced(by: -value.1.stride)]
        }

        return value.0[index]
    }
}

extension Join2Collection: MutableCollection where C0: MutableCollection, C1: MutableCollection {
    public subscript(index: Index) -> Element {
        get {
            return CollectionOnly(value.0).join(value.1)[index]
        } set {
            if index >= value.0.endIndex {
                value.1[index.advanced(by: -value.1.stride)] = newValue
            }

            else {
                value.0[index] = newValue
            }
        }
    }
}

public struct RangeReplaceableCollectionOnly<C: RangeReplaceableCollection>: ImplementationForwardingMutableWrapper, Initiable, RangeReplaceableCollection2 {
    public typealias Value = C

    public typealias Element = C.Element
    public typealias Index = C.Index
    public typealias Iterator = C.Iterator
    public typealias SubSequence = C.SubSequence

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct SequenceToCollection<S: Sequence>: RandomAccessCollection2, Wrapper {
    public typealias Value = S

    public typealias Element = S.Element
    public typealias Index = Int
    public typealias Indices = SignedIntegerRange<Index>
    public typealias Iterator = Value.Iterator

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public var startIndex: Index {
        return 0
    }

    public var endIndex: Index {
        return sequenceOnly.countElements()
    }

    public var indices: Indices {
        return .init(bounds: (startIndex, endIndex))
    }

    public subscript(index: Index) -> Element {
        fatallyAssertIndexAsValidSubscriptArgument(index)

        return value.sequenceOnly.dropFirst(index).first.forceUnwrap()
    }

    public func makeIterator() -> Iterator {
        return value.makeIterator()
    }
}

// MARK: - Helpers -

public typealias CollectionOfTwo<T> = Join2Collection<CollectionOfOne<T>, CollectionOfOne<T>>
public typealias CollectionOfThree<T> = Join2Collection<CollectionOfOne<T>, CollectionOfTwo<T>>
public typealias CollectionOfFour<T> = Join2Collection<CollectionOfOne<T>, CollectionOfThree<T>>

public typealias SequenceOfTwo<T> = Join2Sequence<CollectionOfOne<T>, CollectionOfOne<T>>

public typealias Join3Collection<C0, C1, C2> = Join2Collection<Join2Collection<C0, C1>, C2> where C0: Collection, C1: Collection, C2: Collection, C0.Index: Strideable, C0.Element == C1.Element, C1.Element == C2.Element, C0.Index == C1.Index, C1.Index == C2.Index

extension Sequence {
    public func toFauxCollection() -> SequenceToCollection<Self> {
        return .init(self)
    }
}

extension Collection {
    public var collectionOnly: CollectionOnly<Self> {
        return .init(self)
    }
}

extension Collection where Index: Strideable {
    public func join<C: Collection>(_ other: C) -> Join2Collection<Self, C> where C.Element == Element {
        return Join2Collection((self, other))
    }

    public func join<C0: Collection, C1: Collection>(_ other0: C0, _ other1: C1) -> Join3Collection<Self, C0, C1> where C0.Element == Element {
        return join(other0).join(other1)
    }
}
