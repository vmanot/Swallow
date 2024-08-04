//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import Swallow

@objc(_SwallowMacros_module)
public class _SwallowMacros_module: NSObject {
    private static let lock = OSUnfairLock()
    private static var initialized: Bool = false
    
    private static let _didCompleteSweep = _AsyncGate(initiallyOpen: false)
    private static var _inlineTestCases: [any _PerformOnceOnAppLaunchClosure.Type] = []
    
    @_StaticMirrorQuery(type: (any _PerformOnceOnAppLaunchClosure).self)
    private static var performOnceOnAppLaunchClosureTypes: [any _PerformOnceOnAppLaunchClosure.Type]
    
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
        let regular = performOnceOnAppLaunchClosureTypes.filter({ !$0._isInlineTestCase })

        _inlineTestCases = performOnceOnAppLaunchClosureTypes.filter({ $0._isInlineTestCase })
        
        regular.forEach { type in
            type.init().perform()
        }
        
        _didCompleteSweep.open()
    }
    
    public static func _executeDiscoveredInlineTestCases() async throws {
        guard _isDebugAssertConfiguration else {
            return
        }
        
        await _inlineTestCases.asyncForEach { @MainActor type in
            await XCTAssertNoThrowAsync { @MainActor in
                do {
                    try await type.init().perform().value
                } catch {
                    runtimeIssue(error)
                    
                    throw error
                }
            }
        }
        
        _inlineTestCases = []
    }
}

extension _SwallowMacros_module {
    @TaskLocal static var isInitializing: Bool = false
}
