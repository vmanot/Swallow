//
// Copyright (c) Vatsal Manot
//

import Swift

extension ArraySlice: DestructivelyMutableSequence {

}

extension Dictionary: ElementRemoveableDestructivelyMutableSequence {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try forEach(mutating: { (element: inout Element!) in try iterator(&element!) })
    }

    public mutating func forEach<T>(mutating iterator: ((inout Element?) throws -> T)) rethrows {
        for element in self {
            var newElement: Element! = element

            _ = try iterator(&newElement)

            removeValue(forKey: element.0)

            (newElement as Element?).collapse({ updateValue($0.1, forKey: $0.0) })
        }
    }

    public mutating func remove(_ element: Element) -> Element? {
        return compound(element.0, removeValue(forKey: element.0))
    }
}

extension Set: DestructivelyMutableSequence {
    public mutating func forEach<T>(mutating iterator: ((inout Element) throws -> T)) rethrows {
        try forEach(mutating: { (element: inout Element!) in try iterator(&element!) })
    }

    public mutating func forEach<T>(mutating f: ((inout Element?) throws -> T)) rethrows {
        for element in self {
            var newElement: Element! = element

            _ = try f(&newElement)

            if element != newElement {
                remove(element)

                optional(newElement).collapse({ self.insert($0) })
            }
        }
    }
}

extension String: DestructivelyMutableSequence {

}

extension String.UnicodeScalarView: DestructivelyMutableSequence {

}

