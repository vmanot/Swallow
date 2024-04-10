//
// Copyright (c) Vatsal Manot
//

import Swift

@frozen
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
        self = x._opaqueIdentifier
    }
}

// MARK: - Auxiliary

extension Identifiable {
    public var _opaqueIdentifier: _OpaqueIdentifier {
        _OpaqueIdentifier(from: self)
    }
}
