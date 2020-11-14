//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol SequenceInitiableSequence: Sequence {
    init(noSequence: ())
    
    init(repeating _: Element, count: Int)
    init(repeating _: (@escaping () -> Element), count: Int)
    
    init(element: Element)
    
    init<I: IteratorProtocol>(iterator: I) where I.Element == Element
    init<I: IteratorProtocol>(iterator: I, count: Int) where I.Element == Element
    init<I: IteratorProtocol>(iterator: inout I) where I.Element == Element
    init<I: IteratorProtocol>(iterator: inout I, count: Int) where I.Element == Element
    
    init<S: Sequence>(_: S, count: Int) where S.Element == Element
    init<S: Sequence>(_: S) where S.Element == Element
    
    init<C: Collection>(_: C, count: Int) where C.Element == Element
    init<C: Collection>(_: C) where C.Element == Element
}

// MARK: - Implementation -

extension SequenceInitiableSequence {
    public init(noSequence: ()) {
        self.init(EmptyCollection())
    }
    
    public init(repeating repeatedValue: Element, count: Int) {
        self.init(repeatElement(repeatedValue, count: count))
    }
    
    public init(repeating repeatedValue: (@escaping () -> Element), count: Int) {
        self.init(FixedCountSequence(AnyIterator(repeatedValue), limit: count))
    }
    
    public init(element: Element) {
        self.init(repeating: element, count: 1)
    }
    
    public init<I: IteratorProtocol>(iterator: I) where I.Element == Element {
        self.init(IteratorSequence(iterator))
    }
    
    public init<I: IteratorProtocol>(iterator: I, count: Int) where I.Element == Element {
        self.init(iterator: FixedCountIterator(iterator, limit: count))
    }
    
    public init<I: IteratorProtocol>(iterator: inout I) where I.Element == Element {
        var _iterator = iterator
        
        self.init(iterator: AnyIterator({ _iterator.next() }))
        
        iterator = _iterator
    }
    
    public init<I: IteratorProtocol>(iterator: inout I, count: Int) where I.Element == Element {
        var _iterator = FixedCountIterator(iterator, limit: count)
        
        self.init(iterator: &_iterator)
        
        iterator = _iterator.value
    }
    
    public init<S: Sequence>(_ source: S, count: Int) where S.Element == Element {
        self.init(FixedCountSequence(source, limit: count))
    }
}

extension SequenceInitiableSequence where Self: RangeReplaceableCollection {
    public init(repeating repeatedValue: Element, count: Int) {
        self.init(repeatElement(repeatedValue, count: count))
    }
    
    public init(repeating repeatedValue: (@escaping () -> Element), count: Int) {
        self.init(FixedCountSequence(AnyIterator(repeatedValue), limit: count))
    }
}

// MARK: - Extensions -

extension SequenceInitiableSequence {
    public func prependAll<S: SequenceInitiableSequence>(_ newElement: Element) -> S where S.Element == Element {
        return .init(flatMap({ CollectionOfOne(newElement).join(CollectionOfOne($0)) }))
    }
    
    public func intersperse<S: SequenceInitiableSequence>(_ type: S.Type = S.self, _ newElement: Element) -> S where S.Element == Element {
        guard !isEmpty else {
            return .init(noSequence: ())
        }
        
        return .init(lazy.flatMap({ CollectionOfOne(newElement).join(CollectionOfOne($0)) }).join(newElement))
    }
    
    public func intersperse(_ newElement: Element) -> [Element] {
        return intersperse([Element].self, newElement)
    }
}

// MARK: - Protocol Conformances -

extension SequenceInitiableSequence where Self: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Self.Element...) {
        self.init(elements, count: elements.count)
    }
}

// MARK: - Helpers -

extension Sequence {
    public func _filter<S: SequenceInitiableSequence>(_ includeElement: ((Element) throws -> Bool)) rethrows -> S where S.Element == Element {
        return .init(try lazy.filter(includeElement))
    }
    
    public func _map<S: SequenceInitiableSequence>(_ transform: ((Element) throws -> S.Element)) rethrows -> S {
        return .init(try lazy.map(transform))
    }
    
    public func _flatMap<S0: Sequence, S1: SequenceInitiableSequence>(_ transform: ((Element) throws -> S0)) rethrows -> S1 where S1.Element == S0.Element {
        return S1(try lazy.map(transform).joined())
    }
}

// MARK: - Implementation Forwarding -

extension ImplementationForwarder where Self: SequenceInitiableSequence, ImplementationProvider: SequenceInitiableSequence, Self.Element == ImplementationProvider.Element {
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init(implementationProvider: .init(sequence))
    }
}

extension ImplementationForwarder where Self: ResizableSequence, ImplementationProvider: ResizableSequence, Self.Element == ImplementationProvider.Element {
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init(implementationProvider: .init(sequence))
    }
}

extension ImplementationForwarder where Self: ResizableCollection, ImplementationProvider: ResizableCollection, Self.Element == ImplementationProvider.Element {
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init(implementationProvider: .init(sequence))
    }
}

extension ImplementationForwarder where Self: ExpressibleByArrayLiteral & SequenceInitiableSequence, ImplementationProvider: ExpressibleByArrayLiteral, Self.ArrayLiteralElement == ImplementationProvider.ArrayLiteralElement, Self.ArrayLiteralElement == Self.Element {
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(implementationProvider: (-*>ImplementationProvider.init as ((Array) -> ImplementationProvider))(elements))
    }
}
