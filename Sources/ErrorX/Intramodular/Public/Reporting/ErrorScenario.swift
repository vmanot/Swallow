//
// Copyright (c) Vatsal Manot
//

/// A stable category assigned when an error is observed at a system boundary.
public struct ErrorScenario: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// The scenario's stable identifier.
  public let identifier: String

  /// The scenario's stable identifier.
  public var description: String {
    identifier
  }

  /// A structural description of the scenario.
  public var debugDescription: String {
    "ErrorScenario(\(String(reflecting: identifier)))"
  }

  /// Creates a scenario with the given stable identifier.
  public init(_ identifier: String) {
    self.identifier = identifier
  }
}
