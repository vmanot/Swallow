//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol DestructivelyMutableSequence: MutableSequence {
    mutating func forEach<T>(destructivelyMutating _: ((inout Element?) throws -> T)) rethrows
    mutating func map<S: ExtensibleSequence & Initiable>(mutating _: ((inout Element?) throws -> S.Element)) rethrows -> S
    mutating func filter(inPlace _: ((Element) throws -> Bool)) rethrows
    mutating func remove(_: ((Element) throws -> Bool)) rethrows
    mutating func removeAll()
}

public protocol ElementRemoveableDestructivelyMutableSequence: DestructivelyMutableSequence {
    @discardableResult mutating func remove(_: Element) -> Element?
}

// MARK: - Implementation -

extension DestructivelyMutableSequence {
    public mutating func map<S: ExtensibleSequence & Initiable>(mutating iterator: ((inout Element?) throws -> S.Element)) rethrows -> S {
        var result = S()
        
        try forEach {
            (element: inout Element?) in
            
            result += try iterator(&element)
        }
        
        return result
    }
    
    public mutating func filter(inPlace predicate: ((Element) throws -> Bool)) rethrows {
        try forEach(destructivelyMutating: { try predicate($0!) &&-> ($0 = nil) })
    }
    
    public mutating func remove(_ predicate: ((Element) throws -> Bool)) rethrows {
        try forEach(destructivelyMutating: {
            (element: inout Element!) in
            
            if try predicate(element) {
                element = nil
            }
        })
    }

    public mutating func removeAll() {
        forEach(destructivelyMutating: { $0 = nil })
    }
}

extension DestructivelyMutableSequence where Self: RangeReplaceableCollection {
    public mutating func forEach<T>(destructivelyMutating iterator: ((inout Element?) throws -> T)) rethrows {
        var indexOffset: Int = 0
        
        for (index, element) in enumerated() {
            let index = self.index(index, offsetBy: indexOffset)
            
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

    public mutating func remove(_ predicate: ((Element) throws -> Bool)) rethrows {
        try forEach(destructivelyMutating: {
            (element: inout Element!) in

            if try predicate(element) {
                element = nil
            }
        })
    }

    public mutating func removeAll() {
        removeAll(keepingCapacity: false)
    }
}

// MARK: - Extensions -

extension DestructivelyMutableSequence where Element: Equatable {
    public mutating func removeAll(of someElement: Element) {
        forEach(destructivelyMutating: { $0 == someElement &&-> ($0 = nil) })
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
    
    public mutating func remove<S: Sequence>(contentsOf sequence: S) where S.Element == Element {
        forEach(destructivelyMutating: { sequence.contains($0!) &&-> ($0 = nil) })
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
        remove(contentsOf: SequenceOnly(sequence))
    }
    
    public func removing<C: Collection>(contentsOf elements: C) -> Self where C.Element == Element {
        return build(self, with: { $0.remove(contentsOf: $1) }, elements)
    }
}
