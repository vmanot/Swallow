//
// Copyright (c) Vatsal Manot
//

import Swift

public func assertionFailure(_ error: Error) {
    assertionFailure(String(describing: error))
}

public func assertionFailure(_ reason: Never.Reason) {
    assertionFailure(String(describing: reason))
}
