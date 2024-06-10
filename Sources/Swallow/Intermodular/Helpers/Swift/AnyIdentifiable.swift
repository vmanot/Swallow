//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _AnyIdentifiableIdentifier: Hashable {
    @_HashableExistential
    public var _swiftType: Any.Type
    public let id: AnyHashable
    
    public init<T>(from x: T) where T: Identifiable {
        self._swiftType = type(of: x)
        self.id = x.id
    }
}

public struct AnyIdentifiable<ID>: Identifiable {
    public let base: any Identifiable<ID>
    
    public var id: AnyHashable {
        base._Identifiable_opaque_id
    }
    
    public init(erasing base: any Identifiable<ID>) {
        self.base = base
    }
}

public struct _ObjectIdentifierIdentified<Object>: Hashable {
    public let base: Object
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(try! cast(base, to: AnyObject.self))
    }
    
    public init(_ base: Object) {
        self.base = base
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id.hashValue == rhs.id.hashValue
    }
}

extension _ObjectIdentifierIdentified: Sendable where Object: Sendable {
    
}
