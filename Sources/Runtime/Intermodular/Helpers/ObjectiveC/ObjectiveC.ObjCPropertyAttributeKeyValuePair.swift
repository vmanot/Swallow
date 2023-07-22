//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCPropertyAttributeKeyValuePair: CustomStringConvertible, Wrapper {
    public typealias Value = objc_property_attribute_t
    
    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances

extension ObjCPropertyAttributeKeyValuePair: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value.name)
        hasher.combine(value.value)
    }
}

extension ObjCPropertyAttributeKeyValuePair: Named {
    public var name: String {
        get {
            String(utf8String: value.name)
        } set {
            value.name = .init(newValue.nullTerminatedUTF8String())
        }
    }
}
