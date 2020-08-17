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
    public static func pass(_ instance: Instance, ownership: ObjectOwnershipQualfier) -> Self {
        switch ownership {
            case .autoreleasing:
                return Unmanaged.passUnretained(instance).autorelease()
            case .strong:
                return Unmanaged.passRetained(instance)
            case .unsafeUnretained:
                return Unmanaged.passUnretained(instance)
            case .weak:
                return Unmanaged.passUnretained(instance)
        }
    }
    
    public func relinquish(ownership: ObjectOwnershipQualfier) {
        switch ownership {
            case .autoreleasing:
                break
            case .strong:
                release()
            case .unsafeUnretained:
                break
            case .weak:
                break
        }
    }
}
