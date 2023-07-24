//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@discardableResult
public func objc_sync<T>(
    _ object: AnyObject,
    operation: () throws -> T
) rethrows -> T {
    objc_sync_enter(object)
    
    defer {
        objc_sync_exit(object)
    }
    
    return try operation()
}

@discardableResult
public func objc_sync<T>(
    _ first: AnyObject,
    _ second: AnyObject,
    _ rest: AnyObject..., f: (() throws -> T)
) rethrows -> T {
    defer {
        objc_sync_exit(first)
        objc_sync_exit(second)
        
        rest.forEach({ objc_sync_exit($0) })
    }
    
    objc_sync_enter(first)
    objc_sync_enter(second)
    
    rest.forEach({ objc_sync_enter($0) })
    
    return try f()
}
