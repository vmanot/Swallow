//
// Copyright (c) Vatsal Manot
//

import Foundation
import ObjectiveC
import Swallow

@objc public protocol ObjCObject {
    
}

// MARK: - Extensions

extension ObjCObject {
    public var objCClass: ObjCClass {
        return .init(type(of: self))
    }
    
    public static var objCClass: ObjCClass {
        return .init(self)
    }
    
    public func setClass(_ `class`: ObjCClass) -> ObjCClass {
        return .init(object_setClass(self, `class`.value)!)
    }
    
    public func responds(to selector: ObjCSelector) -> Bool {
        return (self as? NSObject)?.responds(to: selector.value) ?? objCClass.responds(to: selector)
    }
}

extension ObjCObject {
    public subscript(instanceVariable value: ObjCInstanceVariable) -> Any? {
        get {
            return object_getIvar(self, value.value)
        } set {
            object_setIvar(self, value.value, newValue)
        }
    }
    
    public subscript(instanceVariableNamed name: String) -> Any? {
        get {
            return objCClass[instanceVariableNamed: name].flatMap({ self[instanceVariable: $0] })
        } set {
            objCClass[instanceVariableNamed: name].flatMap({ self[instanceVariable: $0] = newValue })
        }
    }
}

extension ObjCObject {
    public subscript(methodNamed name: String) -> ObjCMethod? {
        return objCClass[methodNamed: name]
    }
    
    public subscript(classMethodNamed name: String) -> ObjCMethod? {
        return objCClass[classMethodNamed: name]
    }
}

// MARK: - Auxiliary Extensions

extension ObjCObject {
    public func keepAlive<T>(_ value: T) {
        let key = ObjCAssociationKey<ExecuteClosureOnDeinit>()
        
        _objC_associatedObjects[key] = ExecuteClosureOnDeinit {
            _ = value
        }
    }
}

// MARK: - Helpers

public func asObjCObject(_ object: AnyObject) -> ObjCObject {
    return unsafeBitCast(object)
}
