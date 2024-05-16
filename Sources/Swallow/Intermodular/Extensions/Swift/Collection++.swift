//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Swift

// MARK: - nilIfEmpty

extension Collection {
    public func nilIfEmpty() -> Self? {
        guard !isEmpty else {
            return nil
        }
        
        return self
    }
}

extension Optional {
    public func nilIfEmpty() -> Optional<Wrapped> where Wrapped: Collection {
        self?.nilIfEmpty()
    }
}

// MARK: - Consecutive Elements

extension Collection {
    public func consecutives() -> AnySequence<(Element, Element)> {
        guard !isEmpty else {
            return .init([])
        }
        
        func makeIterator() -> AnyIterator<(Element, Element)> {
            var index: Index = startIndex
            
            return AnyIterator {
                let nextIndex = self.index(after: index)
                
                guard nextIndex < self.endIndex else {
                    return nil
                }
                
                defer {
                    index = nextIndex
                }
                
                return (self[index], self[nextIndex])
            }
        }
        
        return .init(makeIterator)
    }
    
    public func consecutivesAllowingHalfEmptyPairs() -> LazyMapSequence<_EnumeratedSequence, (Self.Element, Self.Element?)> {
        _enumerated().lazy.map({ (index: $0.1, element: self[try: self.index(after: $0.0)]) })
    }
}

// MARK: - Indexing

extension Collection {
    public subscript(atDistance distance: Int) -> Element {
        get {
            self[index(atDistance: distance)]
        }
    }
    
    public subscript(after index: Index) -> Element {
        return self[self.index(after: index)]
    }
    
    @inlinable
    public subscript(try index: Index) -> Element? {
        get {
            guard containsIndex(index) else {
                return nil
            }
            
            return self[index]
        }
    }
    
    @inlinable
    public subscript(try index: Index) -> Element? where Index == Int {
        get {
            guard containsIndex(index) else {
                return nil
            }
            
            return self[index]
        }
    }
    
    @inlinable
    public subscript(try bounds: Range<Index>) -> SubSequence? {
        get {
            guard contains(bounds) else {
                return nil
            }
            
            return self[bounds]
        }
    }
    
    @inlinable
    public func cycle(index: Index) -> Index {
        if distance(from: lastIndex!, to: index) > 0 {
            return self.index(atDistance: distance(from: lastIndex!, to: self.index(index, offsetBy: -1)) % count)
        } else {
            return index
        }
    }
    
    @inlinable
    public subscript(cycling index: Index) -> Element {
        get {
            return self[cycle(index: index)]
        }
    }
}

// MARK: - Prefixing

extension Collection {
    @_disfavoredOverload
    public func prefix(_ maxLength: Int?) -> SubSequence {
        if let maxLength {
            return self.prefix(maxLength)
        } else {
            return self[startIndex..<endIndex]
        }
    }
    
    @_disfavoredOverload
    public func prefix(
        till isTerminator: (Element) throws -> Bool
    ) rethrows -> SubSequence {
        guard let index = try firstIndex(where: isTerminator) else {
            return self[...]
        }
        
        if index == startIndex {
            return prefix(0)
        }
        
        return self[..<index]
    }
    
    @_disfavoredOverload
    public func prefix(
        till element: Element
    ) -> SubSequence where Element: Equatable {
        prefix(till: { $0 == element })
    }
}

// MARK: - Reduction

extension Collection {
    @_disfavoredOverload
    public func reduce(_ combine: ((Element, Element) -> Element)) -> Element? {
        guard let first = first else {
            return nil
        }
        
        return dropFirst().reduce(first, combine)
    }
}

// MARK: - Splitting

extension Collection {
    /// https://stackoverflow.com/a/71087582/2747515
    @inlinable
    public func splitIncludingSeparators(
        maxSplits: Int = .max,
        omittingEmptySubsequences: Bool = true,
        whereSeparator isSeparator: (Element) throws -> Bool
    ) rethrows -> [SubSequence] {
        precondition(maxSplits >= 0, "maxSplits can not be negative")
        
        if isEmpty {
            return []
        }
        
        var subsequences: [SubSequence] = []
        var lowerBound = startIndex
        
        func appendAndAdvance(with upperBound: Index) {
            let range = lowerBound..<upperBound
            if !omittingEmptySubsequences || !range.isEmpty {
                subsequences.append(self[range])
                lowerBound = upperBound
            }
        }
        
        while
            var upperBound = try self[lowerBound...].firstIndex(where: isSeparator),
            subsequences.count < maxSplits
        {
            appendAndAdvance(with: upperBound)
            
            if subsequences.count == maxSplits {
                break
            }
            
            formIndex(after: &upperBound)
            
            appendAndAdvance(with: upperBound)
        }
        
        appendAndAdvance(with: endIndex)
        
        return subsequences
    }
    
    @inlinable
    public func splitIncludingSeparators<Separator>(
        maxSplits: Int = .max,
        omittingEmptySubsequences: Bool = true,
        separator: (Element) throws -> Separator?
    ) rethrows -> [Either<SubSequence, Separator>] {
        precondition(maxSplits >= 0, "maxSplits can not be negative")
        
        var result: [Either<SubSequence, Separator>] = []
        var subsequenceStart = startIndex
        var splitCount = 0
        
        for index in indices {
            if let separator = try separator(self[index]) {
                if !(omittingEmptySubsequences && subsequenceStart == index) {
                    result.append(.left(self[subsequenceStart..<index]))
                }
                
                result.append(.right(separator))
                
                subsequenceStart = self.index(after: index)
                splitCount += 1
                
                if splitCount == maxSplits {
                    break
                }
            }
        }
        
        if !(omittingEmptySubsequences && subsequenceStart == endIndex) {
            result.append(.left(self[subsequenceStart..<endIndex]))
        }
        
        assert({ () -> Bool in
            let expectedCount: Int = result
                .map({
                    $0.reduce(
                        left: \SubSequence.count,
                        right: { _ -> Int in 1 }
                    )
                })
                .reduce(0, +)
            
            return expectedCount == self.count
        }())
        
        return result
    }
    
    @inlinable
    public func splitIncludingSeparators<Separator>(
        maxSplits: Int = .max,
        omittingEmptySubsequences: Bool = true,
        separator: CasePath<Element, Separator>
    ) -> [Either<SubSequence, Separator>] {
        splitIncludingSeparators(
            maxSplits: maxSplits,
            omittingEmptySubsequences: omittingEmptySubsequences,
            separator: {
                separator.extract(from: $0)
            }
        )
    }
    
    public func splittingFirst() -> (head: Element, tail: SubSequence)? {
        guard let head = first else {
            return nil
        }
        
        return (head: head, tail: suffix(from: index(after: startIndex)))
    }
    
    public func unfoldingForward() -> UnfoldSequence<(Element, SubSequence), SubSequence> {
        return sequence(state: suffix(from: startIndex)) {
            (subsequence: inout SubSequence) in
            
            guard let (head, tail) = subsequence.splittingFirst() else {
                return nil
            }
            
            subsequence = tail
            
            return (head, tail)
        }
    }
}

// MARK: - Subsequencing -

extension Collection {
    public func chunked(
        by chunkSize: Int
    ) -> [Self.SubSequence] {
        return stride(from: 0, to: count, by: chunkSize).map {
            self[index(atDistance: $0)..<index(atDistance: Swift.min($0 + chunkSize, self.count))]
        }
    }
    
    public func allSubrangesChunked<C: Collection>(
        by ranges: C
    ) -> [Range<Index>] where C.Element == Range<Index> {
        guard !ranges.isEmpty else {
            return [startIndex..<endIndex]
        }
        
        var result: [Range<Index>] = []
        var lastRange: Range<Index>? = nil
        
        for (index, range) in ranges._enumerated() {
            if index == ranges.startIndex {
                if range.lowerBound == startIndex {
                    result.append(range)
                } else if range.lowerBound > startIndex {
                    result.append(self.startIndex..<range.lowerBound)
                    result.append(range)
                }
            } else if let _lastRange = lastRange {
                if _lastRange.upperBound == range.lowerBound {
                    result.append(range)
                } else {
                    result.append(_lastRange.upperBound..<range.lowerBound)
                    result.append(range)
                }
            }
            
            lastRange = range
            
            if index == ranges.lastIndex  {
                if range.upperBound < endIndex {
                    result.append(range.upperBound..<endIndex)
                }
            }
        }
        
        return result
    }
    
    public func chunked<C: Collection>(
        by ranges: C
    ) -> [SubSequence] where C.Element == Range<Index> {
        allSubrangesChunked(by: ranges).map({ self[$0] })
    }
}

// MARK: - Concatenation

extension Collection {
    public func _lazyConcatenate<C: Collection>(
        with other: C
    ) -> LazySequence<FlattenSequence<LazyMapSequence<LazySequence<[AnyCollection<Element>]>.Elements, AnyCollection<Self.Element>>>> where C.Element == Element {
        return [AnyCollection(self), AnyCollection(other)].lazy.flatMap({ $0 })
    }
}

// MARK: - Intersection

extension Collection {
    /// The intersection of all the elements in this collection.
    public func _intersection<T>() -> Set<T> where Element == Set<T> {
        Set._intersection(self)
    }
}
