//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct TypeAssociatedIdentifier<Parent, RawValue: Codable & Hashable>: Codable, Hashable, RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: .init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension TypeAssociatedIdentifier: CustomStringConvertible where RawValue: CustomStringConvertible {
    public var description: String {
        rawValue.description
    }
}
