//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCObject {
    public subscript(associated key: UnsafeRawPointer) -> Any? {
        get {
            return objc_getAssociatedObject(self, key)
        } set {
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public subscript(associated key: UnsafeRawPointer, default defaultValue: @autoclosure () -> Any) -> Any {
        get {
            if let result = objc_getAssociatedObject(self, key) {
                return result
            } else {
                let result = defaultValue()
                
                objc_setAssociatedObject(self, key, result, .OBJC_ASSOCIATION_RETAIN)
                
                return result
            }
        } set {
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension ObjCObject {
    public var _objC_associatedObjects: ObjCAssociatedObjectView<Self> {
        ObjCAssociatedObjectView(base: self)
    }
    
    public subscript<T>(key: ObjCAssociationKey<T>) -> T? {
        get {
            return _objC_associatedObjects[key]
        } set {
            _objC_associatedObjects[key] = newValue
        }
    }
    
    public subscript<T>(
        key: ObjCAssociationKey<T>,
        default defaultValue: @autoclosure () -> T
    ) -> T {
        get {
            _objC_associatedObjects[key, default: defaultValue()]
        } set {
            _objC_associatedObjects[key, default: defaultValue()] = newValue
        }
    }
}

private var staticAssociationMap: [AnyHashable: Any] = [:]

extension ObjCClass {
    public subscript<T>(_ key: ObjCAssociationKey<T>) -> T? {
        get {
            staticAssociationMap[key].map { $0 as! T }
        } nonmutating set {
            staticAssociationMap[key] = newValue
        }
    }
    
    public subscript<T>(_ key: ObjCAssociationKey<T>, default defaultValue: @autoclosure () -> T) -> T {
        get {
            staticAssociationMap[key].map({ $0 as! T }) ?? defaultValue()
        } nonmutating set {
            staticAssociationMap[key] = newValue
        }
    }
}
