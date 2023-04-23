//
// Copyright (c) Vatsal Manot
//

import Swift

/// A value that can be classified using a type discriminator.
public protocol TypeDiscriminable {
    /// A type that represents a value-kind.
    associatedtype InstanceType: Hashable
    
    /// The type discriminator for the value.
    var type: InstanceType { get }
}

extension Sequence where Element: TypeDiscriminable {
    public func first(
        ofType type: Element.InstanceType
    ) -> Element? {
        first(where: { $0.type == type })
    }
    
    public func firstAndOnly(
        ofType type: Element.InstanceType
    ) throws -> Element? {
        try self.lazy.filter({ $0.type == type }).toCollectionOfZeroOrOne()?.value
    }
}
