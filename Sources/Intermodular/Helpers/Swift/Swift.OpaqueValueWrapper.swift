//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_OpaqueValueWrapper: AnyProtocol {
    var opaque_OpaqueValueWrapper_opaqueValue: Any { get }
    
    static func opaque_OpaqueValueWrapper_init(opaqueValue: Any) -> opaque_OpaqueValueWrapper?
}

extension opaque_OpaqueValueWrapper where Self: OpaqueValueWrapper {
    public var opaque_OpaqueValueWrapper_opaqueValue: Any {
        return opaqueValue
    }
    
    public static func opaque_OpaqueValueWrapper_init(opaqueValue: Any) -> opaque_OpaqueValueWrapper? {
        return (-?>opaqueValue).map({ self.init(opaqueValue: $0) })
    }
}

public protocol OpaqueValueWrapper: opaque_OpaqueValueWrapper, FailableOpaqueValueWrapper {
    var opaqueValue: OpaqueValue { get }

    init(opaqueValue: OpaqueValue)
}
