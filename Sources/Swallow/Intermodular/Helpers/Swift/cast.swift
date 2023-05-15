//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swift

@inlinable
public func _openExistentialAndCast<T>(
    _ value: T,
    to type: Any.Type,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> Any {
    let _type: Any.Type = type
    
    func _cast<T>(to type: T.Type) -> Result<Any, Error> {
        Result(catching: {
            try cast(value, to: type)
        })
    }
    
    let result = _openExistential(_type, do: _cast)
    
    return try result.get()
}

@inlinable
public func _openExistentialAndCast<T, U>(
    _ value: T,
    to type: U.Type = U.self,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> U {
    try cast(_openExistentialAndCast(value, to: type as Any.Type), to: type)
}

@inlinable
public func cast<T, U>(
    _ value: T,
    to type: U.Type = U.self,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> U {
    guard let result = value as? U else {
        throw RuntimeCastError.invalidTypeCast(
            from: __fixed__type(of: value),
            to: type,
            value: value,
            location: .init(file: file, fileID: fileID, function: function, line: line, column: column)
        )
    }
    
    return result
}

@inlinable
public func cast<T, U>(
    _ value: T,
    to type: U.Type = U.self,
    default: U,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) -> U {
    guard let result = _runtimeCast(value, to: type) else {
        return `default`
    }
    
    return result
}

// MARK: - Auxiliary

@usableFromInline
func _runtimeCast<T, U>(_ value: T, to otherType: U.Type) -> U? {
    var _value: Any?
    
    if let value = value as? (any OptionalProtocol) {
        _value = value._wrapped
    }
    
    if _value == nil {
        if otherType == Optional<Any>.self {
            return (Optional<Any>.none as! U)
        }
    }
    
    guard !(value is NSNull) else {
        return nil
    }
    
    if let result = _value as? U {
        return result
    } else {
        return nil
    }
}

public enum RuntimeCastError: CustomStringConvertible, LocalizedError {
    case invalidTypeCast(from: Any.Type, to: Any.Type, value: Any, location: SourceCodeLocation)
    
    public var description: String {
        switch self {
            case let .invalidTypeCast(sourceType, destinationType, value, location): do {
                if let value = Optional(_unwrapping: value) {
                    var description = "Could not cast \(value) to '\(destinationType)'"
                    
                    if let file = location.file, file != #file {
                        description = "\(location): \(description)"
                    }
                    
                    return description
                } else {
                    var description = "Could not cast value of type '\(sourceType)' to '\(destinationType)'"
                    
                    if let file = location.file, file != #file {
                        description = "\(location): \(description)"
                    }
                    
                    return description
                }
            }
        }
    }
    
    public var errorDescription: String? {
        description
    }
}

@inlinable
public func unsafeBitCast<T, U>(_ x: T) -> U {
    return unsafeBitCast(x, to: U.self)
}

@_optimize(none)
@inline(never)
public func __fixed__type(of x: Any) -> Any.Type {
    let x = _takeOpaqueExistentialUnoptimized(x)
    
    func _swift_type<T>(of value: T) -> T.Type {
        Swift.type(of: value) as T.Type
    }
    
    let firstAttempt = type(of: _takeOpaqueExistentialUnoptimized(x))
    let secondAttempt = _openExistential(x, do: _swift_type)
    
    if firstAttempt != Any.self || firstAttempt != Any.Protocol.self {
        return firstAttempt
    } else {
        assert(secondAttempt != Any.self)
        assert(secondAttempt != Any.Protocol.self)
        
        return secondAttempt
    }
}

/// Prevent the compiler from making any optimizations when passing an opaque existential value.
@_optimize(none)
@inline(never)
public func _takeOpaqueExistentialUnoptimized(_ value: Any) -> Any {
    return value
}

public func _isValueOfGivenType<Value>(
    _ value: Value,
    type: Any.Type
) -> Bool {
    func check<T>(_ type: T.Type) -> Bool {
        value is T
    }
    
    return _openExistential(type, do: check)
}

public struct _TypeCastTo2<T, U> {
    public let base: Any
    
    public var first: T {
        base as! T
    }
    
    public var second: U {
        base as! U
    }
    
    public init(base: Any) throws {
        self.base = base
        
        _ = try cast(base, to: T.self)
        _ = try cast(base, to: U.self)
    }
}

extension _TypeCastTo2: @unchecked Sendable where T: Sendable, U: Sendable {
    
}

public protocol _ArrayProtocol: Initiable {
    func _opaque_castElementType(to _: Any.Type) throws -> _ArrayProtocol
    func _castElementType<T>(to _: T.Type) throws -> [T]
}

extension Array: _ArrayProtocol {
    public func _opaque_castElementType(
        to type: Any.Type
    ) throws -> _ArrayProtocol {
        func castElementType<T>(to elementType: T.Type) throws -> _ArrayProtocol {
            try map({ try cast($0, to: elementType) })
        }
        
        return try _openExistential(type, do: castElementType)
    }
    
    public func _castElementType<T>(to type: T.Type) throws -> [T] {
        try map({ try cast($0, to: type) })
    }
}

public func _makeArrayType(withElementType element: Any.Type) -> _ArrayProtocol.Type {
    func makeArrayType<T>(from type: T.Type) -> _ArrayProtocol.Type {
        Array<T>.self
    }
    
    return _openExistential(element, do: makeArrayType)
}

/// Prevent the compiler from making any optimizations when passing an opaque existential value.
@_optimize(none)
@inline(never)
public func _strictlyUnoptimized_passOpaqueExistential(_ value: Any) -> Any {
    return value
}
