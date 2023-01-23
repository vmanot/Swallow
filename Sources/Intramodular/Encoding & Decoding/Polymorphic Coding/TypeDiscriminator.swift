//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol TypeDiscriminator: Hashable {
    func resolveType() throws -> Any.Type
}

public protocol TypeDiscriminatorDecoding {
    associatedtype TypeDiscriminator
    
    func decodeTypeDiscriminator(from decoder: Decoder) throws -> TypeDiscriminator
}

extension Decodable {
    public typealias Discriminated<D, T> = _TypeDiscriminatedCodable<D, T>
}

@propertyWrapper
public struct _TypeDiscriminatedCodable<Discriminator, WrappedValue>: PropertyWrapper {
    public var wrappedValue: WrappedValue
    
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
    
    public init(wrappedValue: WrappedValue, by _: Discriminator.Type) where Discriminator: TypeDiscriminatorDecoding {
        self.wrappedValue = wrappedValue
    }
    
    public init(wrappedValue: WrappedValue) where WrappedValue: Codable & TypeDiscriminable, WrappedValue.InstanceType == Discriminator {
        self.wrappedValue = wrappedValue
    }
}

extension _TypeDiscriminatedCodable: Codable {
    public init(from decoder: Decoder) throws {
        throw Never.Reason.unavailable
    }
    
    public func encode(to encoder: Encoder) throws {
        throw Never.Reason.unavailable
    }
}

extension _TypeDiscriminatedCodable: Equatable where WrappedValue: Equatable {
    
}

extension _TypeDiscriminatedCodable: Hashable where WrappedValue: Hashable {
    
}
