//
// Copyright (c) Vatsal Manot
//

import Swift

extension RangeReplaceableCollection {
    @inlinable
    public init(capacity: Int) {
        self.init()
        
        reserveCapacity(capacity)
    }
}

extension RangeReplaceableCollection {
    @inlinable
    public subscript(flexible bounds: Range<Index>) -> SubSequence {
        get {
            return self[bounds]
        } set {
            replaceSubrange(bounds, with: newValue)
        }
    }
    
    @inlinable
    public subscript(flexible bounds: Range<Int>) -> SubSequence {
        get {
            return self[range(from: bounds)]
        } set {
            replaceSubrange(range(from: bounds), with: newValue)
        }
    }
}

extension RangeReplaceableCollection {
    @discardableResult
    public mutating func replace(
        at index: Index,
        with replacement: Element
    ) -> Element {
        insert(replacement, at: index)
        
        return remove(at: self.index(index, offsetBy: 1))
    }
    
    @discardableResult
    public mutating func replace<S: Collection>(
        at index: Index,
        with replacements: S
    ) -> Element where S.Element == Element {
        let oldCount = count
        
        self.insert(contentsOf: replacements, at: index)
        
        return self.remove(at: self.index(index, offsetBy: (count - oldCount)))
    }
    
    @discardableResult
    public mutating func replace<S: Sequence>(
        at indices: S,
        with replacement: Element
    ) -> [Element] where S.Element == Index {
        return indices.map({ self.insert(replacement, at: $0); return self.remove(at: self.index($0, offsetBy: 1)) })
    }
    
    @inlinable
    public mutating func replace<S0: Sequence, S1: Sequence, S2: ExtensibleSequence>(
        at indices: S0,
        with replacements: S1,
        removedInto sink: inout S2
    ) where S0.Element == Index, S1.Element == Element, S2.Element == Element {
        let replacements = Array(replacements)
        var indexOffset: Int = 0
        
        for index in indices {
            insert(contentsOf: replacements, at: index)
            indexOffset += replacements.count - 1
            sink += remove(at: self.index(index, offsetBy: indexOffset + 1))
        }
    }
    
    @discardableResult
    public mutating func replace<S0: Sequence, S1: Sequence>(
        at indices: S0,
        with replacements: S1
    ) -> [Element] where S0.Element == Index, S1.Element == Element {
        var result: [Element] = []
        replace(at: indices, with: replacements, removedInto: &result)
        return result
    }
}

extension RangeReplaceableCollection {
    @discardableResult
    public mutating func replace(
        _ predicate: ((Element) -> Bool),
        with replacement: Element
    ) -> [Element] {
        return replace(at: indices.filter({ predicate(self[$0]) }), with: replacement)
    }
    
    @discardableResult
    public mutating func replace<S: Collection>(
        _ predicate: ((Element) -> Bool),
        with replacements: S
    ) -> [Element] where S.Element == Element {
        return replace(at: indices.filter({ predicate(self[$0]) }), with: replacements)
    }
}

extension RangeReplaceableCollection {
    @discardableResult
    public mutating func remove(at first: Index, _ second: Index, _ rest: Index...) -> [Element] {
        return remove(at: [first, second] + rest)
    }
    
    @discardableResult
    public func removing(at index: Index) -> Self {
        return build(self, with: { $0.remove(at: index) })
    }
    
    public mutating func remove<S0: Sequence, S1: ExtensibleSequence>(at indices: S0, into result: inout S1) where S0.Element == Index, S1.Element == Element {
        var indexOffset: Int = 0
        
        for index in indices {
            result += self.remove(at: self.index(index, offsetBy: -indexOffset))
            
            indexOffset.advance()
        }
    }
    
    @_disfavoredOverload
    @discardableResult
    public mutating func remove<S: Sequence>(at indices: S) -> [Element] where S.Element == Index {
        var result: [Element] = []
        
        remove(at: indices, into: &result)
        
        return result
    }
    
    @discardableResult
    public func removing<S: Sequence>(at indices: S) -> Self where S.Element == Index {
        return build(self, with: { $0.remove(at: indices) })
    }
    
    public mutating func remove<C0: Collection, C1: ExtensibleCollection>(at indices: C0, into result: inout C1) where C0.Element == Index, C1.Element == Element {
        remove(at: AnySequence(indices), into: &result)
    }
    
    @discardableResult
    public mutating func remove<C: Collection>(at indices: C) -> [Element] where C.Element == Index {
        var result: [Element] = .init(capacity: indices.count)
        
        remove(at: indices, into: &result)
        
        return result
    }
    
    @discardableResult
    public func removing<C: Collection>(at indices: C) -> Self where C.Element == Index {
        return build(self, with: { $0.remove(at: indices) })
    }
    
    public mutating func remove(_ predicate: ((Element) throws -> Bool)) rethrows {
        var indices: [Index] = []
        
        for (index, element) in enumerated() {
            try predicate(element) &&-> (indices += index)
        }
        
        remove(at: indices)
    }
    
    @discardableResult
    public func removing(_ predicate: ((Element) throws -> Bool)) rethrows -> Self {
        var result = self
        
        _ = try result.remove(predicate)
        
        return result
    }
}

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    public mutating func replace(allOf element: Element, with replacement: Element) -> [Element] {
        return replace(at: indices.filter({ self[$0] == element }), with: replacement)
    }
    
    @discardableResult
    public mutating func replace<C: Collection>(allOf element: Element, with replacements: C) -> [Element] where C.Element == Element {
        return replace(at: indices.filter({ self[$0] == element }), with: replacements)
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func upsert(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            replace(at: index, with: element)
        } else {
            insert(element, at: 0)
        }
    }
    
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func upsert<S: Sequence>(contentsOf elements: S) where S.Element == Element {
        elements.forEach({ upsert($0) })
    }
    
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func updateOrAppend(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            replace(at: index, with: element)
        } else {
            append(element)
        }
    }
    
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func updateOrAppend<S: Sequence>(contentsOf elements: S) where S.Element == Element {
        elements.forEach({ updateOrAppend($0) })
    }
}

extension RangeReplaceableCollection {
    public mutating func replaceSubranges<
        Ranges: Collection,
        Replacements: Collection,
        Replacement: Collection
    >(
        _ subranges: Ranges,
        with replacements: Replacements,
        file: StaticString = #file,
        line: UInt = #line
    ) where Ranges.Element == Range<Index>,
            Replacement.Element == Element,
            Replacements.Element == Replacement
    {
        TODO.whole(.document, .optimize, .refactor, .test)
        
        assert(subranges.count == replacements.count)
        
        guard !subranges.isEmpty else {
            return
        }
        
        guard !(subranges.count == 1) else {
            return replaceSubrange(subranges.first.forceUnwrap(), with: replacements.first.forceUnwrap())
        }
        
        let sortedReplacements = subranges.zip(replacements).sorted(by: { $0.0 <~= $1.0 }).lazy.map({ ($0.0, Optional.some($0.1)) })
        
        let first = sortedReplacements.first.forceUnwrap()
        let last = sortedReplacements.last.forceUnwrap()
        
        sortedReplacements
            .consecutives()
            .forEach {
                if $0.0.0.upperBound > $0.1.0.lowerBound {
                    fatalError("Input ranges may not overlap", file: file, line: line)
                }
            }
        
        let sortedReplacmentsAndGaps = CollectionOfOne(first).join(
            sortedReplacements
                .consecutives()
                .map { [($0.0.0.upperBound..<$0.1.0.lowerBound, nil), ($0.1.0, $0.1.1)] }
                .joined()
        )
        
        var sortedReplacementsAndGapsWithEnd = sortedReplacmentsAndGaps.join([])
        
        if last.0.upperBound < endIndex {
            sortedReplacementsAndGapsWithEnd = sortedReplacmentsAndGaps.join([(last.0.upperBound..<endIndex, nil)])
        }
        
        let emptyJoiner: [(Range<Index>, Replacement?)] = []
        var sortedReplacementsAndGapsWithStart = emptyJoiner.join(sortedReplacementsAndGapsWithEnd)
        
        if first.0.lowerBound > startIndex {
            let joiner: [(Range<Index>, Replacement?)] = [(startIndex..<first.0.lowerBound, nil)]
            sortedReplacementsAndGapsWithStart = joiner.join(sortedReplacementsAndGapsWithEnd)
        }
        
        var newSelf = Self.init(capacity: 0); TODO.here(.optimize)
        
        sortedReplacementsAndGapsWithStart.forEach { range, replacement in
            replacement
                .map { newSelf.append(contentsOf: $0) }
                .ifNone { newSelf.append(contentsOf: self[range]) }
        }
        
        self = newSelf
    }
    
    public func replacingSubranges<
        Ranges: Collection,
        Replacements: Collection,
        Replacement: Collection
    >(
        _ subranges: Ranges,
        with replacements: Replacements
    ) -> Self where Ranges.Element == Range<Index>,
                    Replacement.Element == Element,
                    Replacements.Element == Replacement
    {
        var result = self
        
        result.replaceSubranges(subranges, with: replacements)
        
        return result
    }
}

extension RangeReplaceableCollection {
    public mutating func insert(
        _ element: Element,
        at index: RelativeIndex
    ) {
        insert(element, at: self.index(atDistance: index.distanceFromStartIndex))
    }
    
    public mutating func insert<C: Collection>(
        contentsOf collection: C,
        at index: RelativeIndex
    ) where C.Element == Element {
        insert(contentsOf: collection, at: self.index(atDistance: index.distanceFromStartIndex))
    }
    
    public mutating func pad(
        at index: Index,
        with padding: Element,
        toCount targetCount: Int
    ) {
        let index = RelativeIndex(index, in: self)
        
        while targetCount > count {
            insert(padding, at: index)
        }
    }
    
    public func padded(
        at index: Index,
        with padding: Element,
        toCount targetCount: Int
    ) -> Self {
        var collection = self
        collection.pad(at: index, with: padding, toCount: targetCount)
        return collection
    }
    
    public mutating func pad<C: Collection>(
        at index: Index,
        withContentsOf padding: C,
        toCount targetCount: Int
    ) where C.Element == Element {
        precondition(!padding.isEmpty, "Empty padding")
        
        let index = RelativeIndex(index, in: self)
        
        while targetCount > count {
            insert(contentsOf: padding, at: index)
        }
    }
    
    public func padded<C: Collection>(at index: Index, withContentsOf padding: C, toCount targetCount: Int) -> Self where C.Element == Element {
        var result = self
        
        result.pad(at: index, withContentsOf: padding, toCount: targetCount)
        
        return result
    }
}
