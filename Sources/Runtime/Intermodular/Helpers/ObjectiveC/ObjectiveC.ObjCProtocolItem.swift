//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public enum ObjCProtocolItem {
    case instanceMethod(ObjCMethodDescription)
    case classMethod(ObjCMethodDescription)
    case optionalInstanceMethod(ObjCMethodDescription)
    case optionalClassMethod(ObjCMethodDescription)

    case instanceProperty(ObjCProperty)
    case classProperty(ObjCProperty)
    case optionalInstanceProperty(ObjCProperty)
    case optionalClassProperty(ObjCProperty)

    case adoptedProtocol(ObjCProtocol)
}

// MARK: - Conformances

extension ObjCProtocolItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .instanceMethod(let value):
            hasher.combine(ObjectIdentifier(ObjCMethodDescription.self))
            hasher.combine(value)
        case .classMethod(let value):
            hasher.combine(ObjectIdentifier((ObjCClass, ObjCMethodDescription).self))
            hasher.combine(value)
        case .optionalInstanceMethod(let value):
            hasher.combine(ObjectIdentifier(Optional<ObjCMethodDescription>.self))
            hasher.combine(value)
        case .optionalClassMethod(let value):
            hasher.combine(ObjectIdentifier(Optional<(ObjCClass, ObjCMethodDescription)>.self))
            hasher.combine(value)
        case .instanceProperty(let value):
            hasher.combine(ObjectIdentifier(ObjCProperty.self))
            hasher.combine(value)
        case .classProperty(let value):
            hasher.combine(ObjectIdentifier((ObjCClass, ObjCProperty).self))
            hasher.combine(value)
        case .optionalInstanceProperty(let value):
            hasher.combine(ObjectIdentifier(Optional<ObjCProperty>.self))
            hasher.combine(value)
        case .optionalClassProperty(let value):
            hasher.combine(ObjectIdentifier(Optional<(ObjCClass, ObjCProperty)>.self))
            hasher.combine(value)
        case .adoptedProtocol(let value):
            hasher.combine(ObjectIdentifier(ObjCProtocol.self))
            hasher.combine(value)
        }
    }
}

extension ObjCProtocolItem: Named {
    public var name: String {
        switch self {
        case .instanceMethod(let value):
            return value.name
        case .classMethod(let value):
            return value.name
        case .optionalInstanceMethod(let value):
            return value.name
        case .optionalClassMethod(let value):
            return value.name

        case .instanceProperty(let value):
            return value.name
        case .classProperty(let value):
            return value.name
        case .optionalInstanceProperty(let value):
            return value.name
        case .optionalClassProperty(let value):
            return value.name

        case .adoptedProtocol(let value):
            return value.name
        }
    }
}
