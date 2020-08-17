//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias MutableCollection2 = _opaque_MutableCollection & MutableCollection

public protocol _opaque_MutableCollection: _opaque_Collection {
    mutating func _opaque_MutableCollection_set(element: Any, atPosition _: Any) -> Void?
    mutating func _opaque_MutableCollection_set(elements: Any, withinBounds _: Any) -> Void?
}

extension _opaque_MutableCollection where Self: MutableCollection {
    public mutating func _opaque_MutableCollection_set(element: Any, atPosition position: Any) -> Void? {
        guard let element: Element = -?>element, let position: Index = -?>position else {
            return nil
        }
        
        self[position] = element
        
        return ()
    }
    
    public mutating func _opaque_MutableCollection_set(elements: Any, withinBounds bounds: Any) -> Void? {
        guard let bounds = (bounds as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence<Index>, let elements = (elements as? _opaque_Sequence)?._opaque_Sequence_toAnySequence() as? AnySequence<Element> else {
            return nil
        }
        
        for (index, element) in bounds.zip(elements) {
            self[index] = element
        }
        
        return ()
    }
}
