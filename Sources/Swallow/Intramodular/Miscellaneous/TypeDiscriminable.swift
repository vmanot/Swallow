//
// Copyright (c) Vatsal Manot
//

import Swift

/// A value that can be classified using a type discriminator.
public protocol TypeDiscriminable {
    /// A type that represents a value-kind.
    associatedtype InstanceType: Hashable
    
    /// The type discriminator for the value.
    var instanceType: InstanceType { get }
}

extension Sequence where Element: TypeDiscriminable {
    public func first(
        ofType type: Element.InstanceType
    ) -> Element? {
        first(where: { $0.instanceType == type })
    }
    
    public func firstAndOnly(
        ofType type: Element.InstanceType
    ) throws -> Element? {
        try self.lazy.filter({ $0.instanceType == type }).toCollectionOfZeroOrOne()?.value
    }
}
