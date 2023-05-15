//
// Copyright (c) Vatsal Manot
//

import Swift

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

extension Collection {
    public var bounds: Range<Index> {
        startIndex..<endIndex
    }
}

extension Collection where Index: Strideable {
    public var stride: Index.Stride {
        return startIndex.distance(to: endIndex)
    }
}

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
    
    public func consecutivesAllowingHalfEmptyPairs() -> LazyMapSequence<LazyMapSequence<Self.Indices, (offset: Self.Index, element: Self.Element)>, (Self.Element, Self.Element?)> {
        return enumerated().map({ ($0.1, self[try: self.index(after: $0.0)]) })
    }
}

extension Collection {
    public func containsIndex(_ index: Index) -> Bool {
        index >= startIndex && index < endIndex
    }
    
    public func contains(after index: Index) -> Bool {
        containsIndex(index) && containsIndex(self.index(after: index))
    }
    
    public func contains(_ bounds: Range<Index>) -> Bool {
        containsIndex(bounds.lowerBound) && containsIndex(index(bounds.upperBound, offsetBy: -1))
    }
}

extension Collection {
    public func index(atDistance distance: Int) -> Index {
        index(startIndex, offsetBy: distance)
    }
    
    public func index(_ index: Index, insetBy distance: Int) -> Index {
        self.index(index, offsetBy: -distance)
    }
    
    public func index(_ index: Index, offsetByDistanceFromStartIndexFor otherIndex: Index) -> Index {
        self.index(index, offsetBy: distanceFromStartIndex(to: otherIndex))
    }
    
    public func distanceFromStartIndex(to index: Index) -> Int {
        distance(from: startIndex, to: index)
    }
    
    public func range(from range: Range<Int>) -> Range<Index> {
        index(atDistance: range.lowerBound)..<index(atDistance: range.upperBound)
    }
    
    public subscript(atDistance distance: Int) -> Element {
        get {
            self[index(atDistance: distance)]
        }
    }
    
    public subscript(betweenDistances distance: Range<Int>) -> SubSequence {
        get {
            self[index(atDistance: distance.lowerBound)..<index(atDistance: distance.upperBound)]
        }
    }
    
    public subscript(betweenDistances distance: ClosedRange<Int>) -> SubSequence {
        get {
            return self[index(atDistance: distance.lowerBound)...index(atDistance: distance.upperBound)]
        }
    }
}

extension Collection {
    public subscript(after index: Index) -> Element {
        return self[self.index(after: index)]
    }
}

extension Collection {
    public subscript(try index: Index) -> Element? {
        get {
            guard containsIndex(index) else {
                return nil
            }
            
            return self[index]
        }
    }
    
    public subscript(try bounds: Range<Index>) -> SubSequence? {
        get {
            guard contains(bounds) else {
                return nil
            }
            
            return self[bounds]
        }
    }
}

extension Collection where Index == Int {
    public subscript(try index: Index) -> Element? {
        get {
            guard containsIndex(index) else {
                return nil
            }
            
            return self[index]
        }
    }
}

extension Collection {
    public var lastIndex: Index? {
        guard !isEmpty else {
            return nil
        }
        
        return self.index(atDistance: self.count - 1)
    }
    
    public var last: Element? {
        guard let lastIndex else {
            return nil
        }
        
        return self[lastIndex]
    }
    
    public func enumerated() -> LazyMapCollection<Self.Indices, (offset: Self.Index, element: Self.Element)> {
        indices.lazy.map({ (offset: $0, element: self[$0]) })
    }
}

extension Collection where Element: Equatable {
    public func indices(of element: Element) -> [Index] {
        indices.filter({ self[$0] == element })
    }
}

extension Collection where Index: Strideable {
    public func index(before index: Index) -> Index {
        index.predecessor()
    }
    
    public func index(after index: Index) -> Index {
        index.successor()
    }
}

extension Collection {
    public func prefix(
        till isTerminator: (Element) -> Bool
    ) -> SubSequence? {
        guard count > 1 else {
            return nil
        }
        
        guard let index = firstIndex(where: isTerminator), index != startIndex else {
            return nil
        }
        
        return self[..<index]
    }
    
    public func prefix(
        till element: Element
    ) -> SubSequence? where Element: Equatable {
        prefix(till: { $0 == element })
    }
}

extension Collection {
    public func cycle(index: Index) -> Index {
        if distance(from: lastIndex!, to: index) > 0 {
            return self.index(atDistance: distance(from: lastIndex!, to: self.index(index, offsetBy: -1)) % count)
        } else {
            return index
        }
    }
    
    public subscript(cycling index: Index) -> Element {
        get {
            return self[cycle(index: index)]
        }
    }
}

extension Collection {
    @_disfavoredOverload
    public func reduce(_ combine: ((Element, Element) -> Element)) -> Element? {
        guard let first = first else {
            return nil
        }
        
        return dropFirst().reduce(first, combine)
    }
}

extension Collection {
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
    public func allSubrangesChunked<C: Collection>(
        by ranges: C
    ) -> [Range<Index>] where C.Element == Range<Index> {
        guard !ranges.isEmpty else {
            return [startIndex..<endIndex]
        }
        
        var result: [Range<Index>] = []
        var lastRange: Range<Index>? = nil
        
        for (index, range) in ranges.enumerated() {
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
    
    public func chunked<C: Collection>(by ranges: C) -> [SubSequence] where C.Element == Range<Index> {
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
