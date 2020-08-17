//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_RandomAccessIndex: _opaque_BidirectionalIndex {
    func _opaque_RandomAccessIndex_distance(to other: Any) -> Any?
    func _opaque_RandomAccessIndex_advanced(by n: Any) -> Self?
}

extension _opaque_RandomAccessIndex where Self: _opaque_Strideable {
    public func _opaque_RandomAccessIndex_distance(to other: Any) -> Any? {
        return _opaque_Strideable_distance(to: other)
    }
    
    public func _opaque_RandomAccessIndex_advanced(by n: Any) -> Self? {
        return _opaque_Strideable_advanced(by: n)
    }
}
