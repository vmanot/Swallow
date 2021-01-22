//
// Copyright (c) Vatsal Manot
//

import Swift

extension KeyedEncodingContainerProtocol {
    public mutating func encode(opaque value: Encodable, forKey key: Key) throws {
        try value.encode(to: &self, forKey: key)
    }
    
    public mutating func encodeIfPresent(opaque value: Encodable?, forKey key: Key) throws {
        guard let value = value else {
            return
        }
        
        try encode(opaque: value, forKey: key)
    }
}

extension KeyedEncodingContainerProtocol {
    public mutating func encode(using encodeImpl: @escaping (Encoder) throws -> (), forKey key: Key) throws {
        try encode(EncodableImpl(encodeImpl), forKey: key)
    }
}
