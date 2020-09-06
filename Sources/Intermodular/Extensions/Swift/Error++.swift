//
// Copyright (c) Vatsal Manot
//

import Swift

extension Error {
    /// Throws self.
    public func `throw`() throws -> Never {
        throw self
    }

    /// Throws self based upon a predicate on self.
    public func throwSelf(if predicate: ((Self) -> Bool)) throws {
        if predicate(self) {
            throw self
        }
    }
}
