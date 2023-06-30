//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol EitherValueConvertible {
    associatedtype LeftValue
    associatedtype RightValue
    
    typealias EitherValue = Either<LeftValue, RightValue>
    
    var eitherValue: Either<LeftValue, RightValue> { get }
}

public protocol MutableEitherValueConvertible: EitherValueConvertible {
    var eitherValue: Either<LeftValue, RightValue> { get set }
}

// MARK: - Extensions

extension EitherValueConvertible {
    public var leftValue: LeftValue? {
        get {
            guard case .left(let result) = eitherValue else {
                return nil
            }
            
            return result
        }
    }
    
    public var isLeft: Bool {
        return leftValue != nil
    }
    
    public var rightValue: RightValue? {
        get {
            guard case .right(let result) = eitherValue else {
                return nil
            }
            
            return result
        }
    }
    
    public var isRight: Bool {
        return rightValue != nil
    }
}

extension MutableEitherValueConvertible {
    public var leftValue: LeftValue? {
        get {
            if case .left(let value) = eitherValue {
                return value
            }
            
            return nil
        } set {
            if let newValue = newValue {
                eitherValue = .left(newValue)
            } else {
                assertionFailure()
            }
        }
    }
    
    public var rightValue: RightValue? {
        get {
            if case .right(let value) = eitherValue {
                return value
            }
            
            return nil
        } set {
            if let newValue = newValue {
                eitherValue = .right(newValue)
            } else {
                assertionFailure()
            }
        }
    }
}

extension EitherValueConvertible where LeftValue == RightValue {
    public var leftOrRight: LeftValue {
        return leftValue ?? rightValue!
    }
}

// MARK: - Auxiliary Extensions

extension EitherValueConvertible {
    @inlinable
    public func collapse<T>(_ f: ((LeftValue) throws -> T)) rethrows {
        _ = try leftValue.map(f)
    }
    
    @inlinable
    public func collapse<T>(_ f: ((RightValue) throws -> T)) rethrows {
        _ = try rightValue.map(f)
    }
    
    @inlinable
    public func collapse<T, U>(_ f: ((LeftValue) throws -> T), _ g: ((RightValue) throws -> U)) rethrows {
        _ = try leftValue.map(f)
        _ = try rightValue.map(g)
    }
    
    @inlinable
    public func collapse<T, U>(_ f: ((LeftValue) throws -> T), do x: @autoclosure () throws -> U) rethrows {
        try collapse(f, { _ in try x() })
    }
    
    @inlinable
    public func collapse<T, U>(do x: @autoclosure () throws -> T, _ f: ((RightValue) throws -> U)) rethrows {
        try collapse({ _ in try x() }, f)
    }
    
    @inlinable
    public func collapse<T, U>(do x: @autoclosure () throws -> T, do y: @autoclosure () throws -> U) rethrows {
        try collapse({ _ in try x() }, { _ in try y() })
    }
}

extension EitherValueConvertible {
    public func filter(_ leftPredicate: ((LeftValue) throws -> Bool), _ rightPredicate: ((RightValue) throws -> Bool)) rethrows -> EitherValue? {
        return try reduce({ try leftPredicate($0) &&-> .left($0) }, { try rightPredicate($0) &&-> .right($0) })
    }
    
    public func filterOrMap<T>(_ predicate: ((LeftValue) throws -> Bool), _ transform: ((RightValue) throws -> T)) rethrows -> Either<LeftValue, T>? {
        return try reduce({ try predicate($0) &&-> .left($0) }, { .right(try transform($0)) })
    }
}

extension EitherValueConvertible {
    public func map<T, U>(
        left f: ((LeftValue) throws -> T),
        right g: ((RightValue) throws -> U)
    ) rethrows -> Either<T, U> {
        return try leftValue.map(f) ||| rightValue.map(g)!
    }
    
    public func flatMap<T, U>(
        left transformLeft: ((LeftValue) throws -> T?),
        right transformRight: ((RightValue) throws -> U?)
    ) rethrows -> Either<T, U>? {
        switch eitherValue {
            case .left(let lhs):
                return try transformLeft(lhs).map({ Either.left($0) })
            case .right(let rhs):
                return try transformRight(rhs).map({ Either.right($0) })
        }
    }
    
    public func map<T>(
        left transform: ((LeftValue) throws -> T)
    ) rethrows -> Either<T, RightValue> {
        return try leftValue.map(transform) ||| rightValue!
    }
    
    public func map<T>(
        right transform: ((RightValue) throws -> T)
    ) rethrows -> Either<LeftValue, T> {
        return try leftValue ||| transform(rightValue!)
    }

    public func map<T, U>(_ f: ((LeftValue) throws -> T), _ g: ((RightValue) throws -> U)) rethrows -> Either<T, U> {
        return try leftValue.map(f) ||| rightValue.map(g)!
    }
    
    public func mapLeft<T>(_ f: ((LeftValue) throws -> T)) rethrows -> Either<T, RightValue> {
        return try map(f, id)
    }
    
    public func mapRight<T>(_ f: ((RightValue) throws -> T)) rethrows -> Either<LeftValue, T> {
        return try map(id, f)
    }
}

extension EitherValueConvertible {
    public func reduce<T>(left f: ((LeftValue) throws -> T), right g: ((RightValue) throws -> T)) rethrows -> T {
        try leftValue.map(f) ?? rightValue.map(g)!
    }
    
    public func reduce<T>(_ f: ((LeftValue) throws -> T), _ g: ((RightValue) throws -> T)) rethrows -> T {
        return try leftValue.map(f) ?? rightValue.map(g)!
    }
    
    public func reduce<T>(_ x: @autoclosure () throws -> T, _ f: ((RightValue) throws -> T)) rethrows -> T {
        return try reduce({ _ in try x() }, f)
    }
    
    public func reduce<T>(_ f: ((LeftValue) throws -> T), _ x: @autoclosure () throws -> T) rethrows -> T {
        return try reduce(f, { _ in try x() })
    }
    
    public func reduce<T>(_ x: @autoclosure () throws -> T, _ y: @autoclosure () throws -> T) rethrows -> T {
        return try reduce({ _ in try x() }, { _ in try y() })
    }
    
    public func reduce(_ f: ((LeftValue) throws -> RightValue)) rethrows -> RightValue {
        return try leftValue.map(f) ?? rightValue!
    }
    
    public func reduce(_ f: ((RightValue) throws -> LeftValue)) rethrows -> LeftValue {
        return try leftValue ?? rightValue.map(f)!
    }
}

extension EitherValueConvertible where LeftValue: EitherRepresentable {
    public func collapse(
        _ f: (LeftValue.LeftValue) throws -> (),
        _ g: (LeftValue.RightValue) throws -> (),
        _ h: (RightValue) throws -> ()
    ) rethrows {
        try collapse({ try $0.reduce(f, g) }, h)
    }
    
    public func reduce<T>(
        _ f: ((LeftValue.LeftValue) throws -> T),
        _ g: ((LeftValue.RightValue) throws -> T),
        _ h: ((RightValue) throws -> T)
    ) rethrows -> T {
        return try reduce({ try $0.reduce(f, g) }, h)
    }
}

extension MutableEitherValueConvertible {
    public mutating func mapOrMutate<T, U>(_ f: ((LeftValue) -> T), _ g: ((inout RightValue) -> U)) -> Either<T, U> {
        return leftValue.map(f) ||| rightValue.mutate(with: g)!
    }
    
    public mutating func mapOrMutate<T, U>(_ x: @autoclosure () throws -> T, _ f: ((inout RightValue) throws -> U)) rethrows -> Either<T, U> {
        return try leftValue.map({ _ in try x() }) ||| rightValue.mutate(with: f)!
    }
    
    public mutating func mutateOrMap<T, U>(_ f: ((inout LeftValue) -> T), _ g: ((RightValue) -> U)) -> Either<T, U> {
        return leftValue.mutate(with: f) ||| rightValue.map(g)!
    }
    
    public mutating func mutateOrMap<T, U>(_ f: ((inout LeftValue) throws -> T), _ x: @autoclosure () throws -> U) rethrows -> Either<T, U> {
        return try leftValue.mutate(with: f) ||| rightValue.map({ _ in try x() })!
    }
    
    @discardableResult
    public mutating func mutate<T, U>(_ f: ((inout LeftValue) throws -> T), _ g: ((inout RightValue) throws -> U)) rethrows -> Either<T, U> {
        return try leftValue.mutate(with: f) ||| rightValue.mutate(with: g)!
    }
    
    public mutating func mapInPlace(_ f: ((LeftValue) throws -> LeftValue), _ g: ((RightValue) throws -> RightValue)) rethrows {
        eitherValue = try map(f, g)
    }
    
    public mutating func mapInPlace(_ f: ((LeftValue) throws -> LeftValue), _ g: ((RightValue) throws -> LeftValue)) rethrows {
        eitherValue = .left(try map(f, g).reduce(id, id))
    }
    
    public mutating func mapInPlace(_ f: ((LeftValue) throws -> LeftValue), _ x: @autoclosure () throws -> LeftValue) rethrows {
        eitherValue = .left(try map(f, { _ in try x() }).reduce(id, id))
    }
    
    public mutating func mapInPlace(_ f: ((LeftValue) throws -> RightValue), _ g: ((RightValue) throws -> RightValue)) rethrows {
        eitherValue = .right(try map(f, g).reduce(id, id))
    }
    
    public mutating func mapInPlace(_ x: @autoclosure () throws -> RightValue, _ f: ((RightValue) throws -> RightValue)) rethrows {
        eitherValue = .right(try map({ _ in try x() }, f).reduce(id, id))
    }
    
    public mutating func mapInPlace(_ f: ((LeftValue) throws -> LeftValue), _ x: @autoclosure () throws -> RightValue) rethrows {
        eitherValue = try map(f, { _ in try x() })
    }
    
    public mutating func mapInPlace(_ x: @autoclosure () throws -> LeftValue, _ f: ((RightValue) throws -> RightValue)) rethrows {
        eitherValue = try map({ _ in try x() }, f)
    }
}
