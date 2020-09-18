//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol AnyCodableConvertible {
    func toAnyCodable() throws -> AnyCodable
}

public protocol AnyCodableUnconditionalConvertible: AnyCodableConvertible {
    func toAnyCodable() -> AnyCodable
}

// MARK: - Conformances -

extension Array: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .array(try cast(self, to: [AnyCodableConvertible].self).map({ try $0.toAnyCodable() }))
    }
}

extension Bool: AnyCodableConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .bool(self)
    }
}

extension Dictionary: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .dictionary(try mapKeysAndValues({
            .init(stringValue: try cast($0, to: String.self))
        }, {
            try cast($0, to: AnyCodableConvertible.self).toAnyCodable()
        }))
    }
}

extension Double: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .number(.init(self))
    }
}

extension Float: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .number(.init(Double(self)))
    }
}

extension Int: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .number(.init(self))
    }
}

extension Int16: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .number(.init(self))
    }
}

extension Int32: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .number(.init(self))
    }
}

extension Int64: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .number(.init(self))
    }
}

extension Set: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return try Array(self).toAnyCodable()
    }
}

extension String: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .string(self)
    }
}

extension NSArray: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return try (self as [AnyObject]).toAnyCodable()
    }
}

extension NSDictionary: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return try (self as Dictionary).toAnyCodable()
    }
}

extension NSNull: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .none
    }
}

extension NSNumber: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .number(.init(self))
    }
}

extension NSSet: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return try (self as Set).toAnyCodable()
    }
}

extension NSString: AnyCodableUnconditionalConvertible {
    public func toAnyCodable() -> AnyCodable {
        return .string(self as String)
    }
}

extension UInt: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .number(.init(self))
    }
}

extension UInt16: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .number(.init(self))
    }
}

extension UInt32: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .number(.init(self))
    }
}

extension UInt64: AnyCodableConvertible {
    public func toAnyCodable() throws -> AnyCodable {
        return .number(.init(self))
    }
}
