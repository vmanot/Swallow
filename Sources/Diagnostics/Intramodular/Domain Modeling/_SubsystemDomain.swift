//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A domain within a subsystem.
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
