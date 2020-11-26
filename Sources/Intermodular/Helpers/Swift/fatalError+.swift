//
// Copyright (c) Vatsal Manot
//

import Swift

public func fatalError(
    reason: Never.Reason,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> Never {
    Never.materialize(reason: reason, file: file, function: function, line: line)
}

extension Never {
    public enum Reason: Error {
        case abstract
        case functionFailure
        case illegal
        case impossible
        case irrational
        case unavailable
        case unimplemented
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
            case .unavailable:
                fatalError("\(function) unavailable")
            case .unimplemented:
                fatalError("\(function) unimplemented", file: file, line: line)
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
