//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A type-erased coding key.
public struct AnyCodingKey: CodingKey, StringConvertible {
    private enum Storage {
        case string(String)
        case integer(Int)
        case stringAndInteger(String, Int)
        case opaque(CodingKey)
    }
    
    private let storage: Storage
    
    public var stringValue: String {
        switch storage {
            case .string(let value):
                return value
            case .integer(let value):
                return .init(value)
            case .stringAndInteger(let value, _):
                return value
            case .opaque(let value):
                return value.stringValue
        }
    }
    
    public var intValue: Int? {
        switch storage {
            case .string:
                return nil
            case .integer(let value):
                return value
            case .stringAndInteger(_, let value):
                return value
            case .opaque(let value):
                return value.intValue
        }
    }
    
    public init(stringValue: String) {
        storage = .string(stringValue)
    }
    
    public init(intValue: Int) {
        storage = .integer(intValue)
    }
    
    public init(erasing key: CodingKey) {
        storage = .opaque(key)
    }
}

// MARK: - Conformances

extension AnyCodingKey: _UnwrappableTypeEraser {
    public func _unwrapBase() -> CodingKey {
        switch storage {
            case .string:
                return AnyStringKey(stringValue: stringValue)
            case .integer:
                return AnyStringKey(stringValue: stringValue)
            case .stringAndInteger:
                return AnyStringKey(stringValue: stringValue)
            case .opaque(let key):
                return key
        }
    }
}

extension AnyCodingKey: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self.storage = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self.storage = .integer(value)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch storage {
            case .string(let value):
                try value.encode(to: encoder)
            case .integer(let value):
                try value.encode(to: encoder)
            case .stringAndInteger(let value, _):
                try value.encode(to: encoder)
            case .opaque(let value):
                try value.stringValue.encode(to: encoder)
        }
    }
}

extension AnyCodingKey: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}

extension AnyCodingKey: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public static func == (lhs: Self, rhs: any CodingKey) -> Bool {
        lhs == AnyCodingKey(erasing: rhs)
    }
}

extension AnyCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(intValue: value)
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

extension AnyCodingKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        stringValue.hash(into: &hasher)
    }
}
