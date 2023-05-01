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

extension Either: CustomStringConvertible {
    public var description: String {
        reduce(left: { String(describing: $0) }, right: { String(describing: $0) })
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

extension Either: Sendable where LeftValue: Sendable, RightValue: Sendable {
    
}

extension Either {
    public enum _Comparison: Hashable, Sendable {
        case left
        case right
        
        public static func == (lhs: Either<T, U>, rhs: _Comparison) -> Bool {
            lhs._comparison == rhs
        }
        
        public static func != (lhs: Either<T, U>, rhs: _Comparison) -> Bool {
             lhs._comparison != rhs
        }
    }
    
    private var _comparison: _Comparison {
        switch self {
            case .left:
                return .left
            case .right:
                return .right
        }
    }
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
