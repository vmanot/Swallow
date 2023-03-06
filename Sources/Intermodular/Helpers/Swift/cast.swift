//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swift

@inlinable
public func cast<T, U>(
    _ value: T,
    to type: U.Type = U.self,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> U {
    guard let result = value as? U else {
        throw RuntimeCastError.invalidTypeCast(
            from: Swift.type(of: value),
            to: type,
            value: value,
            location: .init(file: file, function: function, line: line, column: column)
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
            case let .invalidTypeCast(sourceType, destinationType, _, _):
                return "Could not cast value of type '\(sourceType)' to '\(destinationType)'"
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
