//
// Copyright (c) Vatsal Manot
//

import Swallow

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
