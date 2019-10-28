//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_FailableOpaqueValueWrapper: AnyProtocol {
    var opaque_FailableOpaqueValueWrapper_opaqueValue: Any { get }
    
    static func opaque_FailableOpaqueValueWrapper_init(opaqueValue: Any) -> opaque_FailableOpaqueValueWrapper??
}

extension opaque_FailableOpaqueValueWrapper where Self: FailableOpaqueValueWrapper {
    public var opaque_FailableOpaqueValueWrapper_opaqueValue: Any {
        return opaqueValue
    }
    
    public static func opaque_FailableOpaqueValueWrapper_init(opaqueValue: Any) -> opaque_FailableOpaqueValueWrapper?? {
        return (-?>opaqueValue).map({ self.init(opaqueValue: $0) })
    }
}

public protocol FailableOpaqueValueWrapper: opaque_FailableOpaqueValueWrapper {
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
