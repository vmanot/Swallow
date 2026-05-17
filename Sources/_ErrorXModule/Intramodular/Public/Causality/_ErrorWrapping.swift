//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Metadata available while wrapping one error in another.
public struct _ErrorWrappingContext: Hashable, Sendable {
    public var location: SourceCodeLocation?
    public var observation: _ErrorObservationContext?

    public init(
        location: SourceCodeLocation? = nil,
        observation: _ErrorObservationContext? = nil
    ) {
        self.location = location
        self.observation = observation
    }
}

/// An `_ErrorX` wrapper that preserves the wrapped error as cause.
public protocol _ErrorWrappingRepresentable: _ErrorX, _ErrorCauseRepresentable {
    init(wrapping error: AnyError, context: _ErrorWrappingContext)
}
