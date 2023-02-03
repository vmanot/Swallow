//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool: EitherRepresentable {
    public typealias EitherValue = Either<True.Type, False.Type>
    
    public var eitherValue: EitherValue {
        self ? .left(True.self) : .right(False.self)
    }
    
    public init(_ eitherValue: EitherValue) {
        self = eitherValue.isLeft ? true : false
    }
}

/// A type representing a choice between one of two types.
public enum Either<T, U>: EitherRepresentable, MutableEitherRepresentable {
    public typealias LeftValue = T
    public typealias RightValue = U
    
    case left(T)
    case right(U)
    
    public var eitherValue: Either<LeftValue, RightValue> {
        get {
            return self
        } set {
            self = newValue
        }
    }
    
    public init(_ eitherValue: Either<LeftValue, RightValue>) {
        self = eitherValue
    }
}

extension Either where T == U {
    public var leftOrRightValue: T {
        switch self {
            case .left(let value):
                return value
            case .right(let value):
                return value
        }
    }
}

extension Either: Equatable where LeftValue: Equatable, RightValue: Equatable {
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
            case (.left(let x), .left(let y)):
                return x == y
            case (.right(let x), .right(let y)):
                return x == y
            default:
                return false
        }
    }
}

extension Either: Comparable where LeftValue: Comparable, RightValue: Comparable {
    
}

/// A type representing a choice between one of three types.
public enum Either3<T, U, V>: EitherRepresentable {
    public typealias EitherValue = Either<Either<T, U>, V>
    
    case result1(T)
    case result2(U)
    case result3(V)
    
    public var eitherValue: EitherValue {
        switch self {
            case .result1(let value):
                return .left(.left(value))
            case .result2(let value):
                return .left(.right(value))
            case .result3(let value):
                return .right(value)
        }
    }
    
    public init(_ eitherValue: EitherValue) {
        self = eitherValue.reduce(
            { $0.reduce(Either3.result1, Either3.result2) },
            Either3.result3
        )
    }
}

/// A type representing a choice between one of four types.
public enum Either4<T, U, V, W> {
    public typealias EitherValue = Either<Either3<T, U, V>.EitherValue, V>
    
    case result1(T)
    case result2(U)
    case result3(V)
    case result4(W)
}

/// A type representing a choice between one of five types.
public enum Either5<T, U, V, W, X> {
    public typealias EitherValue = Either<Either4<T, U, V, W>.EitherValue, X>
    
    case result1(T)
    case result2(U)
    case result3(V)
    case result4(W)
    case result5(X)
}

/// A type representing a choice between one of six types.
public enum Either6<T, U, V, W, X, Y> {
    public typealias EitherValue = Either<Either5<T, U, V, W, X>.EitherValue, Y>
    
    case result1(T)
    case result2(U)
    case result3(V)
    case result4(W)
    case result5(X)
    case result6(Y)
}

/// A type representing a choice between one of seven types.
public enum Either7<T, U, V, W, X, Y, Z> {
    public typealias EitherValue = Either<Either6<T, U, V, W, X, Y>.EitherValue, Z>
    
    case result1(T)
    case result2(U)
    case result3(V)
    case result4(W)
    case result5(X)
    case result6(Y)
    case result7(Z)
}

extension Result: EitherRepresentable {
    public typealias EitherValue = Either<Success, Failure>
    
    public var eitherValue: EitherValue {
        switch self {
            case .success(let value):
                return .left(value)
            case .failure(let error):
                return .right(error)
        }
    }
    
    public init(_ eitherValue: EitherValue) {
        switch eitherValue {
            case .left(let value):
                self = .success(value)
            case .right(let error):
                self = .failure(error)
        }
    }
}
