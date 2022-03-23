//
// Copyright (c) Vatsal Manot
//

import Swift

extension Collection {
    @inlinable
    public var bounds: Range<Index> {
        return startIndex..<endIndex
    }
    
    @inlinable
    public var distances: LazyMapCollection<Indices, Int> {
        return indices.lazy.map(self.distanceFromStartIndex)
    }
    
    @inlinable
    public var length: Int {
        return distance(from: startIndex, to: endIndex)
    }
}

extension Collection where Index: Strideable {
    @inlinable
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
    @inlinable
    public func containsIndex(_ index: Index) -> Bool {
        return index >= startIndex && index < endIndex
    }
    
    @inlinable
    public func contains(after index: Index) -> Bool {
        return containsIndex(index) && containsIndex(self.index(after: index))
    }
    
    @inlinable
    public func contains(_ bounds: Range<Index>) -> Bool {
        return containsIndex(bounds.lowerBound) && containsIndex(index(bounds.upperBound, offsetBy: -1))
    }
}

extension Collection {
    @inlinable
    public func index(atDistance distance: Int) -> Index {
        return index(startIndex, offsetBy: distance)
    }
    
    @inlinable
    public func index(_ index: Index, insetBy distance: Int) -> Index {
        return self.index(index, offsetBy: -distance)
    }
    
    @inlinable
    public func index(_ index: Index, offsetByDistanceFromStartIndexFor otherIndex: Index) -> Index {
        return self.index(index, offsetBy: distanceFromStartIndex(to: otherIndex))
    }
    
    @inlinable
    public func distanceFromStartIndex(to index: Index) -> Int {
        return distance(from: startIndex, to: index)
    }
    
    @inlinable
    public func range(from range: Range<Int>) -> Range<Index> {
        return index(atDistance: range.lowerBound)..<index(atDistance: range.upperBound)
    }
    
    public subscript(atDistance distance: Int) -> Element {
        @inlinable get {
            return self[index(atDistance: distance)]
        }
    }
    
    public subscript(betweenDistances distance: Range<Int>) -> SubSequence {
        @inlinable get {
            return self[index(atDistance: distance.lowerBound)..<index(atDistance: distance.upperBound)]
        }
    }
    
    public subscript(betweenDistances distance: ClosedRange<Int>) -> SubSequence {
        @inlinable
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
        @inlinable get {
            return Optional(self[index], if: containsIndex(index))
        }
    }
    
    public subscript(try bounds: Range<Index>) -> SubSequence? {
        @inlinable get {
            return Optional(self[bounds], if: contains(bounds))
        }
    }
}

extension Collection where Index == Int {
    public subscript(try index: Index) -> Element? {
        @inlinable get {
            return Optional(self[index], if: containsIndex(index))
        }
    }
}

extension Collection {
    @inlinable
    public var lastIndex: Index {
        try! indices.last.unwrap()
    }
    
    @inlinable
    public func enumerated() -> LazyMapCollection<Self.Indices, (offset: Self.Index, element: Self.Element)> {
        indices.lazy.map({ (offset: $0, element: self[$0]) })
    }
    
    @inlinable
    public func index(of predicate: ((Element) throws -> Bool)) rethrows -> Index? {
        try enumerated().find({ try predicate($1) })?.0
    }
}

extension Collection where Element: Equatable {
    @inlinable
    public func indices(of element: Element) -> [Index] {
        return indices.filter({ self[$0] == element })
    }
}

extension Collection where Index: Strideable {
    @inlinable
    public func index(before index: Index) -> Index {
        return index.predecessor()
    }
    
    @inlinable
    public func index(after index: Index) -> Index {
        return index.successor()
    }
}

extension Collection {
    @inlinable
    public func cycle(index: Index) -> Index {
        if distance(from: lastIndex, to: index) > 0 {
            return self.index(atDistance: distance(from: lastIndex, to: self.index(index, offsetBy: -1)) % count)
        } else {
            return index
        }
    }
    
    public subscript(cycling index: Index) -> Element {
        @inlinable get {
            return self[cycle(index: index)]
        }
    }
}

extension Collection {
    @_disfavoredOverload
    @inlinable
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
    @inlinable
    public func range(till f: ((Element) throws -> Bool)) rethrows -> Range<Index>? {
        var lastIndex: Index?
        
        for (index, element) in enumerated() {
            if let lastIndex = lastIndex, try f(element) {
                return startIndex..<self.index(after: lastIndex)
            }
            
            lastIndex = index
        }
        
        return nil
    }
    
    @inlinable
    public func range(after f: ((Element) throws -> Bool)) rethrows -> Range<Index>? {
        return try enumerated().find({ try f($1) }).map({ self.index(after: $0.0)..<endIndex })
    }
}

extension Collection {
    @inlinable
    public func subsequence(till index: Index) -> SubSequence {
        fatallyAssertIndexAsValidSubscriptArgument(index)
        
        return self[startIndex..<index]
    }
    
    @inlinable
    public func subsequence(till f: ((Element) throws -> Bool)) rethrows -> SubSequence? {
        return try range(till: f).map({ self[$0] })
    }
    
    @inlinable
    public func subsequence(after index: Index) -> SubSequence {
        fatallyAssertIndexAsValidSubscriptArgument(index)
        
        return self[self.index(after: index)..<endIndex]
    }
    
    @inlinable
    public func subsequence(after f: ((Element) throws -> Bool)) rethrows -> SubSequence? {
        return try range(after: f).map({ self[$0] })
    }
}

extension Collection {
    public func allSubrangesChunked<C: Collection>(by ranges: C) -> [Range<Index>] where C.Element == Range<Index> {
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
