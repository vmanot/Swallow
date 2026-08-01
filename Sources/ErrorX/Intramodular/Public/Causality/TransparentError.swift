//
// Copyright (c) Vatsal Manot
//

/// An error wrapper that does not introduce a new semantic failure.
public protocol TransparentError: Error {
  /// The wrapped error.
  var wrappedError: any Error { get }
}
