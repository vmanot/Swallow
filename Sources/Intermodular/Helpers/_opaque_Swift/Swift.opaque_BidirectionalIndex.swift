//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_BidirectionalIndex: _opaque_ForwardIndex {
    func predecessor() -> Self
}

extension _opaque_BidirectionalIndex where Self: Strideable {
    public func predecessor() -> Self {
        return advanced(by: -1)
    }
}
