//
// Copyright (c) Vatsal Manot
//

import Swift

/// A sink type.
public protocol Sink {
    /// The element type that the sink accepts.
    associatedtype Element

    /// Puts the given value into the sink.
    mutating func put(_ element: Element)
}
