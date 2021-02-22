//
// Copyright (c) Vatsal Manot
//

import Swift

extension Sequence {
    public func countElements() -> Int {
        var count = 0
        
        for _ in self {
            count += 1
        }
        
        return count
    }
}

extension Sequence {
    public func group<ID: Hashable>(
        by identify: (Element) throws -> ID
    ) rethrows -> [ID: [Element]] {
        var result: [ID: [Element]] = .init(minimumCapacity: underestimatedCount)
        
        for element in self {
            result[try identify(element), default: []].append(element)
        }
        
        return result
    }
}

extension Sequence {
    public func optionalFilter<T>(_ predicate: (T) throws -> Bool) rethrows -> [T?] where Element == T? {
        return try filter({ try $0.map(predicate) ?? true })
    }
    
    public func optionalMap<T, U>(_ transform: (T) throws -> U) rethrows -> [U?] where Element == T? {
        return try map({ try $0.map(transform) })
    }
}

extension Sequence {
    @inlinable
    public var isEmpty: Bool {
        return first == nil
    }
    
    @inlinable
    public var first: Element? {
        for element in self {
            return element
        }
        
        return nil
    }
    
    @inlinable
    public var last: Element? {
        var result: Element?
        
        for element in self {
            result = element
        }
        
        return result
    }
    
    public func element(atCount count: Int) -> Element? {
        return SequenceOnly(self).dropFirst(count).last
    }
    
    public func element(atReverseCount count: Int) -> Element? {
        return SequenceOnly(self).dropLast(count).last
    }
}

// MARK: zip

extension Sequence {
    @inlinable
    public func zip<S: Sequence>(_ other: S) -> Zip2Sequence<Self, S> {
        return Swift.zip(self, other)
    }
    
    public func separated(by separator: Element) -> AnySequence<Element> {
        guard let first = first else {
            return .init(noSequence: ())
        }
        return .init(CollectionOfOne(first).join(dropFirst().flatMap({ CollectionOfOne(separator).join(CollectionOfOne($0)) })))
    }
}

// MARK: minimum/maximum

extension Sequence where Element: Comparable {
    @inlinable
    public var minimum: Element? {
        return sorted(by: <).first
    }
    
    @inlinable
    public var maximum: Element? {
        return sorted(by: <).last
    }
}

// MARK: reduce

extension Sequence {
    @inlinable
    public func reduce(_ combine: ((Element, Element) -> Element)) -> Element? {
        var result: Element! = nil
        
        for element in self {
            guard result != nil else {
                result = element
                
                continue
            }
            
            result = combine(result, element)
        }
        
        return result
    }
    
    @inlinable
    public func reduce<T>(_ initial: T, _ combine: ((T) throws -> ((Element) -> T))) rethrows -> T {
        return try reduce(initial, { try combine($0)($1) })
    }
    
    @inlinable
    public func reduce<T: ExpressibleByNilLiteral>(_ combine: ((T) throws -> ((Element) -> T))) rethrows -> T {
        return try reduce(nil, { try combine($0)($1) })
    }
    
    @inlinable
    public func reduce<T: ExpressibleByNilLiteral>(_ combine: ((T, Element) throws -> T)) rethrows -> T {
        return try reduce(nil, combine)
    }
}

// MARK: forEach

extension Sequence {
    @_disfavoredOverload
    @inlinable
    public func forEach<T>(do iterator: @autoclosure () throws -> T) rethrows {
        for _ in self {
            _ = try iterator()
        }
    }
}

// MARK: find

extension Sequence {
    public func elements(between firstPredicate: ((Element) throws -> Bool), and lastPredicate: ((Element) throws -> Bool)) rethrows -> [Element] {
        var first: Element?
        var result: [Element] = []
        
        for element in self {
            if try firstPredicate(element) && first == nil {
                first = element
            }
            
            else if try lastPredicate(element) {
                return result
            }
            
            else if first != nil {
                result += element
            }
        }
        
        return []
    }
}


extension Sequence {
    public func element(before predicate: ((Element) throws -> Bool)) rethrows -> Element? {
        var last: Element?
        
        for element in self {
            if try predicate(element) {
                return last
            }
            
            last = element
        }
        
        return nil
    }
    
    public func element(after predicate: ((Element) throws -> Bool)) rethrows -> Element? {
        var returnNext: Bool = false
        
        for element in self {
            if returnNext {
                return element
            }
            
            if try predicate(element) {
                returnNext = true
            }
        }
        
        return nil
    }
}

extension Sequence {
    @inlinable
    public func find<T, U>(_ iterator: ((_ take: ((T) -> Void), _ element: Element) throws -> U)) rethrows -> T? {
        var result: T? = nil
        var stop: Bool = false
        
        for element in self {
            _ = try iterator({ stop = true; result = $0 }, element)
            
            if stop {
                break
            }
        }
        
        return result
    }
    
    @inlinable
    public func find<T: Boolean>(_ predicate: ((Element) throws -> T)) rethrows -> Element? {
        return try find({ take, element in try predicate(element) &&-> take(element) })
    }
}

extension Sequence {
    public var isSingleElement: Bool {
        var iterator = makeIterator()
        
        _ = iterator.next()
        
        return iterator.next() == nil
    }
}

extension Sequence where Element: Equatable {
    public func allElementsAreEqual(to other: Element) -> Bool {
        var iterator = makeIterator()
        
        while let next = iterator.next() {
            if next != other {
                return false
            }
        }
        
        return true
    }
    
    public func allElementsAreEqual() -> Bool {
        var iterator = makeIterator()
        
        guard let first = iterator.next() else {
            return true
        }
        
        while let next = iterator.next() {
            if first != next {
                return false
            }
        }
        
        return true
    }
}

extension Sequence {
    public func map<T>(_ f: (@escaping (Element) -> T), everyOther g: (@escaping  (Element) -> T)) -> LazyMapSequenceWithMemoryRecall<Self, Bool, T> {
        return LazyMapSequenceWithMemoryRecall(base: self, initial: false, transform: { $0 = !$0; return $0 ? f($1) : g($1) })
    }
    
    public func intersperse(at f: ((Element) throws -> Bool)) rethrows -> [[Element]] {
        var result: [[Element]] = [[]]
        
        for element in self {
            if try f(element) {
                result += [element]
                result += []
            }
            
            else {
                result.mutableLast! += element
            }
        }
        
        if result.first?.isEmpty ?? false {
            result.removeFirst()
        }
        
        if result.last?.isEmpty ?? false {
            result.removeLast()
        }
        
        return result
    }
}

extension Sequence where Element: Equatable {
    public func hasPrefix(_ prefix: Element) -> Bool {
        return first == prefix
    }
    
    public func hasSuffix(_ suffix: Element) -> Bool {
        return last == suffix
    }
}

extension Sequence  {
    public func between(count startIndex: Int, and endIndex: Int) -> PrefixSequence<DropFirstSequence<Self>> {
        return dropFirst(startIndex).prefix(endIndex - startIndex)
    }
    
    public subscript(between range: Range<Int>) -> PrefixSequence<DropFirstSequence<Self>> {
        return between(count: range.lowerBound, and: range.upperBound)
    }
}

extension Sequence where Element: Equatable {
    public func hasPrefix(_ prefix: [Element]) -> Bool {
        var iterator = makeIterator()
        var prefixIterator = prefix.makeIterator()
        
        while let other = prefixIterator.next() {
            if let element = iterator.next() {
                guard element == other else {
                    return false
                }
            }
            
            else {
                return false
            }
        }
        
        return true
    }
    
    public func hasSuffix(_ suffix: [Element]) -> Bool {
        var result: Bool = false
        
        for (element, other) in suffix.zip(self.suffix(suffix.toFauxCollection().count)) {
            guard element == other else {
                return false
            }
            
            result = true
        }
        
        return result
    }
}

extension Sequence where Element: Comparable {
    func lexicographicallyPrecedes<OtherSequence: Sequence>(_ other: OtherSequence, orderingShorterSequencesAfter: ()) -> Bool where OtherSequence.Element == Element {
        var elementsOfFirstSequence = self.makeIterator()
        var elementsOfSecondSequence = other.makeIterator()
        
        while let elementOfFirstSequence = elementsOfFirstSequence.next() {
            guard let elementOfSecondSequence = elementsOfSecondSequence.next() else {
                return true
            }
            
            if elementOfFirstSequence < elementOfSecondSequence {
                return true
            }
            
            else if elementOfFirstSequence > elementOfSecondSequence {
                return false
            }
        }
        
        return false
    }
}

extension Sequence where Element: Numeric {
    @inlinable
    public func sum() -> Element {
        return reduce(into: 0, { $0 += $1 })
    }
}
