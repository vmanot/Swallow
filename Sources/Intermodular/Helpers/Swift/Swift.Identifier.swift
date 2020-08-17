//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _opaque_Identifier: _opaque_Hashable {
    
}

public protocol Identifier: _opaque_Identifier, Hashable {
    
}

public protocol _opaque_Identifiable: AnyProtocol {
    var _opaque_identifier: _opaque_Identifier { get }
}

public protocol Identifiable: _opaque_Identifiable, Swift.Identifiable {
    typealias Identifier = ID
    
    var identifier: ID { get }
}

public protocol IdentifierGenerator {
    associatedtype Identifier: Swallow.Identifier
    
    mutating func next() -> Identifier
}

// MARK: - Implementation -

extension _opaque_Identifiable where Self: Identifiable, Identifier: Swallow.Identifier {
    public var _opaque_identifier: _opaque_Identifier {
        identifier
    }
}

extension _opaque_Identifiable where Self: Identifiable {
    public var _opaque_identifier: _opaque_Identifier {
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
    public typealias Value = _opaque_Identifier
    
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
