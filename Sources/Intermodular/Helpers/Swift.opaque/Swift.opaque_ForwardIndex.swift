//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_ForwardIndex: opaque_Comparable {
    func successor() -> Self
}

extension opaque_ForwardIndex where Self: Strideable {
    public func successor() -> Self {
        return advanced(by: 1)
    }
}
