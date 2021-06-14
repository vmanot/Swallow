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
    static func _opaque_PolymorphicProxyDecodableType() -> (_opaque_PolymorphicProxyDecodable & Decodable).Type
}

extension _opaque_PolymorphicDecodable where Self: PolymorphicDecodable {
    public static func _opaque_PolymorphicProxyDecodableType() -> (_opaque_PolymorphicProxyDecodable & Decodable).Type {
        return _PolymorphicProxyDecodable<Self>.self
    }
}

// MARK: - Protocols -

public protocol CodingTypeDiscriminator: Codable, Hashable {
    var typeValue: Decodable.Type { get }
}

public protocol PolymorphicDecodable: _opaque_PolymorphicDecodable, AnyObject {
    associatedtype TypeDiscriminator: Decodable, Equatable
    
    static func decodeTypeDiscriminator(from _: Decoder) throws -> TypeDiscriminator
    static func resolveSubtype(for _: TypeDiscriminator) throws -> Decodable.Type
}

// MARK: - Implementation -

extension PolymorphicDecodable where TypeDiscriminator: CodingTypeDiscriminator {
    public static func resolveSubtype(
        for discriminator: TypeDiscriminator
    ) throws -> Decodable.Type {
        return discriminator.typeValue
    }
}

// MARK: - API -

public enum PolymorphicDecodingError: Error {
    case abstractSuperclass
}

extension TopLevelDecoder {
    public func polymorphic() -> _PolymorphicTopLevelDecoder<Self> {
        .init(from: self)
    }
}

// MARK: - Auxiliary Implementation -

public struct _PolymorphicTopLevelDecoder<Base: TopLevelDecoder> {
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
        value = try cast(try T.resolveSubtype(for: T.decodeTypeDiscriminator(from: decoder)).init(from: decoder), to: T.self)
    }
    
    func _opaque_getValue() -> Any {
        return value
    }
}
