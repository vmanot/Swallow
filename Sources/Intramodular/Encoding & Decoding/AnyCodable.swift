//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum AnyCodable {
    case none
    case bool(Bool)
    case number(AnyNumber)
    case string(String)
    case date(Date)
    case url(URL)
    case data(Data)
    case array([AnyCodable])
    case dictionary([AnyCodingKey: AnyCodable])
    case encodable(Encodable)
    case _unsafe(Any)
    
    public init(_ encodable: Encodable) {
        self = .encodable(encodable)
    }
    
    public init(_ value: Any) throws {
        switch value {
            case let value as AnyCodableConvertible:
                self = try value.toAnyCodable()
            case let value as Encodable:
                self = .encodable(value)
            default:
                self = try cast((value as? NSCoding).unwrap(), to: AnyCodable.self)
        }
    }
}

// MARK: - Conformances -

extension AnyCodable: AnyCodableConvertible {
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
            } else if let value = try? container.decode(Date.self) {
                self = .date(value)
            } else if let value = try? container.decode(URL.self) {
                self = .url(value)
            } else if let value = try? container.decode(Data.self) {
                self = .data(value)
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
                try encoder.encodeSingleNil()
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
            case .data(let value):
                try value.encode(to: encoder)
            case .array(let value):
                try value.encode(to: encoder)
            case .dictionary(let value):
                try value.encode(to: encoder)
            case .encodable(let value):
                try value.encode(to: encoder)
            case ._unsafe(let value): do {
                if let value = value as? Encodable {
                    try value.encode(to: encoder)
                } else {
                    assertionFailure()
                }
            }
        }
    }
}

extension AnyCodable: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.bool(let x), .bool(let y)):
                return x == y
            case (.number(let x), .number(let y)):
                return x == y
            case (.string(let x), .string(let y)):
                return x == y
            case (.date(let x), .date(let y)):
                return x == y
            case (.url(let x), .url(let y)):
                return x == y
            case (.array(let x), .array(let y)):
                return x == y
            case (.dictionary(let x), .dictionary(let y)):
                return x == y
            case (.encodable, .encodable):
                fatalError(reason: .unimplemented)
            case (._unsafe, ._unsafe):
                fatalError(reason: .unimplemented)
            default:
                return false
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

extension AnyCodable: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .none:
                hasher.combine(Empty())
            case .bool(let value):
                hasher.combine(value)
            case .number(let value):
                hasher.combine(value)
            case .string(let value):
                hasher.combine(value)
            case .date(let value):
                hasher.combine(value)
            case .url(let value):
                hasher.combine(value)
            case .data(let value):
                hasher.combine(value)
            case .array(let value):
                hasher.combine(value)
            case .dictionary(let value):
                hasher.combine(value)
            case .encodable:
                fatalError(reason: .unimplemented)
            case ._unsafe:
                fatalError(reason: .unimplemented)
        }
    }
}

extension AnyCodable: ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSCoding
    
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
                return try value.toNSNumber()
            case .string(let value):
                return value as NSString
            case .date(let value):
                return value as NSDate
            case .url(let value):
                return value as NSURL
            case .data(let value):
                return value as NSData
            case .array(let value):
                return try value.map({ try $0.bridgeToObjectiveC() }) as NSArray
            case .dictionary(let value):
                return try value.mapKeysAndValues({ $0.stringValue }, { try $0.bridgeToObjectiveC() }) as NSDictionary
            case .encodable(let value):
                return try ObjectEncoder().encode(value)
            case ._unsafe:
                return try Self.encodable(self).bridgeToObjectiveC()
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
