//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadLockReference: Initiable, Wrapper {
    public typealias Value = POSIXThreadMutex
    
    public internal(set) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public init() {
        value = .init()
        
        try! value.construct()
    }
        
    public func acquireOrBlock() {
        try! value.acquireOrBlock()
    }
    
    public func acquireOrFail() throws {
        try value.acquireOrFail()
    }
    
    public func relinquish() {
        try! value.relinquish()
    }
    
    @discardableResult
    public func withCriticalScope<T>(_ f: (() throws -> T)) rethrows -> T {
        defer {
            relinquish()
        }
        
        acquireOrBlock()
        
        return try f()
    }

    deinit {
        try! value.destruct()
    }
}
