//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Marker for non-fatal errors that should be treated as warnings.
public protocol _WarningError: Error, Sendable {

}

public func _warn(_ error: Error) {
    print(error)
}
