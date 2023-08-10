//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCAssociatedObjectView<Object> {
    private let base: AnyObject
    
    public init(base: Object) {
        assert(_swift_isClassType(type(of: base)))

        self.base = try! cast(base, to: AnyObject.self)
    }
}

extension ObjCAssociatedObjectView {
    public func value<T>(
        forKey key: ObjCAssociationKey<T>
    ) -> T? {
        objc_getAssociatedObject(base, key.rawValue).map({ $0 as! T })
    }
    
    public func value(
        forKey key: ObjCAssociationKey<Any>
    ) -> Any? {
        objc_getAssociatedObject(base, key.rawValue)
    }
    
    public func setValue<T>(
        _ value: T?,
        forKey key: ObjCAssociationKey<T>
    ) {
        objc_setAssociatedObject(base, key.rawValue, value as Any?, key.policy.rawValue)
    }
    
    public func setValue(
        _ value: Any?,
        forKey key: ObjCAssociationKey<Any>
    ) {
        objc_setAssociatedObject(base, key.rawValue, value as AnyObject, key.policy.rawValue)
    }

    public subscript<T>(
        key: ObjCAssociationKey<T>
    ) -> T? {
        get {
            return value(forKey: key)
        } nonmutating set {
            setValue(newValue, forKey: key)
        }
    }
    
    public subscript<T>(
        key: ObjCAssociationKey<T>,
        default defaultValue: @autoclosure () -> T
    ) -> T {
        get {
            guard let result = self.value(forKey: key) else {
                let value = defaultValue()
                                
                self.setValue(value, forKey: key)
                
                return value
            }
            
            return result
        } nonmutating set {
            setValue(newValue, forKey: key)
        }
    }

    public func removeAll() {
        objc_removeAssociatedObjects(base)
    }
}
