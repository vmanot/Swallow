//
// Copyright (c) Vatsal Manot
//

/// Supplies a stable code for an error that is not declared with `@ErrorModel`.
public protocol ErrorCodeProviding: Error {
  /// The concrete error-code type.
  associatedtype Code: ErrorCode

  /// The stable code for this error.
  var errorCode: Code { get }
}

extension ErrorCodeProviding {
  var _opaqueErrorCode: AnyErrorCode {
    AnyErrorCode(errorCode)
  }
}

extension Error {
  func _errorXCode(
    resolvedDescriptor: _ResolvedErrorDescriptor?
  ) -> AnyErrorCode? {
    if let resolvedDescriptor {
      return resolvedDescriptor.code
    }

    return (self as? any ErrorCodeProviding)?._opaqueErrorCode
  }
}
