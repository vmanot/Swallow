//
// Copyright (c) Vatsal Manot
//

import Swift

extension OptionSet {
    @inlinable
    public static func with(rawValue: RawValue) -> Self {
        return .init(rawValue: rawValue)
    }
}
