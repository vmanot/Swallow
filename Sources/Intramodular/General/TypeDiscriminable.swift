//
// Copyright (c) Vatsal Manot
//

import Swift

/// A value that can be classified using a type discriminator.
public protocol TypeDiscriminable {
    /// A type that represents a value-kind.
    associatedtype TypeDiscriminator: Hashable
    
    /// The type discriminator for the value.
    var type: TypeDiscriminator { get }
}
