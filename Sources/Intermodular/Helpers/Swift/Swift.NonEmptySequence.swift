//
// Copyright (c) Vatsal Manot
//

import Swift

///
/// A sequence type that is guaranteed to be non-empty.
///
public protocol NonEmptySequence: Sequence {
    /// The first element of this sequence.
    var first: Element { get }

    /// The last element of this sequence.
    var last: Element { get }
}
