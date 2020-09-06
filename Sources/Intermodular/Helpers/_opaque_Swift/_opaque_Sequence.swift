//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Sequence2 = _opaque_Sequence & Sequence

public protocol _opaque_Sequence: AnyProtocol {
    static var _opaque_Sequence_Iterator: Any.Type { get }
    static var _opaque_Sequence_Iterator_Element: Any.Type { get }
    
    func _opaque_Sequence_makeIterator() -> _opaque_IteratorProtocol
    func _opaque_Sequence_toAnySequence() -> Any
    
    func toOpaque() -> AnySequence<Any>
}

extension _opaque_Sequence where Self: Sequence {
    public static var _opaque_Sequence_Iterator: Any.Type {
        return Iterator.self
    }
    
    public static var _opaque_Sequence_Iterator_Element: Any.Type {
        return Element.self
    }
    
    public func _opaque_Sequence_makeIterator() -> _opaque_IteratorProtocol {
        return makeIterator().iteratorOnly
    }

    public func _opaque_Sequence_toAnySequence() -> Any {
        return AnySequence({ self.makeIterator() })
    }
    
    public func toOpaque() -> AnySequence<Any> {
        return AnySequence(lazy.map({ $0 }))
    }
}

extension _opaque_Sequence where Self: Sequence, Self.Iterator: _opaque_IteratorProtocol {
    public func _opaque_Sequence_makeIterator() -> _opaque_IteratorProtocol {
        return makeIterator()
    }
}
