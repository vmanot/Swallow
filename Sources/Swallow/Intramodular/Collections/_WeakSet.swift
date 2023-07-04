//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A set of weakly-held objects.
public struct _WeakSet<Element: AnyObject> {
    /// Wrapper of a set of weakly-referenced objects
    private var _boxedObjects = WrapperBox<NSHashTable<Element>>(NSHashTable.weakObjects())
    /// Set of immutable objects
    private var _objects: NSHashTable<Element> {
        return _boxedObjects.unbox
    }
    /// Set of mutable objects
    private var _mutableObjects: NSHashTable<Element> {
        mutating get {
            if !isKnownUniquelyReferenced(&_boxedObjects) {
                // `_boxedObjects` is being referenced by another `WeakSet` struct (that must have been
                // created through a copied assignment). Create a copy of `_boxedObjects` so that both
                // structs now reference a different set of objects.
                _boxedObjects = WrapperBox(_objects.copy() as! NSHashTable)
            }
            return _boxedObjects.unbox
        }
    }
}

extension _WeakSet {
    /// Adds an object to the set.
    public mutating func add(_ object: Element) {
        _mutableObjects.add(object)
    }
    
    /// Removes an object from the set.
    public mutating func remove(_ object: Element) {
        _mutableObjects.remove(object)
    }
    
    /// Removes all objects from the set.
    public mutating func removeAll() {
        _mutableObjects.removeAllObjects()
    }
}

// MARK: - Conformances

extension _WeakSet: Sequence {
    public typealias Iterator = AnyIterator<Element>
    
    public var count: Int {
        _objects.count
    }
    
    public func makeIterator() -> Iterator {
        var index = 0
        let allObjects = _objects.allObjects
        
        return AnyIterator {
            if index < allObjects.count {
                let nextObject = allObjects[index]
                
                index += 1
                
                return nextObject
            }
            return nil
        }
    }
}

// MARK: - Auxiliary

extension _WeakSet {
    internal final class WrapperBox<T> {
        let unbox: T
        
        init(_ element: T) {
            unbox = element
        }
    }
}
