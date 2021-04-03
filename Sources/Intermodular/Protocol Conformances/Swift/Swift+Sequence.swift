//
// Copyright (c) Vatsal Manot
//

import Swift

public struct ChunkSequence<S: Sequence>: CustomDebugStringConvertible, Sequence2, Wrapper  {
    public private(set) var value: S

    public var chunkSize: Int = 1

    public init(_ value: S) {
        self.value = value
    }

    public init(_ value: S, chunkSize: Int) {
        self.value = value
        self.chunkSize = chunkSize
    }

    public func makeIterator() -> AnyIterator<[S.Element]> {
        var iterator = value.makeIterator()

        return AnyIterator {
            let result = [S.Element](iterator: &iterator, count: self.chunkSize)

            if !result.isEmpty {
                return result
            }

            return nil
        }
    }
}

public struct CyclicSequence<S: Sequence>: CustomDebugStringConvertible, Sequence2, Wrapper {
    public typealias Value = S

    public private(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public func makeIterator() -> CyclicIterator<S.Element> {
        return .init(value.makeIterator())
    }
}

public struct FixedCountSequence<S: Sequence>: Sequence, Wrapper {
    public private(set) var value: S
    public private(set) var limit: Int = -1

    public init(_ value: S) {
        self.value = value
    }

    public init(_ value: S, limit: Int) {
        self.value = value
        self.limit = limit
    }

    public func makeIterator() -> FixedCountIterator<S.Iterator> {
        return .init(value.makeIterator(), limit: limit)
    }
}

public struct HashableSequence<S: Sequence>: Hashable, ImplementationForwardingWrapper, Sequence2 where S.Element: Hashable {
    public typealias Iterator = Value.Iterator
    public typealias Value = S

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public func hash(into hasher: inout Hasher) {
        forEach({ hasher.combine($0) })
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value.elementsEqual(rhs.value)
    }
}

public struct Join2Sequence<S0: Sequence, S1: Sequence>: Sequence, Wrapper where S0.Element == S1.Element {
    public typealias Value = (S0, S1)

    public typealias Element = S0.Element

    public private(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public func makeIterator() -> Join2Iterator<S0.Iterator, S1.Iterator> {
        return .init((value.0.makeIterator(), value.1.makeIterator()))
    }
}

public struct LazyMapSequenceWithMemoryRecall<S: Sequence, Memory, Element>: Sequence {
    private var base: S
    private var initial: () -> Memory
    private var transform: (inout Memory, S.Element) -> Element

    public init(base: S, initial: @escaping () -> Memory, transform: @escaping (inout Memory, S.Element) -> Element) {
        self.base = base
        self.initial = initial
        self.transform = transform
    }

    public init(base: S, initial: @autoclosure @escaping () -> Memory, transform: @escaping (inout Memory, S.Element) -> Element) {
        self.base = base
        self.initial = initial
        self.transform = transform
    }

    public func makeIterator() -> LazyMapIteratorWithMemoryRecall<S, Memory, Element> {
        return .init(base: base.makeIterator(), initial: initial(), transform: transform)
    }
}

public struct CompactSequence<S: Sequence>: Sequence, Wrapper where S.Element: OptionalProtocol {
    public typealias Value = S

    public private(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public func makeIterator() -> CompactSequenceIterator<S.Iterator> {
        return .init(value.makeIterator())
    }
}

public struct PredicatedSequencePrefix<S: Sequence>: Sequence {
    public typealias Element = S.Element

    private var base: S

    public let isTerminator: ((Element) -> Bool)

    public init(_ base: S, isTerminator: (@escaping (Element) -> Bool)) {
        self.base = base
        self.isTerminator = isTerminator
    }

    public struct Iterator: IteratorProtocol {
        private var base: S.Iterator

        public let isTerminator: ((Element) -> Bool)

        public init(_ base: S.Iterator, isTerminator: (@escaping (Element) -> Bool)) {
            self.base = base
            self.isTerminator = isTerminator
        }

        public mutating func next() -> Element? {
            return base.next().filter({ !isTerminator($0) })
        }
    }

    public func makeIterator() -> Iterator {
        return .init(base.makeIterator(), isTerminator: isTerminator)
    }
}

public struct SequenceOnly<S: Sequence>: ImplementationForwardingWrapper, Sequence2 {
    public typealias Iterator = Value.Iterator
    public typealias Value = S

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct MutableSequenceOnly<S: MutableSequence>: ImplementationForwardingMutableWrapper, MutableSequence {
    public typealias Iterator = Value.Iterator
    public typealias Value = S

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct DestructivelyMutableSequenceOnly<S: DestructivelyMutableSequence>: DestructivelyMutableSequence, ImplementationForwardingMutableWrapper {
    public typealias Iterator = Value.Iterator
    public typealias Value = S

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct SequenceWrapperMap<S: Sequence, I: IteratorProtocol & Wrapper>: Sequence where I.Value == S.Iterator {
    public typealias Value = S

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public typealias Iterator = I

    public func makeIterator() -> Iterator {
        return I(value.makeIterator())
    }
}

extension Set: ResizableSetProtocol {

}

// MARK: - Helpers -

public typealias Join3Sequence<C0, C1, C2> = Join2Sequence<Join2Sequence<C0, C1>, C2> where C0: Sequence, C1: Sequence, C2: Sequence, C0.Element == C1.Element, C1.Element == C2.Element

extension Sequence {
    public var sequenceOnly: SequenceOnly<Self> {
        return .init(self)
    }
}

extension Sequence where Element: OptionalProtocol {
    public func compact() -> CompactSequence<Self> {
        return .init(self)
    }
}

extension Sequence {
    public func prefix(till isTerminator: (@escaping (Element) -> Bool)) -> PredicatedSequencePrefix<Self> {
        return PredicatedSequencePrefix(self, isTerminator: isTerminator)
    }
}

extension Sequence where Element: Equatable {
    public func prefix(till element: Element) -> PredicatedSequencePrefix<Self> {
        return PredicatedSequencePrefix(self, isTerminator: { $0 == element })
    }
}

extension Sequence {
    public func join<S: Sequence>(_ other: S) -> Join2Sequence<Self, S> {
        return .init((self, other))
    }

    public func join(_ other: Element) -> Join2Sequence<Self, CollectionOfOne<Element>> {
        return join(.init(other))
    }
}

extension Sequence {
    public func map<State, T>(state: State, transform: (@escaping (inout State, Element) -> T)) -> LazyMapSequenceWithMemoryRecall<Self, State, T> {
        return .init(base: self, initial: state, transform: transform)
    }
}
