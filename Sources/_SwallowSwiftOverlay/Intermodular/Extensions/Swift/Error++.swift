//
// Copyright (c) Vatsal Manot
//

import Swift

extension Error {
    /// Throws self.
    @_transparent
    public func `throw`() throws -> Never {
        throw self
    }
}
