//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadConditionReference {
    public typealias Value = POSIXThreadCondition
    
    public internal(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public init() {
        value = .init()
        
        try! value.construct()
    }
    
    public func broadcast() {
        try! value.broadcast()
    }
    
    public func signal()  {
        try! value.signal()
    }
    
    public func wait(with mutex: POSIXThreadLockReference) {
        try! value.wait(with: mutex.value)
    }
    
    public func wait(with mutex: POSIXThreadLockReference, while predicate: @autoclosure () throws -> Bool) rethrows {
        while try predicate() {
            wait(with: mutex)
        }
    }

    deinit {
        try! value.destruct()
    }
}
