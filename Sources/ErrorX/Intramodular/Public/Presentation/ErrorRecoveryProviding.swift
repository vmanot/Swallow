//
// Copyright (c) Vatsal Manot
//

/// Supplies structured recovery options for an error that is not declared with `@ErrorModel`.
public protocol ErrorRecoveryProviding: Error {
  /// The actions available to recover from this error.
  var errorRecoveryOptions: [ErrorRecoveryOption] { get }
}
