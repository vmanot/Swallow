//
// Copyright (c) Vatsal Manot
//

/// Human-readable information about an error, kept separate from its identity.
public struct ErrorPresentation: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// A concise description of the failure.
  public let message: String?

  /// An explanation of why the operation failed.
  public let failureReason: String?

  /// Additional text intended for diagnostics rather than presentation.
  public let diagnosticDescription: String?

  /// A location where the user can find additional help.
  public let helpAnchor: String?

  /// Creates presentation information for an error.
  public init(
    message: String? = nil,
    failureReason: String? = nil,
    diagnosticDescription: String? = nil,
    helpAnchor: String? = nil
  ) {
    self.message = message
    self.failureReason = failureReason
    self.diagnosticDescription = diagnosticDescription
    self.helpAnchor = helpAnchor
  }

  /// The most concise authored description available for presentation.
  public var description: String {
    message ?? failureReason ?? diagnosticDescription ?? helpAnchor ?? ""
  }

  /// A structural description of every presentation field.
  public var debugDescription: String {
    "ErrorPresentation(message: \(String(reflecting: message)), failureReason: \(String(reflecting: failureReason)), diagnosticDescription: \(String(reflecting: diagnosticDescription)), helpAnchor: \(String(reflecting: helpAnchor)))"
  }
}
