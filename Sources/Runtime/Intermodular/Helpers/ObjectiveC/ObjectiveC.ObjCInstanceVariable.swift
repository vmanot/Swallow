//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCInstanceVariable: Wrapper {
    public typealias Value = Ivar
    
    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

extension ObjCInstanceVariable {
    public var offset: Int {
        return ivar_getOffset(value)
    }

    public var typeEncoding: ObjCTypeEncoding {
        return .init(String(utf8String: ivar_getTypeEncoding(value))!)
    }
}

// MARK: - Conformances

extension ObjCInstanceVariable: CustomStringConvertible {
    public var description: String {
        return name
    }
}

extension ObjCInstanceVariable: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(offset)
        hasher.combine(typeEncoding)
    }
}

extension ObjCInstanceVariable: Named {
    public var name: String {
        return String(utf8String: ivar_getName(value))!
    }
}
