//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol opaque_Identifier: opaque_Hashable {
    
}

public protocol Identifier: opaque_Identifier, Hashable {
    
}

public protocol opaque_Identifiable {
    var opaque_identifier: opaque_Identifier { get }
}

public protocol Identifiable: opaque_Identifiable, Swift.Identifiable {
    typealias Identifier = ID
    
    var identifier: ID { get }
}

public protocol IdentifierGenerator {
    associatedtype Identifier: Swallow.Identifier
    
    mutating func next() -> Identifier
}

// MARK: - Implementation -

extension opaque_Identifiable where Self: Identifiable, Identifier: Swallow.Identifier {
    public var opaque_identifier: opaque_Identifier {
        identifier
    }
}

extension opaque_Identifiable where Self: Identifiable {
    public var opaque_identifier: opaque_Identifier {
        AnyHashable(identifier)
    }
}

// MARK: - Protocol Implementations -

extension Identifiable {
    public var id: Identifier {
        identifier
    }
    
    public var identifier: ID {
        id
    }
}

// MARK: - Concrete Implementations -

extension AnyHashable: Identifier {
    
}

public struct AnyIdentifier: Identifier {
    public typealias Value = opaque_Identifier
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(opaque: value)
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
