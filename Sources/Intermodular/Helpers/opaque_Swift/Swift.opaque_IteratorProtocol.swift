//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias IteratorProtocol2 = opaque_IteratorProtocol & IteratorProtocol

public protocol opaque_IteratorProtocol: AnyProtocol {
    static var opaque_IteratorProtocol_Element: Any.Type { get }
    
    mutating func opaque_IteratorProtocol_next() -> Any?
    
    func opaque_IteratorProtocol_toAnyIterator() -> Any
    func toOpaque() -> AnyIterator<Any>
}

extension opaque_IteratorProtocol where Self: IteratorProtocol {
    public static var opaque_IteratorProtocol_Element: Any.Type {
        return Element.self
    }
    
    public mutating func opaque_IteratorProtocol_next() -> Any? {
        return next().map({ $0 })
    }
    
    public func opaque_IteratorProtocol_toAnyIterator() -> Any {
        return AnyIterator(self)
    }
    
    public func toOpaque() -> AnyIterator<Any> {
        var copyOfSelf = self
        
        return .init({ copyOfSelf.next() })
    }
}
