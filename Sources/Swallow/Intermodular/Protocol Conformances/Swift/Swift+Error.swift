//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased error.
public struct AnyError: CustomDebugStringConvertible, Error, Hashable, @unchecked Sendable {
    public let base: Error
    
    public var description: String {
        return CustomStringConvertibleOnly(base).description
    }
    
    public var localizedDescription: String {
        String(describing: base)
    }
    
    public init(erasing error: Error) {
        self.base = (error as? AnyError)?.base ?? error
    }
    
    init(_ base: Error) {
        self.init(erasing: base)
    }
    
    public init(description: String) {
        self.init(CustomStringError(description: description))
    }
    
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(type(of: base)).hash(into: &hasher)
        
        if let value = try? cast(base, to: (any Hashable).self) {
            value.hash(into: &hasher)
        } else {
            String(describing: base).hash(into: &hasher)
        }
    }
    
    public func `throw`() throws -> Never {
        throw base
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description && lhs.localizedDescription == rhs.localizedDescription
    }
}

extension Array: Error where Element: Error {
    
}

public struct CustomStringError: Codable, CustomStringConvertible, Error, ExpressibleByStringLiteral, Hashable, Sendable {
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

public struct _PlaceholderError: Hashable, Error, CustomStringConvertible, Sendable {
    public let note: String?
    public let location: SourceCodeLocation?
    
    public var description: String {
        return "Empty error at \(location ?? "<unspecified>" as Any)"
    }
    
    private init(note: String? = nil, location: SourceCodeLocation? = nil) {
        self.note = note
        self.location = location
        
        runtimeIssue("This is a placeholder error and should not be used in production.")
    }
    
    public init(
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.init(
            location: .exact(
                .init(
                    file: file,
                    fileID: fileID,
                    function: function,
                    line: line,
                    column: column
                )
            )
        )
    }
}

/// A thin wrapper that can wrap an arbitrary value as a Swift error.
public struct Erroneous<Value>: Error, Wrapper {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

extension Erroneous: Codable where Value: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(Value(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension Erroneous: Equatable where Value: Equatable {
    
}

extension Erroneous: Hashable where Value: Hashable {
    
}

extension Erroneous: Sendable where Value: Sendable {
    
}

public struct ErrorPair<T: Error, U: Error>: CustomDebugStringConvertible, CustomStringConvertible, Error, Wrapper, @unchecked Sendable {
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
