//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OptionalProtocol: _opaque_Optional, MutableEitherRepresentable where RightValue == Void {
    typealias Wrapped = LeftValue
}

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

extension Optional {
    public init<T: OptionalProtocol>(_ wrapped: T) where T.Wrapped == Wrapped {
        self = wrapped.leftValue
    }
}

// MARK: - Conformances -

extension ExpressibleByNilLiteral where Self: OptionalProtocol {
    public init(nilLiteral: ()) {
        self.init(Optional<Wrapped>.none)
    }
}
