//
// Copyright (c) Vatsal Manot
//

/// Stable, typed key for an error occurrence or observation fact.
public struct _TypedErrorContextKey<Value: Hashable & Sendable>: Hashable, Sendable, _ErrorOccurrenceContextKey {
    public var rawValue: String
    public var privacy: _ErrorContextPrivacy

    public var stableIdentifier: String {
        rawValue
    }

    public var description: String {
        stableIdentifier
    }

    public init(
        rawValue: String,
        privacy: _ErrorContextPrivacy = .private
    ) {
        self.rawValue = rawValue
        self.privacy = privacy
    }

    public init(
        _ rawValue: String,
        privacy: _ErrorContextPrivacy = .private
    ) {
        self.init(rawValue: rawValue, privacy: privacy)
    }
}

extension _TypedErrorContextKey: _ErrorOccurrenceContextKeyPrivacyRepresentable {
    public var defaultErrorContextPrivacy: _ErrorContextPrivacy {
        privacy
    }
}
