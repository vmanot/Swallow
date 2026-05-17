//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Report-time facts supplied by the observer.
public struct _ErrorObservationContext: Hashable, Sendable {
    public var scenario: _AnyErrorReportScenario?
    public var sourceLocation: SourceCodeLocation?
    public var contextBindings: [_ErrorContextBinding]

    public init(
        scenario: _AnyErrorReportScenario? = nil,
        sourceLocation: SourceCodeLocation? = nil,
        contextBindings: [_ErrorContextBinding] = []
    ) {
        self.scenario = scenario
        self.sourceLocation = sourceLocation
        self.contextBindings = contextBindings
    }
}
