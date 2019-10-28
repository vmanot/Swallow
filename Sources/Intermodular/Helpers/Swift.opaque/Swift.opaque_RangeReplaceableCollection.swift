//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias RangeReplaceableCollection2 = opaque_RangeReplaceableCollection & RangeReplaceableCollection

public protocol opaque_RangeReplaceableCollection: opaque_Collection {
    init()
    
    mutating func opaque_RangeReplaceableCollection_reserveCapacity(_ n: Any) -> Void?
    mutating func opaque_RangeReplaceableCollection_replaceSubrange(_ subrange: Any, with newElements: Any) -> Void?
    mutating func opaque_RangeReplaceableCollection_append(_ x: Any) -> Void?
    mutating func opaque_RangeReplaceableCollection_append(contentsOf newElements: Any) -> Void?
    mutating func opaque_RangeReplaceableCollection_insert(_ newElement: Any, atIndex i: Any) -> Void?
    mutating func opaque_RangeReplaceableCollection_insert(contentsOf newElements: Any, at i: Any) -> Void?
    mutating func opaque_RangeReplaceableCollection_removeAtIndex(_ i: Any) -> Any?
    mutating func opaque_RangeReplaceableCollection_removeFirst() -> Any
    mutating func opaque_RangeReplaceableCollection_removeRange(_ subrange: Any) -> Void?
}

extension opaque_RangeReplaceableCollection where Self: RangeReplaceableCollection {
    public mutating func opaque_RangeReplaceableCollection_reserveCapacity(_ n: Any) -> Void? {
        return (-?>n).map({ self.reserveCapacity($0) })
    }
    
    public mutating func opaque_RangeReplaceableCollection_replaceSubrange(_ bounds: Any, with newElements: Any) -> Void? {
        if let bounds = bounds as? Range<Index>, let newElements = (newElements as? opaque_Collection)?.opaque_Collection_toAnyCollection() as? AnyCollection<Element> {
            replaceSubrange(bounds, with: newElements)
        }
        
        return nil
    }
    
    public mutating func opaque_RangeReplaceableCollection_append(_ x: Any) -> Void? {
        return (x as? Element).map({ self.append($0) })
    }
    
    public mutating func opaque_RangeReplaceableCollection_append(contentsOf newElements: Any) -> Void? {
        return ((newElements as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence).map({ self.append(contentsOf: $0) })
    }
    
    public mutating func opaque_RangeReplaceableCollection_insert(_ newElement: Any, atIndex i: Any) -> Void? {
        if let newElement = newElement as? Element, let i = i as? Index {
            insert(newElement, at: i)
        }
        
        return nil
    }
    
    public mutating func opaque_RangeReplaceableCollection_insert(contentsOf newElements: Any, at i: Any) -> Void? {
        if let newElements = (newElements as? opaque_Collection)?.opaque_Collection_toAnyCollection() as? AnyCollection<Element>, let i = i as? Index {
            insert(contentsOf: newElements, at: i)
        }
        
        return nil
    }
    
    public mutating func opaque_RangeReplaceableCollection_removeAtIndex(_ i: Any) -> Any? {
        return (i as? Index).map({ self.remove(at: $0) })
    }
    
    public mutating func opaque_RangeReplaceableCollection_removeFirst() -> Any {
        return removeFirst()
    }
    
    public mutating func opaque_RangeReplaceableCollection_removeRange(_ subrange: Any) -> Void? {
        return (subrange as? Range<Index>).map({ self.removeSubrange($0) })
    }
}
