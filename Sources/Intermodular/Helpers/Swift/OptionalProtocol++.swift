//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK: - Implementation -

extension MutableEitherRepresentable where Self: OptionalProtocol {
    public var wrapped: Wrapped? {
        get {
            return eitherValue.leftValue
        } set {
            eitherValue.leftValue = newValue
        }
    }
    
    public init(_ wrapped: Wrapped?) {
        self.init(wrapped ||| ())
    }
}

// MARK: - Extensions -

extension OptionalProtocol {
    public func filter(_ f: ((Wrapped) -> Bool)) -> Self {
        guard let wrapped = wrapped, f(wrapped) else {
            return .init(.right(()))
        }
        
        return self
    }
}

extension OptionalProtocol {
    public mutating func mutate<T>(with f: ((inout Wrapped) throws -> T)) rethrows -> T? {
        guard var wrapped = wrapped else {
            return nil
        }
        
        let result = try f(&wrapped)
        
        self.wrapped = wrapped
        
        return result
    }
    
    public mutating func defaulting(to x: @autoclosure () -> Wrapped) -> Self.Wrapped {
        if wrapped == nil {
            wrapped = x()
        }
        
        return wrapped!
    }
}

extension OptionalProtocol where Wrapped: Initiable {
    public mutating func initializeIfNil() {
        wrapped = initializedIfNil
    }
    
    public var initializedIfNil: Wrapped {
        get {
            return wrapped ?? .init()
        } set {
            wrapped = newValue
        }
    }
}

extension OptionalProtocol where Wrapped: ExpressibleByNilLiteral {
    public mutating func setNilIfNil() {
        wrapped = nilIfNil
    }
    
    public var nilIfNil: Wrapped {
        get {
            return wrapped ?? nil
        } set {
            wrapped = newValue
        }
    }
}

extension OptionalProtocol where Wrapped: ExpressibleByNilLiteral & OptionalProtocol, Wrapped.Wrapped: ExpressibleByNilLiteral {
    public mutating func setNilIfNil() {
        wrapped = .init(nilIfNil)
    }
    
    public var nilIfNil: Wrapped.Wrapped {
        get {
            return (wrapped?.wrapped).nilIfNil
        } set {
            wrapped.nilIfNil.wrapped = newValue
        }
    }
}

extension OptionalProtocol where Wrapped: ExpressibleByNilLiteral & OptionalProtocol, Wrapped.Wrapped: ExpressibleByNilLiteral & OptionalProtocol, Wrapped.Wrapped.Wrapped: ExpressibleByNilLiteral {
    public mutating func setNilIfNil() {
        wrapped = Wrapped(nilIfNil)
    }
    
    public var nilIfNil: Wrapped.Wrapped.Wrapped {
        get {
            return (wrapped?.wrapped?.wrapped).nilIfNil
        } set {
            wrapped.nilIfNil.wrapped.nilIfNil.wrapped = newValue
        }
    }
}

infix operator !>: LogicalConjunctionPrecedence

extension OptionalProtocol {
    public func then<T>(_ value: @autoclosure () -> T) -> T? {
        return isNotNil ? value() : nil
    }
    
    public static func !> <T>(lhs: Self, rhs: @autoclosure () -> T) -> T? {
        return lhs.then(rhs())
    }
    
    public func then<T>(_ value: @autoclosure () -> T?) -> T? {
        return isNotNil ? value() : nil
    }
    
    public static func !> <T>(lhs: Self, rhs: @autoclosure () -> T?) -> T? {
        return lhs.then(rhs())
    }
}

infix operator ?>: LogicalConjunctionPrecedence

extension OptionalProtocol {
    public func or(_ value: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        return try wrapped ?? value()
    }
    
    public static func ?> (lhs: Self, rhs: @autoclosure () -> Wrapped) -> Wrapped {
        return lhs.or(rhs())
    }
    
    public func or(_ value: @autoclosure () throws -> Wrapped?) rethrows -> Wrapped? {
        return try wrapped ?? value()
    }
    
    public static func ?> (lhs: Self, rhs: @autoclosure () -> Wrapped?) -> Wrapped? {
        return lhs.or(rhs())
    }
    
    public func or<T>(_ value: @autoclosure () throws -> T) rethrows -> Either<Self.Wrapped, T> {
        return try wrapped ||| value()
    }
}

extension OptionalProtocol {
    public func or(_ condition: Bool, then value: @autoclosure () -> Wrapped) -> Wrapped? {
        return wrapped ?? (condition ? (wrapped ?? value()): nil)
    }
    
    public func or(_ condition: Bool, then value: @autoclosure () -> Wrapped?) -> Wrapped? {
        return wrapped ?? (condition ? (wrapped ?? value()): nil)
    }
}
