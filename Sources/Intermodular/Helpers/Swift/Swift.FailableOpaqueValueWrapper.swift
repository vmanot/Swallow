//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_FailableOpaqueValueWrapper: AnyProtocol {
    var _opaque_FailableOpaqueValueWrapper_opaqueValue: Any { get }
    
    static func _opaque_FailableOpaqueValueWrapper_init(opaqueValue: Any) -> _opaque_FailableOpaqueValueWrapper??
}

extension _opaque_FailableOpaqueValueWrapper where Self: FailableOpaqueValueWrapper {
    public var _opaque_FailableOpaqueValueWrapper_opaqueValue: Any {
        return opaqueValue
    }
    
    public static func _opaque_FailableOpaqueValueWrapper_init(opaqueValue: Any) -> _opaque_FailableOpaqueValueWrapper?? {
        return (-?>opaqueValue).map({ self.init(opaqueValue: $0) })
    }
}

public protocol FailableOpaqueValueWrapper: _opaque_FailableOpaqueValueWrapper {
    associatedtype OpaqueValue
    
    var opaqueValue: OpaqueValue { get }
    
    init(uncheckedOpaqueValue: OpaqueValue)
    
    init?(opaqueValue: OpaqueValue)
}

extension FailableOpaqueValueWrapper {
    public init(uncheckedOpaqueValue opaqueValue: OpaqueValue) {
        self = Self(opaqueValue: opaqueValue)!
    }
}
