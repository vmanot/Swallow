//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct _TypeAssociated<Parent, RawValue: Hashable>: Hashable, RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// MARK: - Conformances

extension _TypeAssociated: CustomStringConvertible {
    public var description: String {
        String(describing: rawValue)
    }
}

extension _TypeAssociated: Codable where RawValue: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension _TypeAssociated: Initiable where RawValue: Initiable {
    public init() {
        self.init(rawValue: .init())
    }
}

extension _TypeAssociated: Randomnable where RawValue: Randomnable {
    public static func random() -> _TypeAssociated<Parent, RawValue> {
        .init(rawValue: .random())
    }
}

extension _TypeAssociated: Sendable where RawValue: Sendable {
    
}
