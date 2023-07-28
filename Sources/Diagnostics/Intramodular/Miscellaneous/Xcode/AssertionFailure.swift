//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A Swift `Error` that represents a precondition failure.
@frozen
public struct _PreconditionFailure: Error {
    @_transparent
    public init() {
        XcodeRuntimeIssueLogger.default.raise("Assertion failure raised.")
    }
}

/// A Swift `Error` that represents an assertion failure.
@frozen
public struct _AssertionFailure: Error {
    @_transparent
    public init() {
        XcodeRuntimeIssueLogger.default.raise("Assertion failure raised.")
    }
}
