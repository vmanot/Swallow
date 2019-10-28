//
// Copyright (c) Vatsal Manot
//

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
    public static func here(_ action: Action..., note: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
    }

    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func below(_ action: Action..., note: String? = nil, file: StaticString = #file, line: UInt = #line) {

    }
}

public enum TODO: Error {
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

public func debugOnly<T, U>(_ type: T.Type, _ body: () throws -> U) rethrows -> U? {
    if isDebugEnabled(for: type) {
        return try debugOnly(body)
    } else {
        return nil
    }
}

struct TypeDebugging {
    var isEnabled: Bool
}

var typeDebugMap: [ObjectIdentifier: TypeDebugging] = [:]

public func isDebugEnabled<T>(for type: T.Type) -> Bool {
    return typeDebugMap[.init(type)]?.isEnabled ?? true
}

public func debug<T>(_ type: T.Type, _ body: () -> ()) {
    if isDebugEnabled(for: type) {
        debug(body)
    }
}

public protocol StaticBoolean {
    static var value: Bool { get }
}

public struct IsDebug: StaticBoolean {
    public static var value: Bool {
        return true
    }
}

@inlinable
@inline(__always)
public func static_if(_ boolean: StaticBoolean.Type, do f: (() throws -> ())) rethrows {
    if boolean.value {
        try f()
    }
}

@inlinable
@inline(__always)
public func fragile<T>(_ f: () -> T) -> T {
    return f()
}

@inlinable
@inline(__always)
public func fragile<T>(_ x: @autoclosure () -> T) -> T {
    return x()
}

@inlinable
@inline(__always)
public func hack<T>(_ message: StaticString? = nil, _ f: (() throws -> T)) rethrows -> T {
    return try f()
}

@inlinable
@inline(__always)
public func undocumented<T>(_ f: (() -> T)) -> T {
    return f()
}

public func warn(file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
    debugPrint("This should be happening!")
}
