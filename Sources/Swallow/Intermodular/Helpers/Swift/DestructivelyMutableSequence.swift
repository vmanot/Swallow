//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol DestructivelyMutableSequence: MutableSequence {
    @_disfavoredOverload
    mutating func _forEach<T>(
        destructivelyMutating _: ((inout Element?) throws -> T)
    ) rethrows
    
    @_disfavoredOverload
    mutating func _map<S: ExtensibleSequence & Initiable>(
        destructivelyMutating _: ((inout Element?) throws -> S.Element)
    ) rethrows -> S
    
    mutating func filterInPlace(_: ((Element) throws -> Bool)) rethrows
    mutating func removeAll(where _: ((Element) throws -> Bool)) rethrows
    mutating func removeAll()
}

public protocol ElementRemoveableDestructivelyMutableSequence: DestructivelyMutableSequence {
    @discardableResult mutating func remove(_: Element) -> Element?
}

// MARK: - Implementation

extension DestructivelyMutableSequence {
    @_disfavoredOverload
    public mutating func _map<S: ExtensibleSequence & Initiable>(
        destructivelyMutating iterator: ((inout Element?) throws -> S.Element)
    ) rethrows -> S {
        var result = S()
        
        try _forEach(destructivelyMutating: {
            (element: inout Element?) in
            
            result += try iterator(&element)
        })
        
        return result
    }
    
    public mutating func filterInPlace(
        _ predicate: ((Element) throws -> Bool)
    ) rethrows {
        try _forEach(destructivelyMutating: {
            guard try predicate($0!) else {
                $0 = nil
                
                return
            }
        })
    }
    
    @_disfavoredOverload
    public mutating func _removeAll(where predicate: ((Element) throws -> Bool)) rethrows {
        try _forEach(destructivelyMutating: {
            (element: inout Element!) in
            
            if try predicate(element) {
                element = nil
            }
        })
    }
    
    public mutating func removeAll() {
        _forEach(destructivelyMutating: { $0 = nil })
    }
}

extension DestructivelyMutableSequence where Self: RangeReplaceableCollection {
    public mutating func _forEach<T>(
        destructivelyMutating iterator: ((inout Element?) throws -> T)
    ) rethrows {
        var indexOffset: Int = 0
        
        for (offset, element) in enumerated() {
            let index = self.index(startIndex, offsetBy: offset + indexOffset)
            
            var wasElementMutated: Bool = false
            
            var newElement: Element! = element {
                didSet {
                    wasElementMutated = true
                }
            }
            
            _ = try iterator(&newElement)
            
            if wasElementMutated {
                if let newElement = newElement {
                    replaceSubrange(index..<self.index(index, offsetBy: 1), with: CollectionOfOne(newElement))
                }
                
                else {
                    remove(at: index)
                    
                    indexOffset = indexOffset - 1
                }
            }
        }
    }
        
    public mutating func removeAll() {
        removeAll(keepingCapacity: false)
    }
}

// MARK: - Extensions

extension DestructivelyMutableSequence where Element: Equatable {
    public mutating func removeAll(of element: Element) {
        filterInPlace({ $0 != element })
    }
    
    public static func -= (lhs: inout Self, rhs: Element) {
        lhs.removeAll(of: rhs)
    }
    
    public func removing(allOf element: Element) -> Self {
        return build(self, with: { $0.removeAll(of: $1) }, element)
    }
    
    public static func - (lhs: Self, rhs: Element) -> Self {
        return lhs.removing(allOf: rhs)
    }
}

extension DestructivelyMutableSequence where Element: Hashable {
    public mutating func remove<S: Sequence>(
        contentsOf sequence: S
    ) where S.Element == Element {
        let set = Set(sequence)

        filterInPlace {
            !set.contains($0)
        }
    }
    
    public static func -= <S: Sequence>(lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.remove(contentsOf: rhs)
    }
    
    public func removing<S: Sequence>(contentsOf elements: S) -> Self where S.Element == Element {
        return build(self, with: { $0.remove(contentsOf: $1) }, elements)
    }
    
    public static func - <S: Sequence>(lhs: Self, rhs: S) -> Self where S.Element == Element {
        return lhs.removing(contentsOf: rhs)
    }
    
    public mutating func remove<C: Collection>(contentsOf sequence: C) where C.Element == Element {
        remove(contentsOf: AnySequence(sequence))
    }
    
    public func removing<C: Collection>(contentsOf elements: C) -> Self where C.Element == Element {
        return build(self, with: { $0.remove(contentsOf: $1) }, elements)
    }
}
