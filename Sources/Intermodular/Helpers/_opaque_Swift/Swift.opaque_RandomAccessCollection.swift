//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias RandomAccessCollection2 = _opaque_RandomAccessCollection & RandomAccessCollection

public protocol _opaque_RandomAccessCollection: _opaque_BidirectionalCollection {
    func _opaque_RandomAccessCollection_toAnyRandomAccessCollection() -> Any
}

extension _opaque_RandomAccessCollection where Self: RandomAccessCollection {
    public func _opaque_RandomAccessCollection_toAnyRandomAccessCollection() -> Any {
        return AnyRandomAccessCollection(fauxRandomAccessView)
    }
}
