//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol CoderPrimitive: Codable, Hashable {
    func _encode<Key: CodingKey>(to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws
}

// MARK: - Implementations

extension Bool: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Double: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Float: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int8: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int16: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int32: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension Int64: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt8: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt16: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt32: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension UInt64: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

extension String: CoderPrimitive {
    public func _encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        try container.encode(self, forKey: key)
    }
}

// MARK: - Supplementary API

extension KeyedEncodingContainer {
    public mutating func _encode<T: CoderPrimitive>(
        primitive value: T,
        forKey key: Key
    ) throws {
        try value._encode(to: &self, forKey: key)
    }
}
