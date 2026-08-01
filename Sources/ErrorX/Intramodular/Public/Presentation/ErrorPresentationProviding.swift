//
// Copyright (c) Vatsal Manot
//

/// Supplies presentation data for an error that is not declared with `@ErrorModel`.
public protocol ErrorPresentationProviding: Error {
  /// The human-readable presentation for this error.
  var errorPresentation: ErrorPresentation { get }
}
