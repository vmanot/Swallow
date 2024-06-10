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

extension Either: Decodable where LeftValue: Decodable, RightValue: Decodable {
    public init(from decoder: Decoder)  throws{
        do {
            self = try .left(.init(from: decoder))
        } catch(let firstError) {
            do {
                self = try .right(.init(from: decoder))
            } catch {
                throw firstError
            }
        }
    }
}

extension Either: Encodable where LeftValue: Encodable, RightValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        try collapse({ try $0.encode(to: encoder) }, { try $0.encode(to: encoder) })
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

#if !os(visionOS)
extension Never: Codable {
    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
    
    public init(from decoder: Decoder) throws {
        fatalError()
    }
}
#endif
