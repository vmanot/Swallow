//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCAssociatedObjectView<T: ObjCObject> {    
    public let superValue: T
    
    public init(of superValue: T) {
        self.superValue = superValue
    }
}

extension ObjCAssociatedObjectView {
    public func removeAll() {
        objc_removeAssociatedObjects(superValue)
    }
}

extension ObjCAssociatedObjectView {
    public func value<T>(forKey key: ObjCAssociationKey<T>) -> T? {
        return objc_getAssociatedObject(superValue, key.rawValue) as! T?
    }
    
    public func value(forKey key: ObjCAssociationKey<Any>) -> Any? {
        return objc_getAssociatedObject(superValue, key.rawValue) 
    }
    
    public func setValue<T>(_ value: T?, forKey key: ObjCAssociationKey<T>) {
        objc_setAssociatedObject(superValue, key.rawValue, value as Any?, key.policy.rawValue)
    }

    public subscript<T>(key: ObjCAssociationKey<T>) -> T? {
        get {
            return value(forKey: key)
        } nonmutating set {
            setValue(newValue, forKey: key)
        }
    }
}

extension ObjCAssociatedObjectView {
    public func setValue(_ value: Any?, forKey key: ObjCAssociationKey<Any>) {
        objc_setAssociatedObject(superValue, key.rawValue, value as AnyObject, key.policy.rawValue)
    }
}
