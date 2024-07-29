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
        _ type: T.Type = T.self,
        forKey key: Key,
        default defaultValue: @autoclosure () -> T
    ) throws -> T {
        try decodeIfPresent(T.self, forKey: key) ?? defaultValue()
    }

    public func decodeIfPresent<T: Decodable & OptionalProtocol>(
        _ type: T.Type = T.self,
        forKey key: Key
    ) throws -> T where T.Wrapped: Decodable {
        .init(try decodeIfPresent(T.Wrapped.self, forKey: key))
    }
}

extension KeyedDecodingContainerProtocol {
    public func decoder(forKey key: Key) throws -> Decoder {
        try decode(DecoderUnwrapper.self, forKey: key).value
    }
    
    public func _firstValueDecoder(forKey key: Key) throws -> Decoder {
        do {
            var container = try nestedUnkeyedContainer(forKey: key)
            
            return try container.decode(DecoderUnwrapper.self).value
        } catch {
            return try decode(DecoderUnwrapper.self, forKey: key).value
        }
    }
    
    public func _decodeFirstUnkeyedValue<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        var container = try nestedUnkeyedContainer(forKey: key)
        
        return try container.decode(type)
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
    
    public func _attemptToDecodeIfPresent<T>(
        opaque type: T.Type,
        forKey key: Key
    ) throws -> T {
        if let type = type as? any OptionalProtocol.Type {
            let unwrappedType = try cast(type._opaque_Optional_WrappedType, to: (any Decodable.Type).self)
            
            if let unwrapped = try decodeIfPresent(unwrappedType, forKey: key) {
                return try cast(type.init(_opaque_wrappedValue: unwrapped), to: T.self)
            } else {
                return try cast(type.init(nilLiteral: ()), to: T.self)
            }
        } else {
            return try _attemptToDecode(opaque: type, forKey: key)
        }
    }
    
    public func _attemptToDecode(
        opaque type: Any.Type,
        forKey key: Key
    ) throws -> Any {
        try decode(try cast(type, to: Decodable.Type.self), forKey: key)
    }
}
