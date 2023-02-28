//
// Copyright (c) Vatsal Manot
//

import Swift

extension KeyedEncodingContainerProtocol {
    @_disfavoredOverload
    public mutating func encode(_ value: Encodable, forKey key: Key) throws {
        try value.encode(to: &self, forKey: key)
    }
    
    @_disfavoredOverload
    public mutating func encodeIfPresent(_ value: Encodable?, forKey key: Key) throws {
        guard let value = value else {
            return
        }
        
        try encode(value, forKey: key)
    }
}

extension KeyedEncodingContainerProtocol {
    public mutating func encode(
        using encodeImpl: @escaping @Sendable (Encoder) throws -> (),
        forKey key: Key
    ) throws {
        try encode(AnyEncodable(encodeImpl), forKey: key)
    }
}
