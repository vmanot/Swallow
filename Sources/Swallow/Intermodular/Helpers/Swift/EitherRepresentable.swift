//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be represented as a choice between one of two types.
public protocol EitherRepresentable: EitherValueConvertible {
    init(_: Either<LeftValue, RightValue>)
}

/// A mutable type that can be represented as a choice between one of two types.
public protocol MutableEitherRepresentable: EitherRepresentable, MutableEitherValueConvertible {
    
}

// MARK: - Implementation

extension MutableEitherRepresentable where Self: Initiable {
    public init(_ eitherValue: Either<LeftValue, RightValue>) {
        self.init()
        
        self.eitherValue = eitherValue
    }
}

// MARK: - Extensions

extension EitherRepresentable {
    public init(leftValue: LeftValue) {
        self.init(.left(leftValue))
    }
    
    public init(rightValue: RightValue) {
        self.init(.right(rightValue))
    }
}

// MARK: - Helpers

infix operator |||: CompositionPrecedence

public func ||| <T: EitherRepresentable>(lhs: T.LeftValue?, rhs: @autoclosure () throws -> T.RightValue) rethrows -> T {
    if let lhs = lhs {
        return .init(leftValue: lhs)
    } else {
        return .init(rightValue: try rhs())
    }
}

public func ||| <T: EitherRepresentable>(lhs: T.LeftValue?, rhs: @autoclosure () throws -> T.RightValue?) rethrows -> T? {
    if let lhs = lhs {
        return .init(leftValue: lhs)
    } else if let rhs = try rhs() {
        return .init(rightValue: rhs)
    } else {
        return nil
    }
}
