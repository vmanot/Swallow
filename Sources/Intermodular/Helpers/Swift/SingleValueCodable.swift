//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol SingleValueCodable: Codable {
    
}

// MARK: - Implementation -

extension SingleValueCodable where Self: Wrapper, Value: Codable {
    public init(from decoder: Decoder) throws {
        self.init(try Value.init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
