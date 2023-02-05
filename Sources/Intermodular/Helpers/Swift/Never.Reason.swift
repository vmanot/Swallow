//
// Copyright (c) Vatsal Manot
//

import Swift

extension Never {
    /// A reason for why something returns `Never`.
    ///
    /// This type is a work-in-progress. Do not use this type directly in your code.
    public enum Reason: Error {
        case abstract
        case functionFailure
        case illegal
        case impossible
        case irrational
        case osUnsupported
        case unavailable
        case unimplemented
        case unsupported
    }
    
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
            case .functionFailure:
                fatalError(String(describing: function) + " failure", file: file, line: line)
            case .illegal:
                fatalError("illegal", file: file, line: line)
            case .impossible:
                fatalError("t'is but impossible", file: file, line: line)
            case .irrational:
                fatalError("irrational", file: file, line: line)
            case .osUnsupported:
                fatalError("\(function) unsupported on this operating-system", file: file, line: line)
            case .unavailable:
                fatalError("\(function) unavailable", file: file, line: line)
            case .unimplemented:
                fatalError("\(function) unimplemented", file: file, line: line)
            case .unsupported:
                fatalError("\(function) unsupported", file: file, line: line)
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

// MARK: - API -

public func fatalError(
    reason: Never.Reason,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> Never {
    Never.materialize(reason: reason, file: file, function: function, line: line)
}
