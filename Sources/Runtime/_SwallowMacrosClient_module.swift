//
// Copyright (c) Vatsal Manot
//

import Foundation
@_exported import SwallowMacrosClient
@_spi(Internal) import Swallow

@objc(_SwallowMacrosClient_module)
public class _SwallowMacrosClient_module: NSObject {
    @TaskLocal static var isInitializing: Bool = false
    
    private static let lock = OSUnfairLock()
    private static var initialized: Bool = false
    
    public override init() {
        _SwallowMacrosClient_module.$isInitializing.withValue(true) {
            Self.lock.withCriticalScope {
                guard !Self.initialized else {
                    return
                }
                
                defer {
                    Self.initialized = true
                }
                
                let onces = TypeMetadataIndex.shared.fetch(
                    .conformsTo((any _PerformOnceOnAppLaunch).self),
                    .nonAppleFramework
                )
                
                onces.forEach {
                    let type = $0 as! any _PerformOnceOnAppLaunch.Type
                    
                    type.init().perform()
                }
            }
        }
    }
}
