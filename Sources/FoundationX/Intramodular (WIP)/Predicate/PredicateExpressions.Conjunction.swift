//
// Copyright (c) Vatsal Manot
//

import Swallow

extension PredicateExpressionsX {
    public struct Conjunction<
        LHS: PredicateExpressionX,
        RHS: PredicateExpressionX
    >: PredicateExpressionX where LHS.Output == Bool, RHS.Output == Bool {
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
    public struct _ConjunctionOfMany: PredicateExpressionX {
        public typealias Output = Bool
        
        public let expressions: [any PredicateExpressionX<Bool>]
        
        public init(expressions: [any PredicateExpressionX<Bool>]) {
            self.expressions = expressions
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            try expressions.reduce(true, { try $0 && $1.evaluate(bindings) })
        }
    }
}
