//
// Copyright (c) Vatsal Manot
//

import Swift

public struct EncodableEncodables<S: Sequence>: Encodable where S.Element == Encodable {
    public let value: S
    
    public init(_ value: S) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.forEach({ try $0.encode(to: encoder) })
    }
}

public struct EncodableImpl: Encodable {
    public let impl: ((Encoder) throws -> ())
    
    public init(_ impl: (@escaping (Encoder) throws -> ())) {
        self.impl = impl
    }
    
    public func encode(to encoder: Encoder) throws {
        try impl(encoder)
    }
}
