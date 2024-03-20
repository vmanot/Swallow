//
// Copyright (c) Vatsal Manot
//

import _SwallowMacrosRuntime
import Runtime
@_spi(Internal) import Swallow

public typealias module = _module

public struct _module {
    private static let lock = OSUnfairLock()
    private static var initialized: Bool = false
    
    public static func initialize() {
        lock.withCriticalScope {
            guard !initialized else {
                return
            }
            
            defer {
                initialized = true
            }
            
            let onces = _SwiftRuntime._index.fetch(.conformsTo((any _PerformOnce).self), .nonAppleFramework, .pureSwift)
            
            onces.forEach {
                let type = $0 as! any _PerformOnce.Type
                
                type.init().perform()
            }
        }
    }
}
