//
// Copyright (c) Vatsal Manot
//

/// An error type whose semantic model is available as a runtime descriptor.
public protocol _ModeledError: Error {
  /// The runtime descriptor synthesized for this error type.
  static var _errorDescriptor: _ErrorDescriptor<Self> { get }

  /// The modeled information for this error occurrence.
  var _resolvedErrorDescriptor: _ResolvedErrorDescriptor? { get }
}

extension _ModeledError {
  public var _resolvedErrorDescriptor: _ResolvedErrorDescriptor? {
    Self._errorDescriptor.resolve(self)
  }
}
