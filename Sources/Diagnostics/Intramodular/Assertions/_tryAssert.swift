//
// Copyright (c) Vatsal Manot
//

import Swallow

public func _tryAssert(_ condition: Bool, message: String? = nil) throws {
    guard condition else {
        throw _PlaceholderError()
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
