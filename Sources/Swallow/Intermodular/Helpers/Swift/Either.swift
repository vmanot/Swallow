//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type representing a choice between one of two types.
@frozen
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

// MARK: - Extensions

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

extension Either where LeftValue: Collection, RightValue: Collection {
    public var count: Int {
        reduce(left: { $0.count }, right: { $0.count })
    }
    
    public func nilIfEmpty() -> Self? {
        flatMap(left: { $0.nilIfEmpty() }, right: { $0.nilIfEmpty() })
    }
}

// MARK: - Conformances

extension Either: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        reduce(
            left: { String(describing: $0) },
            right: { String(describing: $0) }
        )
    }
    
    public var debugDescription: String {
        reduce(
            left: { "Either.left(\(String(describing: $0)))" },
            right: { "Either.right(\(String(describing: $0)))" }
        )
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

// MARK: - Auxiliary

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
