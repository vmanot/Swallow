//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@objc open class _RuntimeConversion: NSObject {
    open class var type: Any.Type {
        assertionFailure()
        
        return Never.self
    }
}

public protocol _NonGenericRuntimeConversionProtocol: _RuntimeConversion {
    associatedtype Source
    associatedtype Destination
    
    static func __convert(_ source: Source) throws -> Destination
}

public protocol _PerformOnceOnAppLaunch: Initiable {
    init()
    
    @discardableResult
    func perform() -> _SyncOrAsyncValue<Void>
}
