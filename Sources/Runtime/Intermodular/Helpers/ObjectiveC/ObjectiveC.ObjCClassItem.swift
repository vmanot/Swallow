//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public enum ObjCClassItem: Hashable {
    case instanceVariable(ObjCInstanceVariable)
    case method(ObjCMethod)
    case property(ObjCProperty)
    case `protocol`(ObjCProtocol)
    
    public init(_ value: ObjCInstanceVariable) {
        self = .instanceVariable(value)
    }
    
    public init(_ value: ObjCMethod) {
        self = .method(value)
    }
    
    public init(_ value: ObjCProperty) {
        self = .property(value)
    }
    
    public init(_ value: ObjCProtocol) {
        self = .`protocol`(value)
    }
}

// MARK: - Conformances

extension ObjCClassItem: CustomStringConvertible {
    public var description: String {
        switch self {
            case .instanceVariable(let value):
                return value.description
            case .method(let value):
                return value.description
            case .property(let value):
                return value.description
            case .`protocol`(let value):
                return value.description
        }
    }
}

extension ObjCClassItem: Named {
    public var name: String {
        switch self {
            case .instanceVariable(let value):
                return value.name
            case .method(let value):
                return value.name
            case .property(let value):
                return value.name
            case .`protocol`(let value):
                return value.name
        }
    }
}
