//
// Copyright (c) Vatsal Manot
//

import Swift

public struct CompactSequenceIterator<G: IteratorProtocol>: IteratorProtocol, Wrapper where G.Element: OptionalProtocol {
    public typealias Value = G

    public private(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public mutating func next() -> G.Element.Wrapped? {
        if let nextElement = value.next() {
            return nextElement._wrapped ?? next()
        } else {
            return nil
        }
    }
}

public struct ConsecutiveIterator<Value: IteratorProtocol>: IteratorProtocol, Wrapper {
    public typealias Element = (Value.Element, Value.Element)

    public var value: Value
    private var previousElement: Value.Element? = nil

    public init(_ value: Value) {
        self.value = value
    }

    public mutating func next() -> Element? {
        if let previous = previousElement {
            if let next = value.next() {
                let result = (previous, next)
                previousElement = next
                return result
            }
        } else if let next = value.next() {
            self.previousElement = next
            return self.next()
        }
        
        return nil
    }
}

public struct CyclicIterator<Element>: CustomDebugStringConvertible, IteratorProtocol, Wrapper {
    public private(set) var value: AnyIterator<Element>
    public private(set) var cache: [Element] = []
    public private(set) var isCacheComplete: Bool = false
    
    public init<G: IteratorProtocol>(_ value: G) where G.Element == Element {
        self.value = .init(value)
    }
    
    private mutating func reset() {
        if isCacheComplete {
            value = .init(cache.makeIterator())
        } else {
            fatalError("CyclicIterator cache incomplete")
        }
    }
    
    public mutating func next() -> Element? {
        if let next = value.next() {
            if !isCacheComplete {
                cache.append(next)
            }
            
            return next
        } else {
            isCacheComplete = true
            
            reset()
            
            return value.next()
        }
    }
}

public struct FixedCountIterator<Value: IteratorProtocol>: IteratorProtocol, Wrapper {
    public private(set) var value: Value
    public private(set) var count: Int = 0

    public let limit: Int?

    public var hasReachedLimit: Bool {
        return count == limit
    }

    public init(_ value: Value, limit: Int?) {
        self.value = value
        self.limit = limit
    }

    public init(_ value: Value) {
        self.init(value, limit: nil)
    }

    public mutating func next() -> Value.Element? {
        let _count = self.count

        if limit.map({ _count < $0 }) ?? true {
            defer {
                count += 1
            }
            
            return value.next()
        } else {
            return nil
        }
    }
}

public struct Join2Iterator<G0: IteratorProtocol, G1: IteratorProtocol>: IteratorProtocol, Wrapper where G0.Element == G1.Element {
    public typealias Value = (G0, G1)
    
    public private(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public mutating func next() -> G0.Element? {
        return value.0.next() ?? value.1.next()
    }
}

public struct LazyMapIteratorWithMemoryRecall<S: Sequence, Memory, Element>: IteratorProtocol {
    private var base: S.Iterator
    private var initial: Memory
    private var transform: ((inout Memory, S.Element) -> Element)
    
    public init(base: S.Iterator, initial: Memory, transform: (@escaping (inout Memory, S.Element) -> Element)) {
        self.base = base
        self.initial = initial
        self.transform = transform
    }
    
    public mutating func next() -> Element? {
        guard let next = base.next() else {
            return nil
        }
        
        return transform(&initial, next)
    }
}

public struct NaiveCountIterator<Value: IteratorProtocol>: IteratorProtocol, Wrapper {
    public private(set) var value: Value
    public private(set) var count: Int = 0

    public init(_ value: Value) {
        self.value = value
    }

    public mutating func next() -> Value.Element? {
        defer {
            count += 1
        }
        
        return value.next()
    }
}

public enum OneOfTwoIterators<I0: IteratorProtocol, I1: IteratorProtocol>: IteratorProtocol, MutableEitherRepresentable where I0.Element == I1.Element {
    public typealias Element = I0.Element
    
    case left(I0)
    case right(I1)
    
    public var eitherValue: Either<I0, I1> {
        get {
            return unsafeBitCast(self)
        } set {
            self = unsafeBitCast(newValue)
        }
    }
    
    public init(_ eitherValue: Either<I0, I1>) {
        self = unsafeBitCast(eitherValue)
    }
    
    public mutating func next() -> Element? {
        return mutate({ $0.next() }, { $0.next() }).leftOrRight
    }
}

// MARK: - Supplementary

extension IteratorProtocol {
    @inlinable
    public func join<G: IteratorProtocol>(_ other: G) -> Join2Iterator<Self, G>  {
        return .init((self, other))
    }
}

extension Sequence {
    @inlinable
    public func consecutives() -> SequenceWrapperMap<Self, ConsecutiveIterator<Iterator>> {
        return .init(self)
    }
}
