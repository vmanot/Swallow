//
// Copyright (c) Vatsal Manot
//

import Swallow

public func _tryAssert(_ condition: Bool, message: String? = nil) throws {
    guard condition else {
        throw _PlaceholderError()
    }
}
