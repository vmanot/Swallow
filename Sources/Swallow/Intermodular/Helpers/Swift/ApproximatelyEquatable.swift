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

// MARK: - Supplementary

extension BidirectionalCollection {
    public func hasApproximateSuffix<Suffix: BidirectionalCollection<Element>>(
        _ suffix: Suffix
    ) -> Bool where Element: ApproximatelyEquatable {
        return hasSuffix(suffix.lazy.map { element in
            { element ~= $0 }
        })
    }
}
