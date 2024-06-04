//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import Swallow

@objc(_SwallowMacros_module)
public class _SwallowMacros_module: NSObject {
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
            
            _SwallowMacros_module.$isInitializing.withValue(true) {
                Self._performAllPerformOnceOnAppLaunchClosures()
            }
        }
    }
    
    private static func _performAllPerformOnceOnAppLaunchClosures() {
        let closures = TypeMetadataIndex.shared.fetch(
            .conformsTo((any _PerformOnceOnAppLaunchClosure).self),
            .nonAppleFramework
        )
        
        closures.forEach {
            let type = $0 as! any _PerformOnceOnAppLaunchClosure.Type
            
            type.init().perform()
        }
    }
}

extension _SwallowMacros_module {
    @TaskLocal static var isInitializing: Bool = false
}
