//
// Copyright (c) Vatsal Manot
//

import Swift

/// A value that can be classified using a type discriminator.
public protocol TypeDiscriminable<TypeDiscriminator> {
    /// A type that represents a value-kind.
    associatedtype TypeDiscriminator: Hashable
    
    /// The type discriminator for the value.
    var typeDiscriminator: TypeDiscriminator { get }
}

extension Sequence where Element: TypeDiscriminable {
    public func first(
        ofType type: Element.TypeDiscriminator
    ) -> Element? {
        first(where: { $0.typeDiscriminator == type })
    }
    
    public func firstAndOnly(
        ofType type: Element.TypeDiscriminator
    ) throws -> Element? {
        try self.lazy.filter({ $0.typeDiscriminator == type }).toCollectionOfZeroOrOne()?.value
    }
}
