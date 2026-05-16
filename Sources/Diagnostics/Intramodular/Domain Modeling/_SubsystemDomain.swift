//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A domain within a subsystem.
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

public struct _SubsystemDomainErrorTrait: _ErrorTrait {
    @_HashableExistential
    public private(set) var domain: any _SubsystemDomain
    @_HashableExistential
    public private(set) var error: (any _ErrorX)?
    
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
        self.error = error
    }
}

extension _ErrorTrait where Self == _SubsystemDomainErrorTrait {
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
