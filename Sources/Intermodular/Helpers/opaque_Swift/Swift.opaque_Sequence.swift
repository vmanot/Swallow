//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Sequence2 = opaque_Sequence & Sequence

public protocol opaque_Sequence: AnyProtocol {
    static var opaque_Sequence_Iterator: Any.Type { get }
    static var opaque_Sequence_Iterator_Element: Any.Type { get }
    
    func opaque_Sequence_makeIterator() -> opaque_IteratorProtocol
    func opaque_Sequence_toAnySequence() -> Any
    
    func toOpaque() -> AnySequence<Any>
}

extension opaque_Sequence where Self: Sequence {
    public static var opaque_Sequence_Iterator: Any.Type {
        return Iterator.self
    }
    
    public static var opaque_Sequence_Iterator_Element: Any.Type {
        return Element.self
    }
    
    public func opaque_Sequence_makeIterator() -> opaque_IteratorProtocol {
        return makeIterator().iteratorOnly
    }

    public func opaque_Sequence_toAnySequence() -> Any {
        return AnySequence({ self.makeIterator() })
    }
    
    public func toOpaque() -> AnySequence<Any> {
        return AnySequence(lazy.map({ $0 }))
    }
}

extension opaque_Sequence where Self: Sequence, Self.Iterator: opaque_IteratorProtocol {
    public func opaque_Sequence_makeIterator() -> opaque_IteratorProtocol {
        return makeIterator()
    }
}
