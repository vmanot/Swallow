//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

extension Hashable {
    /// Wraps this `Hashable` with a type-eraser.
    public func eraseToAnyHashable() -> AnyHashable {
        AnyHashable(self)
    }
}
