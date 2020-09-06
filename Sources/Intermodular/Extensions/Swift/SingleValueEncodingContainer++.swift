//
// Copyright (c) Vatsal Manot
//

import Swift

extension SingleValueEncodingContainer {
    public mutating func encode(opaque value: Encodable) throws {
        try value.encode(to: &self)
    }
}
