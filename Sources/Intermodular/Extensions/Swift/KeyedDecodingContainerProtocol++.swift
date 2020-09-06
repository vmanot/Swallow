//
// Copyright (c) Vatsal Manot
//

import Swift

extension KeyedDecodingContainerProtocol {
    public func decode(opaque type: Decodable.Type, forKey key: Key) throws -> Decodable {
        return try type.decode(from: self, forKey: key)
    }

    public func decodeIfPresent(opaque type: Decodable.Type, forKey key: Key) throws -> Decodable? {
        return try type.decodeIfPresent(from: self, forKey: key)
    }
}

extension KeyedDecodingContainerProtocol {
    public func decode<T: Decodable>(forKey key: Key) throws -> T {
        return try decode(T.self, forKey: key)
    }
    
    public func decodeIfPresent<T: Decodable & OptionalProtocol>(forKey key: Key) throws -> T where T.Wrapped: Decodable {
        return .init(try decodeIfPresent(T.Wrapped.self, forKey: key))
    }
}
