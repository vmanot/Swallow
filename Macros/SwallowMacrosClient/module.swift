//
// Copyright (c) Vatsal Manot
//

import _SwallowMacrosRuntime
import Foundation
import Runtime
@_spi(Internal) import Swallow

@objc(_SwallowMacrosClient_module) public class _module: NSObject {
    private static let lock = OSUnfairLock()
    private static var initialized: Bool = false
    
    public override init() {
        Self.lock.withCriticalScope {
            guard !Self.initialized else {
                return
            }
            
            defer {
                Self.initialized = true
            }
            
            let onces = _SwiftRuntime._index.fetch(.conformsTo((any _PerformOnceOnAppLaunch).self), .nonAppleFramework, .pureSwift)
            
            onces.forEach {
                let type = $0 as! any _PerformOnceOnAppLaunch.Type
                
                type.init().perform()
            }
        }
    }
}
