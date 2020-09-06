//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swift

public enum RuntimeCastError: Error {
    case invalidTypeCast(from: Any.Type, to: Any.Type, value: Any, location: SourceCodeLocation)
}

@inlinable
public func castCore<T, U>(_ value: T, to: U.Type) -> U? {
    if let result = value as? U {
        return result
    } else {
        return nil
    }
}

@inlinable
public func cast<T, U>(_ value: T, to type: U.Type = U.self, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) throws -> U {
    guard let result = value as? U else {
        throw RuntimeCastError
            .invalidTypeCast(
                from: Swift.type(of: value),
                to: type,
                value: value,
                location: .init(file: file, function: function, line: line, column: column)
        )
    }
    
    return result
}

@inlinable
public func cast<T, U>(_ value: T, to type: U.Type = U.self, default: U, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) -> U {
    guard let result = castCore(value, to: type) else {
        return `default`
    }
    
    return result
}

@inlinable
public func cast<T, U>(_ value: T?, to type: U.Type = U.self, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) throws -> U? {
    guard let value = value else {
        return nil
    }

    guard !(value is NSNull) else {
        return nil
    }
    
    guard let result = castCore(value, to: type) else {
        throw RuntimeCastError
            .invalidTypeCast(
                from: Swift.type(of: value),
                to: type,
                value: value,
                location: .init(file: file, function: function, line: line, column: column)
        )
    }
    
    return result
}

// MARK: - Helpers -

prefix operator -!>

@inlinable
public prefix func -!> <T, U>(rhs: T) -> U {
    return try! cast(rhs, to: U.self)
}

@inlinable
public prefix func -!> <T, U>(rhs: T?) -> U {
    return try! cast(rhs, to: U.self)
}

prefix operator -?>

@inlinable
public prefix func -?> <T, U>(rhs: T) -> U? {
    return try? cast(rhs, to: U.self)
}

@inlinable
public prefix func -?> <T, U>(rhs: T?) -> U? {
    return try? cast(rhs, to: U.self)
}

@inlinable
public func unsafeBitCast<T, U>(_ x: T) -> U {
    return unsafeBitCast(x, to: U.self)
}

prefix operator -*>

@inlinable
public prefix func -*> <T, U>(rhs: T) -> U {
    return unsafeBitCast(rhs)
}
