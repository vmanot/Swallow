//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol SingleValueCodable: Codable {
    
}

extension SingleValueCodable where Self: Wrapper, Value: Codable {
    public init(from decoder: Decoder) throws {
        self.init(try Value.init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension SingleValueCodable where Self: RawRepresentable, RawValue: Codable {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: try RawValue.init(from: decoder)).unwrap()
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
