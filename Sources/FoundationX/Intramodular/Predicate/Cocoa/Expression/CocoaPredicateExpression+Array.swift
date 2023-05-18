//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension CocoaPredicateExpression where Value: AnyArray {
    public func at(index: Int) -> ArrayIndexPredicateExpression<Self> {
        .index(self, index)
    }
    
    public var first: ArrayIndexPredicateExpression<Self> {
        .first(self)
    }
    
    public var last: ArrayIndexPredicateExpression<Self> {
        .last(self)
    }
    
    public func at<T>(index: Int, _ keyPath: KeyPath<Value.ArrayElement, T>) -> ArrayElementKeyPathPredicateExpression<Self, T> {
        .init(.index(index), self, keyPath)
    }
    
    public func first<T>(_ keyPath: KeyPath<Value.ArrayElement, T>) -> ArrayElementKeyPathPredicateExpression<Self, T> {
        .init(.first, self, keyPath)
    }
    
    public func last<T>(_ keyPath: KeyPath<Value.ArrayElement, T>) -> ArrayElementKeyPathPredicateExpression<Self, T> {
        .init(.last, self, keyPath)
    }
}

extension CocoaPredicateExpression where Value: AnyArrayOrSet {
    public var size: ComparisonPredicationExpressionTransform<Self, Int> {
        .size(self)
    }
    
    public var count: ComparisonPredicationExpressionTransform<Self, Int> {
        .count(self)
    }
}

extension CocoaPredicateExpression where Value: AnyArrayOrSet & AdditiveCollection {
    public var average: ComparisonPredicationExpressionTransform<Self, Value.AdditiveElement> {
        .average(self)
    }
    
    public var mode: ComparisonPredicationExpressionTransform<Self, Value.AdditiveElement> {
        .mode(self)
    }
    
    public var sum: ComparisonPredicationExpressionTransform<Self, Value.AdditiveElement> {
        .sum(self)
    }
}

extension CocoaPredicateExpression where Value: AnyArrayOrSet & ComparableCollection {
    public var min: ComparisonPredicationExpressionTransform<Self, Value.ComparableElement> {
        .min(self)
    }
    
    public var max: ComparisonPredicationExpressionTransform<Self, Value.ComparableElement> {
        .max(self)
    }
}
