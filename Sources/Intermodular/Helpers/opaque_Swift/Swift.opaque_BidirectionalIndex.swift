//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_BidirectionalIndex: opaque_ForwardIndex {
    func predecessor() -> Self
}

extension opaque_BidirectionalIndex where Self: Strideable {
    public func predecessor() -> Self {
        return advanced(by: -1)
    }
}
