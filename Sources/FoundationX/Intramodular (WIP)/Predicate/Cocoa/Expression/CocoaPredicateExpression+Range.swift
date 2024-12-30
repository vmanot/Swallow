//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension CocoaPredicateExpression where Value: Comparable & PredicateExpressionPrimitive {
    public func between(_ range: ClosedRange<Value>) -> CocoaPredicate<Root> {
        .comparison(.init(self, .between, [range.lowerBound, range.upperBound]))
    }
}

public func ~= <E: CocoaPredicateExpression, T: Comparable & PredicateExpressionPrimitive> (
    lhs: E,
    rhs: ClosedRange<T>
) -> CocoaPredicate<E.Root> where E.Value == T {
    lhs.between(rhs)
}
