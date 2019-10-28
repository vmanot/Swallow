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
    public func iff(_ condition: Bool) -> Optional {
        return condition ? self : .none
    }

    @inlinable
    public func iff(_ predicate: ((Wrapped) -> Bool)) -> Optional {
        return flatMap({ predicate($0) ? $0 : nil })
    }

    @inlinable
    public func ifNone(do f: (() throws -> ())) rethrows {
        if self == nil {
            try f()
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
