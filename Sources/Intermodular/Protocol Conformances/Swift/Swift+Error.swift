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
        if let value = try? cast(value, to: _opaque_Hashable.self) {
            value.hash(into: &hasher)
        } else {
            value.localizedDescription.hash(into: &hasher)
        }
    }
    
    public func `throw`() throws -> Never {
        throw value
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description && lhs.localizedDescription == rhs.localizedDescription
    }
}

extension Array: Error where Element: Error {
    
}

public struct CustomStringError: _opaque_Hashable, Codable, CustomStringConvertible, Error, ExpressibleByStringLiteral, Hashable {
    public let description: String
    
    public var localizedDescription: String {
        return description
    }
    
    public init(description: String) {
        self.description = description
    }
    
    public init(stringLiteral value: String) {
        self.init(description: value)
    }
    
    public init(from error: Error) {
        self.init(description: String(describing: error))
    }
}

public struct EmptyError: Hashable, Error, CustomStringConvertible {
    public let location: SourceCodeLocation?
    
    public var description: String {
        return "Empty error at \(location ?? "<unspecified>" as Any)"
    }
    
    private init(location: SourceCodeLocation? = nil) {
        self.location = location
    }
    
    public init(atFile file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
        self.init(location: .exact(.init(file: file, function: function, line: line, column: column)))
    }
}

public struct Erroneous<Value>: Error, Wrapper {
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
