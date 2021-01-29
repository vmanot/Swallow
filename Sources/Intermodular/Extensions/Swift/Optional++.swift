//
// Copyright (c) Vatsal Manot
//

import Swift

infix operator ??=: AssignmentPrecedence
infix operator =??: AssignmentPrecedence

extension Optional {
    @inlinable
    public init(_ wrapped: @autoclosure () -> Wrapped, if condition: Bool) {
        self = condition ? wrapped() : nil
    }
    
    @inlinable
    public init(_ wrapped: @autoclosure () -> Optional<Wrapped>, if condition: Bool) {
        self = condition ? wrapped() : nil
    }
    
    @inlinable
    public func ifNone(perform action: (() throws -> ())) rethrows {
        if self == nil {
            try action()
        }
    }
}

extension Optional {
    @inlinable
    public func map(into wrapped: inout Wrapped) {
        map { wrapped = $0 }
    }
    
    @inlinable
    public mutating func mutate<T>(_ transform: ((inout Wrapped) throws -> T)) rethrows -> T? {
        guard self != nil else {
            return nil
        }
        
        return try transform(&self!)
    }
    
    @inlinable
    public func castMap<T, U>(_ transform: ((T) -> U)) -> U? {
        return (-?>self).map(transform)
    }
    
    @inlinable
    public mutating func remove() -> Wrapped {
        defer {
            self = nil
        }
        
        return self!
    }
}

extension Optional {
    public static func ??= (lhs: inout Optional<Wrapped>, rhs: @autoclosure () -> Wrapped) {
        if lhs == nil {
            lhs = rhs()
        }
    }
    
    public static func ??= (lhs: inout Optional<Wrapped>, rhs: @autoclosure () -> Wrapped?) {
        if lhs == nil, let rhs = rhs() {
            lhs = rhs
        }
    }
    
    public static func =?? (lhs: inout Wrapped, rhs: Wrapped?) {
        if let rhs = rhs {
            lhs = rhs
        }
    }
    
    public static func =?? (lhs: inout Wrapped, rhs: Wrapped??) {
        lhs =?? rhs.compact()
    }
}

extension Optional {
    public func compact<T>() -> T? where Wrapped == T? {
        return self ?? .none
    }
    
    public func compact<T>() -> T? where Wrapped == T?? {
        return (self ?? .none) ?? .none
    }
    
    public func compact<T>() -> T? where Wrapped == T??? {
        return ((self ?? .none) ?? .none) ?? .none
    }
}

extension Optional {
    public enum UnwrappingError: Error {
        case unexpectedlyFoundNil(at: SourceCodeLocation)
    }
    
    @inlinable
    public func unwrapOrThrow(_ error: @autoclosure () throws -> Error) throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw try error()
        }
    }
    
    @inlinable
    public func orFatallyThrow(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            fatalError(message())
        }
    }
    
    @inlinable
    public func unwrap(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) throws -> Wrapped {
        guard let wrapped = self else {
            throw UnwrappingError.unexpectedlyFoundNil(at: .init(file: file, function: function, line: line, column: column))
        }
        
        return wrapped
    }
    
    @inlinable
    public func forceUnwrap(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> Wrapped {
        try! unwrap(file: file, line: line)
    }
}
