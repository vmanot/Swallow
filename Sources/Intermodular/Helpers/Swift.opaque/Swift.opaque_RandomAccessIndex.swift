//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_RandomAccessIndex: opaque_BidirectionalIndex {
    func opaque_RandomAccessIndex_distance(to other: Any) -> Any?
    func opaque_RandomAccessIndex_advanced(by n: Any) -> Self?
}

extension opaque_RandomAccessIndex where Self: opaque_Strideable {
    public func opaque_RandomAccessIndex_distance(to other: Any) -> Any? {
        return opaque_Strideable_distance(to: other)
    }
    
    public func opaque_RandomAccessIndex_advanced(by n: Any) -> Self? {
        return opaque_Strideable_advanced(by: n)
    }
}
