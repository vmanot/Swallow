//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias IteratorProtocol2 = _opaque_IteratorProtocol & IteratorProtocol

public protocol _opaque_IteratorProtocol: AnyProtocol {
    static var _opaque_IteratorProtocol_Element: Any.Type { get }
    
    mutating func _opaque_IteratorProtocol_next() -> Any?
    
    func _opaque_IteratorProtocol_toAnyIterator() -> Any
    func toOpaque() -> AnyIterator<Any>
}

extension _opaque_IteratorProtocol where Self: IteratorProtocol {
    public static var _opaque_IteratorProtocol_Element: Any.Type {
        return Element.self
    }
    
    public mutating func _opaque_IteratorProtocol_next() -> Any? {
        return next().map({ $0 })
    }
    
    public func _opaque_IteratorProtocol_toAnyIterator() -> Any {
        return AnyIterator(self)
    }
    
    public func toOpaque() -> AnyIterator<Any> {
        var copyOfSelf = self
        
        return .init({ copyOfSelf.next() })
    }
}
