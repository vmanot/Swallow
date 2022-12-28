//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

extension Hashable {
    public var erasedAsAnyHashable: AnyHashable {
        eraseToAnyHashable()
    }
    
    /// Wraps this `Hashable` with a type-eraser.
    public func eraseToAnyHashable() -> AnyHashable {
        AnyHashable(self)
    }
}
