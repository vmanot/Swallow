//
// Copyright (c) Vatsal Manot
//

/// Supplies context that should be attached to an error occurrence.
public protocol ErrorContextProviding {
  /// The context supplied by this value.
  var errorContext: ErrorContext { get }
}
