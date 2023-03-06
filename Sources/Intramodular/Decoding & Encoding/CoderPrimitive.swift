//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol CoderPrimitive: Codable, Hashable {
    static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self

    func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws
    
    func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws

    func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws
}

// MARK: - Implementations

extension Bool: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Double: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Float: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int8: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int16: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int32: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int64: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt8: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt16: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt32: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt64: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }

    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension String: CoderPrimitive {
    public static func _decode<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
    
    public func _encode<Container: SingleValueEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }
    
    public func _encode<Container: UnkeyedEncodingContainer>(
        to container: inout Container
    ) throws {
        try container.encode(self)
    }

    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

// MARK: - Supplementary API

extension KeyedDecodingContainer {
    public func _decodePrimitive<T: CoderPrimitive>(
        _ type: T.Type,
        forKey key: Key
    ) throws -> T {
        try type._decode(from: self, forKey: key)
    }
}

extension SingleValueEncodingContainer {
    public mutating func _encode<T: CoderPrimitive>(
        primitive value: T
    ) throws {
        try value._encode(to: &self)
    }
}

extension UnkeyedEncodingContainer {
    public mutating func _encode<T: CoderPrimitive>(
        primitive value: T
    ) throws {
        try value._encode(to: &self)
    }
}

extension KeyedEncodingContainer {
    public mutating func _encode<T: CoderPrimitive>(
        primitive value: T,
        forKey key: Key
    ) throws {
        try value._encode(to: &self, forKey: key)
    }
}
