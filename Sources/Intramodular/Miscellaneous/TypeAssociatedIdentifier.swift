//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct TypeAssociatedIdentifier<Parent, RawValue: Hashable>: Hashable, RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// MARK: - Conformances -

extension TypeAssociatedIdentifier: Codable where RawValue: Codable {
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

extension TypeAssociatedIdentifier: Randomnable where RawValue: Randomnable {
    public static func random() -> TypeAssociatedIdentifier<Parent, RawValue> {
        .init(rawValue: .random())
    }
}
