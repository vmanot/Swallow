//
// Copyright (c) Vatsal Manot
//

import Swallow

public enum PredicateExpressions {
    
}

extension PredicateExpressions {
    public struct VariableID: Hashable, Codable, Sendable {
        let id: UInt
        private static let nextID = LockedState(initialState: UInt(0))
        
        init() {
            self.id = Self.nextID.withLock { value in
                defer {
                    (value, _) = value.addingReportingOverflow(1)
                }
                return value
            }
        }
    }
    
    public struct Variable<Output>: PredicateExpression {
        public let key: VariableID
        
        public init() {
            self.key = VariableID()
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Output {
            if let value = bindings[self] {
                return value
            }
            throw PredicateError.undefinedVariable
        }
    }
    
    public struct Value<Output>: PredicateExpression {
        public let value: Output
        
        public init(_ value: Output) {
            self.value = value
        }
        
        public func evaluate(_ bindings: PredicateBindings) -> Output {
            return self.value
        }
    }
    
    public struct KeyPath<Root: PredicateExpression, Output>: PredicateExpression {
        public let root: Root
        public let keyPath: Swift.KeyPath<Root.Output, Output> & Sendable
        
        public init(root: Root, keyPath: Swift.KeyPath<Root.Output, Output> & Sendable) {
            self.root = root
            self.keyPath = keyPath
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Output {
            try root.evaluate(bindings)[keyPath: keyPath as Swift.KeyPath<Root.Output, Output>]
        }
    }
}

extension PredicateExpressions {
    public struct Map<Base: PredicateExpression, Output>: PredicateExpression {
        public let base: Base
        public let transform: @Sendable (Base.Output) throws -> Output
        
        public init(
            base: Base,
            transform: @escaping @Sendable (Base.Output) throws -> Output
        ) {
            self.base = base
            self.transform = transform
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Output {
            try transform(base.evaluate(bindings))
        }
    }
}

extension PredicateExpression {
    public func map<T>(
        _ expression: @escaping @Sendable (Output) throws -> T
    ) -> PredicateExpressions.Map<Self, T> {
        .init(base: self, transform: expression)
    }
}
