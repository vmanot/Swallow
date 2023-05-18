//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Optional {
    public func unwrapOrThrowLastPOSIXError() throws -> Wrapped {
        return try unwrapOrThrow(try POSIXError.last.unwrap())
    }
}
