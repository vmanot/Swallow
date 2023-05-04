//
// Copyright (c) Vatsal Manot
//

import Swift

extension ArraySlice: DestructivelyMutableSequence {
    public mutating func removeAll(where shouldBeRemoved: ((Element) throws -> Bool)) rethrows {
        try _removeAll(where: shouldBeRemoved)
    }
}

extension Dictionary: ElementRemoveableDestructivelyMutableSequence {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try forEach(destructivelyMutating: { (element: inout Element!) in try iterator(&element!) })
    }
    
    public mutating func forEach<T>(
        destructivelyMutating iterator: ((inout Element?) throws -> T)
    ) rethrows {
        for element in self {
            var newElement: Element? = element
            
            _ = try iterator(&newElement)
                        
            if let newElement = newElement {
                updateValue(newElement.value, forKey: newElement.key)
            } else {
                removeValue(forKey: element.0)
            }
        }
    }
    
    public mutating func removeAll(where shouldBeRemoved: ((Element) throws -> Bool)) rethrows {
        try _removeAll(where: shouldBeRemoved)
    }

    public mutating func remove(_ element: Element) -> Element? {
        guard let value = removeValue(forKey: element.0) else {
            return nil
        }
        
        return (element.0, value)
    }
}

extension Set: DestructivelyMutableSetProtocol {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try forEach(destructivelyMutating: { try iterator(&$0!) })
    }
    
    public mutating func removeAll(where shouldBeRemoved: ((Element) throws -> Bool)) rethrows {
        try _removeAll(where: shouldBeRemoved)
    }

    public mutating func forEach<T>(destructivelyMutating body: ((inout Element?) throws -> T)) rethrows {
        for element in self {
            var newElement: Element! = element
            
            _ = try body(&newElement)
            
            if element != newElement {
                remove(element)
                
                if let newElement = newElement {
                    insert(newElement)
                }
            }
        }
    }
}

extension String: DestructivelyMutableSequence {
    
}

extension String.UnicodeScalarView: DestructivelyMutableSequence {
    
}

