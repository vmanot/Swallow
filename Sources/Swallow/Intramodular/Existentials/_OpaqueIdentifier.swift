//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _OpaqueIdentifier: Hashable, @unchecked Sendable {
    private let sourceType: ObjectIdentifier
    private let _base: AnyHashable
    
    public var base: any Hashable {
        _base.base as! any Hashable
    }
    
    public init<T: Identifiable>(from x: T) where T.ID: Sendable {
        self.sourceType = .init(type(of: x))
        self._base = x.id
    }
    
    @_disfavoredOverload
    public init(from x: any Identifiable) {
        self.sourceType = .init(type(of: x))
        self._base = x.id.erasedAsAnyHashable
    }
}
