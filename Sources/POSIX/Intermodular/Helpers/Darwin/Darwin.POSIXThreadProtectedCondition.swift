//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXThreadProtectedCondition: POSIXSynchronizationPrimitive, Initiable {
    public typealias Value = (protectee: POSIXThreadCondition, protector: POSIXThreadMutex)
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init() {
        self.init((.init(), .init()))
    }
    
    public func construct(with attributes: (POSIXThreadConditionAttributes, POSIXThreadMutexAttributes)) throws {
        try value.protectee.construct(with: attributes.0)
        try value.protector.construct(with: attributes.1)
    }
    
    public func construct() throws {
        try value.protectee.construct()
        try value.protector.construct()
    }
    
    public mutating func destruct() throws {
        try value.protectee.destruct()
        try value.protector.destruct()
    }
}

extension POSIXThreadProtectedCondition: POSIXThreadMutexProtocol  {
    public func acquireOrFail() throws {
        try value.protector.acquireOrFail()
    }
    
    public func acquireOrBlock() throws {
        try value.protector.acquireOrBlock()
    }
    
    public func relinquish() throws {
        try value.protector.relinquish()
    }
}

extension POSIXThreadProtectedCondition {
    public func broadcast() throws {
        try value.protectee.broadcast()
    }
    
    public func signal() throws {
        try value.protectee.signal()
    }
    
    public func wait() throws {
        try self.value.protectee.wait(with: self.value.protector)
    }
}
