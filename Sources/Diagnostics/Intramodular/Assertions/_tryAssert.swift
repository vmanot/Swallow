//
// Copyright (c) Vatsal Manot
//

import Swallow

@usableFromInline
enum _AssertionFailureError: Error {
    case assertionFailed(SourceCodeLocation)
}

@inline(__always)
public func _tryAssert(
    _ condition: Bool,
    message: String? = nil,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws {
    guard condition else {
        throw _AssertionFailureError.assertionFailed(.init(file: file, function: function, line: line, column: nil))
    }
}

@inline(__always)
public func _tryAssert(
    message: String? = nil,
    _ condition: () throws -> Bool,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws {
    guard try condition() else {
        throw _AssertionFailureError.assertionFailed(.init(file: file, function: function, line: line, column: nil))
    }
}

public func _expectedToNotThrow<T>(_ fn: () throws -> T?) -> T? {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)

        return nil
    }
}

public func _expectedToNotThrow<T>(_ fn: () async throws -> T?) async -> T? {
    do {
        return try await fn()
    } catch {
        runtimeIssue(error)
                
        return nil
    }
}

@_disfavoredOverload
public func _expectedToNotThrowExpression<T>(_ fn: @autoclosure () throws -> T?) -> T? {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)
        
        return nil
    }
}

@_disfavoredOverload
public func _expectedToNotThrowExpression<T>(_ fn: @autoclosure () async throws -> T?) async -> T? {
    do {
        return try await fn()
    } catch {
        runtimeIssue(error)
                
        return nil
    }
}

public func _runtimeIssueOnError<T>(
    _ fn: () throws -> T
) throws -> T {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)
                
        throw error
    }
}

public func _runtimeIssueOnError<T>(
    _ fn: () async throws -> T
) async throws -> T {
    do {
        return try await fn()
    } catch {
        runtimeIssue(error)
        
        throw error
    }
}
