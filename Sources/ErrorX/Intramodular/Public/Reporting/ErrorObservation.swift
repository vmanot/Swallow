//
// Copyright (c) Vatsal Manot
//

public import Swallow

/// Facts supplied at the point where an error is observed.
public struct ErrorObservation: Hashable, Sendable, CustomStringConvertible,
  CustomDebugStringConvertible
{
  /// Observation facts inherited by structured child tasks and actor calls.
  ///
  /// Use ``$current``'s `withValue` operations to establish a scope. Detached
  /// tasks do not inherit task-local values and must receive observation facts
  /// explicitly.
  @TaskLocal public static var current = Self()

  /// The stable scenario in which the error was observed.
  public let scenario: ErrorScenario?

  /// The source location at which the error was observed.
  public let sourceLocation: SourceCodeLocation?

  /// Context known to the observer rather than to the error itself.
  public let context: ErrorContext

  /// Creates observation-time information for an error report.
  public init(
    scenario: ErrorScenario? = nil,
    sourceLocation: SourceCodeLocation? = nil,
    context: ErrorContext = []
  ) {
    self.scenario = scenario
    self.sourceLocation = sourceLocation
    self.context = context
  }

  /// A concise description of the observation boundary.
  public var description: String {
    if let scenario {
      return scenario.description
    }

    if let sourceLocation {
      return sourceLocation.description
    }

    return "unspecified"
  }

  /// A structural description with nonpublic context values redacted.
  public var debugDescription: String {
    "ErrorObservation(scenario: \(String(reflecting: scenario)), sourceLocation: \(String(reflecting: sourceLocation)), context: \(context.debugDescription))"
  }
}
