//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias RandomAccessCollection2 = opaque_RandomAccessCollection & RandomAccessCollection

public protocol opaque_RandomAccessCollection: opaque_BidirectionalCollection {
    func opaque_RandomAccessCollection_toAnyRandomAccessCollection() -> Any
}

extension opaque_RandomAccessCollection where Self: RandomAccessCollection {
    public func opaque_RandomAccessCollection_toAnyRandomAccessCollection() -> Any {
        return AnyRandomAccessCollection(fauxRandomAccessView)
    }
}
