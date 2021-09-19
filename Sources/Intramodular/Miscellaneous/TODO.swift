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
        case implement
        case improve
        case modernize
        case optimize
        case refactor
        case remove
        case rethink
        case test
    }
    
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func whole(_ action: Action..., note: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
    }
    
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func whole<T>(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () -> T
    ) -> T {
        body()
    }
    
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func here(_ action: Action..., note: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
    }
}

public enum TODO {
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static var unimplemented: Never {
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

public func debugOnly<T>(_ body: () throws -> T) rethrows -> T? {
    if isDebugAssertConfiguration {
        return try body()
    } else {
        return nil
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
public func hack<T>(_ message: StaticString? = nil, _ f: (() throws -> T)) rethrows -> T {
    return try f()
}

@inlinable
public func undocumented<T>(_ f: (() -> T)) -> T {
    return f()
}

public func warn(file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
    debugPrint("This should be happening!")
}
