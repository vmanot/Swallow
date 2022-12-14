//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK:

public struct OneOfTwoSequences<S0: Sequence, S1: Sequence>: EitherRepresentable where S0.Element == S1.Element {
    public typealias Iterator = OneOfTwoIterators<S0.Iterator, S1.Iterator>
    
    public var eitherValue: Either<S0, S1>

    public init(_ eitherValue: EitherValue) {
        self.eitherValue = eitherValue
    }

    public func makeIterator() -> Iterator {
        return .init(eitherValue.map({ $0.makeIterator() }, { $0.makeIterator() }))
    }
}

public struct OneOfTwoCollections<C0: Collection, C1: Collection>: EitherRepresentable where C0.Index == C1.Index, C0.Element == C1.Element {
    public var eitherValue: Either<C0, C1>

    public init(_ eitherValue: EitherValue) {
        self.eitherValue = eitherValue
    }
}

// MARK:

extension OneOfTwoCollections: Sequence {
    public typealias Iterator = OneOfTwoSequences<C0, C1>.Iterator
    
    public func makeIterator() -> Iterator {
        return OneOfTwoSequences(eitherValue).makeIterator()
    }
}

extension OneOfTwoCollections: Collection {
    public typealias Element = C0.Element
    public typealias Index = C0.Index
    
    public var startIndex: Index {
        return reduce({ $0.startIndex }, { $0.startIndex })
    }
    
    public var endIndex: Index {
        return reduce({ $0.endIndex }, { $0.endIndex })
    }
    
    public var count: Int {
        return reduce({ $0.count }, { $0.count })
    }
    
    public func index(after i: Index) -> Index {
        return reduce({ $0.index(after: i) }, { $0.index(after: i) })
    }
    
    public subscript(_ position: Index) -> Element {
        return reduce({ $0[position] }, { $0[position] })
    }
}

// MARK:

public struct OneOfTwoMutableCollections<C0: ResizableCollection, C1: ResizableCollection>: MutableEitherRepresentable where C0.Index == C1.Index, C0.Element == C1.Element {
    public var eitherValue: Either<C0, C1>

    public init(_ eitherValue: EitherValue) {
        self.eitherValue = eitherValue
    }
}

extension OneOfTwoMutableCollections: Sequence {
    public typealias Iterator = OneOfTwoSequences<C0, C1>.Iterator
    
    public func makeIterator() -> Iterator {
        return OneOfTwoSequences(eitherValue).makeIterator()
    }
}

extension OneOfTwoMutableCollections: MutableCollection {
    public typealias Element = C0.Element
    public typealias Index = C0.Index
    
    public var startIndex: Index {
        return OneOfTwoCollections(eitherValue).startIndex
    }
    
    public var endIndex: Index {
        return OneOfTwoCollections(eitherValue).endIndex
    }
    
    public var count: Int {
        return OneOfTwoCollections(eitherValue).count
    }
    
    public func index(after i: Index) -> Index {
        return OneOfTwoCollections(eitherValue).index(after: i)
    }
    
    public subscript(_ position: Index) -> Element {
        get {
            return OneOfTwoCollections(eitherValue)[position]
        } set {
            mutate({ $0[position] = newValue }, { $0[position] = newValue })
        }
    }
}

// MARK:

public struct OneOfTwoResizableCollections<C0: ResizableCollection, C1: ResizableCollection>: MutableEitherRepresentable, ResizableCollection where C0.Index == C1.Index, C0.Element == C1.Element {
    public var eitherValue: Either<C0, C1>

    public init(_ eitherValue: EitherValue) {
        self.eitherValue = eitherValue
    }
    
    public init() {
        self.init(.left(.init()))
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init(.left(.init(sequence)))
    }
}

extension OneOfTwoResizableCollections: Sequence {
    public typealias Iterator = OneOfTwoSequences<C0, C1>.Iterator
    
    public func makeIterator() -> Iterator {
        return OneOfTwoSequences(eitherValue).makeIterator()
    }
}

extension OneOfTwoResizableCollections: MutableCollection {
    public typealias Element = C0.Element
    public typealias Index = C0.Index
    
    public var startIndex: Index {
        return OneOfTwoCollections(eitherValue).startIndex
    }
    
    public var endIndex: Index {
        return OneOfTwoCollections(eitherValue).endIndex
    }
    
    public var count: Int {
        return OneOfTwoCollections(eitherValue).count
    }
    
    public func index(after i: Index) -> Index {
        return OneOfTwoCollections(eitherValue).index(after: i)
    }
    
    public subscript(_ position: Index) -> Element {
        get {
            return OneOfTwoCollections(eitherValue)[position]
        } set {
            mutate({ $0[position] = newValue }, { $0[position] = newValue })
        }
    }
}

extension OneOfTwoResizableCollections: ExtensibleSequence {
    public mutating func insert(_ element: Element) {
        mutate({ $0.insert(element) }, { $0.insert(element) })
    }

    public mutating func insert<S: Sequence>(contentsOf sequence: S) where S.Element == Element {
        mutate({ $0.insert(contentsOf: sequence) }, { $0.insert(contentsOf: sequence) })
    }

    public mutating func append(_ element: Element) {
        mutate({ $0.append(element) }, { $0.append(element) })
    }

    public mutating func append<S: Sequence>(contentsOf sequence: S) where S.Element == Element {
        mutate({ $0.append(contentsOf: sequence) }, { $0.append(contentsOf: sequence) })
    }
}

extension OneOfTwoResizableCollections: RangeReplaceableCollection {
    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Index>, with newElements: C) where C.Element == Element {
        mutate({ $0.replaceSubrange(subrange, with: newElements) }, { $0.replaceSubrange(subrange, with: newElements) })
    }
}
