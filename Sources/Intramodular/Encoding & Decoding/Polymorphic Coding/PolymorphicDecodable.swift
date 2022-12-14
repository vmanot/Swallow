//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

// MARK: - Opaque Protocols -

public protocol _opaque_PolymorphicProxyDecodable {
    func _opaque_getValue() -> Any
}

public protocol _opaque_PolymorphicDecodable: Decodable {
    static func _opaque_decodeTypeDiscriminator(from _: Decoder) throws -> Any
    static func _opaque_PolymorphicProxyDecodableType() -> (_opaque_PolymorphicProxyDecodable & Decodable).Type
}

extension _opaque_PolymorphicDecodable where Self: PolymorphicDecodable {
    public static func _opaque_decodeTypeDiscriminator(from decoder: Decoder) throws -> Any {
        try decodeTypeDiscriminator(from: decoder)
    }
    
    public static func _opaque_PolymorphicProxyDecodableType() -> (_opaque_PolymorphicProxyDecodable & Decodable).Type {
        _PolymorphicProxyDecodable<Self>.self
    }
}

// MARK: - Protocols -

public protocol CodingTypeDiscriminator: Hashable {
    var typeValue: Decodable.Type { get }
}

public protocol PolymorphicDecodable: _opaque_PolymorphicDecodable, AnyObject {
    associatedtype TypeDiscriminator: Equatable
    
    static func decodeTypeDiscriminator(from _: Decoder) throws -> TypeDiscriminator
    static func resolveSubtype(for _: TypeDiscriminator) throws -> _opaque_PolymorphicDecodable.Type
}

// MARK: - Implementation -

extension PolymorphicDecodable where TypeDiscriminator: CodingTypeDiscriminator {
    public static func resolveSubtype(
        for discriminator: TypeDiscriminator
    ) throws -> _opaque_PolymorphicDecodable.Type {
        try cast(discriminator.typeValue, to: _opaque_PolymorphicDecodable.Type.self)
    }
}

// MARK: - API -

public enum PolymorphicDecodingError: Error {
    case abstractSuperclass
}

extension Decoder {
    public func polymorphic() -> _PolymorphicDecoder {
        .init(self)
    }
}

extension TopLevelDecoder {
    public func polymorphic() -> _PolymorphicTopLevelDecoder<Self> {
        .init(from: self)
    }
}

// MARK: - Auxiliary -

public struct AnyCodingTypeDiscriminator: CodingTypeDiscriminator, HashEquatable {
    public let base: any CodingTypeDiscriminator
    
    public var typeValue: Decodable.Type {
        base.typeValue
    }
    
    public init<T: CodingTypeDiscriminator>(_ base: T) {
        self.base = base
    }
    
    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

public struct _PolymorphicTopLevelDecoder<Base: TopLevelDecoder>: TopLevelDecoder {
    private let base: Base
    
    public init(from base: Base) {
        self.base = base
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from input: Base.Input) throws -> T {
        try base.decode(_PolymorphicDecodable<T>.self, from: input).value
    }
}

struct _PolymorphicProxyDecodable<T: PolymorphicDecodable>: Decodable, _opaque_PolymorphicProxyDecodable {
    var value: T
    
    init(from decoder: Decoder) throws {
        let discriminator = try T.decodeTypeDiscriminator(from: decoder)
        let subtype = try T.resolveSubtype(for: discriminator)
        
        do {
            let _subtype = try cast(subtype, to: _opaque_PolymorphicDecodable.Type.self)
            let subdiscriminator = try _subtype._opaque_decodeTypeDiscriminator(from: decoder)
            
            if let discriminator = discriminator as? AnyCodingTypeDiscriminator, let subdiscriminator = subdiscriminator as? AnyCodingTypeDiscriminator {
                if discriminator != subdiscriminator {
                    // This cast will always succeed.
                    if let type = (subdiscriminator.typeValue as? _opaque_PolymorphicDecodable.Type) {
                        value = try cast(type._opaque_PolymorphicProxyDecodableType().init(from: decoder)._opaque_getValue(), to: T.self)
                        
                        return
                    }
                }
            }
        }
        
        value = try cast(try T.resolveSubtype(for: T.decodeTypeDiscriminator(from: decoder)).init(from: decoder), to: T.self)
    }
    
    func _opaque_getValue() -> Any {
        return value
    }
}
