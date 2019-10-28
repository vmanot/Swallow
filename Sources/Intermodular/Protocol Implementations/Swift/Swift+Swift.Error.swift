//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased error.
public struct AnyError: CustomDebugStringConvertible, Error, Hashable {
    public typealias Value = Error

    public let value: Value

    public var description: String {
        return CustomStringConvertibleOnly(value).description
    }

    public var localizedDescription: String {
        return value.localizedDescription
    }

    public init(_ value: Value) {
        self.value = (value as? AnyError)?.value ?? value
    }

    public init(description: String) {
        self.init(CustomStringError(description: description))
    }

    public func hash(into hasher: inout Hasher) {
        if let value = try? cast(value, to: opaque_Hashable.self) {
            value.hash(into: &hasher)
        } else {
            value.localizedDescription.hash(into: &hasher)
        }
    }

    public func `throw`() throws -> Never {
        throw value
    }
}

extension Array: Error where Element: Error {

}

extension Bool: Error {

}

public struct CustomStringError: opaque_Hashable, CustomStringConvertible, Error, Hashable {
    public let description: String

    public var localizedDescription: String {
        return description
    }

    public init(description: String) {
        self.description = description
    }
}

public struct EmptyError: Error, CustomStringConvertible {
    public let location: SourceCodeLocation?

    public var description: String {
        TODO.whole(.improve)
        return "Empty error at \(location ?? "<unspecified>" as Any)"
    }

    public init(location: SourceCodeLocation? = nil) {
        self.location = location
    }

    public init(atFile file: StaticString, line: UInt) {
        self.init(location: .regular(file: file, line: line))
    }

    public init(atFile file: StaticString, function: StaticString, line: UInt, column: UInt) {
        self.init(location: .exact(.init(file: file, function: function, line: line, column: column)))
    }
}

public struct ErrorOf<Value>: Error, Wrapper {
    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

public struct ErrorPair<T: Error, U: Error>: CustomDebugStringConvertible, CustomStringConvertible, Error, Wrapper {
    public typealias Value = (T, U)

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public var localizedDescription: String {
        return value.0.localizedDescription + "\n" + value.1.localizedDescription
    }

    public var debugDescription: String {
        return .init(reflecting: value)
    }

    public var description: String {
        return "\(value.0) & \(value.1)"
    }
}

public struct MultipleErrors: CustomStringConvertible, Error, ImplementationForwardingMutableWrapper, ResizableCollection, SequenceInitiableSequence {
    public typealias Value = [Error]

    public typealias Element = Value.Element
    public typealias Index = Value.Index
    public typealias Iterator = Value.Iterator
    public typealias SubSequence = Value.SubSequence

    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}
