//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A Swift `Error` that represents an assertion failure.
public struct _AssertionFailure: Error {
    @_transparent
    public init() {
        XcodeRuntimeIssueLogger.default.raise("Assertion failure raised.")
    }
}
