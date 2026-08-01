//
// Copyright (c) Vatsal Manot
//

/// Supplies the directly underlying error when it cannot be synthesized by `@ErrorModel`.
public protocol ErrorCauseProviding: Error {
  /// The error that directly caused this error, if one exists.
  var underlyingError: (any Error)? { get }
}
