//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be tested for maybe-known inequality.
public protocol _PartiallyEquatable {
    func isNotEqualTo(other: Self) -> Bool?
}
