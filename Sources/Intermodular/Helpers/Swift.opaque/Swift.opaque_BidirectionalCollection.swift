//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias BidirectionalCollection2 = opaque_BidirectionalCollection & BidirectionalCollection

public protocol opaque_BidirectionalCollection: opaque_Collection {
    func opaque_BidirectionalCollection_toAnyBidirectionalCollection() -> Any
}

extension opaque_BidirectionalCollection where Self: BidirectionalCollection {
    public func opaque_BidirectionalCollection_toAnyBidirectionalCollection() -> Any {
        return AnyBidirectionalCollection(fauxRandomAccessView)
    }
}
