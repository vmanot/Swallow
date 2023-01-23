//
// Copyright (c) Vatsal Manot
//

import Swift

extension Error {
    /// Throws self.
    public func `throw`() throws -> Never {
        throw self
    }
}
