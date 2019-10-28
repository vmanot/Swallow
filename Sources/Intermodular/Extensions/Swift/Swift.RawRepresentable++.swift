//
// Copyright (c) Vatsal Manot
//

import Swift

extension RawRepresentable where Self: Equatable, RawValue: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
