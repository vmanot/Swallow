//
// Copyright (c) Vatsal Manot
//

import Swift

@_alwaysEmitConformanceMetadata
public protocol _PerformOnceOnAppLaunchClosure: Initiable {
    static var _isInlineTestCase: Bool { get }
    
    init()
    
    @discardableResult
    func perform() -> _SyncOrAsyncValue<Void>
}

extension _PerformOnceOnAppLaunchClosure {
    public static var _isInlineTestCase: Bool {
        false
    }
}
