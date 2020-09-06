//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_OpaqueValueWrapper: AnyProtocol {
    var _opaque_OpaqueValueWrapper_opaqueValue: Any { get }
    
    static func _opaque_OpaqueValueWrapper_init(opaqueValue: Any) -> _opaque_OpaqueValueWrapper?
}

extension _opaque_OpaqueValueWrapper where Self: OpaqueValueWrapper {
    public var _opaque_OpaqueValueWrapper_opaqueValue: Any {
        return opaqueValue
    }
    
    public static func _opaque_OpaqueValueWrapper_init(opaqueValue: Any) -> _opaque_OpaqueValueWrapper? {
        return (-?>opaqueValue).map({ self.init(opaqueValue: $0) })
    }
}

public protocol OpaqueValueWrapper: _opaque_OpaqueValueWrapper, FailableOpaqueValueWrapper {
    var opaqueValue: OpaqueValue { get }

    init(opaqueValue: OpaqueValue)
}
