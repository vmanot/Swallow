//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol PredicateProtocol {
    associatedtype Input
    
    func evaluate(_ input: Input) throws -> Bool
}

public protocol PredicateExpressionX<Output> {
    associatedtype Output
    
    func evaluate(_ bindings: PredicateBindings) throws -> Output
}

public struct PredicateX<Input>: PredicateProtocol {
    public var expression: any PredicateExpressionX<Bool>
    public let variable: PredicateExpressionsX.Variable<Input>
    
    public func evaluate(_ input: Input) throws -> Bool {
        try expression.evaluate(PredicateBindings((variable, input)))
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public static func `where`(
        _ expressions: StandardPredicateExpressionOver<LHS>...
    ) -> Self {
        let variable = PredicateExpressionsX.Variable<Input>()
        
        return Self(
            expression: PredicateExpressionsX._ConjunctionOfMany(expressions: expressions.map({ $0.expression(variable) })),
            variable: variable
        )
    }
    
    public static func keyPath<Output>(
        _ keyPath: KeyPath<Input, Output>,
        _ expression: StandardPredicateExpressionOver<PredicateExpressionsX.KeyPath<PredicateExpressionsX.Variable<Input>, Output>>
    ) -> Self {
        let variable = PredicateExpressionsX.Variable<Input>()
        
        return Self(
            expression: expression.expression(.init(root: variable, keyPath: keyPath)),
            variable: variable
        )
    }
}

extension PredicateExpressionX {
    public static func value<T>(
        _ value: T
    ) -> Self where Self == PredicateExpressionsX.Value<T> {
        .init(value)
    }
}

extension PredicateX {
    public static func _arbitrary(
        _ predicate: @escaping (Input) throws -> Bool
    ) -> Self {
        let variable = PredicateExpressionsX.Variable<Input>()
        
        return Self(
            expression: PredicateExpressionsX._ArbitraryClosure(root: variable, predicate: predicate),
            variable: variable
        )
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public static func _manyArbitrary(
        _ predicates: [(Input) throws -> Bool]
    ) -> Self {
        let variable = PredicateExpressionsX.Variable<Input>()
        let expression = PredicateExpressionsX._ConjunctionOfMany(
            expressions: predicates.map({ PredicateExpressionsX._ArbitraryClosure(root: variable, predicate: $0) })
        )
        
        return Self(
            expression: expression,
            variable: variable
        )
    }
}

extension PredicateExpressionsX {
    public struct _ArbitraryClosure<Root: PredicateExpressionX>: PredicateExpressionX {
        public let root: Root
        public let predicate: (Root.Output) throws -> Bool
        
        public init(root: Root, predicate: @escaping (Root.Output) throws -> Bool) {
            self.root = root
            self.predicate = predicate
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            try predicate(root.evaluate(bindings))
        }
    }
}
