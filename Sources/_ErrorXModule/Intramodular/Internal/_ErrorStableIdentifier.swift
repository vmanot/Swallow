//
// Copyright (c) Vatsal Manot
//

/// Shared requirement for authored, durable diagnostic identifiers.
public protocol _ErrorStableIdentifier: Hashable, Sendable, CustomStringConvertible {
    var stableIdentifier: String { get }
}

extension _ErrorStableIdentifier where Self: RawRepresentable, RawValue == String {
    public var stableIdentifier: String {
        rawValue
    }

    public var description: String {
        stableIdentifier
    }
}
