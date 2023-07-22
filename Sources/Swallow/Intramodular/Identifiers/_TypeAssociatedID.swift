//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct _TypeAssociatedID<Parent, RawValue: Hashable>: Hashable, RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// MARK: - Conformances

extension _TypeAssociatedID: CustomStringConvertible {
    public var description: String {
        String(describing: rawValue)
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
