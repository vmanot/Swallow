//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Presentation strings carried as data, not identity.
public struct _ErrorPresentation: Hashable, Sendable {
    public var summary: String?
    public var reason: String?
    public var debugDescription: String?
    public var helpAnchor: String?

    public init(
        summary: String? = nil,
        reason: String? = nil,
        debugDescription: String? = nil,
        helpAnchor: String? = nil
    ) {
        self.summary = summary
        self.reason = reason
        self.debugDescription = debugDescription
        self.helpAnchor = helpAnchor
    }
}

/// Manual fallback for errors that cannot use descriptor-generating macros.
public protocol _ErrorPresentationRepresentable {
    var errorPresentation: _ErrorPresentation { get }
}

/// Human-readable recovery suggestion data.
public struct _ErrorRecoverySuggestion: Hashable, Sendable {
    public var title: String
    public var explanation: String?

    public init(
        title: String,
        explanation: String? = nil
    ) {
        self.title = title
        self.explanation = explanation
    }
}

/// Manual fallback for errors that cannot use descriptor-generating macros.
public protocol _ErrorRecoveryRepresentable {
    var errorRecoverySuggestions: [_ErrorRecoverySuggestion] { get }
}
