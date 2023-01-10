//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

public protocol CodingTypeDiscriminator: Hashable {
    var typeValue: Decodable.Type { get }
}

public protocol PolymorphicDecodable: AnyObject, Decodable {
    associatedtype TypeDiscriminator: Equatable
    
    static func decodeTypeDiscriminator(from _: Decoder) throws -> TypeDiscriminator
    static func resolveSubtype(for _: TypeDiscriminator) throws -> any PolymorphicDecodable.Type
}

// MARK: - Implementation -

extension PolymorphicDecodable where TypeDiscriminator: CodingTypeDiscriminator {
    public static func resolveSubtype(
        for discriminator: TypeDiscriminator
    ) throws -> any PolymorphicDecodable.Type {
        try cast(discriminator.typeValue, to: any PolymorphicDecodable.Type.self)
    }
}

extension PolymorphicDecodable where Self: TypeDiscriminable, TypeDiscriminator: CodingTypeDiscriminator {
    public static func decodeTypeDiscriminator(from decoder: Decoder) throws -> TypeDiscriminator {
        try Self(from: decoder).type
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

protocol _PolymorphicProxyDecodableType: Decodable {
    associatedtype Value
    
    var value: Value { get }
}

struct _PolymorphicProxyDecodable<T: PolymorphicDecodable>: _PolymorphicProxyDecodableType {
    var value: T
    
    init(from decoder: Decoder) throws {
        let discriminator = try T.decodeTypeDiscriminator(from: decoder)
        let subtype = try T.resolveSubtype(for: discriminator)
        
        do {
            let _subtype = try cast(subtype, to: any PolymorphicDecodable.Type.self)
            let subdiscriminator = try _subtype.decodeTypeDiscriminator(from: decoder)
            
            if let discriminator = discriminator as? AnyCodingTypeDiscriminator, let subdiscriminator = subdiscriminator as? AnyCodingTypeDiscriminator {
                if discriminator != subdiscriminator {
                    // This cast will always succeed.
                    if let type = (subdiscriminator.typeValue as? any PolymorphicDecodable.Type) {
                        value = try cast(type._PolymorphicProxyDecodableType().init(from: decoder).value, to: T.self)
                        
                        return
                    }
                }
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
    
    func _opaque_getValue() -> Any {
        return value
    }
}

extension PolymorphicDecodable {
    static func _PolymorphicProxyDecodableType() -> any _PolymorphicProxyDecodableType.Type {
        _PolymorphicProxyDecodable<Self>.self
    }
}
