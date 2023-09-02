//
// Copyright (c) Vatsal Manot
//

import Swift

extension Never {
    /// A reason for why something returns `Never`.
    ///
    /// This type is a work-in-progress. Do not use this type directly in your code.
    @frozen
    public struct Reason: Hashable, Error {
        public enum _Base: String, Hashable {
            case abstract
            case illegal
            case impossible
            case unavailable
            case unexpected
            case unimplemented
            case unsupported
        }
        
        public let _base: _Base
        
        @_transparent
        public init(_base base: _Base) {
            self._base = base
            
            runtimeIssue("This code path should never be invoked (reason: \(base.rawValue)).")
        }
    }
}

extension Never.Reason {
    @_transparent
    public static var abstract: Self {
        assertionFailure()
        
        return .init(_base: .abstract)
    }

    public static var illegal: Self {
        .init(_base: .illegal)
    }
    
    @_transparent
    public static var impossible: Self {
        assertionFailure()

        return .init(_base: .impossible)
    }
            
    @_transparent
    public static var unavailable: Self {
        .init(_base: .unavailable)
    }
    
    @_transparent
    public static var unexpected: Self {
        .init(_base: .unexpected)
    }
    
    @_transparent
    public static var unimplemented: Self {
        assertionFailure()
        
        return .init(_base: .unimplemented)
    }
    
    @_transparent
    public static var unsupported: Self {
        .init(_base: .unsupported)
    }
}

extension Never {
    public static func materialize() -> Never {
        fatalError()
    }
    
    public static func materialize<T, U>(_: T) -> U {
        fatalError()
    }
    
    public static func materialize(
        reason: Reason,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> Never {
        switch reason {
            case .abstract:
                fatalError("abstract method called", file: file, line: line)
            case .illegal:
                fatalError("illegal", file: file, line: line)
            case .impossible:
                fatalError("t'is but impossible", file: file, line: line)
            case .unavailable:
                fatalError("\(function) unavailable", file: file, line: line)
            case .unimplemented:
                fatalError("\(function) unimplemented", file: file, line: line)
            case .unsupported:
                fatalError("\(function) unsupported", file: file, line: line)
            default:
                fatalError()
        }
    }
    
    @_disfavoredOverload
    public static func materialize<T>(
        reason: Reason,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> T {
        materialize(reason: reason, file: file, function: function, line: line) as Never
    }
}

// MARK: - API

public func fatalError(
    reason: Never.Reason,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> Never {
    Never.materialize(reason: reason, file: file, function: function, line: line)
}
