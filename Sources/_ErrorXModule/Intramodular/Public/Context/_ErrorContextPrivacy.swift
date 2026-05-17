//
// Copyright (c) Vatsal Manot
//

/// Export policy for an error context value.
public enum _ErrorContextPrivacy: Hashable, Sendable {
    case `public`
    case `private`
    case sensitive
    case secret
    case redacted
    case omitted
}
