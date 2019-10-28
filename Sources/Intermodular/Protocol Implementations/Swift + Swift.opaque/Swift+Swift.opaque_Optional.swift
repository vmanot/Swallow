//
// Copyright (c) Vatsal Manot
//

import Swift

extension Optional: opaque_Optional {
    public static var opaque_Optional_Wrapped: Any.Type {
        return Wrapped.self
    }
    
    public var isNil: Bool {
        return self == nil
    }

    public var opaque_Optional_wrapped: Any? {
        return flatMap(Optional<Any>.some)
    }
    
    public init(none: Void) {
        self = .none
    }

    public mutating func opaque_Optional_set(wrapped: Any?) -> Void? {
        return (-?>wrapped).map({ self = $0 })
    }
}
