//
// Copyright (c) Vatsal Manot
//

import Swift

extension Unmanaged {
    @inlinable
    public static func retain(_ instance: Instance) {
        _ = retaining(instance)
    }
    
    @discardableResult @inlinable
    public static func retaining(_ instance: Instance) -> Unmanaged {
        return passUnretained(instance).retain()
    }
    
    @inlinable
    public static func release(_ instance: Instance) {
        _ = releasing(instance)
    }
    
    @discardableResult @inlinable
    public static func releasing(_ instance: Instance) -> Unmanaged {
        let result = passUnretained(instance)
        
        result.release()
        
        return result
    }
    
    @inlinable
    public static func autorelease(_ instance: Instance) {
        _ = autoreleasing(instance)
    }
    
    @discardableResult @inlinable
    public static func autoreleasing(_ instance: Instance) -> Unmanaged {
        return passUnretained(instance).autorelease()
    }
}

extension Unmanaged {
    public func map<T: AnyObject>(
        _ transform: (Instance) throws -> T
    ) rethrows -> Unmanaged<T> {
        try _withUnsafeGuaranteedRef {
            try .passUnretained(transform($0))
        }
    }
    
    public func map<T: AnyObject>(
        _ transform: (Instance) throws -> T?
    ) rethrows -> Unmanaged<T>? {
        try _withUnsafeGuaranteedRef {
            try transform($0).map({ .passUnretained($0) })
        }
    }
    
    public func flatMap<T>(
        _ transform: (Instance) throws -> T
    ) rethrows -> T {
        try _withUnsafeGuaranteedRef {
            try transform($0)
        }
    }
}
