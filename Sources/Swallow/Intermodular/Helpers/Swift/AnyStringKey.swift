//
// Copyright (c) Vatsal Manot
//

import Swift

/// Allows any arbitrary `String` to be used as a coding key.
public struct AnyStringKey: Codable, CodingKey, ExpressibleByStringLiteral, Hashable {
    public var stringValue: String

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int? {
        return nil
    }

    public init?(intValue: Int) {
        return nil
    }

    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }

    public init(from decoder: Decoder) throws {
        self.init(stringValue: try String(from: decoder))
    }

    public func encode(to encoder: Encoder) throws {
        try stringValue.encode(to: encoder)
    }
}
