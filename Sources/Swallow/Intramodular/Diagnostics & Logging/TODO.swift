//
// Copyright (c) Vatsal Manot
//

import Swift

@dynamicMemberLookup
public enum TODO {
    public static subscript<T>(
        dynamicMember action: KeyPath<_Actions, Action>
    ) -> _CallFunctionAsFunction<T> {
        @_transparent
        get {
            _CallFunctionAsFunction()
        }
    }
    
    @_disfavoredOverload
    public static subscript(
        dynamicMember action: KeyPath<AbstractReturnValue._InstanceKeyPaths, AbstractReturnValue>
    ) -> Never {
        @_transparent
        get {
            fatalError("Unimplemented function or code path")
        }
    }
}

/// I know, terrible fucking name.
public struct _CallFunctionAsFunction<T> {
    public init() {
        
    }
    
    public func callAsFunction(_ fn: () throws -> T) rethrows -> T {
        try fn()
    }
}

/// A strongly typed to-do item.
extension TODO {
    public enum AbstractReturnValue {
        public struct _InstanceKeyPaths {
            public let unimplemented = AbstractReturnValue.unimplemented
            public let fixMe = AbstractReturnValue.fixMe
        }
        
        case unimplemented
        case fixMe
    }
    
    public struct _Actions {
        public let addressEdgeCase: Action = .addressEdgeCase
        public let benchmark: Action = .benchmark
        public let complete: Action = .complete
        public let document: Action = .document
        public let fix: Action = .fix
        public let maybeFix: Action = .maybeFix
        public let implement: Action = .implement
        public let improve: Action = .improve
        public let modernize: Action = .modernize
        public let optimize: Action = .optimize
        public let refactor: Action = .refactor
        public let remove: Action = .remove
        public let rethink: Action = .rethink
        public let test: Action = .test
    }
    
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

#if DEBUG
extension TODO {
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func whole(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
    }
}
#else
extension TODO {
    public static func whole(
        _ action: Action...,
        note: String? = nil
    ) {
        
    }
}
#endif

#if DEBUG
extension TODO {
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func whole<T>(
        _ action: Action...,
        note: String? = nil,
        _ body: () throws -> T
    ) rethrows -> T {
        try body()
    }
}
#else
extension TODO {
    public static func whole<T>(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () throws -> T
    ) rethrows -> T {
        try body()
    }
}
#endif

#if DEBUG
extension TODO {
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func here(
        _ action: Action...,
        note: String? = nil
    ) {
        
    }
}
#else
extension TODO {
    // @available(*, deprecated, message: "This should not be used in production code.")
    public static func here(
        _ action: Action...,
        note: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
    }
}
#endif

public var _isDebugAssertConfiguration: Bool {
    undocumented({ Swift._isDebugAssertConfiguration() })
}

public func debug(_ body: () -> ()) {
    if _isDebugAssertConfiguration {
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
