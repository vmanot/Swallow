//
// Copyright (c) Vatsal Manot
//

import Swallow

/// An error wrapper that exposes the semantic base error it wraps.
public protocol _ErrorBaseRepresentable {
    var base: any Error { get }
}

extension Error {
    var _errorXBase: any Error {
        if let error = self as? AnyError {
            return error.base._errorXBase
        }

        if let error = self as? any _ErrorBaseRepresentable {
            return error.base._errorXBase
        }

        return self
    }
}
