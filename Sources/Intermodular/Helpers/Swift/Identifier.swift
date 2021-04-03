//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _opaque_Identifier: _opaque_Hashable {
    
}

public protocol Identifier: _opaque_Identifier, Hashable {
    
}

public protocol IdentifierGenerator {
    associatedtype Identifier: Swallow.Identifier
    
    mutating func next() -> Identifier
}

// MARK: - Conformances -

extension AnyHashable: Identifier {
    
}

public struct AnyIdentifier: Identifier {
    public typealias Value = _opaque_Identifier
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(opaque: value)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value._opaque_Equatable_isEqual(to: rhs.value) ?? false
    }
}

public struct AnyStringIdentifier: Codable, Identifier {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        self.init(try .init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension ObjectIdentifier: Identifier {
    
}

extension UUID: Identifier {
    
}
