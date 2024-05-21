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

@_transparent
public func assertNotNil<T>(_ x: T?) {
    guard x != nil else {
        runtimeIssue("Unexpectedly found nil.")
        
        return
    }
}

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

@_transparent
@discardableResult
public func _tryAssert<T, U>(
    _ x: T,
    is type: U.Type,
    _ message: String? = nil,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws -> Bool {
    do {
        _ = try cast(x, to: type)
        
        return true
    } catch {
        return false
    }
}

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
    } catch(_) {
        throw error()
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
    to makeError: (AnyError) -> Error,
    operation: () throws -> Result
) throws -> Result {
    do {
        return try operation()
    } catch {
        throw makeError(AnyError(erasing: error))
    }
}

@_transparent
public func _catchAndMapError<Error: Swift.Error, Result>(
    to makeError: (AnyError) -> Error,
    operation: () async throws -> Result
) async throws -> Result {
    do {
        return try await operation()
    } catch {
        throw makeError(AnyError(erasing: error))
    }
}
