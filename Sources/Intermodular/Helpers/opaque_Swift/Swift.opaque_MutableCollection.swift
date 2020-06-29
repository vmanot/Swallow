//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias MutableCollection2 = opaque_MutableCollection & MutableCollection

public protocol opaque_MutableCollection: opaque_Collection {
    mutating func opaque_MutableCollection_set(element: Any, atPosition _: Any) -> Void?
    mutating func opaque_MutableCollection_set(elements: Any, withinBounds _: Any) -> Void?
}

extension opaque_MutableCollection where Self: MutableCollection {
    public mutating func opaque_MutableCollection_set(element: Any, atPosition position: Any) -> Void? {
        guard let element: Element = -?>element, let position: Index = -?>position else {
            return nil
        }
        
        self[position] = element
        
        return ()
    }
    
    public mutating func opaque_MutableCollection_set(elements: Any, withinBounds bounds: Any) -> Void? {
        guard let bounds = (bounds as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence<Index>, let elements = (elements as? opaque_Sequence)?.opaque_Sequence_toAnySequence() as? AnySequence<Element> else {
            return nil
        }
        
        for (index, element) in bounds.zip(elements) {
            self[index] = element
        }
        
        return ()
    }
}
