//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _CodableRepresentationConvertible: Codable {
    associatedtype _CodableRepresentation: Codable
    
    var _codableRepresentation: _CodableRepresentation { get throws }
    
    init(_codableRepresentation: _CodableRepresentation)
}

extension _CodableRepresentationConvertible {
    public init(from decoder: Decoder) throws {
        self.init(_codableRepresentation: try .init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try _codableRepresentation.encode(to: encoder)
    }
}

