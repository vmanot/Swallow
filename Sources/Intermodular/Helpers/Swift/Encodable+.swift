//
// Copyright (c) Vatsal Manot
//

import Swift

public struct EncodableImpl: Encodable {
    public let impl: ((Encoder) throws -> ())
    
    public init(_ impl: (@escaping (Encoder) throws -> ())) {
        self.impl = impl
    }
    
    public func encode(to encoder: Encoder) throws {
        try impl(encoder)
    }
}
