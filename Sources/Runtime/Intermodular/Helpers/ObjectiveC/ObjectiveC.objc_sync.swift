//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public func objc_sync<T>(_ object: AnyObject, _ f: (() throws -> T)) rethrows -> T {
    objc_sync_enter(object)
    
    defer {
        objc_sync_exit(object)
    }
    
    return try f()
}

public func objc_sync<T>(_ first: AnyObject, _ second: AnyObject, _ rest: AnyObject..., f: (() throws -> T)) rethrows -> T {
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

extension ObjCObject {
    public func objc_withCriticalScope<T>(do x: @autoclosure () throws -> T) rethrows -> T {
        return try objc_sync(self, x)
    }

    public func objc_withCriticalScope<T>(_ f: () throws -> T) rethrows -> T {
        return try objc_withCriticalScope(do: try f())
    }

    public func objc_withCriticalScope<T>(_ f: (Self) throws -> T) rethrows -> T {
        return try objc_sync(self, { try f(self) })
    }
}
