//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCBool: Swallow.Initiable {
    @inlinable
    public init() {
        self.init(false)
    }
}
