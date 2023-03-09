//
// Copyright (c) Vatsal Manot
//

import Swift

extension KeyedEncodingContainerProtocol {
    public mutating func encode(
        using encodeImpl: @escaping @Sendable (Encoder) throws -> (),
        forKey key: Key
    ) throws {
        try encode(AnyEncodable(encodeImpl), forKey: key)
    }
}
