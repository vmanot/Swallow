//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A custom decoder.
public struct _PolymorphicDecoder: Decoder {
    private var base: Decoder
    
    public var codingPath: [CodingKey] {
        base.codingPath
    }
    
    public var userInfo: [CodingUserInfoKey: Any] {
        base.userInfo
    }
    
    public init(_ base: Decoder) {
        self.base = base
    }
    
    public func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        .init(_PolymorphicKeyedDecodingContainer(try base.container(keyedBy: type), parent: self))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        _PolymorphicUnkeyedDecodingContainer(try base.unkeyedContainer(), parent: self)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        _PolymorphicSingleValueDecodingContainer(try base.singleValueContainer(), parent: self)
    }
}

/// A proxy for `Decodable` that forces our custom decoder to be used.

protocol _PolymorphicDecodableType: Decodable {
    
}

internal struct _PolymorphicDecodable<T: Decodable>: _PolymorphicDecodableType {
    public var value: T
    
    public init(from decoder: Decoder) throws {
        guard !(T.self is _PolymorphicDecodableType.Type) else {
            self.value = try T.init(from: decoder)
            
            return
        }
        
        let decoder = _PolymorphicDecoder(decoder)
        
        do {
            if let type = T.self as? any PolymorphicDecodable.Type {
                self.value = try cast(try type._PolymorphicProxyDecodableType().init(from: decoder).value, to: T.self)
            } else {
                self.value = try T.init(from: decoder.polymorphic())
            }
        } catch {
            throw error
        }
    }
}

/// A custom encoder.
public struct _PolymorphicEncoder: Encoder {
    private var base: Encoder
    public init(_ base: Encoder) {
        self.base = base
    }
    
    public var codingPath: [CodingKey] {
        return base.codingPath
    }
    
    public var userInfo: [CodingUserInfoKey: Any] {
        return base.userInfo
    }
    
    public func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return .init(_PolymorphicKeyedEncodingContainer(base.container(keyedBy: type), parent: self))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _PolymorphicUnkeyedEncodingContainer(base.unkeyedContainer(), parent: self)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return _PolymorphicSingleValueEncodingContainer(base.singleValueContainer(), parent: self)
    }
}

/// A proxy for `Encodable` that forces our custom encoder to be used.
internal struct _PolymorphicEncodable<T: Encodable>: Encodable {
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: _PolymorphicEncoder(encoder))
    }
}
