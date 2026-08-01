//
// Copyright (c) Vatsal Manot
//

/// One action a user can take to recover from an error.
public struct ErrorRecoveryOption: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// The action presented to the user.
  public let title: String

  /// Additional guidance about the action.
  public let explanation: String?

  /// Creates a recovery option.
  public init(
    title: String,
    explanation: String? = nil
  ) {
    self.title = title
    self.explanation = explanation
  }

  /// The title presented for this recovery option.
  public var description: String {
    title
  }

  /// A structural description of the recovery option.
  public var debugDescription: String {
    "ErrorRecoveryOption(title: \(String(reflecting: title)), explanation: \(String(reflecting: explanation)))"
  }
}
