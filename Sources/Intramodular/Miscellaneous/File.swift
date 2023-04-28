//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Mergable {
    mutating func mergeInPlace(with other: Self)
    
    func merge(with other: Self) -> Self
}

extension Mergable {
    public mutating func mergeInPlace(with other: Self) {
        self = merge(with: other)
    }
}
