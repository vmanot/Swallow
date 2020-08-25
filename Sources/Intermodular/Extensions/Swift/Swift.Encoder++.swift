//
// Copyright (c) Vatsal Manot
//

import Swift

extension Encoder {
    public func encodeSingleNil() throws {
        var container = self.singleValueContainer()

        try container.encodeNil()
    }

    public func encode<T: Encodable>(single value: T) throws {
        var container = self.singleValueContainer()

        try container.encode(value)
    }

    public func encode(opaqueSingle value: Encodable) throws {
        var container = self.singleValueContainer()

        try value.encode(to: &container)
    }
}

extension Encoder {
    public func encode<T: Encodable>(_ value: T) throws {
        var container = self.unkeyedContainer()

        try container.encode(value)
    }

    public func encode(opaque value: Encodable) throws {
        var container = self.unkeyedContainer()

        try value.encode(to: &container)
    }

    public func encode<S: Sequence>(contentsOf value: S) throws where S.Element == UInt8 {
        var container = self.unkeyedContainer()

        try container.encode(contentsOf: value)
    }
}

extension Encoder {
    public func encode<Key: CodingKey>(opaque value: Encodable, forKey key: Key) throws {
        var container = self.container(keyedBy: Key.self)

        try value.encode(to: &container, forKey: key)
    }

    public func encode<T: Encodable, Key: CodingKey>(_ value: T, forKey key: Key) throws {
        var container = self.container(keyedBy: Key.self)

        try container.encode(value, forKey: key)
    }

    public func encode<S: Sequence, Key: CodingKey>(contentsOf value: S, forKey key: Key) throws where S.Element == UInt8 {
        var container = self.container(keyedBy: Key.self)

        try container.encode(EncodableSequence(base: value), forKey: key)
    }
}
