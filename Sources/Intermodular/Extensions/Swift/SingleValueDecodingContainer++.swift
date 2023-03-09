//
// Copyright (c) Vatsal Manot
//

import Swift

extension SingleValueDecodingContainer {
    /// Decodes a value of the given type, if present.
    public func decodeIfPresent<T: Decodable>(_ type: T.Type = T.self) throws -> Optional<T> {
        if decodeNil() {
            return .none
        } else {
            return .init(try decode(T.self))
        }
    }
}

extension SingleValueDecodingContainer {
    public func decode(opaque type: Decodable.Type) throws -> Decodable {
        try decode(type)
    }
    
    public func decodeIfPresent(opaque type: Decodable.Type) throws -> Decodable? {
        try type.decodeIfPresent(from: self)
    }
}
