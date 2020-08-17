//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_ForwardIndex: _opaque_Comparable {
    func successor() -> Self
}

extension _opaque_ForwardIndex where Self: Strideable {
    public func successor() -> Self {
        return advanced(by: 1)
    }
}
