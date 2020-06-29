//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol SingleValueCodable: Wrapper where Value: Codable {
    
}

extension SingleValueCodable {
    public init(from decoder: Decoder) throws {
        self.init(try Value.init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
