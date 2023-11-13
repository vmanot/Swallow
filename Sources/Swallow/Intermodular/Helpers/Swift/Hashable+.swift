//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol HashEquatable: Hashable {
    
}

extension HashEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

/// A type that forwards an object identity or the `Hashable` implementation.
public struct _HashableOrObjectIdentifier: Hashable {
    public let type: ObjectIdentifier
    public let base: AnyHashable
    
    public init?(from base: Any) {
        self.type = ObjectIdentifier(Swift.type(of: base))
        
        if let base = base as? any Hashable {
            self.base = base.erasedAsAnyHashable
        } else if swift_isClassType(Swift.type(of: base)) {
            self.base = ObjectIdentifier(try! cast(base, to: AnyObject.self))
        } else {
            return nil
        }
    }
}
