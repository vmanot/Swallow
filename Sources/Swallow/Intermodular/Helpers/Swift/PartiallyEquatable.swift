//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be tested for maybe-known inequality.
public protocol _PartiallyEquatable {
    func isNotEqual(to _: Self) -> Bool?
}

extension _PartiallyEquatable {
    public func isEqual(to other: Self) -> Bool? {
        guard let isNotEqual = isNotEqual(to: other) else {
            return nil
        }
        
        return !isNotEqual
    }
}
