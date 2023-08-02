//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A set of weakly-held objects.
public struct _WeakSet<Element: AnyObject>: Initiable {
    private var _storageBox = ReferenceBox<NSHashTable<Element>>(NSHashTable.weakObjects())
    
    private var _unsafelyAccessedStorage: NSHashTable<Element> {
        return _storageBox.wrappedValue
    }
    
    private var _mutableStorage: NSHashTable<Element> {
        mutating get {
            if !isKnownUniquelyReferenced(&_storageBox) {
                _storageBox = ReferenceBox(_unsafelyAccessedStorage.copy() as! NSHashTable)
            }
            
            return _storageBox.wrappedValue
        }
    }
    
    public init() {
        
    }
}

extension _WeakSet {
    public mutating func insert(_ object: Element) {
        _mutableStorage.add(object)
    }
    
    public mutating func remove(_ object: Element) {
        _mutableStorage.remove(object)
    }
    
    public mutating func removeAll() {
        _mutableStorage.removeAllObjects()
    }
}

// MARK: - Conformances

extension _WeakSet: Sequence {
    public typealias Iterator = AnyIterator<Element>
    
    public var count: Int {
        _unsafelyAccessedStorage.count
    }
    
    public func makeIterator() -> Iterator {
        var index = 0
        let allObjects = _unsafelyAccessedStorage.allObjects
        
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

extension _WeakSet: SequenceInitiableSequence {
    public init(_ sequence: some Sequence<Element>) {
        self.init()
        
        for element in sequence {
            _unsafelyAccessedStorage.add(element)
        }
    }
}

extension _WeakSet: SetProtocol {
    public func contains(_ element: Element) -> Bool {
        _unsafelyAccessedStorage.contains(element)
    }
    
    public func isSubset(of other: _WeakSet<Element>) -> Bool {
        _unsafelyAccessedStorage.isSubset(of: other._unsafelyAccessedStorage)
    }
    
    public func isSuperset(of other: _WeakSet<Element>) -> Bool {
        other._unsafelyAccessedStorage.isSubset(of: _unsafelyAccessedStorage)
    }
    
    public func intersection(_ other: Self) -> Self {
        var result = self
        
        result._mutableStorage.intersect(other._unsafelyAccessedStorage)
        
        return result
    }
    
    public func union(_ other: Self) -> Self {
        var result = self
        
        result._mutableStorage.union(other._unsafelyAccessedStorage)
        
        return result
    }
}

extension _WeakSet: @unchecked Sendable where Element: Sendable {
    
}
