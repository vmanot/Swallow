//
// Copyright (c) Vatsal Manot
//

import Swift

/// A strongly typed to-do item.
extension TODO {
    public enum Action {
        case addressEdgeCase
        case benchmark
        case complete
        case document
        case fix
        case maybeFix
        case implement
        case improve
        case modernize
        case optimize
        case refactor
        case remove
        case rethink
        case test
    }
}

extension TODO {
    #if DEBUG
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func whole(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
    }
    #else
    public static func whole(
        _ action: Action...,
        note: String? = nil
    ) {
        
    }
    #endif
    
    #if DEBUG
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func whole<T>(
        _ action: Action...,
        note: String? = nil,
        _ body: () throws -> T
    ) rethrows -> T {
        try body()
    }
    #else
    public static func whole<T>(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () throws -> T
    ) rethrows -> T {
        try body()
    }
    #endif
    
    #if DEBUG
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func here(
        _ action: Action...,
        note: String? = nil
    ) {
        
    }
    #else
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func here(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
    }
    #endif
}

public enum TODO {
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static var unimplemented: Never {
        fatalError("Unimplemented function or code path")
    }
    
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static var fixMe: Never {
        fatalError("Unimplemented function or code path")
    }
}

var isDebugAssertConfiguration: Bool {
    return undocumented({ _isDebugAssertConfiguration() })
}

public func debug(_ body: () -> ()) {
    if isDebugAssertConfiguration {
        body()
    }
}

@inlinable
public func fragile<T>(_ f: () -> T) -> T {
    return f()
}

@inlinable
public func fragile<T>(_ x: @autoclosure () -> T) -> T {
    return x()
}

@inlinable
public func undocumented<T>(_ f: (() -> T)) -> T {
    return f()
}
