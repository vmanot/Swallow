//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be compared for approximate equality.
public protocol ApproximatelyEquatable {
    static func ~= (lhs: Self, rhs: Self) -> Bool
}
