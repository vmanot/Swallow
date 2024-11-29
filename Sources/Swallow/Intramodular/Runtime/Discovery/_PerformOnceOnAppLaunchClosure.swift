//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@_alwaysEmitConformanceMetadata
@objc public protocol _PerformOnceOnAppLaunchClosureObjC {
    
}

@_alwaysEmitConformanceMetadata
public protocol _PerformOnceOnAppLaunchClosure: _PerformOnceOnAppLaunchClosureObjC, Initiable {
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
