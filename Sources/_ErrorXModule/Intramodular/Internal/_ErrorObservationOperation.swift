//
// Copyright (c) Vatsal Manot
//

/// Stable identifier for the operation being observed.
public protocol _ErrorObservationOperation: _ErrorStableIdentifier {

}

/// Type-erased observed operation identifier.
public struct _AnyErrorObservationOperation: Hashable, Sendable, CustomStringConvertible {
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

    public init<Operation: _ErrorObservationOperation>(
        _ operation: Operation
    ) {
        self.init(
            typeIdentifier: String(reflecting: Operation.self),
            stableIdentifier: operation.stableIdentifier
        )
    }
}

/// Explicit escape hatch for migration code without a typed operation yet.
public struct _UnstructuredErrorObservationOperation: Hashable, Sendable, _ErrorObservationOperation {
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
