//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Character: Codable {
    public func encode(to encoder: Encoder) throws {
        try String(self).encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        self.init(try String(from: decoder))
    }
}

public struct EncodableSequence<Base: Sequence>: Encodable where Base.Element: Encodable {
    public let base: Base
    
    public init(base: Base) {
        self.base = base
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(contentsOf: base)
    }
}

extension UnicodeScalar: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try UnicodeScalar(try container.decode(UInt32.self))
            .unwrapOrThrow(DecodingError.dataCorruptedError(in: container, debugDescription: .init()))
    }
}

extension Never: Codable {
    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
    
    public init(from decoder: Decoder) throws {
        fatalError()
    }
}
