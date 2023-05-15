//
// Copyright (c) Vatsal Manot
//

import Swift

extension KeyedDecodingContainerProtocol {
    public func decode<T: Decodable>(
        forKey key: Key
    ) throws -> T {
        try decode(T.self, forKey: key)
    }
    
    public func decode<T: Decodable>(
        forKey key: Key,
        default defaultValue: @autoclosure () -> T
    ) throws -> T {
        try decodeIfPresent(T.self, forKey: key) ?? defaultValue()
    }

    public func decodeIfPresent<T: Decodable & OptionalProtocol>(
        forKey key: Key
    ) throws -> T where T.Wrapped: Decodable {
        .init(try decodeIfPresent(T.Wrapped.self, forKey: key))
    }
}

extension KeyedDecodingContainerProtocol {
    public func decoder(forKey key: Key) throws -> Decoder {
        try decode(DecoderUnwrapper.self, forKey: key).value
    }
}

extension KeyedDecodingContainerProtocol {
    public func _attemptToDecode<T>(
        opaque type: T.Type,
        forKey key: Key
    ) throws -> T {
        try cast(
            decode(try cast(type, to: Decodable.Type.self), forKey: key),
            to: T.self
        )
    }
    
    public func _attemptToDecode(
        opaque type: Any.Type,
        forKey key: Key
    ) throws -> Any {
        try decode(try cast(type, to: Decodable.Type.self), forKey: key)
    }
}
