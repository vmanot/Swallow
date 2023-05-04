//
// Copyright (c) Vatsal Manot
//

import Swift

extension Encoder {
    @available(*, deprecated)
    public func encode<T: Encodable>(_ value: T) throws {
        var container = self.unkeyedContainer()
        
        try container.encode(value)
    }
    
    public func encode<S: Sequence>(contentsOf value: S) throws where S.Element == UInt8 {
        var container = self.unkeyedContainer()
        
        try container.encode(contentsOf: value)
    }
}

extension Encoder {
    @available(*, deprecated)
    public func encode<Key: CodingKey>(
        opaque value: Encodable,
        forKey key: Key
    ) throws {
        var container = self.container(keyedBy: Key.self)
        
        try container.encode(value, forKey: key)
    }
    
    public func encode<T: Encodable, Key: CodingKey>(
        _ value: T, forKey
        key: Key
    ) throws {
        var container = self.container(keyedBy: Key.self)
        
        try container.encode(value, forKey: key)
    }
    
    public func encode<S: Sequence, Key: CodingKey>(
        contentsOf value: S,
        forKey key: Key
    ) throws where S.Element == UInt8 {
        var container = self.container(keyedBy: Key.self)
        
        try container.encode(EncodableSequence(base: value), forKey: key)
    }
}
