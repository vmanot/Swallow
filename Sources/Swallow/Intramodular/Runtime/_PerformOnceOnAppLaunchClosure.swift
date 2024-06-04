//
// Copyright (c) Vatsal Manot
//

import Swift

@_alwaysEmitConformanceMetadata
public protocol _PerformOnceOnAppLaunchClosure: Initiable {
    init()
    
    @discardableResult
    func perform() -> _SyncOrAsyncValue<Void>
}
