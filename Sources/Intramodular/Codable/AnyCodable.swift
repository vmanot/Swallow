//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum AnyCodable: _opaque_Hashable, Hashable {
    case none
    case bool(Bool)
    case number(AnyNumber)
    case string(String)
    case date(Date)
    case url(URL)
    case array([AnyCodable])
    case dictionary([AnyCodingKey: AnyCodable])
    case objectiveC(AnyHashable)
    case encodable(AnyHashableEncodable)
    
    public init(_ value: Any) throws {
        switch value {
            case let value as AnyCodableConvertible:
                self = try value.toAnyCodable()
            case let value as (_opaque_Hashable & NSObject & NSCoding):
                self = .objectiveC(value.toAnyHashable())
            case let value as (_opaque_Hashable & Encodable):
                self = .encodable(.init(value))
            default:
                self = try cast((value as? NSCoding).unwrap(), to: AnyCodable.self)
        }
    }
}

// MARK: - Protocol Implementations -

extension AnyCodable: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return self
    }
}

extension AnyCodable: Codable {
    public init(from decoder: Decoder) throws {
        if var container = try? decoder.unkeyedContainer() {
            var value: [AnyCodable] = []
            
            container.count.map({ value.reserveCapacity($0) })
            
            while !container.isAtEnd {
                value.append(try container.decode(AnyCodable.self))
            }
            
            self = .array(value)
        } else if let container = try? decoder.container(keyedBy: AnyCodingKey.self) {
            var value: [AnyCodingKey: AnyCodable] = [:]
            
            value.reserveCapacity(container.allKeys.count)
            
            for key in container.allKeys {
                value[key] = try container.decode(AnyCodable.self, forKey: key)
            }
            
            self = .dictionary(value)
        } else if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .none
            } else if let value = try? container.decode(Bool.self) {
                self = .bool(value)
            } else if let value = try? container.decode(AnyNumber.self) {
                self = .number(value)
            } else if let value = try? container.decode(String.self) {
                self = .string(value)
            } else if let value = try? container.decode([AnyCodable].self) {
                self = .array(value)
            } else if let value = try? container.decode([AnyCodingKey: AnyCodable].self) {
                self = .dictionary(value)
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "..."
                    )
                )
            }
        } else {
            self = .none
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .none:
                try encoder.encodeNil()
            case .bool(let value):
                try value.encode(to: encoder)
            case .number(let value):
                try value.encode(to: encoder)
            case .string(let value):
                try value.encode(to: encoder)
            case .date(let value):
                try value.encode(to: encoder)
            case .url(let value):
                try value.encode(to: encoder)
            case .array(let value):
                try value.encode(to: encoder)
            case .dictionary(let value):
                try value.encode(to: encoder)
            case .objectiveC(let value):
                TODO.unimplemented
            case .encodable(let value):
                try value.encode(to: encoder)
        }
    }
}

extension AnyCodable: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AnyCodable...) {
        self = .array(elements)
    }
}

extension AnyCodable: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension AnyCodable: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (AnyCodingKey, AnyCodable)...) {
        self = .dictionary(.init(elements))
    }
}

extension AnyCodable: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(.init(value))
    }
}

extension AnyCodable: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(.init(value))
    }
}

extension AnyCodable: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

extension AnyCodable: ExpressibleByStringLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension AnyCodable: ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSCoding
    public typealias ObjectiveCType = NSCoding
    
    public static func bridgeFromObjectiveC(_ source: ObjectiveCType) throws -> AnyCodable {
        switch source {
            case let value as NSNumber:
                return .number(.init(value))
            case let value as NSString:
                return .string(.init(value))
            case let value as NSDate:
                return .date(value as Date)
            case let value as NSURL:
                return .url(value as URL)
            case let value as NSArray:
                return .array(try cast(value as [AnyObject], to: [NSCoding].self).map({ try AnyCodable.bridgeFromObjectiveC($0) }))
            case let value as NSDictionary:
                return .dictionary(try cast(value as [NSObject : AnyObject], to: [String: NSCoding].self).mapKeysAndValues({ .init(stringValue: try cast($0, to: NSString.self) as String) }, { try AnyCodable.bridgeFromObjectiveC($0) }))
            default:
                throw RuntimeCastError.invalidTypeCast(
                    from: type(of: source),
                    to: AnyCodable.self,
                    value: source,
                    location: .unavailable
                )
        }
    }
    
    public func bridgeToObjectiveC() throws -> ObjectiveCType {
        switch self {
            case .none:
                return NSNull()
            case .bool(let value):
                return value as NSNumber
            case .number(let value):
                return value.toNSNumber()
            case .string(let value):
                return value as NSString
            case .date(let value):
                return value as NSDate
            case .url(let value):
                return value as NSURL
            case .array(let value):
                return try value.map({ try $0.bridgeToObjectiveC() }) as NSArray
            case .dictionary(let value):
                return try value.mapKeysAndValues({ $0.stringValue }, { try $0.bridgeToObjectiveC() }) as NSDictionary
            case .objectiveC(let value):
                return value.base as! NSCoding
            case .encodable(let value):
                return try ObjectEncoder().encode(value)
        }
    }
}

// MARK: - Helpers -

public struct AnyEncodable: Encodable {
    public let value: Encodable
    
    public init(_ value: Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

public struct AnyHashableEncodable: Encodable, Hashable {
    public let value: _opaque_Hashable & Encodable
    
    public init(_ value: _opaque_Hashable & Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}
