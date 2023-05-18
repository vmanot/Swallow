//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public enum ObjCPropertyAttribute {
    case readOnly
    case copy
    case retain
    case nonatomic
    case dynamic
    case weak
    case garbageCollectionEligible
    case getter(ObjCSelector)
    case setter(ObjCSelector)
    case oldStyleType(ObjCTypeEncoding)
    case unknown(ObjCPropertyAttributeKeyValuePair)
}

extension ObjCPropertyAttribute {
    public var key: String {
        switch self {
            case .readOnly:
                return "R"
            case .copy:
                return "C"
            case .retain:
                return "&"
            case .nonatomic:
                return "N"
            case .dynamic:
                return "D"
            case .weak:
                return "W"
            case .garbageCollectionEligible:
                return "P"
            case .getter(_):
                return "G"
            case .setter(_):
                return "S"
            case .oldStyleType(_):
                return "t"
            case .unknown(let value):
                return value.name
        }
    }
    
    public var value: String? {
        switch self {
            case .getter(let value):
                return value.rawValue
            case .setter(let value):
                return value.rawValue
            case .oldStyleType(let value):
                return value.value
            case .unknown(let value):
                return .init(cString: value.value.value)
            
            default:
                return nil
        }
    }
    
    public init(key: String, value: String) {
        switch key {
            case "R":
                self = .readOnly
            case "C":
                self = .copy
            case "&":
                self = .retain
            case "N":
                self = .nonatomic
            case "D":
                self = .dynamic
            case "W":
                self = .weak
            case "P":
                self = .garbageCollectionEligible
            case "G":
                self = .getter(.init(rawValue: value))
            case "S":
                self = .setter(.init(rawValue: value))
            case "t":
                self = .oldStyleType(.init(value))
            
            default:
                self = .unknown(.init(.init(name: key.nullTerminatedUTF8String().value, value: value.nullTerminatedUTF8String().value)))
        }
    }
    
    public init(_ keyValuePair: ObjCPropertyAttributeKeyValuePair) {
        self.init(key: keyValuePair.name, value: .init(cString: keyValuePair.value.value))
    }
}

// MARK: - Conformances

extension ObjCPropertyAttribute: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
            case .readOnly:
                return "readonly"
            case .copy:
                return "copy"
            case .retain:
                return "retain"
            case .nonatomic:
                return "nonatomic"
            case .dynamic:
                return "@dynamic"
            case .weak:
                return "__weak"
            case .garbageCollectionEligible:
                return "?(P)"
            case .getter(let name):
                return "getter=" + name.rawValue
            case .setter(let name):
                return "setter=" + name.rawValue
            case .oldStyleType(let string):
                return "?(t=\(string))"
            case .unknown(let value):
                return "?(\(value.name)=" + String(cString: value.value.value)
        }
    }
}

extension ObjCPropertyAttribute: CustomStringConvertible {
    public var description: String {
        key + (value ?? .init())
    }
}

extension ObjCPropertyAttribute: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)!
    }
}

extension ObjCPropertyAttribute: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension ObjCPropertyAttribute: LosslessStringConvertible {
    public init?(_ description: String) {
        guard !description.isEmpty else {
            return nil
        }
        
        self.init(key: String(description.first!), value: .init(description.dropFirst()))
    }
}
