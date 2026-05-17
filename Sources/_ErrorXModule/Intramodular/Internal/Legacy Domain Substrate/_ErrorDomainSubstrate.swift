//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Legacy substrate used by macro-generated error domains.
///
/// Do not author conformances directly; use `@ErrorDomain`.
///
/// Relevant discussion:
/// - https://forums.swift.org/t/proposal-draft-nserror-bridging/3157
///   Swift punted `NSError`'s durable domain/code/userInfo identity to bridging.
/// - https://forums.swift.org/t/error-to-nserror-conversion/74210
///   Associated-value errors decay across XPC/NSError into useless output.
/// - https://forums.swift.org/t/proposal-slg-0003-standardized-error-metadata-via-logger-convenience/84518
///   Logging is still retrofitting basic error identity.
///
/// Domain identity is diagnostic data. It should survive logging, wrapping,
/// export, and interop instead of dissolving into enum names or prose.
public protocol _SubsystemDomain: Hashable, Sendable {
    associatedtype Error: Swift.Error = Swift.Error
}

/// Exportable stable subsystem domain identifier.
public struct _SubsystemDomainIdentifier: Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral, RawRepresentable, RawValueConvertible, StringRepresentable {
    public var rawValue: String

    public var description: String {
        rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

/// Legacy export identity hook for macro-generated error domains.
///
/// Do not author conformances directly; use `@ErrorDomain`.
public protocol _SubsystemDomainIdentifiable {
    var subsystemDomainIdentifier: _SubsystemDomainIdentifier { get }
}

/// Trait that attaches subsystem domain information.
public struct _ErrorDomainTrait: _ErrorTrait {
    @_HashableExistential
    public private(set) var domain: any _SubsystemDomain
    public private(set) var error: AnyError?

    public init<D: _SubsystemDomain>(
        _ domain: D
    ) {
        self.domain = domain
    }

    public init<D: _SubsystemDomain>(
        _ domain: D,
        error: D.Error
    ) where D.Error: _ErrorX {
        self.domain = domain
        self.error = AnyError(erasing: error)
    }
}

extension _ErrorTrait where Self == _ErrorDomainTrait {
    public static func domain<D: _SubsystemDomain>(
        _ domain: D
    ) -> Self {
        Self.init(domain)
    }

    public static func domain<D: _SubsystemDomain>(
        _ domain: D,
        error: D.Error
    ) -> Self where D.Error: _ErrorX {
        Self.init(domain, error: error)
    }
}
