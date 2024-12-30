//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct CocoaComparisonPredicate {
    public enum Operator: Codable {
        case lessThan
        case lessThanOrEqual
        case equal
        case notEqual
        case greaterThanOrEqual
        case greaterThan
        case between
        case beginsWith
        case contains
        case endsWith
        case like
        case matches
        case `in`
    }
    
    public struct Options: Codable, OptionSet {
        public let rawValue: Int
        
        public static let caseInsensitive = Self(rawValue: 1 << 0)
        public static let diacriticInsensitive = Self(rawValue: 1 << 1)
        public static let normalized = Self(rawValue: 1 << 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public enum Modifier: String, Codable {
        case direct
        case all
        case any
        case none
    }
    
    public let expression: AnyPredicateExpression
    public let `operator`: Operator
    public let options: CocoaComparisonPredicate.Options
    public let value: PredicateExpressionPrimitive
    
    public var modifier: Modifier {
        expression._desiredComparisonModifier
    }
}

extension CocoaComparisonPredicate {
    init<E: CocoaPredicateExpression>(
        _ expression: E,
        _ `operator`: CocoaComparisonPredicate.Operator,
        _ value: PredicateExpressionPrimitive,
        _ options: CocoaComparisonPredicate.Options = .caseInsensitive
    ) {
        self.expression = AnyPredicateExpression(expression)
        self.operator = `operator`
        self.value = value
        self.options = options
    }
}

// MARK: - Helpers

extension NSComparisonPredicate.Modifier {
    init(from modifier: CocoaComparisonPredicate.Modifier) {
        switch modifier {
            case .direct:
                self = .direct
            case .all:
                self = .all
            case .any:
                self = .any
            case .none:
                self = .any
        }
    }
}

extension NSComparisonPredicate.Operator {
    init(from operator: CocoaComparisonPredicate.Operator) {
        switch `operator` {
            case .beginsWith:
                self = .beginsWith
            case .between:
                self = .between
            case .contains:
                self = .contains
            case .endsWith:
                self = .endsWith
            case .equal:
                self = .equalTo
            case .greaterThan:
                self = .greaterThan
            case .greaterThanOrEqual:
                self = .greaterThanOrEqualTo
            case .in:
                self = .in
            case .lessThan:
                self = .lessThan
            case .lessThanOrEqual:
                self = .lessThanOrEqualTo
            case .like:
                self = .like
            case .matches:
                self = .matches
            case .notEqual:
                self = .notEqualTo
        }
    }
}

extension NSComparisonPredicate.Options {
    init(from options: CocoaComparisonPredicate.Options) {
        self.init()
        
        if options.contains(.caseInsensitive) {
            formUnion(.caseInsensitive)
        }
        
        if options.contains(.diacriticInsensitive) {
            formUnion(.diacriticInsensitive)
        }
        
        if options.contains(.normalized) {
            formUnion(.normalized)
        }
    }
}

extension CocoaComparisonPredicate: NSPredicateConvertible {
    public func toNSPredicate(
        context: NSPredicateConversionContext
    ) throws -> NSPredicate {
        switch modifier {
            case .direct, .any, .all:
                return NSComparisonPredicate(
                    leftExpression: try expression.toNSExpression(context: context.expressionConversionContext),
                    rightExpression: makeExpression(from: value),
                    modifier: .init(from: modifier),
                    type: .init(from: `operator`),
                    options: .init(from: options)
                )
            case .none:
                return NSCompoundPredicate(
                    notPredicateWithSubpredicate: NSComparisonPredicate(
                        leftExpression: try expression.toNSExpression(context: context.expressionConversionContext),
                        rightExpression: NSExpression(forConstantValue: value),
                        modifier: .init(from: modifier),
                        type: .init(from: `operator`),
                        options: .init(from: options)
                    )
                )
        }
    }
    
    private func makeExpression(
        from primitive: PredicateExpressionPrimitive
    ) -> NSExpression {
        NSExpression(forConstantValue: primitive.value)
    }
}

// MARK: - Auxiliary

private extension PredicateExpressionPrimitive {
    var value: Any? {
        switch Self.predicatePrimitiveType {
            case .nil:
                return NSNull()
            default:
                return self
        }
    }
}
