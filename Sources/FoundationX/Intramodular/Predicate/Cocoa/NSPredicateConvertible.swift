//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct NSPredicateConversionContext {
    public let expressionConversionContext: NSExpressionConversionContext
    
    public init(
        expressionConversionContext: NSExpressionConversionContext
    ) {
        self.expressionConversionContext = expressionConversionContext
    }
}

public protocol NSPredicateConvertible {
    func toNSPredicate(context: NSPredicateConversionContext) throws -> NSPredicate
}

// MARK: - Implemented Conformances

extension NSPredicate: NSPredicateConvertible {
    public func toNSPredicate(context: NSPredicateConversionContext) throws -> NSPredicate {
        self
    }
}

extension CocoaPredicate {
    public func toNSPredicate(context: NSPredicateConversionContext) throws -> NSPredicate {
        switch self {
            case let .comparison(comparison):
                return try comparison.toNSPredicate(context: context)
            case let .boolean(value):
                return NSPredicate(value: value)
            case let .and(lhs, rhs):
                return NSCompoundPredicate(andPredicateWithSubpredicates: [
                    try lhs.toNSPredicate(context: context),
                    try rhs.toNSPredicate(context: context)
                ])
            case let .or(lhs, rhs):
                return NSCompoundPredicate(orPredicateWithSubpredicates: [
                    try lhs.toNSPredicate(context: context),
                    try rhs.toNSPredicate(context: context)
                ])
            case let .not(predicate):
                return try NSCompoundPredicate(notPredicateWithSubpredicate: predicate.toNSPredicate(context: context))
                
            case .cocoa(let predicate):
                return predicate
        }
    }
        
    /*private func makeSortDescriptor<T>(from sortCriterion: SortCriterion<T>) -> NSSortDescriptor {
        guard let comparator = sortCriterion.comparator else {
            return NSSortDescriptor(
                key: sortCriterion.property.stringValue,
                ascending: sortCriterion.order == .ascending
            )
        }
        
        return NSSortDescriptor(
            key: sortCriterion.property.stringValue,
            ascending: sortCriterion.order == .ascending,
            comparator: { lhs, rhs in
                guard let lhs = lhs as? T, let rhs = rhs as? T else {
                    return .orderedDescending
                }
                
                return comparator(lhs, rhs)
            }
        )
    }*/
}
