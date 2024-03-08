//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol AnyCodableConvertible {
    func toAnyCodable() throws -> AnyCodable
}

// MARK: - Conformances

extension Array: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        try AnyCodable.array(map({ try AnyCodable($0) }))
    }
}

extension Bool: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .bool(self)
    }
}

extension Dictionary: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        TODO.here(.fix)
        
        return .dictionary(try mapKeysAndValues({
            AnyCodingKey(stringValue: try cast($0, to: String.self))
        }, {
            try cast($0, to: AnyCodableConvertible.self).toAnyCodable()
        }))
    }
}

extension Double: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .number(.init(self))
    }
}

extension Float: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .number(AnyNumber(Double(self)))
    }
}

extension Int: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .number(.init(self))
    }
}

extension Int16: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .number(.init(self))
    }
}

extension Int32: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .number(.init(self))
    }
}

extension Int64: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .number(.init(self))
    }
}

extension Set: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        try Array(self).toAnyCodable()
    }
}

extension String: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .string(self)
    }
}

extension NSArray: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        try (self as [AnyObject]).toAnyCodable()
    }
}

extension NSDictionary: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        try (self as Dictionary).toAnyCodable()
    }
}

extension NSNull: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .none
    }
}

extension NSNumber: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        .number(.init(self))
    }
}

extension NSSet: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        try (self as Set).toAnyCodable()
    }
}

extension NSString: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        .string(self as String)
    }
}

extension UInt: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        .number(.init(self))
    }
}

extension UInt16: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        .number(.init(self))
    }
}

extension UInt32: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        .number(.init(self))
    }
}

extension UInt64: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        .number(.init(self))
    }
}

extension URL: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        .url(self)
    }
}
