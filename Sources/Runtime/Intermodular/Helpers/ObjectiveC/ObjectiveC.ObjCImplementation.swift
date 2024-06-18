//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCImplementation: Hashable {
    public typealias Value = IMP
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    @_transparent
    public func unsafeBitCast<T>(
        to type: T.Type
    ) -> T {
        Swift.unsafeBitCast(value, to: type)
    }
}

extension ObjCImplementation {
    public var blockView: ObjCBlock? {
        @inlinable
        get {
            if let object = imp_getBlock(value) as? ObjCObject {
                return ObjCBlock(object)
            } else {
                return nil
            }
        } set {
            if let newValue = newValue {
                value = imp_implementationWithBlock(newValue)
            } else {
                try! removeBlock()
            }
        }
    }
    
    @inlinable
    public init?(block: ObjCBlock) {
        self.init(imp_implementationWithBlock(block.value))
    }
    
    @discardableResult
    public func removeBlock() throws -> ObjCBlock? {
        let result = blockView
        try imp_removeBlock(value).orThrow()
        return result
    }
}

// MARK: - Helpers

extension ObjCMethod {
    public var implementation: ObjCImplementation {
        get {
            return .init(method_getImplementation(value))
        } nonmutating set {
            method_setImplementation(value, newValue.value)
        }
    }
    
    public func exchangeImplementations(with other: ObjCMethod) {
        method_exchangeImplementations(value, other.value)
    }
}
