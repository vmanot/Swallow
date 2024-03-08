//
// Copyright (c) Vatsal Manot
//

import CoreFoundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif
import Foundation
import Swift

public struct AnyNumber: Codable, Hashable, Sendable {
    private enum Storage: Codable, Hashable, Sendable {
        case bool(Bool)
        
        case double(Double)
        case float(Float)
        
        case cgFloat(CGFloat)
        
        case int(Int)
        case int8(Int8)
        case int16(Int16)
        case int32(Int32)
        case int64(Int64)
        
        case uint(UInt)
        case uint8(UInt8)
        case uint16(UInt16)
        case uint32(UInt32)
        case uint64(UInt64)
        
        case decimal(Decimal)
        
        case floatingPointLiteral(Double)
        case integerLiteral(Int)
        
        case opaque(any Number)
        
        public var rawValue: Any {
            switch self {
                case .bool(let value):
                    return value
                case .double(let value):
                    return value
                case .float(let value):
                    return value
                case .cgFloat(let value):
                    return value
                case .int(let value):
                    return value
                case .int8(let value):
                    return value
                case .int16(let value):
                    return value
                case .int32(let value):
                    return value
                case .int64(let value):
                    return value
                case .uint(let value):
                    return value
                case .uint8(let value):
                    return value
                case .uint16(let value):
                    return value
                case .uint32(let value):
                    return value
                case .uint64(let value):
                    return value
                case .decimal(let value):
                    return value
                case .floatingPointLiteral(let value):
                    return value
                case .integerLiteral(let value):
                    return value
                case .opaque(let value):
                    return value
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let value = try? container.decode(Double.self) {
                self = .double(value)
            } else if let value = try? container.decode(Float.self) {
                self = .float(value)
            } else if let value = try? container.decode(CGFloat.self) {
                self = .cgFloat(value)
            } else if let value = try? container.decode(Int.self) {
                self = .int(value)
            } else if let value = try? container.decode(Int8.self) {
                self = .int8(value)
            } else if let value = try? container.decode(Int16.self) {
                self = .int16(value)
            } else if let value = try? container.decode(Int32.self) {
                self = .int32(value)
            } else if let value = try? container.decode(Int64.self) {
                self = .int64(value)
            } else if let value = try? container.decode(UInt.self) {
                self = .uint(value)
            } else if let value = try? container.decode(UInt8.self) {
                self = .uint8(value)
            } else if let value = try? container.decode(UInt16.self) {
                self = .uint16(value)
            } else if let value = try? container.decode(UInt32.self) {
                self = .uint32(value)
            } else if let value = try? container.decode(UInt64.self) {
                self = .uint64(value)
            } else if let value = try? container.decode(Decimal.self) {
                self = .decimal(value)
            } else if let value = try? container.decode(Bool.self) {
                self = .bool(value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "..."))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
                case .bool(let value):
                    try container.encode(value)
                case .double(let value):
                    try container.encode(value)
                case .float(let value):
                    try container.encode(value)
                case .cgFloat(let value):
                    try container.encode(value)
                case .int(let value):
                    try container.encode(value)
                case .int8(let value):
                    try container.encode(value)
                case .int16(let value):
                    try container.encode(value)
                case .int32(let value):
                    try container.encode(value)
                case .int64(let value):
                    try container.encode(value)
                case .uint(let value):
                    try container.encode(value)
                case .uint8(let value):
                    try container.encode(value)
                case .uint16(let value):
                    try container.encode(value)
                case .uint32(let value):
                    try container.encode(value)
                case .uint64(let value):
                    try container.encode(value)
                case .decimal(let value):
                    try container.encode(value)
                case .floatingPointLiteral(let value):
                    try container.encode(value)
                case .integerLiteral(let value):
                    try container.encode(value)
                case .opaque(let value):
                    try container.encode(value)
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            ObjectIdentifier(type(of: rawValue)).hash(into: &hasher)
            
            switch self {
                case .bool(let value):
                    value.hash(into: &hasher)
                case .double(let value):
                    value.hash(into: &hasher)
                case .float(let value):
                    value.hash(into: &hasher)
                case .cgFloat(let value):
                    value.hash(into: &hasher)
                case .int(let value):
                    value.hash(into: &hasher)
                case .int8(let value):
                    value.hash(into: &hasher)
                case .int16(let value):
                    value.hash(into: &hasher)
                case .int32(let value):
                    value.hash(into: &hasher)
                case .int64(let value):
                    value.hash(into: &hasher)
                case .uint(let value):
                    value.hash(into: &hasher)
                case .uint8(let value):
                    value.hash(into: &hasher)
                case .uint16(let value):
                    value.hash(into: &hasher)
                case .uint32(let value):
                    value.hash(into: &hasher)
                case .uint64(let value):
                    value.hash(into: &hasher)
                case .decimal(let value):
                    value.hash(into: &hasher)
                case .floatingPointLiteral(let value):
                    value.hash(into: &hasher)
                case .integerLiteral(let value):
                    value.hash(into: &hasher)
                case .opaque(let value):
                    value.hash(into: &hasher)
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }
    
    private let storage: Storage
    
    public init<N: Number>(_ value: N) {
        self.storage = .opaque(value)
    }
    
    public init<T: BinaryInteger>(_ value: T) {
        let number = value as! any Number
        
        self.init(number) // FIXME: Hack, bad performance
    }
    
    public init<T: FloatingPoint>(_ value: T) {
        let number = value as! any Number
        
        self.init(number) // FIXME: Hack, bad performance
    }
    
    public init(opaque value: any Number) {
        self.storage = .opaque(value)
    }
    
    public init(from decoder: Decoder) throws {
        storage = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try storage.encode(to: encoder)
    }
}

// MARK: - Conformances

extension AnyNumber: BooleanInitiable {
    public init(_ value: Bool) {
        self.storage = .bool(value)
    }
}

extension AnyNumber: CustomStringConvertible {
    public var description: String {
        String(describing: storage.rawValue)
    }
}

extension AnyNumber: FloatingPointInitiable {
    public init(_ value: Double) {
        self.storage = .double(value)
    }
    
    public init(_ value: Float) {
        self.storage = .float(value)
    }
    
    public init(_ value: Decimal) {
        self.storage = .decimal(value)
    }
    
    public init(_ value: NSNumber) {
        self = value.toAnyNumber()
    }
}

extension AnyNumber: IntegerInitiable {
    public init(_ value: Int) {
        self.storage = .int(value)
    }
    
    public init(_ value: Int8) {
        self.storage = .int8(value)
    }
    
    public init(_ value: Int16) {
        self.storage = .int16(value)
    }
    
    public init(_ value: Int32) {
        self.storage = .int32(value)
    }
    
    public init(_ value: Int64) {
        self.storage = .int64(value)
    }
    
    public init(_ value: UInt) {
        self.storage = .uint(value)
    }
    
    public init(_ value: UInt8) {
        self.storage = .uint8(value)
    }
    
    public init(_ value: UInt16) {
        self.storage = .uint16(value)
    }
    
    public init(_ value: UInt32) {
        self.storage = .uint32(value)
    }
    
    public init(_ value: UInt64) {
        self.storage = .uint64(value)
    }
}

extension AnyNumber {
    public func toNSNumber() throws -> NSNumber {
        try (storage.rawValue as? NSNumber).unwrap()
    }
}

// MARK: - Helpers

extension NSNumber {
    fileprivate func toAnyNumber() -> AnyNumber {
        if let value = self as? CGFloat {
            return .init(value)
        } else if let value = self as? Double {
            return .init(value)
        } else if let value = self as? Float {
            return .init(value)
        } else if let value = self as? Int {
            return .init(value)
        } else if let value = self as? Int8 {
            return .init(value)
        } else if let value = self as? Int16 {
            return .init(value)
        } else if let value = self as? Int32 {
            return .init(value)
        } else if let value = self as? Int64 {
            return .init(value)
        } else if let value = self as? UInt {
            return .init(value)
        } else if let value = self as? UInt8 {
            return .init(value)
        } else if let value = self as? UInt16 {
            return .init(value)
        } else if let value = self as? UInt32 {
            return .init(value)
        } else if let value = self as? UInt64 {
            return .init(value)
        } else if let value = self as? Decimal {
            return .init(value)
        } else if self == kCFBooleanTrue {
            return .init(true)
        } else if self == kCFBooleanFalse {
            return .init(false)
        } else {
            fatalError()
        }
    }
}
