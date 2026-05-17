//
// Copyright (c) Vatsal Manot
//

/// Stable category for an observed error report boundary.
public protocol _ErrorReportScenario: _ErrorStableIdentifier {

}

/// Stable scenario identifier produced by `@ErrorScenario`.
public struct _ErrorReportScenarioIdentifier: Hashable, Sendable, _ErrorReportScenario {
    public var stableIdentifier: String

    public var description: String {
        stableIdentifier
    }

    public init(
        _ stableIdentifier: String
    ) {
        self.stableIdentifier = stableIdentifier
    }

    public init(
        stableIdentifier: String
    ) {
        self.init(stableIdentifier)
    }
}

/// Type-erased report scenario identifier.
public struct _AnyErrorReportScenario: Hashable, Sendable, CustomStringConvertible {
    public var typeIdentifier: String
    public var stableIdentifier: String

    public var description: String {
        stableIdentifier
    }

    public init(
        typeIdentifier: String,
        stableIdentifier: String
    ) {
        self.typeIdentifier = typeIdentifier
        self.stableIdentifier = stableIdentifier
    }

    public init<Scenario: _ErrorReportScenario>(
        _ scenario: Scenario
    ) {
        self.init(
            typeIdentifier: String(reflecting: Scenario.self),
            stableIdentifier: scenario.stableIdentifier
        )
    }
}

/// Migration escape hatch for reports without a typed scenario yet.
public struct _UnstructuredErrorReportScenario: Hashable, Sendable, _ErrorReportScenario {
    public var rawValue: String

    public var stableIdentifier: String {
        rawValue
    }

    public var description: String {
        stableIdentifier
    }

    public init(
        _ rawValue: String
    ) {
        self.rawValue = rawValue
    }
}
