//
// Copyright (c) Vatsal Manot
//

import Swift

extension SingleValueDecodingContainer {
    public func decode(opaque type: Decodable.Type) throws -> Decodable {
        return try type.decode(from: self)
    }

    public func decodeIfPresent(opaque type: Decodable.Type) throws -> Decodable? {
        return try type.decodeIfPresent(from: self)
    }
}

extension SingleValueDecodingContainer {
    public func decodeIfPresent<T: Decodable & OptionalProtocol>() throws -> T where T.Wrapped: Decodable {
        if decodeNil() {
            return .init(none: ())
        } else {
            return .init(try decode(T.Wrapped.self))
        }
    }
}
