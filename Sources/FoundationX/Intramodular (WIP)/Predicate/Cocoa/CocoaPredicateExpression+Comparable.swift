//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public func < <E: CocoaPredicateExpression, T: Comparable & PredicateExpressionPrimitive> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where E.Value == T {
    .comparison(.init(lhs, .lessThan, rhs))
}

public func <= <E: CocoaPredicateExpression, T: Comparable & PredicateExpressionPrimitive> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where E.Value == T {
    .comparison(.init(lhs, .lessThanOrEqual, rhs))
}

public func == <E: CocoaPredicateExpression, T: Equatable & PredicateExpressionPrimitive> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where E.Value == T {
    .comparison(.init(lhs, .equal, rhs))
}

public func == <E: CocoaPredicateExpression, T: PredicateExpressionPrimitiveConvertible> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> {
    .comparison(.init(lhs, .equal, rhs.toPredicateExpressionPrimitive()))
}

public func == <E: CocoaPredicateExpression, T: RawRepresentable> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where T.RawValue: Equatable & PredicateExpressionPrimitive {
    .comparison(.init(lhs, .equal, rhs.rawValue))
}

@_disfavoredOverload
public func == <E: CocoaPredicateExpression> (lhs: E, rhs: NilPredicateExpressionValue) -> CocoaPredicate<E.Root> where E.Value: OptionalProtocol {
    .comparison(.init(lhs, .equal, rhs))
}

public func != <E: CocoaPredicateExpression, T: Equatable & PredicateExpressionPrimitive> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where E.Value == T {
    .comparison(.init(lhs, .notEqual, rhs))
}

public func >= <E: CocoaPredicateExpression, T: Comparable & PredicateExpressionPrimitive> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where E.Value == T {
    .comparison(.init(lhs, .greaterThanOrEqual, rhs))
}

public func > <E: CocoaPredicateExpression, T: Comparable & PredicateExpressionPrimitive> (lhs: E, rhs: T) -> CocoaPredicate<E.Root> where E.Value == T {
    .comparison(.init(lhs, .greaterThan, rhs))
}
