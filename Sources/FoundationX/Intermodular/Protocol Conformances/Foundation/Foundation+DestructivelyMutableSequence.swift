//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSMutableArray: Swallow.DestructivelyMutableSequence {
    public func _forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        for (index, _) in enumerated() {
            _ = try iterator(&self[index])
        }
    }
    
    public func _forEach<T>(
        destructivelyMutating iterator: ((inout Element?) throws -> T)
    ) rethrows {
        TODO.whole(.test)
        
        for (index, element) in enumerated() {
            var newElement: Element? = element
            
            _ = try iterator(&newElement)
            
            if let newElement = newElement {
                self[index] = newElement
            } else {
                remove(element)
            }
        }
    }
    
    public func removeAll(
        where predicate: ((Element) throws -> Bool)
    ) rethrows {
        var _self = self
        
        try _self._removeAll(where: predicate)
    }
}

extension Foundation.NSMutableData: Swallow.MutableSequence {
    public func _forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        for (index, _) in enumerated() {
            _ = try iterator(&self[_position: index])
        }
    }
}

extension Foundation.NSMutableSet: Swallow.DestructivelyMutableSequence {
    public func _forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try _forEach(destructivelyMutating: { try iterator(&$0!) })
    }
    
    public func _forEach<T>(
        destructivelyMutating iterator: ((inout Element?) throws -> T)
    ) rethrows {
        for element in self {
            var newElement: Element? = element
            
            remove(element)
            
            _ = try iterator(&newElement)
            
            if let newElement = newElement {
                add(newElement)
            }
        }
    }
    
    public func removeAll(where predicate: ((Element) throws -> Bool)) rethrows {
        var _self = self
        
        try _self._removeAll(where: predicate)
    }
}
