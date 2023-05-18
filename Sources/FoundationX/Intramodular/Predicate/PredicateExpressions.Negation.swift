//
// Copyright (c) Vatsal Manot
//

import Swallow

extension PredicateExpressions {
    public struct Negation<Wrapped: PredicateExpression>: PredicateExpression where Wrapped.Output == Bool {
        public typealias Output = Bool
        
        public let wrapped: Wrapped
        
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            try !wrapped.evaluate(bindings)
        }
    }
}
