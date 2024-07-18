//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension Selector: Swallow.MutableNamed {
    @inlinable
    public var name: String {
        get {
            return .init(cString: sel_getName(self))
        } set {
            self = .init(newValue)
        }
    }
}
