//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias BidirectionalCollection2 = _opaque_BidirectionalCollection & BidirectionalCollection

public protocol _opaque_BidirectionalCollection: _opaque_Collection {
    func _opaque_BidirectionalCollection_toAnyBidirectionalCollection() -> Any
}

extension _opaque_BidirectionalCollection where Self: BidirectionalCollection {
    public func _opaque_BidirectionalCollection_toAnyBidirectionalCollection() -> Any {
        return AnyBidirectionalCollection(fauxRandomAccessView)
    }
}
