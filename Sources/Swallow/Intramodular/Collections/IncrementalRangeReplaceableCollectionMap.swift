//
// Copyright (c) Vatsal Manot
//

import Swift

/// A protocol that defines a mapping operation for a range-replaceable collection.
public protocol IncrementalRangeReplaceableCollectionMap: Initiable {
    associatedtype BaseCollectionElement
    associatedtype Element
    associatedtype Cache
    
    /// Creates a cache for the given base collection.
    func makeCache<Base: RangeReplaceableCollection<BaseCollectionElement>>(
        base: Base
    ) -> Cache
    
    /// Maps the elements of the base collection to a new collection of the specified type.
    func map<Base: RangeReplaceableCollection<BaseCollectionElement>, MappedCollection: RangeReplaceableCollection<Element>>(
        _ base: Base,
        to destination: MappedCollection.Type,
        cache: inout Cache
    ) -> MappedCollection
    
    /// Updates the base collection and cache based on the provided difference in the mapped elements.
    func update<Base: RangeReplaceableCollection<BaseCollectionElement>>(
        base: inout Base,
        cache: inout Self.Cache,
        difference: CollectionDifference<Element>
    )
}

public struct IncrementallyMappedRangeReplaceableCollection<Base: RangeReplaceableCollection, Map: IncrementalRangeReplaceableCollectionMap, MappedCollection: RangeReplaceableCollection<Map.Element>> where MappedCollection.Index: Strideable, Map.BaseCollectionElement == Base.Element {
    public var base: Base
    public var map: Map
    public var cache: Map.Cache
    
    private var _mappedCollection: MappedCollection
    
    public init(
        base: Base,
        map: Map
    ) {
        self.base = base
        self.map = map
        self.cache = map.makeCache(base: base)
        self._mappedCollection = map.map(base, to: MappedCollection.self, cache: &self.cache)
    }
}

extension IncrementallyMappedRangeReplaceableCollection: RangeReplaceableCollection {
    public typealias Element = Map.Element
    public typealias Index = MappedCollection.Index
    
    public init() {
        self.init(base: .init(), map: .init())
    }
    
    public var startIndex: Index {
        _mappedCollection.startIndex
    }
    
    public var endIndex: Index {
        _mappedCollection.endIndex
    }
    
    public subscript(position: Index) -> Element {
        get {
            _mappedCollection[position]
        } set {
            replaceSubrange(position..<index(after: position), with: [newValue])
        }
    }
    
    public func index(before i: Index) -> Index {
        _mappedCollection.index(before: i)
    }
    
    public func index(after i: Index) -> Index {
        _mappedCollection.index(after: i)
    }
    
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        _mappedCollection.index(i, offsetBy: distance)
    }
    
    public func distance(from start: Index, to end: Index) -> Int {
        _mappedCollection.distance(from: start, to: end)
    }
    
    public mutating func append(_ element: Element) {
        let changes: [CollectionDifference<Element>.Change] = [
            .insert(offset: _mappedCollection.count, element: element, associatedWith: nil)
        ]
        
        let difference = CollectionDifference(changes)!
        
        map.update(
            base: &base,
            cache: &cache,
            difference: difference
        )
        
        _mappedCollection.append(element)
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        var changes: [CollectionDifference<Element>.Change] = []
        var offset = _mappedCollection.count
        
        for element in newElements {
            changes.append(.insert(offset: offset, element: element, associatedWith: nil))
            offset += 1
        }
        
        let difference = CollectionDifference(changes)!
        
        map.update(
            base: &base,
            cache: &cache,
            difference: difference
        )
        
        _mappedCollection.append(contentsOf: newElements)
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        let changes: [CollectionDifference<Element>.Change] = _mappedCollection.indices.map { index in
            CollectionDifference<Element>.Change.remove(
                offset: _mappedCollection.distance(
                    from: _mappedCollection.startIndex,
                    to: index
                ),
                element: _mappedCollection[index],
                associatedWith: nil
            )
        }
        
        let difference = CollectionDifference(changes)!
        
        map.update(
            base: &base,
            cache: &cache,
            difference: difference
        )
        
        _mappedCollection.removeAll(keepingCapacity: keepCapacity)
    }
    
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>,
        with newElements: C
    ) where C.Element == Element {
        let removedElements = _mappedCollection[subrange]
        let insertedElements = Array(newElements)
        
        var changes: [CollectionDifference<Element>.Change] = []
        
        let subrangeOffset: Int = _mappedCollection.distance(
            from: _mappedCollection.startIndex,
            to: subrange.lowerBound
        )
        
        for (offset, element) in removedElements.enumerated() {
            changes.append(
                .remove(
                    offset: subrangeOffset + offset,
                    element: element,
                    associatedWith: nil
                )
            )
        }
        
        for (offset, element) in insertedElements.enumerated() {
            changes.append(
                .insert(
                    offset: subrangeOffset + offset,
                    element: element,
                    associatedWith: nil
                )
            )
        }
        
        let difference = CollectionDifference(changes)!
        
        map.update(
            base: &base,
            cache: &cache,
            difference: difference
        )
        
        _mappedCollection.replaceSubrange(subrange, with: newElements)
    }
}
