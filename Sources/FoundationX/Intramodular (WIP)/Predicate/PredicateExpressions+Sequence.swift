//
// Copyright (c) Vatsal Manot
//

import Swallow

extension PredicateExpressionsX {
    public struct SequenceContains<
        LHS: PredicateExpressionX,
        RHS: PredicateExpressionX
    >: PredicateExpressionX
    where
        LHS.Output: Sequence,
        LHS.Output.Element: Equatable,
        RHS.Output == LHS.Output.Element
    {
        public typealias Output = Bool
        
        public let sequence: LHS
        public let element: RHS
        
        public init(sequence: LHS, element: RHS) {
            self.sequence = sequence
            self.element = element
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            let a = try sequence.evaluate(bindings)
            let b = try element.evaluate(bindings)
                    
            return a.contains(b)
        }
    }
    
    public struct SequenceHasPrefix<
        LHS: PredicateExpressionX,
        RHS: PredicateExpressionX
    >: PredicateExpressionX
    where
        LHS.Output: Sequence,
        LHS.Output.Element: Equatable,
        RHS.Output: Sequence<LHS.Output.Element>
    {
        public typealias Output = Bool
        
        public let sequence: LHS
        public let prefix: RHS
        
        public init(sequence: LHS, prefix: RHS) {
            self.sequence = sequence
            self.prefix = prefix
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            let a = try sequence.evaluate(bindings)
            let b = try prefix.evaluate(bindings)
            
            return a.hasPrefix(b)
        }
    }

    public struct CollectionHasSuffix<
        LHS: PredicateExpressionX,
        RHS: PredicateExpressionX
    >: PredicateExpressionX
    where
        LHS.Output: BidirectionalCollection,
        LHS.Output.Element: Equatable,
        RHS.Output: BidirectionalCollection<LHS.Output.Element>
    {
        public typealias Output = Bool
        
        public let collection: LHS
        public let suffix: RHS
        
        public init(
            collection: LHS,
            suffix: RHS
        ) {
            self.collection = collection
            self.suffix = suffix
        }
        
        public init<E: PredicateExpressionX>(
            collection: LHS,
            suffix: E
        ) where LHS.Output.Element: _UnwrappableTypeEraser, E.Output: BidirectionalCollection<LHS.Output.Element._UnwrappedBaseType>, RHS == PredicateExpressionsX.Map<E, AnyBidirectionalCollection<LHS.Output.Element>> {
            self.collection = collection
            self.suffix = suffix.map { suffix in
                suffix
                    .lazy
                    .map(LHS.Output.Element.init(_erasing:))
                    .eraseToAnyBidirectionalCollection()
            }
        }

        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            let a = try collection.evaluate(bindings)
            let b = try suffix.evaluate(bindings)
            
            return a.hasSuffix(b)
        }
    }
    
    public struct CollectionHasApproximateSuffix<
        LHS: PredicateExpressionX,
        RHS: PredicateExpressionX
    >: PredicateExpressionX
    where
        LHS.Output: BidirectionalCollection,
        LHS.Output.Element: ApproximatelyEquatable,
        RHS.Output: BidirectionalCollection<LHS.Output.Element>
    {
        public typealias Output = Bool
        
        public let collection: LHS
        public let suffix: RHS
        
        public init(
            collection: LHS,
            suffix: RHS
        ) {
            self.collection = collection
            self.suffix = suffix
        }
        
        public init<E: PredicateExpressionX>(
            collection: LHS,
            suffix: E
        ) where LHS.Output.Element: _UnwrappableTypeEraser, E.Output: BidirectionalCollection<LHS.Output.Element._UnwrappedBaseType>, RHS == PredicateExpressionsX.Map<E, AnyBidirectionalCollection<LHS.Output.Element>> {
            self.collection = collection
            self.suffix = suffix.map { suffix in
                suffix
                    .lazy
                    .map(LHS.Output.Element.init(_erasing:))
                    .eraseToAnyBidirectionalCollection()
            }
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            let a = try collection.evaluate(bindings)
            let b = try suffix.evaluate(bindings)
            
            return a.hasApproximateSuffix(b)
        }
    }

    public struct CollectionHasPredicatedSuffix<
        LHS: PredicateExpressionX,
        RHS: BidirectionalCollection<(LHS.Output.Element) -> Bool>
    >: PredicateExpressionX where LHS.Output: BidirectionalCollection {
        public typealias Output = Bool
        
        public let collection: LHS
        public let suffix: RHS
        
        public init(collection: LHS, suffix: RHS) {
            self.collection = collection
            self.suffix = suffix
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            let a = try collection.evaluate(bindings)
            let b = suffix
            
            return a.hasSuffix(b)
        }
    }
    
    public struct StringContainsSubstring<
        LHS: PredicateExpressionX<String>,
        RHS: PredicateExpressionX<String>
    >: PredicateExpressionX {
        public typealias Output = Bool
        
        public let sequence: LHS
        public let element: RHS
        
        public init(sequence: LHS, element: RHS) {
            self.sequence = sequence
            self.element = element
        }
        
        public func evaluate(_ bindings: PredicateBindings) throws -> Bool {
            let a = try sequence.evaluate(bindings)
            let b = try element.evaluate(bindings)
            
            return a.contains(b)
        }
    }
}
