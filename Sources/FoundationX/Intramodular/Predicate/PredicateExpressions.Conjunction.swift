//
// Copyright (c) Vatsal Manot
//

import Swallow

extension PredicateExpressions {
    public struct Conjunction<
        LHS: PredicateExpression,
        RHS: PredicateExpression
    >: PredicateExpression
    where
    LHS.Output == Bool,
    RHS.Output == Bool
    {
        public typealias Output = Bool
        
        public let lhs: LHS
        public let rhs: RHS
        
        public init(lhs: LHS, rhs: RHS) {
            self.lhs = lhs
            self.rhs = rhs
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            try lhs.evaluate(bindings) && rhs.evaluate(bindings)
        }
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public struct _ConjunctionOfMany: PredicateExpression {
        public typealias Output = Bool
        
        public let expressions: [any PredicateExpression<Bool>]
        
        public init(expressions: [any PredicateExpression<Bool>]) {
            self.expressions = expressions
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            try expressions.reduce(true, { try $0 && $1.evaluate(bindings) })
        }
    }
}
