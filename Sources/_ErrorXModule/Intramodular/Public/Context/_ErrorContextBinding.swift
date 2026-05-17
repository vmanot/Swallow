//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Stable key for an occurrence or observation fact.
public protocol _ErrorOccurrenceContextKey: _ErrorStableIdentifier {

}

/// An occurrence context key that carries default export privacy.
public protocol _ErrorOccurrenceContextKeyPrivacyRepresentable: _ErrorOccurrenceContextKey {
    var defaultErrorContextPrivacy: _ErrorContextPrivacy { get }
}

/// A typed fact attached to an error occurrence or observation.
public struct _ErrorContextBinding: Hashable, Sendable {
    /// Boundary policy for turning raw context into display/export context.
    public struct ProjectionPolicy: Hashable, Sendable {
        public enum Visibility: Hashable, Sendable {
            case publicOnly
            case publicAndPrivate
            case allDiagnostic
        }

        public var visibility: Visibility
        public var includesRedactedPlaceholders: Bool

        public init(
            visibility: Visibility,
            includesRedactedPlaceholders: Bool = false
        ) {
            self.visibility = visibility
            self.includesRedactedPlaceholders = includesRedactedPlaceholders
        }

        public static var publicOnly: Self {
            .init(visibility: .publicOnly)
        }

        public static var publicAndPrivate: Self {
            .init(visibility: .publicAndPrivate)
        }

        public static var allDiagnostic: Self {
            .init(visibility: .allDiagnostic)
        }

        public static func publicOnly(
            includingRedactedPlaceholders: Bool
        ) -> Self {
            .init(visibility: .publicOnly, includesRedactedPlaceholders: includingRedactedPlaceholders)
        }

        public static func publicAndPrivate(
            includingRedactedPlaceholders: Bool
        ) -> Self {
            .init(visibility: .publicAndPrivate, includesRedactedPlaceholders: includingRedactedPlaceholders)
        }

        public static func allDiagnostic(
            includingRedactedPlaceholders: Bool
        ) -> Self {
            .init(visibility: .allDiagnostic, includesRedactedPlaceholders: includingRedactedPlaceholders)
        }
    }

    /// Exportable context key representation.
    public struct Key: Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible, RawRepresentable, RawValueConvertible, StringRepresentable {
        public var rawValue: String

        public var description: String {
            rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }

        public init<Key: _ErrorOccurrenceContextKey>(
            _ key: Key
        ) {
            self.init(rawValue: key.stableIdentifier)
        }

        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
    }

    /// Narrow value model for diagnostic facts.
    public enum Value: Hashable, Sendable, CustomStringConvertible {
        case string(String)
        case int(Int)
        case bool(Bool)
        case double(Double)
        case description(String)

        public var stringValue: String? {
            guard case .string(let value) = self else {
                return nil
            }

            return value
        }

        public var intValue: Int? {
            guard case .int(let value) = self else {
                return nil
            }

            return value
        }

        public var boolValue: Bool? {
            guard case .bool(let value) = self else {
                return nil
            }

            return value
        }

        public var doubleValue: Double? {
            guard case .double(let value) = self else {
                return nil
            }

            return value
        }

        public var description: String {
            switch self {
                case .string(let value):
                    return value
                case .int(let value):
                    return String(value)
                case .bool(let value):
                    return String(value)
                case .double(let value):
                    return String(value)
                case .description(let value):
                    return value
            }
        }
    }

    public var key: Key
    public var value: Value
    public var privacy: _ErrorContextPrivacy

    public init(
        key: Key,
        value: Value,
        privacy: _ErrorContextPrivacy = .private
    ) {
        self.key = key
        self.value = value
        self.privacy = privacy
    }

    public init<Key: _ErrorOccurrenceContextKey>(
        key: Key,
        value: Value,
        privacy: _ErrorContextPrivacy? = nil
    ) {
        self.init(
            key: .init(key),
            value: value,
            privacy: privacy ?? (key as? any _ErrorOccurrenceContextKeyPrivacyRepresentable)?.defaultErrorContextPrivacy ?? .private
        )
    }

    public init<Value: Hashable & Sendable>(
        key: _TypedErrorContextKey<Value>,
        value: Value,
        privacy: _ErrorContextPrivacy? = nil
    ) {
        self.init(
            key: key,
            value: Self.Value(value),
            privacy: privacy ?? key.defaultErrorContextPrivacy
        )
    }
}

extension _ErrorContextBinding {
    public static func publicValue(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .public)
    }

    public static func privateValue(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .private)
    }

    public static func sensitiveValue(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .sensitive)
    }

    public static func secretValue(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .secret)
    }

    public static func publicValue<Key: _ErrorOccurrenceContextKey>(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .public)
    }

    public static func privateValue<Key: _ErrorOccurrenceContextKey>(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .private)
    }

    public static func sensitiveValue<Key: _ErrorOccurrenceContextKey>(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .sensitive)
    }

    public static func secretValue<Key: _ErrorOccurrenceContextKey>(
        key: Key,
        value: Value
    ) -> Self {
        .init(key: key, value: value, privacy: .secret)
    }

    /// Returns boundary-safe context according to `policy`.
    public func projected(
        using policy: ProjectionPolicy
    ) -> Self? {
        switch privacy {
            case .public:
                return self
            case .private:
                switch policy.visibility {
                    case .publicOnly:
                        return _redactedPlaceholderIfNeeded(policy, placeholder: "<private>")
                    case .publicAndPrivate, .allDiagnostic:
                        return self
                }
            case .sensitive:
                switch policy.visibility {
                    case .publicOnly:
                        return _redactedPlaceholderIfNeeded(policy, placeholder: "<redacted>")
                    case .publicAndPrivate:
                        return _redactedPlaceholder(placeholder: "<redacted>")
                    case .allDiagnostic:
                        return self
                }
            case .secret:
                return _redactedPlaceholderIfNeeded(policy, placeholder: "<secret>")
            case .redacted:
                return _redactedPlaceholder(placeholder: "<redacted>")
            case .omitted:
                return nil
        }
    }

    private func _redactedPlaceholderIfNeeded(
        _ policy: ProjectionPolicy,
        placeholder: String
    ) -> Self? {
        policy.includesRedactedPlaceholders ? _redactedPlaceholder(placeholder: placeholder) : nil
    }

    private func _redactedPlaceholder(
        placeholder: String
    ) -> Self {
        .init(
            key: key,
            value: .description(placeholder),
            privacy: privacy
        )
    }
}

extension _ErrorContextBinding.Value {
    public init<Value>(_ value: Value) {
        switch value {
            case let value as String:
                self = .string(value)
            case let value as Int:
                self = .int(value)
            case let value as Bool:
                self = .bool(value)
            case let value as Double:
                self = .double(value)
            default:
                self = .description(String(describing: value))
        }
    }
}

/// Manual fallback for errors that cannot use descriptor-generated context.
public protocol _ErrorOccurrenceContextRepresentable {
    var errorOccurrenceContextBindings: [_ErrorContextBinding] { get }
}

/// Compatibility spelling for occurrence context providers.
public protocol _ErrorContextRepresentable: _ErrorOccurrenceContextRepresentable {
    var errorContextBindings: [_ErrorContextBinding] { get }
}

extension _ErrorContextRepresentable {
    public var errorOccurrenceContextBindings: [_ErrorContextBinding] {
        errorContextBindings
    }
}
