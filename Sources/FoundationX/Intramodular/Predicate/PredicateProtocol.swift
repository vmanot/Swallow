//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol PredicateProtocol {
    associatedtype Input
    
    func evaluate(_ input: Input) throws -> Bool
}

public protocol PredicateExpression<Output> {
    associatedtype Output
    
    func evaluate(_ bindings: PredicateBindings) throws -> Output
}

public struct PredicateX<Input>: PredicateProtocol {
    public var expression: any PredicateExpression<Bool>
    public let variable: PredicateExpressionsX.Variable<Input>

    public func evaluate(_ input: Input) throws -> Bool {
        try expression.evaluate(PredicateBindings((variable, input)))
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public static func `where`(
        _ expressions: StandardPredicateExpressionOver<LHS>...
    ) -> Self {
        let variable = PredicateExpressionsX.Variable<Input>()
        
        return .init(
            expression: PredicateExpressionsX._ConjunctionOfMany(expressions: expressions.map({ $0.expression(variable) })),
            variable: variable
        )
    }

    public static func keyPath<Output>(
        _ keyPath: KeyPath<Input, Output>,
        _ expression: StandardPredicateExpressionOver<PredicateExpressionsX.KeyPath<PredicateExpressionsX.Variable<Input>, Output>>
    ) -> Self {
        let variable = PredicateExpressionsX.Variable<Input>()
        
        return .init(
            expression: expression.expression(.init(root: variable, keyPath: keyPath)),
            variable: variable
        )
    }
}

func foo(_ predicate: PredicateX<String>) {
    
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
func bar() {
    foo(.where(.contains("sh"), .hasSuffix("it")))
}


extension PredicateExpression {
    public static func value<T>(
        _ value: T
    ) -> Self where Self == PredicateExpressionsX.Value<T> {
        .init(value)
    }
}
