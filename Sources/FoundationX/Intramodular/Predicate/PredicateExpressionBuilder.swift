//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public protocol StandardPredicateExpressionBuilder {
    associatedtype LHS: PredicateExpression
    
    init(expression: @escaping (LHS) -> any PredicateExpression<Bool>)
}

public struct StandardPredicateExpressionOver<LHS: PredicateExpression>: StandardPredicateExpressionBuilder {
    public let expression: (LHS) -> any PredicateExpression<Bool>
    
    public init(expression: @escaping (LHS) -> any PredicateExpression<Bool>) {
        self.expression = expression
    }
}

extension Predicate: StandardPredicateExpressionBuilder {
    public typealias LHS = PredicateExpressions.Variable<Input>
    
    public init(expression: (LHS) -> any PredicateExpression<Bool>) {
        self.variable = .init()
        self.expression = expression(variable)
    }
}
extension StandardPredicateExpressionBuilder {
    public static func contains(
        _ element: LHS.Output.Element
    ) -> Self where LHS.Output: Sequence, LHS.Output.Element: Equatable {
        .init(expression: {
            PredicateExpressions.SequenceContains(sequence: $0, element: .value(element))
        })
    }
    
    public static func contains(
        _ substring: String
    ) -> Self where LHS: PredicateExpression<String> {
        .init(expression: {
            PredicateExpressions.StringContainsSubstring(sequence: $0, element: .value(substring))
        })
    }
    
    public static func hasSuffix(
        _ suffix: some BidirectionalCollection<LHS.Output.Element>
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: Equatable {
        .init(expression: {
            PredicateExpressions.CollectionHasSuffix(collection: $0, suffix: .value(suffix))
        })
    }
    
    public static func hasSuffix(
        _ suffix: Any.Type...
    ) -> Self where LHS.Output: BidirectionalCollection {
        .init(expression: {
            PredicateExpressions.CollectionHasPredicatedSuffix(
                collection: $0,
                suffix: suffix.map { type in
                    return { (element: LHS.Output.Element) in
                        _isValueOfGivenType(element, type: type)
                    }
                }
            )
        })
    }
    
    public static func hasSuffix(
        _ suffix: LHS.Output.Element._UnwrappedBaseType...
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: _UnwrappableTypeEraser & Equatable {
        .init(expression: {
            PredicateExpressions.CollectionHasSuffix(
                collection: $0,
                suffix: .value(suffix)
            )
        })
    }
    
    public static func hasSuffix(
        _ suffix: LHS.Output.Element._UnwrappedBaseType...
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: _UnwrappableTypeEraser & ApproximatelyEquatable {
        .init(expression: {
            PredicateExpressions.CollectionHasApproximateSuffix(
                collection: $0,
                suffix: .value(suffix)
            )
        })
    }
    
    public static func hasSuffix(
        _ suffix: LHS.Output.Element._UnwrappedBaseType...
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: _UnwrappableTypeEraser & ApproximatelyEquatable & Equatable {
        .init(expression: {
            PredicateExpressions.CollectionHasApproximateSuffix(
                collection: $0,
                suffix: .value(suffix)
            )
        })
    }
}
