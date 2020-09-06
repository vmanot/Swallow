//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ApproximatelyEquatable {
    static func ~= (lhs: Self, rhs: Self) -> Bool
}
