//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyEncodable: Encodable, Sendable {
    public let impl: (@Sendable (Encoder) throws -> ())
    
    public init(_ impl: (@escaping @Sendable (Encoder) throws -> ())) {
        self.impl = impl
    }
    
    public func encode(to encoder: Encoder) throws {
        try impl(encoder)
    }
}
