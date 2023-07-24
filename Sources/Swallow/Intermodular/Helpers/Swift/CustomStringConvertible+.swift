//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK:

public protocol CustomStringConvertibleOptionSet: CustomStringConvertible, Hashable, OptionSet {
    static var descriptions: [Self: String] { get }
}

extension CustomStringConvertibleOptionSet where Element == Self {
    public var description: String {
        return Self.descriptions.filter({ self.contains($0.0) }).map({ $0.1 }).description
    }
}

// MARK:

public struct CustomStringConvertibleOnly: CustomDebugStringConvertible, CustomStringConvertible, Wrapper {
    public typealias Value = Any

    public let value: Value

    public init<T>(_ value: T) {
        self.value = value
    }

    public var debugDescription: String {
        return description
    }

    public var description: String {
        return (value as? CustomStringConvertible)?.description ?? String(describing: value)
    }
}
