//
// Copyright (c) Vatsal Manot
//

import Foundation

/// A versioned type.
public protocol Versioned {
    /// The version of this instance.
    var version: Version? { get }
}
