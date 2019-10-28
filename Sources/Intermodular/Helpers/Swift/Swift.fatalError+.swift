//
// Copyright (c) Vatsal Manot
//

import Swift

public enum SwiftFunctionError: Error {
    case abstractMethod
}

public func fatalError(_ error: Error) -> Never {
    fatalError(String(describing: error))
}

public func functionFailure(file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> Never {
    fatalError(String(describing: function) + " failure", file: file, line: line)
}

public func abstract(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("abstract method called", file: file, line: line)
}

public func abstract<T>(file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("abstract method called", file: file, line: line)
}

public func illegal(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("illegal", file: file, line: line)
}

public func illegal(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("illegal: \(message)", file: file, line: line)
}

public func illegal<T>(file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("illegal", file: file, line: line)
}

public func irrational(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("irrational", file: file, line: line)
}

public func irrational<T>(file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("irrational", file: file, line: line)
}

public func impossible(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("t'is but impossible", file: file, line: line)
}

public func impossible<T>(file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("t'is but impossible", file: file, line: line)
}

public func unavailable(_ function: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) unavailable")
}

public func unavailable<T>(_ function: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("\(function) unavailable")
}

public func unavailable<T, U>(_: T) -> U {
    fatalError("function unavailable")
}

public func unimplemented(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) unimplemented", file: file, line: line)
}
 
public func unimplemented<T>(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("\(function) unimplemented", file: file, line: line)
}

public func unimplemented<T, U>(_: T) -> U {
    fatalError("function unimplemented")
}

public func unmigrated(_ function: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) unimplemented", file: file, line: line)
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
    
    public static func materialize<T>(reason: Reason, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> T {
        switch reason {
        case .abstract:
            abstract(file: file, line: line)
        case .functionFailure:
            functionFailure(file: file, function: function, line: line)
        case .illegal:
            illegal(file: file, line: line)
        case .impossible:
            impossible(file: file, line: line)
        case .irrational:
            irrational(file: file, line: line)
        case .unavailable:
            unavailable(file: file, line: line)
        case .unimplemented:
            unimplemented(file: file, line: line)
        }
    }
}

extension Error {
    /// Halt the execution of the program with self thrown as a fatal error.
    public func fatalThrow(file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError(.init(describing: self), file: file, line: line)
    }

    /// Halt the execution of the program with self thrown as a fatal error.
    public func fatalThrow<T>(file: StaticString = #file, line: UInt = #line) -> T {
        fatalError(.init(describing: self), file: file, line: line)
    }
}
