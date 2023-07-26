//
// Copyright (c) Vatsal Manot
//

import Swift

extension Sequence {
    public func eraseToAnySequence() -> AnySequence<Element> {
        .init(self)
    }
}

extension Sequence {
    @_disfavoredOverload
    public func first<T>(
        byUnwrapping transform: (Element) throws -> T?
    ) rethrows -> T? {
        for element in self {
            if let match = try transform(element) {
                return match
            }
        }
        
        return nil
    }
    
    @_disfavoredOverload
    public func firstAndOnly<T>(
        byUnwrapping transform: (Element) throws -> T?
    ) throws -> T? {
        var result: T?
        
        for element in self {
            if let match = try transform(element) {
                guard result == nil else {
                    throw _PlaceholderError()
                }
                
                result = match
            }
        }
        
        return result
    }

    public func first<T>(ofType type: T.Type) -> T? {
        first(byUnwrapping: { $0 as? T })
    }
    
    public func firstAndOnly<T>(ofType type: T.Type) throws -> T? {
        try firstAndOnly(byUnwrapping: { $0 as? T })
    }
    
    public func firstAndOnly(
        where predicate: (Element) throws -> Bool
    ) throws -> Element? {
        try firstAndOnly(byUnwrapping: { try predicate($0) ? $0 : nil })
    }
}

// MARK: Grouping

extension Sequence {
    public func subsequences<T: Equatable>(
        groupedBy grouping: (Element) throws -> T
    ) rethrows -> [Array<Element>] {
        var groups: [Array<Element>] = []
        var currentGroup: [Element] = []
        var lastKey: T?
        
        for element in self {
            let key = try grouping(element)
            
            if key != lastKey {
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [element]
                lastKey = key
            } else {
                currentGroup.append(element)
            }
        }
        
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
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
    
    public func groupFirstOnly<ID: Hashable>(
        by identify: (Element) throws -> ID
    ) rethrows -> [ID: Element] {
        var result: [ID: Element] = .init(minimumCapacity: underestimatedCount)
        
        for element in self {
            let id = try identify(element)
            
            if result[id] == nil {
                result[id] = element
            }
        }
        
        return result
    }

    public func _flatMapToTuples<T: Sequence>(
        by values: (Element) throws -> T
    ) rethrows -> [(Element, T.Element)] {
        var result = Array<(Element, T.Element)>()
        
        for element in self {
            try result.append(contentsOf: values(element).map({ (element, $0) }))
        }
        
        return result
    }
    
    public func mapToDictionaryWithUniqueKeys<Key: Hashable>(
        _ uniqueKeys: (Element) throws -> some Sequence<Key>
    ) rethrows -> [Key: Element] {
        var result = [Key: Element](minimumCapacity: underestimatedCount)
        
        for element in self {
            let keys = try uniqueKeys(element)
            
            for key in keys {
                guard result[key] == nil else {
                    assertionFailure()
                    
                    continue
                }
                
                result[key] = element
            }
        }
        
        return result
    }
    
    public func multiplicativelyKeyed<Key: Hashable>(
        by keys: (Element) throws -> some Sequence<Key>
    ) rethrows -> [Key: [Element]] {
        var result = [Key: [Element]](minimumCapacity: underestimatedCount)
        
        for element in self {
            let keys = try keys(element)
            
            for key in keys {
                result[key, default: []].append(element)
            }
        }
        
        return result
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
}

// MARK: Concurrent Iteration

extension Sequence {
    /// Returns an array containing the results of mapping the given async closure over
    /// the sequence’s elements.
    ///
    /// The closure calls are made serially. The next call is only made once the previous call
    /// has finished. Returns once the closure has run on all the elements of the Sequence
    /// or when the closure throws an error.
    /// - Parameter transform: An async  mapping closure. transform accepts an
    ///     element of this sequence as its parameter and returns a transformed value of
    ///     the same or of a different type.
    /// - Returns: An array containing the transformed elements of this sequence.
    public func asyncMap<T: Sendable>(
        _ transform: @Sendable (Element) async throws -> T
    ) async rethrows -> [T] {
        let initialCapacity = underestimatedCount
        var result = ContiguousArray<T>()
        
        result.reserveCapacity(initialCapacity)
        
        for element in self {
            try await result.append(transform(element))
        }
        
        return Array(result)
    }
    
    public func asyncFlatMap<T: Sequence>(
        _ transform: @Sendable (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        let initialCapacity = underestimatedCount
        var result = Array<T.Element>()
        
        result.reserveCapacity(initialCapacity)
        
        for element in self {
            try await result.append(contentsOf: transform(element))
        }
        
        return result
    }
    
    /// Returns an array containing the results of mapping the given async closure over
    /// the sequence’s elements.
    ///
    /// This differs from `asyncMap` in that it uses a `TaskGroup` to run the transform
    /// closure for all the elements of the Sequence. This allows all the transform closures
    /// to run concurrently instead of serially. Returns only when the closure has been run
    /// on all the elements of the Sequence.
    /// - Parameters:
    ///   - priority: Task priority for tasks in TaskGroup
    ///   - transform: An async mapping closure. transform accepts an
    ///     element of this sequence as its parameter and returns a transformed value of
    ///     the same or of a different type.
    /// - Returns: An array containing the transformed elements of this sequence.
    public func concurrentMap<T: Sendable>(
        priority: TaskPriority? = nil,
        @_implicitSelfCapture _ transform: @Sendable @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            enumerated().forEach { element in
                group.addTask(priority: priority) {
                    let result = try await transform(element.1)
                    
                    return (element.0, result)
                }
            }
            
            let initialCapacity = underestimatedCount
            
            var result = ContiguousArray<(Int, T)>()
            
            result.reserveCapacity(initialCapacity)
            
            for _ in 0..<initialCapacity {
                try await result.append(group.next()!)
            }
            
            while let element = try await group.next() {
                result.append(element)
            }
            
            try await group.waitForAll()
            
            return result.sorted(by: { $0.0 < $1.0 }).map({ $0.1 })
        }
    }
    
    public func concurrentFlatMap<T: Sequence>(
        priority: TaskPriority? = nil,
        @_implicitSelfCapture _ transform: @Sendable @escaping (Element) async throws -> T
    ) async rethrows -> [T.Element] where T.Element: Sendable {
        try await concurrentMap(transform).flatMap({ $0 })
    }

    public func asyncForEach(
        _ body: @Sendable (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await body(element)
        }
    }
    
    public func concurrentForEach(
        @_implicitSelfCapture _ operation: @escaping @Sendable (Element) async -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
            
            await group.waitForAll()
        }
    }
    
    public func concurrentForEach(
        @_implicitSelfCapture _ operation: @escaping @Sendable (Element) async throws -> Void
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    try await operation(element)
                }
            }
            
            try await group.waitForAll()
        }
    }
}

// MARK: zip

extension Sequence {
    @inlinable
    public func zip<S: Sequence>(_ other: S) -> Zip2Sequence<Self, S> {
        return Swift.zip(self, other)
    }
}

// MARK: Minimum/Maximum

public enum _SequenceMinimumOrMaximum {
    case minimum
    case maximum
}

extension Sequence where Element: Comparable {
    @inlinable
    public var minimum: Element? {
        self.min(by: <)
    }
    
    @inlinable
    public var maximum: Element? {
        self.max(by: <)
    }
}

extension Sequence {
    public func minOrMax(
        _ minOrMax: _SequenceMinimumOrMaximum
    ) -> Element? where Element: Comparable {
        switch minOrMax {
            case .minimum:
                return minimum
            case .maximum:
                return maximum
        }
    }
    
    public func minOrMax<Value: Comparable>(
        _ minOrMax: _SequenceMinimumOrMaximum,
        by value: (Element) -> Value
    ) -> Element? {
        switch minOrMax {
            case .minimum:
                return self.min(by: { value($0) < value($1) })
            case .maximum:
                return self.max(by: { value($0) < value($1) })
        }
    }
    
    public func minOrMax<Value: Comparable>(
        _ minOrMax: _SequenceMinimumOrMaximum,
        by keyPath: KeyPath<Element, Value>
    ) -> Element? {
        switch minOrMax {
            case .minimum:
                return self.min(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
            case .maximum:
                return self.max(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
        }
    }
    
    public func min<Value: Comparable>(
        by value: (Element) -> Value
    ) -> Element? {
        minOrMax(.minimum, by: value)
    }
    
    public func max<Value: Comparable>(
        by value: (Element) -> Value
    ) -> Element? {
        minOrMax(.maximum, by: value)
    }
}

// MARK: Reducing

extension Sequence {
    @inlinable
    public func reduce(
        _ combine: ((Element, Element) throws -> Element)
    ) rethrows -> Element? {
        var result: Element? = nil
        
        for element in self {
            guard let lastResult = result else {
                result = element
                
                continue
            }
            
            result = try combine(lastResult, element)
        }
        
        return result
    }
    
    @inlinable
    public func reduce<T>(
        _ initial: T,
        _ combine: ((T) throws -> ((Element) -> T))
    ) rethrows -> T {
        return try reduce(initial, { try combine($0)($1) })
    }
    
    @_disfavoredOverload
    @inlinable
    public func reduce<T: ExpressibleByNilLiteral>(
        _ combine: ((T) throws -> ((Element) -> T))
    ) rethrows -> T {
        return try reduce(nil, { try combine($0)($1) })
    }
    
    @_disfavoredOverload
    @inlinable
    public func reduce<T: ExpressibleByNilLiteral>(
        _ combine: ((T, Element) throws -> T)
    ) rethrows -> T {
        return try reduce(nil, combine)
    }
    
    @inlinable
    public func reduce<T>(
        _ initial: (Element) -> T,
        combine: ((T, Element) throws -> T)
    ) rethrows -> T? {
        guard let first = self.first else {
            return nil
        }
        
        return try dropFirst().reduce(initial(first), combine)
    }

    public func concatenateAndReduce<T>(
        _ initialValue: (Element, Element) throws -> T,
        _ combine: (T, Element) throws -> T
    ) rethrows -> T? {
        var iterator = makeIterator()
        
        guard let first = iterator.next(), let second = iterator.next() else {
            return nil
        }
        
        var result = try initialValue(first, second)
        
        while let next = iterator.next() {
            result = try combine(result, next)
        }
        
        return result
    }
}

// MARK: Slicing

extension Sequence {
    public func interspersed(
        with separator: Element
    ) -> AnyRandomAccessCollection<Element> {
        guard let first = first else {
            return AnyRandomAccessCollection(EmptyCollection())
        }
        
        return AnyRandomAccessCollection(
            CollectionOfOne(first).join(
                self.dropFirst().flatMap {
                    CollectionOfOne(separator).join(CollectionOfOne($0))
                }
            )
        )
    }
    
    public func interspersed(
        with separator: Element,
        where shouldSeparate: (Element) -> Bool
    ) -> AnyRandomAccessCollection<Element> {
        guard let first = first else {
            return AnyRandomAccessCollection(EmptyCollection())
        }
        
        return AnyRandomAccessCollection(
            CollectionOfOne(first).join(
                self.dropFirst().flatMap { element in
                    if shouldSeparate(element) {
                        return CollectionOfOne(separator).join(CollectionOfOne(element)).eraseToAnyRandomAccessCollection()
                    } else {
                        return CollectionOfOne(element).eraseToAnyRandomAccessCollection()
                    }
                }
            )
        )
    }

    public func between(
        count startIndex: Int,
        and endIndex: Int
    ) -> PrefixSequence<DropFirstSequence<Self>> {
        dropFirst(startIndex).prefix(endIndex - startIndex)
    }
    
    public subscript(
        between range: Range<Int>
    ) -> PrefixSequence<DropFirstSequence<Self>> {
        between(count: range.lowerBound, and: range.upperBound)
    }
    
    public func elements(
        between firstPredicate: ((Element) throws -> Bool),
        and lastPredicate: ((Element) throws -> Bool)
    ) rethrows -> [Element] {
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
    
    public func splitBefore(
        separator isSeparator: (Iterator.Element) throws -> Bool
    ) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []
        
        var iterator = self.makeIterator()
        
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            }
            else {
                subSequence.append(element)
            }
        }
        
        result.append(AnySequence(subSequence))
        
        return result
    }
}

// MARK: Finding

extension Sequence {
    public func element(
        before predicate: ((Element) throws -> Bool)
    ) rethrows -> Element? {
        var last: Element?
        
        for element in self {
            if try predicate(element) {
                return last
            }
            
            last = element
        }
        
        return nil
    }
    
    public func element(
        after predicate: ((Element) throws -> Bool)
    ) rethrows -> Element? {
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
    
    @inlinable
    public func find<T>(
        _ iterator: ((_ take: ((T) -> Void), _ element: Element) throws -> Void)
    ) rethrows -> T? {
        var result: T? = nil
        var stop: Bool = false
        
        for element in self {
            try iterator({ stop = true; result = $0 }, element)
            
            if stop {
                break
            }
        }
        
        return result
    }
    
    @inlinable
    public func find<T: Boolean>(
        _ predicate: ((Element) throws -> T)
    ) rethrows -> Element? {
        try find({ take, element in try predicate(element) &&-> take(element) })
    }
}

extension Sequence {
    public func map<T>(
        _ f: (@escaping (Element) -> T),
        everyOther g: (@escaping (Element) -> T)
    ) -> LazyMapSequenceWithMemoryRecall<Self, Bool, T> {
        return LazyMapSequenceWithMemoryRecall(
            base: self,
            initial: false,
            transform: { $0 = !$0; return $0 ? f($1) : g($1) }
        )
    }
}

// MARK: hasPrefix & hasSuffix

extension Sequence where Element: Equatable {
    public func hasPrefix(_ prefix: Element) -> Bool {
        first == prefix
    }
        
    public func hasPrefix(_ prefix: some Sequence<Element>) -> Bool {
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
}

// MARK: lexicographicallyPrecedes

extension Sequence where Element: Comparable {
    public func lexicographicallyPrecedes<OtherSequence: Sequence>(
        _ other: OtherSequence,
        orderingShorterSequencesAfter: ()
    ) -> Bool where OtherSequence.Element == Element {
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

// MARK: Sorted

@frozen public enum _SequenceSortOrder: Hashable, Codable, Sendable {
    case forward
    case reverse
}

extension Sequence {
    public func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        order: _SequenceSortOrder
    ) -> [Element] {
        switch order {
            case .forward:
                return sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
            case .reverse:
                return sorted(by: { $0[keyPath: keyPath] > $1[keyPath: keyPath] })
        }
    }
    
    public func sorted(
        order: _SequenceSortOrder
    ) -> [Element] where Element: Comparable {
        sorted(by: \.self, order: order)
    }
    
    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted(by: keyPath, order: .forward)
    }
    
    public func sorted<T: Comparable>(
        by transform: (Element) throws -> T
    ) rethrows -> [Element] {
        try sorted(by: { try transform($0) < transform($1) })
    }
}

// MARK: Sum

extension Sequence where Element: Numeric {
    @inlinable
    public func sum() -> Element {
        return reduce(into: 0, { $0 += $1 })
    }
}

// MARK: Uniquing

extension Sequence {
    public func allElementsAreEqual(to other: Element) -> Bool where Element: Equatable {
        var iterator = makeIterator()
        
        while let next = iterator.next() {
            if next != other {
                return false
            }
        }
        
        return true
    }
    
    public func allElementsAreEqual() -> Bool where Element: Equatable {
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
    
    public func duplicates<T: Hashable>(
        groupedBy keyPath: KeyPath<Element, T>
    ) -> [T: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] }).filter({ $1.count > 1 })
    }
    
    public func distinct<T: Hashable>(
        by hashable: @escaping (Element) -> T
    ) -> AnySequence<Element> {
        return AnySequence<Element> { () -> AnyIterator<Element> in
            var iterator = makeIterator()
            var seen: [T: Bool] = [:]
            
            return AnyIterator<Element> { () -> Element? in
                guard var next = iterator.next() else {
                    return nil
                }
                
                while seen.updateValue(true, forKey: hashable(next)) == true {
                    guard let _next = iterator.next() else {
                        return nil
                    }
                    
                    next = _next
                }
                
                return next
            }
        }
    }

    public func distinct<T: Hashable>(
        by keyPath: KeyPath<Element, T>
    ) -> AnySequence<Element> {
        distinct(by: { $0[keyPath: keyPath] })
    }
        
    public func distinct() -> AnySequence<Element> where Element: Hashable {
        distinct(by: \.hashValue)
    }
    
    @_disfavoredOverload
    public func distinct() -> [Element] where Element: Hashable {
        Array(self.distinct(by: \.hashValue))
    }
}
