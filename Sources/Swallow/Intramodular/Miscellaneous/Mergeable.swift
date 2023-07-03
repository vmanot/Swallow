//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ThrowingMergeOperatable {
    mutating func mergeInPlace(with other: Self) throws
}

public protocol MergeOperatable: ThrowingMergeOperatable {
    mutating func mergeInPlace(with other: Self)
    
    func merging(_ other: Self) -> Self
}

extension ThrowingMergeOperatable {
    public func _opaque_merging(_ other: Any) throws -> Any {
        try merging(try cast(other, to: Self.self))
    }

    public func merging(_ other: Self) throws -> Self {
        try build(self) {
            try $0.mergeInPlace(with: other)
        }
    }
}

extension MergeOperatable {
    public func merging(_ other: Self) -> Self {
        build(self) {
            $0.mergeInPlace(with: other)
        }
    }
}
