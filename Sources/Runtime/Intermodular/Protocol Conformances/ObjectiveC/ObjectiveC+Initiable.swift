//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCBool: Initiable {
    @inlinable
    public init() {
        self.init(false)
    }
}
