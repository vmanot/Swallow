//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol CocoaPredicateExpression: NSExpressionConvertible {
    associatedtype Root
    associatedtype Value
    
    var _desiredComparisonModifier: CocoaComparisonPredicate.Modifier { get }
}

// MARK: - Implementation

extension CocoaPredicateExpression {
    public var _desiredComparisonModifier: CocoaComparisonPredicate.Modifier {
        CocoaComparisonPredicate.Modifier.direct
    }
}

// MARK: - Conformances

extension KeyPath: CocoaPredicateExpression {
    
}

public struct AnyPredicateExpression: CocoaPredicateExpression {
    public typealias Root = Any
    public typealias Value = Any
    
    public let _desiredComparisonModifier: CocoaComparisonPredicate.Modifier
    public let expression: NSExpressionConvertible
    
    init<E: NSExpressionConvertible & CocoaPredicateExpression>(_ expression: E) {
        self._desiredComparisonModifier = expression._desiredComparisonModifier
        self.expression = expression
    }
    
    public func toNSExpression(context: NSExpressionConversionContext) throws -> NSExpression {
        try expression.toNSExpression(context: context)
    }
}
