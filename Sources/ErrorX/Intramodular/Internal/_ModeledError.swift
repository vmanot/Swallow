//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// An error type whose semantic model is available as a runtime descriptor.
///
/// This refines `LocalizedError` so that a modeled error's authored
/// presentation reaches `localizedDescription` and every `catch` site that
/// reads it, not only `ErrorReport`. Refining the protocol keeps the bridge in
/// one place instead of making each `@ErrorModel` expansion restate it.
public protocol _ModeledError: LocalizedError {
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

/// `LocalizedError` conformance derived from the authored presentation.
///
/// An unauthored field reads as absent rather than as empty text, so
/// `localizedDescription` keeps Foundation's fallback instead of becoming `""`.
extension _ModeledError {
  /// The authored message for this occurrence.
  public var errorDescription: String? {
    _resolvedErrorDescriptor?.presentation?.message?.nilIfEmpty()
  }

  /// The authored failure reason for this occurrence.
  public var failureReason: String? {
    _resolvedErrorDescriptor?.presentation?.failureReason?.nilIfEmpty()
  }

  /// The authored help anchor for this occurrence.
  public var helpAnchor: String? {
    _resolvedErrorDescriptor?.presentation?.helpAnchor?.nilIfEmpty()
  }

  /// The authored explanation of how to recover, when exactly one recovery
  /// option is offered.
  ///
  /// `recoverySuggestion` is a single piece of prose, whereas a modeled error
  /// may offer several recovery options. Describing only the first would
  /// silently misrepresent the rest, so an ambiguous set reads as absent and
  /// callers consult `recoveryOptions` instead.
  public var recoverySuggestion: String? {
    guard let options: [ErrorRecoveryOption] = _resolvedErrorDescriptor?.recoveryOptions,
      let option: ErrorRecoveryOption = options.first, options.count == 1
    else {
      return nil
    }

    return option.explanation?.nilIfEmpty()
  }
}
