//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public protocol StandardPredicateExpressionBuilder {
    associatedtype LHS: PredicateExpressionX
    
    init(expression: @escaping (LHS) -> any PredicateExpressionX<Bool>)
}

public struct StandardPredicateExpressionOver<LHS: PredicateExpressionX>: StandardPredicateExpressionBuilder {
    public let expression: (LHS) -> any PredicateExpressionX<Bool>
    
    public init(expression: @escaping (LHS) -> any PredicateExpressionX<Bool>) {
        self.expression = expression
    }
}

extension PredicateX: StandardPredicateExpressionBuilder {
    public typealias LHS = PredicateExpressionsX.Variable<Input>
    
    public init(expression: (LHS) -> any PredicateExpressionX<Bool>) {
        self.variable = .init()
        self.expression = expression(variable)
    }
}
extension StandardPredicateExpressionBuilder {
    public static func contains(
        _ element: LHS.Output.Element
    ) -> Self where LHS.Output: Sequence, LHS.Output.Element: Equatable {
        .init(expression: {
            PredicateExpressionsX.SequenceContains(sequence: $0, element: .value(element))
        })
    }
    
    public static func contains(
        _ substring: String
    ) -> Self where LHS: PredicateExpressionX<String> {
        .init(expression: {
            PredicateExpressionsX.StringContainsSubstring(sequence: $0, element: .value(substring))
        })
    }
    
    public static func hasSuffix(
        _ suffix: some BidirectionalCollection<LHS.Output.Element>
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: Equatable {
        .init(expression: {
            PredicateExpressionsX.CollectionHasSuffix(collection: $0, suffix: .value(suffix))
        })
    }
    
    public static func hasSuffix(
        _ suffix: Any.Type...
    ) -> Self where LHS.Output: BidirectionalCollection {
        .init(expression: {
            PredicateExpressionsX.CollectionHasPredicatedSuffix(
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
            PredicateExpressionsX.CollectionHasSuffix(
                collection: $0,
                suffix: .value(suffix)
            )
        })
    }
    
    public static func hasSuffix(
        _ suffix: LHS.Output.Element._UnwrappedBaseType...
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: _UnwrappableTypeEraser & ApproximatelyEquatable {
        .init(expression: {
            PredicateExpressionsX.CollectionHasApproximateSuffix(
                collection: $0,
                suffix: .value(suffix)
            )
        })
    }
    
    public static func hasSuffix(
        _ suffix: LHS.Output.Element._UnwrappedBaseType...
    ) -> Self where LHS.Output: BidirectionalCollection, LHS.Output.Element: _UnwrappableTypeEraser & ApproximatelyEquatable & Equatable {
        .init(expression: {
            PredicateExpressionsX.CollectionHasApproximateSuffix(
                collection: $0,
                suffix: .value(suffix)
            )
        })
    }
}
