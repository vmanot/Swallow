//
// Copyright (c) Vatsal Manot
//

import Swallow

@usableFromInline
enum _AssertionFailureError: Error {
    case assertionFailed(SourceCodeLocation)
}

extension Task where Failure == Error {
    @discardableResult
    public func _expectNoThrow() -> Task {
        Task(priority: .utility) {
            try await Diagnostics._warnOnThrow {
                try await self.value
            }
        }
    }
}

@inline(__always)
@_transparent
public func assertNotNil<T>(_ x: T?) {
    guard x != nil else {
        runtimeIssue("Unexpectedly found nil.")
        
        return
    }
}

@inline(__always)
@_transparent
public func _tryAssert(
    _ condition: Bool,
    _ message: String? = nil,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws {
    guard condition else {
        if let message = message {
            runtimeIssue(message)
        }
        
        throw _AssertionFailureError.assertionFailed(
            .init(
                file: file,
                function: function,
                line: line,
                column: nil
            )
        )
    }
}

@inline(__always)
@_transparent
public func _tryAssert(
    _ message: String? = nil,
    _ condition: () throws -> Bool,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws {
    guard try condition() else {
        if let message = message {
            runtimeIssue(message)
        }

        throw _AssertionFailureError.assertionFailed(.init(file: file, function: function, line: line, column: nil))
    }
}

@_transparent
public func _expectNoThrow<T>(_ fn: () throws -> T?) -> T? {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)

        return nil
    }
}

@_transparent
@_disfavoredOverload
public func _expectNoThrow<T>(_ fn: () throws -> T) throws -> T {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)
        
        throw error
    }
}

@_transparent
public func _warnOnThrow<T>(_ fn: () throws -> T) throws -> T {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)
        
        throw error
    }
}

@_transparent
public func _warnOnThrow<T>(_ fn: () async throws -> T) async throws -> T {
    do {
        return try await fn()
    } catch {
        runtimeIssue(error)
        
        throw error
    }
}

@_transparent
public func _expectNoThrow<T>(_ fn: () async throws -> T?) async -> T? {
    do {
        return try await fn()
    } catch {
        runtimeIssue(error)
                
        return nil
    }
}

@_disfavoredOverload
@_transparent
public func _expectNoThrowExpression<T>(_ fn: @autoclosure () throws -> T?) -> T? {
    do {
        return try fn()
    } catch {
        runtimeIssue(error)
        
        return nil
    }
}

@_disfavoredOverload
@_transparent
public func _expectNoThrowExpression<T>(_ fn: @autoclosure () async throws -> T?) async -> T? {
    do {
        return try await fn()
    } catch {
        runtimeIssue(error)
                
        return nil
    }
}

@_transparent
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

@_transparent
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

@_transparent
public func _catchAndMapError<Error: Swift.Error, Result>(
    to error: @autoclosure () -> Error,
    operation: () throws -> Result
) throws -> Result {
    do {
        return try operation()
    } catch {
        throw error
    }
}

@_transparent
public func _catchAndMapError<Error: Swift.Error, Result>(
    to error: @autoclosure () -> Error,
    operation: () async throws -> Result
) async throws -> Result {
    do {
        return try await operation()
    } catch(_) {
        throw error()
    }
}

@_transparent
public func _catchAndMapError<Error: Swift.Error, Result>(
    to error: (AnyError) -> Error,
    operation: () throws -> Result
) throws -> Result {
    do {
        return try operation()
    } catch {
        throw error
    }
}

@_transparent
public func _catchAndMapError<Error: Swift.Error, Result>(
    to error: (AnyError) -> Error,
    operation: () async throws -> Result
) async throws -> Result {
    do {
        return try await operation()
    } catch {
        throw error
    }
}
