//
// Copyright (c) Vatsal Manot
//

import Swift

public struct OpaqueIdentifier: Hashable {
    private let source: ObjectIdentifier
    private let _base: AnyHashable
    
    public var base: any Hashable {
        _base.base as! any Hashable
    }
    
    public init<T: Identifiable>(from x: T) {
        self.source = .init(type(of: x))
        self._base = x.id
    }
    
    @_disfavoredOverload
    public init(from x: any Identifiable) {
        self.source = .init(type(of: x))
        self._base = x.id.erasedAsAnyHashable
    }
}
