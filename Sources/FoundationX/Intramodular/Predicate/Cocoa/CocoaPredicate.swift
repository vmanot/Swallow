//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// A type-safe set of conditions used to filter a list of objects of type `Root`.
public indirect enum CocoaPredicate<Root>: NSPredicateConvertible {
    case comparison(CocoaComparisonPredicate)
    case boolean(Bool)
    case and(CocoaPredicate<Root>, CocoaPredicate<Root>)
    case or(CocoaPredicate<Root>, CocoaPredicate<Root>)
    case not(CocoaPredicate<Root>)
    
    case cocoa(NSPredicate)
}

public struct AnyPredicate: NSPredicateConvertible {
    private let base: NSPredicateConvertible
    
    public init(_ predicate: NSPredicate) {
        self.base = predicate
    }
    
    public init<Root>(_ predicate: CocoaPredicate<Root>) {
        self.base = predicate
    }
    
    public func toNSPredicate(context: NSPredicateConversionContext) throws -> NSPredicate {
        try base.toNSPredicate(context: context)
    }
}

public enum ComparisonPredicationExpressionTransform<
    Input: CocoaPredicateExpression,
    Output
>: CocoaPredicateExpression where Input.Value: AnyArrayOrSet {
    public typealias Root = Input.Root
    public typealias Value = Output
    
    case average(Input)
    case count(Input)
    case sum(Input)
    case min(Input)
    case max(Input)
    case mode(Input)
    case size(Input)
}

public struct QueryPredicateExpression<Root, Subject: AnyArrayOrSet>: CocoaPredicateExpression {
    public typealias Value = Subject
    
    let key: AnyKeyPath
    let predicate: CocoaPredicate<Subject.Element>
}

// MARK: - Compound Predicates

public func && <T> (lhs: CocoaPredicate<T>, rhs: CocoaPredicate<T>) -> CocoaPredicate<T> {
    .and(lhs, rhs)
}

public func || <T> (lhs: CocoaPredicate<T>, rhs: CocoaPredicate<T>) -> CocoaPredicate<T> {
    .or(lhs, rhs)
}

public prefix func ! <T> (predicate: CocoaPredicate<T>) -> CocoaPredicate<T> {
    .not(predicate)
}


// MARK: - Aggregate Operations

extension CocoaPredicateExpression where Value: AnyArrayOrSet {
    public var all: ArrayElementKeyPathPredicateExpression<Self, Value.Element> {
        all(\Value.Element.self)
    }
    
    public var any: ArrayElementKeyPathPredicateExpression<Self, Value.Element> {
        any(\Value.Element.self)
    }
    
    public var none: ArrayElementKeyPathPredicateExpression<Self, Value.Element> {
        none(\Value.Element.self)
    }
    
    public func all<T>(_ keyPath: KeyPath<Value.Element, T>) -> ArrayElementKeyPathPredicateExpression<Self, T> {
        .init(.all, self, keyPath)
    }
    
    public func any<T>(_ keyPath: KeyPath<Value.Element, T>) -> ArrayElementKeyPathPredicateExpression<Self, T> {
        .init(.any, self, keyPath)
    }
    
    public func none<T>(_ keyPath: KeyPath<Value.Element, T>) -> ArrayElementKeyPathPredicateExpression<Self, T> {
        .init(.none, self, keyPath)
    }
}

extension CocoaPredicateExpression where Value: PredicateExpressionPrimitive {
    public func `in`(_ list: Value...) -> CocoaPredicate<Root> {
        .comparison(.init(self, .in, list))
    }
}

extension CocoaPredicateExpression where Value == String {
    public func `in`(_ list: [Value], _ options: CocoaComparisonPredicate.Options = .caseInsensitive) -> CocoaPredicate<Root> {
        .comparison(.init(self, .in, list, options))
    }
}


// MARK: - Sub-predicates

/// Creates a query to filter the collection of objects represented by the specified key-path.
///
/// - Parameters:
///   - keyPath: The key-path representing the collection to filter. The value of this key-path must be a valid
///     collection (an array or a set).
///   - predicate: The predicate to use to filter the collection.
///
/// - Returns: A query returning an array of objects matching the specified predicate. The returned query
///   can be composed in more complex predicates.
///
/// ###### Example
///
///       (\Account.name).contains("Account") && all(\.profiles, where: (\Profile.name).contains("Doe")).size == 2)
///
public func all<T, U: AnyArrayOrSet>(_ keyPath: KeyPath<T, U>, where predicate: CocoaPredicate<U.Element>) -> QueryPredicateExpression<T, U> {
    .init(key: keyPath, predicate: predicate)
}

// MARK: - Boolean predicates

extension CocoaPredicate: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}


// MARK: - Supporting Protocols

// MARK: - AnyArrayOrSet

public protocol AnyArrayOrSet {
    associatedtype Element
}

extension Array: AnyArrayOrSet {
}

extension Set: AnyArrayOrSet {
}

extension NSSet: AnyArrayOrSet {
}

extension Optional: AnyArrayOrSet where Wrapped: AnyArrayOrSet {
    public typealias Element = Wrapped.Element
}

// MARK: - AnyArray

public protocol AnyArray {
    associatedtype ArrayElement
}

extension Array: AnyArray {
    public typealias ArrayElement = Element
}

extension Optional: AnyArray where Wrapped: AnyArray {
    public typealias ArrayElement = Wrapped.ArrayElement
}

// MARK: - PrimitiveCollection

public protocol PrimitiveCollection {
    associatedtype PrimitiveElement: PredicateExpressionPrimitive
}

extension Array: PrimitiveCollection where Element: PredicateExpressionPrimitive {
    public typealias PrimitiveElement = Element
}

extension Set: PrimitiveCollection where Element: PredicateExpressionPrimitive {
    public typealias PrimitiveElement = Element
}

extension Optional: PrimitiveCollection where Wrapped: PrimitiveCollection {
    public typealias PrimitiveElement = Wrapped.PrimitiveElement
}

// MARK: - AdditiveCollection

public protocol AdditiveCollection {
    associatedtype AdditiveElement: AdditiveArithmetic & PredicateExpressionPrimitive
}

extension Array: AdditiveCollection where Element: AdditiveArithmetic & PredicateExpressionPrimitive {
    public typealias AdditiveElement = Element
}

extension Optional: AdditiveCollection where Wrapped: PrimitiveCollection & AdditiveCollection {
    public typealias AdditiveElement = Wrapped.AdditiveElement
}

// MARK: - ComparableCollection

public protocol ComparableCollection {
    associatedtype ComparableElement: Comparable & PredicateExpressionPrimitive
}

extension Array: ComparableCollection where Element: Comparable & PredicateExpressionPrimitive {
    public typealias ComparableElement = Element
}

extension Optional: ComparableCollection where Wrapped: ComparableCollection {
    public typealias ComparableElement = Wrapped.ComparableElement
}
