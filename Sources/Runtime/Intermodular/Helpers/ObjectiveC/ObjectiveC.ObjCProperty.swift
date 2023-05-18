//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCProperty: CustomStringConvertible, Wrapper {
    public typealias Value = objc_property_t
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

extension ObjCProperty {
    public var attributeKeyValuePairs: AnyRandomAccessCollection<ObjCPropertyAttributeKeyValuePair> {
        return objc_realizeListAllocator({ property_copyAttributeList($0, $1) }, value)
    }
    
    public var attributes: AnyRandomAccessCollection<ObjCPropertyAttribute> {
        return .init(attributeKeyValuePairs.lazy.map({ .init($0) }))
    }

    public var isWeak: Bool {
        return attributes.contains(.weak)
    }
}

// MARK: - Conformances

extension ObjCProperty: Named {
    public var name: String {
        return .init(utf8String: property_getName(value))
    }
}

extension ObjCProperty: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(HashableSequence(attributeKeyValuePairs))
    }
}
