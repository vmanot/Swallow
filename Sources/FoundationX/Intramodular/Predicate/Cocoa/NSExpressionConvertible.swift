//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol NSExpressionConvertible {
    func toNSExpression(context: NSExpressionConversionContext) throws -> NSExpression
}

public struct NSExpressionConversionContext {
    public enum KeyPathConversionStrategy {
        case _kvcKeyPathString
        case custom((AnyKeyPath) throws -> String)
    }
    
    let keyPathConversionStrategy: KeyPathConversionStrategy
    let keyPathPrefix: String?
    
    public init(
        keyPathConversionStrategy: KeyPathConversionStrategy = ._kvcKeyPathString,
        keyPathPrefix: String? = nil
    ) {
        self.keyPathConversionStrategy = keyPathConversionStrategy
        self.keyPathPrefix = keyPathPrefix
    }
    
    func convertKeyPathToString(_ keyPath: AnyKeyPath) throws -> String {
        let keyPathString: String
        
        switch keyPathConversionStrategy {
            case ._kvcKeyPathString:
                keyPathString = try keyPath._kvcKeyPathString.unwrap()
            case .custom(let transform):
                keyPathString = try transform(keyPath)
        }
        
        return keyPathPrefix.flatMap({ "\($0).\(keyPathString)" }) ?? keyPathString
    }
}

// MARK: - ComparisonResult

extension ComparisonResult {
    static let `default`: ComparisonResult = .orderedDescending
}

// MARK: - NSExpressionConvertibles

extension KeyPath: NSExpressionConvertible {
    public func toNSExpression(context: NSExpressionConversionContext) throws -> NSExpression {
        try NSExpression(forKeyPath: context.convertKeyPathToString(self))
    }
}

extension ArrayIndexPredicateExpression: NSExpressionConvertible where ArrayExpression: NSExpressionConvertible {
    public func toNSExpression(context: NSExpressionConversionContext) throws -> NSExpression {
        switch self {
            case let .index(expression, index):
                return try NSExpression(format: "(\(expression.toNSExpression(context: context)))[\(index)]")
            case let .first(expression):
                return try NSExpression(format: "(\(expression.toNSExpression(context: context)))[FIRST]")
            case let .last(expression):
                return try NSExpression(format: "(\(expression.toNSExpression(context: context)))[LAST]")
        }
    }
}

extension ComparisonPredicationExpressionTransform: NSExpressionConvertible where Input: NSExpressionConvertible {
    public func toNSExpression(context: NSExpressionConversionContext) throws -> NSExpression {
        switch self {
            case let .average(expression):
                return try NSExpression(
                    forFunction: "average:",
                    arguments: [expression.toNSExpression(context: context)]
                )
            case let .count(expression):
                return try NSExpression(
                    forFunction: "count:",
                    arguments: [expression.toNSExpression(context: context)]
                )
            case let .sum(expression):
                return try NSExpression(
                    forFunction: "sum:",
                    arguments: [expression.toNSExpression(context: context)]
                )
            case let .min(expression):
                return try NSExpression(
                    forFunction: "min:",
                    arguments: [expression.toNSExpression(context: context)]
                )
            case let .max(expression):
                return try NSExpression(
                    forFunction: "max:",
                    arguments: [expression.toNSExpression(context: context)]
                )
            case let .mode(expression):
                return try NSExpression(
                    forFunction: "mode:",
                    arguments: [expression.toNSExpression(context: context)]
                )
            case let .size(expression):
                return try NSExpression(format: "(\(expression.toNSExpression(context: context)))[SIZE]")
        }
    }
}

extension QueryPredicateExpression: NSExpressionConvertible {
    public func toNSExpression(context: NSExpressionConversionContext) throws -> NSExpression {
        NSExpression(
            forSubquery: NSExpression(forKeyPath: try context.convertKeyPathToString(key)),
            usingIteratorVariable: "x",
            predicate: try predicate.toNSPredicate(context: .init(expressionConversionContext: .init(keyPathConversionStrategy: context.keyPathConversionStrategy, keyPathPrefix: "$x"))) // FIXME? - `context.keyPathPrefix` is not used
        )
    }
}
