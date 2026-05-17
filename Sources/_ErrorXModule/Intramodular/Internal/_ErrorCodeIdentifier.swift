//
// Copyright (c) Vatsal Manot
//

/// Compatibility identifier for static-member error code declarations.
///
/// Prefer `@ErrorCodeCatalog` enum cases in new code; this keeps older catalog
/// shapes source-compatible.
public struct _ErrorCodeIdentifier<Domain: _SubsystemDomain & Initiable>: Hashable, Sendable, _ErrorCode {
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
