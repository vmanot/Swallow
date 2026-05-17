//
// Copyright (c) Vatsal Manot
//

/// Stable operation identifier for static-member observation declarations.
public struct _ErrorObservationOperationIdentifier: Hashable, Sendable, _ErrorObservationOperation {
    public var rawValue: String

    public var stableIdentifier: String {
        rawValue
    }

    public var description: String {
        stableIdentifier
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}
