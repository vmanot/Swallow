//
// Copyright (c) Vatsal Manot
//

import Foundation

/// An affordance for phantom identifier types.
///
/// https://swiftwithmajid.com/2021/02/18/phantom-types-in-swift/
public struct _TypeAssociatedID<Parent, RawValue: Hashable>: Hashable, RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Conformances

extension _TypeAssociatedID: CustomStringConvertible, CustomTruncatedStringConvertible {
    public var description: String {
        String(describing: rawValue)
    }
    
    public var truncatedDescription: String {
        String(_describingTruncated: rawValue)
    }
}

extension _TypeAssociatedID: Codable where RawValue: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension _TypeAssociatedID: Identifiable {
    public typealias ID = Self
    
    public var id: Self {
        self
    }
}

extension _TypeAssociatedID: _ThrowingInitiable where RawValue: _ThrowingInitiable {
    public init() throws {
        self.init(rawValue: try .init())
    }
}

extension _TypeAssociatedID: Initiable where RawValue: Initiable {
    public init() {
        self.init(rawValue: .init())
    }
}

extension _TypeAssociatedID: Randomnable where RawValue: Randomnable {
    public static func random() -> _TypeAssociatedID<Parent, RawValue> {
        .init(rawValue: .random())
    }
}

extension _TypeAssociatedID: Sendable where RawValue: Sendable {
    
}
