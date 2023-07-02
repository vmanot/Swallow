//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// A generic subsystem domain.
public protocol _PlatformSubsystemDomain: _StaticInstance, _SubsystemDomain {
    
}

public enum _PlatformSubsystemDomains {
    public struct Filesystem: _PlatformSubsystemDomain {
        public init() {
            
        }
    }
    
    public struct Networking: _PlatformSubsystemDomain {
        public init() {
            
        }
    }
}

extension _SubsystemDomain where Self == _PlatformSubsystemDomains.Filesystem {
    public static var filesystem: Self {
        .init()
    }
}

extension _SubsystemDomain where Self == _PlatformSubsystemDomains.Networking {
    public static var networking: Self {
        .init()
    }
}
