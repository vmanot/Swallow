//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum AnyCodable: @unchecked Sendable {
    case none
    case bool(Bool)
    case number(AnyNumber)
    case string(String)
    case date(Date)
    case url(URL)
    case data(Data)
    case array([AnyCodable])
    case dictionary([AnyCodingKey: AnyCodable])
    
    /// Do **not** use this case yourself. This is meant for internal use only.
    case _lazy(Codable)
    
    public static func number<T: BinaryInteger>(_ number: T) -> Self {
        .number(AnyNumber(number))
    }
    
    public static func number<T: FloatingPoint>(_ number: T) -> Self {
        .number(AnyNumber(number))
    }
    
    @_disfavoredOverload
    public static func dictionary(_ dictionary: [String: AnyCodable]) -> Self {
        .dictionary(dictionary.mapKeys(AnyCodingKey.init(stringValue:)))
    }
}

// MARK: - Initializers

extension AnyCodable {
    public init(_ value: Codable) {
        if let value = value as? (AnyCodableConvertible & Codable) {
            do {
                self = try value.toAnyCodable()
            } catch {
                assertionFailure(error)
                
                self = ._lazy(value)
            }
        } else {
            self = ._lazy(value)
        }
    }
    
    public init(lazy value: Codable) {
        self = ._lazy(value)
    }
    
    public init(_ value: Any) throws {
        switch value {
            case let value as AnyCodableConvertible:
                self = try value.toAnyCodable()
            case let value as Codable:
                self = ._lazy(value)
            default:
                self = try cast((value as? NSCoding).unwrap(), to: AnyCodable.self)
        }
    }
    
    public init(
        destructuring value: Encodable
    ) throws {
        self = try ObjectDecoder().decode(
            AnyCodable.self,
            from: ObjectEncoder().encode(value)
        )
    }
}

// MARK: - Extensions

extension AnyCodable {
    public var _dictionaryValue: [AnyCodingKey: AnyCodable]? {
        get {
            guard case .dictionary(let value) = self else {
                return nil
            }
            
            return value
        } set {
            guard let newValue else {
                assertionFailure(.illegal)
                
                return
            }
            
            self = .dictionary(newValue)
        }
    }
    
    public var _arrayValue: [AnyCodable]? {
        guard case .array(let value) = self else {
            return nil
        }
        
        return value
    }
    
    public var value: (any Codable)? {
        switch self {
            case .none:
                return nil
            case .bool(let value):
                return value
            case .number(let value):
                return value
            case .string(let value):
                return value
            case .date(let value):
                return value
            case .url(let value):
                return value
            case .data(let value):
                return value
            case .array(let value):
                return value
            case .dictionary(let value):
                return value
            case ._lazy(let value):
                return value
        }
    }
}

extension AnyCodable {
    public subscript(key codingKey: AnyCodingKey) -> AnyCodable? {
        get throws {
            let value = try cast(self.value, to: [AnyCodingKey: AnyCodable].self)
            
            return value[codingKey]
        }
    }
    
    public subscript(key codingKey: String) -> AnyCodable? {
        get throws {
            try self[key: AnyCodingKey(stringValue: codingKey)]
        }
    }
    
    struct DictionaryKeyMatchingError: CustomStringConvertible, Error {
        let data: AnyCodable
        let key: String
        
        public var description: String {
            "Failed to find key: \(key) in data:\n\(data)"
        }
    }
    
    public subscript(
        key codingKey: String,
        caseInsensitive caseInsensitive: Bool
    ) -> AnyCodable? {
        get throws {
            do {
                let key = AnyCodingKey(stringValue: codingKey).lowercased()
                let value = try cast(self.value, to: [AnyCodingKey: AnyCodable].self)
                let matchedKey: AnyCodingKey = try value.keys.firstAndOnly(where: { $0.lowercased() == key }).unwrap()
                
                return value[matchedKey]
            } catch {
                throw DictionaryKeyMatchingError(data: self, key: codingKey)
            }
        }
    }
}

// MARK: - Conformances

extension AnyCodable: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        return self
    }
}

extension AnyCodable: Codable {
    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? ObjectDecoder.Decoder {
            if let object = decoder.object as? [String: Any] {
                _ = object
                
                self = Self.dictionary(try Dictionary<String, AnyCodable>(from: decoder))
                
                return
            }
        }
        
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
                var container = encoder.singleValueContainer()
                
                try container.encodeNil()
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
            case .dictionary(let value): do {
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                
                for (key, value) in value {
                    try container.encode(value, forKey: key)
                }
            }
            case ._lazy(let value):
                try value.encode(to: encoder)
        }
    }
}

extension AnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let value = value {
            if let value = value as? CustomDebugStringConvertible {
                return value.debugDescription
            } else {
                return String(describing: value)
            }
        } else {
            return "(No value)"
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        if let value = value {
            return String(describing: value)
        } else {
            return ""
        }
    }
    
    public var prettyPrintedDescription: String {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try! String(data: try encoder.encode(self), using: String.DataDecodingStrategy(encoding: .utf8))
    }
}

extension AnyCodable: Decoder {
    public var codingPath: [CodingKey] {
        []
    }
    
    public var userInfo: [CodingUserInfoKey: Any] {
        [:]
    }
    
    public func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        do {
            return try _decoder().container(keyedBy: type)
        } catch {
            throw error
        }
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        do {
            return try _decoder().unkeyedContainer()
        } catch {
            throw error
        }
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        do {
            return try _decoder().singleValueContainer()
        } catch {
            throw error
        }
    }
    
    private func _decoder() throws -> ObjectDecoder.Decoder {
        let decoder = try ObjectDecoder().decode(DecoderUnwrapper.self, from: self).value
        
        return try cast(decoder, to: ObjectDecoder.Decoder.self)
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
                
            default: do {
                do {
                    switch (lhs, rhs) {
                        case (._lazy(let lhs), ._lazy(let rhs)):
                            return try AnyCodable(destructuring: lhs) == AnyCodable(destructuring: rhs)
                        case (._lazy(let lhs), _):
                            return try AnyCodable(destructuring: lhs) == rhs
                        case (_, ._lazy(let rhs)):
                            return try lhs == AnyCodable(destructuring: rhs)
                        default:
                            return false
                    }
                } catch {
                    assertionFailure(error)
                    
                    return false
                }
            }
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
                hasher.combine(EmptyValue())
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
            case ._lazy(let value):
                if let value = value as? any Hashable {
                    value.hash(into: &hasher)
                } else {
                    do {
                        try hasher.combine(AnyCodable(destructuring: value))
                    } catch {
                        assertionFailure(error)
                    }
                }
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
                return .dictionary(
                    try cast(
                        value as [NSObject : AnyObject],
                        to: [String: NSCoding].self
                    )
                    .mapKeysAndValues(
                        {
                            AnyCodingKey(stringValue: try cast($0, to: NSString.self) as String)
                        },
                        { 
                            try AnyCodable.bridgeFromObjectiveC($0)
                        }
                    )
                )
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
            case ._lazy(let value):
                return try Self(destructuring: value)._bridgeToObjectiveC()
        }
    }
}

/*struct _Foundation_JSONDecoderImpl {
 let decodingContainerKind: _DecodingContainerKind?
 
 init?(from decoder: Decoder) {
 let typeName = String(describing: Swift.type(of: decoder))
 
 guard typeName.contains("Foundation") && typeName.contains("JSONDecoderImpl") else {
 return nil
 }
 
 let mirror = Mirror(reflecting: decoder)
 
 if let _ = mirror.descendant("values") as? (any _ArrayProtocol) {
 self.decodingContainerKind = .unkeyed
 }
 guard String(describing: Swift.type(of: decoder))
 }
 }*/
