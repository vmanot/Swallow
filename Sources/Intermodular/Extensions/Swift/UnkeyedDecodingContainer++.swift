//
// Copyright (c) Vatsal Manot
//

import Swift

extension UnkeyedDecodingContainer {
    public mutating func decode(opaque type: Decodable.Type) throws -> Decodable {
        return try type.decode(from: &self)
    }
    
    public mutating func decodeIfPresent(opaque type: Decodable.Type) throws -> Decodable? {
        return try type.decodeIfPresent(from: &self)
    }
}

extension UnkeyedDecodingContainer {
    public mutating func decodeIfPresent<T: Decodable & OptionalProtocol>() throws -> T where T.Wrapped: Decodable {
        return .init(try decodeIfPresent(T.Wrapped.self))
    }
}
