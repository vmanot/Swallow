//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public protocol POSIXThreadMutexProtocol {
    mutating func acquireOrFail() throws
    mutating func acquireOrBlock() throws
    mutating func relinquish() throws
    
    mutating func withCriticalScope<T>(_: (() -> T)) throws -> T
}

// MARK: - Implementation

extension POSIXThreadMutexProtocol {
    public mutating func withCriticalScope<T>(_ f: (() -> T)) throws -> T {
        let result: T
        
        try acquireOrBlock()
        
        result = f()

        try relinquish()

        return result
    }
}
