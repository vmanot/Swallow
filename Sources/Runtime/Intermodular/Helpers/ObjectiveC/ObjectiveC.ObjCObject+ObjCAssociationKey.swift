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
    public subscript<T>(key: ObjCAssociationKey<T>) -> T? {
        get {
            return associatedObjectView[key]
        } set {
            associatedObjectView[key] = newValue
        }
    }
    
    public subscript<T>(key: ObjCAssociationKey<T>, default defaultValue: @autoclosure () -> T) -> T {
        get {
            if let result = associatedObjectView[key] {
                return result
            } else {
                let result = defaultValue()
                associatedObjectView[key] = result
                return result
            }
        } set {
            self[key] = newValue
        }
    }
}

// MARK:

private let objectAssociationMapKey = ObjCAssociationKey<[String: ObjCAssociationKey<Any>]>()

extension ObjCObject {
    public var associatedObjectView: ObjCAssociatedObjectView<Self> {
        .init(of: self)
    }
    
    public var objectAssociationMap: [String: ObjCAssociationKey<Any>] {
        get {
            associatedObjectView.value(forKey: objectAssociationMapKey) ?? .init()
        } set {
            associatedObjectView.setValue(newValue, forKey: objectAssociationMapKey)
        }
    }
    
    public subscript(associationKeyForString string: String) -> ObjCAssociationKey<Any> {
        objectAssociationMap[string, defaultInPlace: ObjCAssociationKey<Any>()]
    }
    
    public subscript(associated key: String) -> Any? {
        get {
            associatedObjectView[self[associationKeyForString: key]]
        } set {
            associatedObjectView[self[associationKeyForString: key]] = newValue
        }
    }
    
    public subscript<T>(associated key: String, _ type: T.Type) -> T? {
        get {
            self[self[associationKeyForString: key]].map({ $0 as! T })
        } set {
            self[self[associationKeyForString: key]] = newValue
        }
    }
    
    public subscript<T>(associated key: String, default defaultValue: @autoclosure () -> T) -> T {
        get {
            self[self[associationKeyForString: key], default: defaultValue()] as! T
        } set {
            self[self[associationKeyForString: key]] = newValue
        }
    }
    
    @discardableResult
    public func associateRuntimeValue<Value>(
        _ value: Value,
        policy: ObjCAssociationPolicy = .retain
    ) -> ObjCAssociation<Self, Value>  {
        let key = ObjCAssociationKey<Value>(policy: policy)
        
        self[key] = value
        
        return .init(object: self, key: key)
    }
}

// MARK:

private let objectAssociationKeyAssociationMapKey = ObjCAssociationKey<[AnyHashable: Any]>()

extension ObjCObject {
    public func associationKey<T>(for hashable: AnyHashable, valueType: T.Type = T.self) -> ObjCAssociationKey<T> {
        if let result = self[objectAssociationKeyAssociationMapKey, default: [:]][hashable] {
            return result as! ObjCAssociationKey
        } else {
            let result = ObjCAssociationKey<T>()
            self[objectAssociationKeyAssociationMapKey, default: [:]][hashable] = result
            return result
        }
    }
    
    public subscript<T>(associatedWith hashable: AnyHashable) -> T? {
        get {
            self[associationKey(for: hashable)]
        } set {
            self[associationKey(for: hashable)] = newValue
        }
    }
    
    public subscript<T>(associatedWith hashables: AnyHashable...) -> T? {
        get {
            self[associatedWith: hashables]
        } set {
            self[associatedWith: hashables] = newValue
        }
    }
    
    public subscript<T>(associatedWith hashable: AnyHashable, default defaultValue: @autoclosure () -> T) -> T {
        get {
            if let result: T = self[associatedWith: hashable] {
                return result
            } else {
                let result = defaultValue()
                self[associatedWith: hashable] = result
                return result
            }
        } set {
            self[associatedWith: hashable] = newValue
        }
    }
    
    public subscript<T>(associatedWith hashables: AnyHashable..., default defaultValue: @autoclosure () -> T) -> T {
        get {
            self[associatedWith: hashables, default: defaultValue()]
        } set {
            self[associatedWith: hashables, default: defaultValue()] = newValue
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
