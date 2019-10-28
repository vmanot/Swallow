//
// Copyright (c) Vatsal Manot
//

import Swift

extension Decoder {
    public func decodeSingleValueNil() throws -> Bool {
        let container = try singleValueContainer()
        
        return container.decodeNil()
    }

    public func decode<T: Decodable>(single type: T.Type = T.self) throws -> T {
        let container = try singleValueContainer()

        return try container.decode(T.self)
    }
    
    public func decodeUnkeyedNil() throws -> Bool {
        var container = try unkeyedContainer()
        
        return try container.decodeNil()
    }

    public func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        var container = try unkeyedContainer()

        return try container.decode(T.self)
    }

    public func decode<T: Decodable, Key: CodingKey>(_ type: T.Type = T.self, forKey key: Key) throws -> T {
        let container = try self.container(keyedBy: Key.self)

        return try container.decode(T.self, forKey: key)
    }
}

extension Decoder {
    public func decodeNil() throws -> Bool {
        try Result(try decodeSingleValueNil(), or: try decodeUnkeyedNil()).unwrap()
    }
}
