//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

public protocol PolymorphicDecodable: AnyObject, Decodable {
    associatedtype DecodingTypeDiscriminator: Equatable
    
    static func decodeTypeDiscriminator(from _: Decoder) throws -> DecodingTypeDiscriminator
    static func resolveSubtype(for _: DecodingTypeDiscriminator) throws -> any PolymorphicDecodable.Type
}

// MARK: - Implementation

extension PolymorphicDecodable where DecodingTypeDiscriminator: Swallow.TypeDiscriminator {
    public static func resolveSubtype(
        for discriminator: DecodingTypeDiscriminator
    ) throws -> any PolymorphicDecodable.Type {
        try cast(discriminator.resolveType(), to: any PolymorphicDecodable.Type.self)
    }
}

extension PolymorphicDecodable where Self: TypeDiscriminable, InstanceType == DecodingTypeDiscriminator {
    public static func decodeTypeDiscriminator(
        from decoder: Decoder
    ) throws -> DecodingTypeDiscriminator {
        try Self(from: decoder).instanceType
    }
}

// MARK: - Supplementary API

extension Decoder {
    public func _polymorphic() -> _PolymorphicDecoder {
        if let decoder = self as? _PolymorphicDecoder {
            return decoder
        } else {
            return _PolymorphicDecoder(self)
        }
    }
}

extension TopLevelDecoder {
    public func _polymorphic() -> _PolymorphicTopLevelDecoder<Self> {
        .init(from: self)
    }
}

// MARK: - Auxiliary

public struct _PolymorphicTopLevelDecoder<Base: TopLevelDecoder>: TopLevelDecoder {
    private let base: Base
    
    public init(from base: Base) {
        self.base = base
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from input: Base.Input) throws -> T {
        try base.decode(_PolymorphicDecodable<T>.self, from: input).value
    }
}

protocol _PolymorphicProxyDecodableType: Decodable {
    associatedtype Value
    
    var value: Value { get }
}

fileprivate struct _PolymorphicProxyDecodable<T: PolymorphicDecodable>: _PolymorphicProxyDecodableType {
    var value: T
    
    init(from decoder: Decoder) throws {
        let discriminator = try T.decodeTypeDiscriminator(from: decoder)
        let subtype = try T.resolveSubtype(for: discriminator)
        
        do {
            let _subtype = try cast(subtype, to: any PolymorphicDecodable.Type.self)
            let subdiscriminator = try _subtype.decodeTypeDiscriminator(from: decoder)
            
            if let discriminator = discriminator as? any TypeDiscriminator,
               let subdiscriminator = subdiscriminator as? any TypeDiscriminator,
               discriminator.eraseToAnyHashable() != subdiscriminator.eraseToAnyHashable(),
               let type = (try? subdiscriminator.resolveType() as? any PolymorphicDecodable.Type)
            {
                // This cast will always succeed.
                value = try cast(type._PolymorphicProxyDecodableType().init(from: decoder).value, to: T.self)
                
                return
            }
        }
        
        if isType(T.self, descendantOf: subtype) {
            value = try T.init(from: decoder)
        } else if !isType(subtype, descendantOf: T.self) {
            value = try T.init(from: decoder)
        } else {
            value = try cast(try subtype.init(from: decoder), to: T.self)
        }
    }
}

extension PolymorphicDecodable {
    static func _PolymorphicProxyDecodableType() -> any _PolymorphicProxyDecodableType.Type {
        _PolymorphicProxyDecodable<Self>.self
    }
}
