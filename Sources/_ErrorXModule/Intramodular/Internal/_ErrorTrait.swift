//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Typed fact contributed to an error report.
public protocol _ErrorTrait: Hashable, Sendable {

}

/// Marker trait for recoverable errors.
public struct _RecoverableErrorTrait: _ErrorTrait {

}

/// Trait that contributes stable error identity.
public struct _ErrorIdentityTrait: _ErrorTrait {
    public var identity: _ErrorIdentity

    public init(_ identity: _ErrorIdentity) {
        self.identity = identity
    }
}

/// Trait that contributes presentation data.
public struct _ErrorPresentationTrait: _ErrorTrait {
    public var presentation: _ErrorPresentation

    public init(_ presentation: _ErrorPresentation) {
        self.presentation = presentation
    }
}

/// Trait that contributes recovery suggestions.
public struct _ErrorRecoveryTrait: _ErrorTrait {
    public var suggestions: [_ErrorRecoverySuggestion]

    public init(_ suggestions: [_ErrorRecoverySuggestion]) {
        self.suggestions = suggestions
    }
}

/// Trait that contributes occurrence or observation facts.
public struct _ErrorContextTrait: _ErrorTrait {
    public var bindings: [_ErrorContextBinding]

    public init(_ bindings: [_ErrorContextBinding]) {
        self.bindings = bindings
    }
}
