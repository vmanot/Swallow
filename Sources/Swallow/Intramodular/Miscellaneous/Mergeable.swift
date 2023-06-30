//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ThrowingMergeOperatable {
    mutating func mergeInPlace(with other: Self) throws
}

public protocol MergeOperatable: ThrowingMergeOperatable {
    mutating func mergeInPlace(with other: Self)
    
    func merge(with other: Self) -> Self
}

extension ThrowingMergeOperatable {
    public func _opaque_mergeInPlace(with other: Any) throws -> Any {
        try merge(with: try cast(other, to: Self.self))
    }

    public func merge(with other: Self) throws -> Self {
        try build(self) {
            try $0.mergeInPlace(with: other)
        }
    }
}

extension MergeOperatable {
    public func merge(with other: Self) -> Self {
        build(self) {
            $0.mergeInPlace(with: other)
        }
    }
}
