//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol MergeOperatable {
    mutating func mergeInPlace(with other: Self)
    
    func merge(with other: Self) -> Self
}

public protocol ThrowingMergeOperatable {
    static func merge(lhs: Self, rhs: Self) throws -> Self
}

extension MergeOperatable {
    public mutating func mergeInPlace(with other: Self) {
        self = merge(with: other)
    }
    
    public func merge(with other: Self) -> Self {
        build(self) {
            $0.mergeInPlace(with: other)
        }
    }
}
