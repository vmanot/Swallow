//
// Copyright (c) Vatsal Manot
//

/// Type-erased resolved descriptor for a specific error occurrence.
public struct _ResolvedErrorDescriptor {
  /// The stable code for this error occurrence.
  public let code: AnyErrorCode

  /// Context authored on this error occurrence.
  public let context: ErrorContext

  /// Presentation authored on this error occurrence.
  public let presentation: ErrorPresentation?

  /// Recovery options authored on this error occurrence.
  public let recoveryOptions: [ErrorRecoveryOption]

  /// The directly underlying error.
  public let underlyingError: (any Error)?

  /// The complete error tree, when the model provides one.
  public let errorTree: ErrorTree?

  /// Creates a resolved descriptor.
  public init(
    code: AnyErrorCode,
    context: ErrorContext = [],
    presentation: ErrorPresentation? = nil,
    recoveryOptions: [ErrorRecoveryOption] = [],
    underlyingError: (any Error)? = nil,
    errorTree: ErrorTree? = nil
  ) {
    self.code = code
    self.context = context
    self.presentation = presentation
    self.recoveryOptions = recoveryOptions
    self.underlyingError = underlyingError
    self.errorTree = errorTree
  }
}
