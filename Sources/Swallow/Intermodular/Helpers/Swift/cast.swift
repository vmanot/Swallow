//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swift

@inlinable
public func _opaque_openExistentialAndCast<T>(
    _ value: T,
    to type: Any.Type,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> Any {
    let _type: Any.Type = type
    
    func _cast<U>(to type: U.Type) -> Result<Any, Error> {
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
    try cast(_opaque_openExistentialAndCast(value, to: type as Any.Type), to: type)
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
            from: __fixed_type(of: value),
            to: type,
            value: value,
            location: .init(file: file, fileID: fileID, function: function, line: line, column: column)
        )
    }
    
    return result
}

@inlinable
public func _forceCast<T, U>(
    _ value: T,
    to type: U.Type = U.self,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> U {
    return try! cast(value, to: type)
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
                    var description = "Could not cast value \(value) of type '\(sourceType)' to '\(destinationType)'"
                    
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
public func __fixed_type<T>(of x: T) -> Any.Type {
    __fixed_type(ofOpaque: x)
}

@_optimize(none)
@inline(never)
private func __fixed_type(ofOpaque x: Any) -> Any.Type {
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

public func __fixed_opaqueExistential(_ value: Any) -> Any {
    let type = __fixed_type(of: value)
    
    do {
        return try _opaque_openExistentialAndCast(value, to: type)
    } catch {
        assertionFailure()
        
        return value
    }
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

public func cast<T, U, Result>(
    _ value: inout T,
    to type: U.Type,
    _ body: (inout U) -> Result
) throws -> Result {
    var _value = try cast(value, to: U.self)
    
    let result = body(&_value)
    
    value = try cast(_value, to: T.self)
    
    return result
}

public struct _TypeCastTo2<T, U> {
    public private(set) var base: Any
    
    public var first: T {
        get {
            base as! T
        } set {
            base = newValue
        }
    }
    
    public var second: U {
        get {
            base as! U
        } set {
            base = newValue
        }
    }
    
    public init(base: Any) throws {
        self.base = base
        
        _ = try cast(base, to: T.self)
        _ = try cast(base, to: U.self)
    }
}

extension _TypeCastTo2: @unchecked Sendable where T: Sendable, U: Sendable {
    
}

public protocol _ProtocolizableType {
    
}

extension _ProtocolizableType {
    public static func _ProtocolizableType_withInstance<T>(
        _ body: (Self.Type) throws -> T
    ) rethrows -> T {
        try body(self)
    }

    public func _ProtocolizableType_withInstance<T>(
        _ body: (Self) throws -> T
    ) rethrows -> T {
        try body(self)
    }
}

public protocol _ArrayProtocol<Element>: _ProtocolizableType, Initiable, RandomAccessCollection {
    static var _opaque_ArrayProtocol_ElementType: Any.Type { get }
    
    func _opaque_castElementType(to _: Any.Type) throws -> any _ArrayProtocol
    func _castElementType<T>(to _: T.Type) throws -> [T]
    
    static func _ProtocolizableType_withInstance<T>(
        _ body: (Array<Element>.Type) throws -> T
    ) rethrows -> T

    func _ProtocolizableType_withInstance<T>(
        _ body: (Array<Element>) throws -> T
    ) rethrows -> T 
}

public protocol _IdentifierIndexingArrayOf_Protocol<Element>: _ProtocolizableType, Initiable, RandomAccessCollection where Element: Identifiable, Element.ID == Self.ID {
    associatedtype ID
    
    static func _ProtocolizableType_withInstance<T>(
        _ body: (IdentifierIndexingArrayOf<Element>.Type) throws -> T
    ) rethrows -> T

    func _ProtocolizableType_withInstance<T>(
        _ body: (IdentifierIndexingArrayOf<Element>) throws -> T
    ) rethrows -> T
}

extension IdentifierIndexingArray: _ProtocolizableType {
    
}

extension Array: _ArrayProtocol {
    public static var _opaque_ArrayProtocol_ElementType: Any.Type {
        Element.self
    }
    
    public func _opaque_castElementType(
        to type: Any.Type
    ) throws -> any _ArrayProtocol {
        func castElementType<T>(to elementType: T.Type) throws -> any _ArrayProtocol {
            try map({ try cast($0, to: elementType) })
        }
        
        return try _openExistential(type, do: castElementType)
    }
    
    public func _castElementType<T>(to type: T.Type) throws -> [T] {
        try map({ try cast($0, to: type) })
    }
}

extension IdentifierIndexingArray: _IdentifierIndexingArrayOf_Protocol where Element: Identifiable, Element.ID == ID {
    
}

public func _makeArrayType(withElementType element: Any.Type) -> any _ArrayProtocol.Type {
    func makeArrayType<T>(from type: T.Type) -> any _ArrayProtocol.Type {
        Array<T>.self
    }
    
    return _openExistential(element, do: makeArrayType)
}

/// Prevent the compiler from making any optimizations when passing an opaque existential value.
@_optimize(none)
@inline(never)
public func _strictlyUnoptimized_passOpaqueExistential(_ value: Any) -> Any {
    func convert<T>(_ x: T) -> Any {
        x as Any
    }

    return _openExistential(value, do: convert)
}
