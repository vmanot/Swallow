//
// Copyright (c) Vatsal Manot
//

import Swift

extension Optional: _opaque_Optional {
    public static var _opaque_Optional_Wrapped: Any.Type {
        return Wrapped.self
    }
    
    public var isNil: Bool {
        return self == nil
    }

    public var _opaque_Optional_wrapped: Any? {
        return flatMap(Optional<Any>.some)
    }
    
    public init(none: Void) {
        self = .none
    }

    public mutating func _opaque_Optional_set(wrapped: Any?) -> Void? {
        return (-?>wrapped).map({ self = $0 })
    }
}
