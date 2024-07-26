//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

/// A type that logs its activities.
public protocol Logging {
    static var logger: PassthroughLogger { get }
    
    var logger: PassthroughLogger { get }
}

// MARK: - Implementation

private var logger_objcAssociationKey: UInt = 0

extension Logging {
    public static var logger: PassthroughLogger {
        PassthroughLogger(source: .type(self))
    }
    
    public var logger: PassthroughLogger {
        if swift_isClassType(type(of: self)) {
            let _self = self as! any Logging & AnyObject
            
            return _self._defaultLogger
        } else {
            return PassthroughLogger(source: .something(self))
        }
    }
}

extension Logging where Self: AnyObject {
    fileprivate var _defaultLogger: PassthroughLogger {
        if let result = objc_getAssociatedObject(self, &logger_objcAssociationKey) as? PassthroughLogger {
            return result
        } else {
            objc_sync_enter(self)
            
            defer {
                objc_sync_exit(self)
            }
            
            let result = PassthroughLogger(source: .object(self))
            
            objc_setAssociatedObject(self, &logger_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}
