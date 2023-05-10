//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be compared for approximate equality.
public protocol ApproximatelyEquatable {
    static func ~= (lhs: Self, rhs: Self) -> Bool
}

extension ApproximatelyEquatable {
    public func _opaque_isApproximatelyEqual(
        to other: any ApproximatelyEquatable
    ) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        
        return self ~= other
    }
}
