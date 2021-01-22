//
// Copyright (c) Vatsal Manot
//

import Swift

extension KeyedDecodingContainerProtocol {
    public func decode(opaque type: Decodable.Type, forKey key: Key) throws -> Decodable {
        try type.decode(from: self, forKey: key)
    }
    
    public func decodeIfPresent(opaque type: Decodable.Type, forKey key: Key) throws -> Decodable? {
        try type.decodeIfPresent(from: self, forKey: key)
    }
}

extension KeyedDecodingContainerProtocol {
    public func decode<T: Decodable>(forKey key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }
    
    public func decodeIfPresent<T: Decodable & OptionalProtocol>(forKey key: Key) throws -> T where T.Wrapped: Decodable {
        .init(try decodeIfPresent(T.Wrapped.self, forKey: key))
    }
}

extension KeyedDecodingContainerProtocol {
    public func decoder(forKey key: Key) throws -> Decoder {
        try decode(DecoderUnwrapper.self, forKey: key).value
    }
}
