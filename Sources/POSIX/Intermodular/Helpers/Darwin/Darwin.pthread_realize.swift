//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public func pthread_realize<T, U>(_ f: ((UnsafePointer<T>, UnsafeMutablePointer<U>) -> Int32), with x: POSIXIndirect<T>) throws -> U where T: Trivial {
    return try x.withConstructedValue { value in
        let pointer = UnsafeMutablePointer<U>.allocate(capacity: 1)
        
        try f(value, pointer).throwingAsPOSIXErrorIfNecessary()
        
        return pointer.remove()
    }
}

@discardableResult
public func pthread_realize<T, U>(_ f: ((UnsafeMutablePointer<T>, U) -> Int32), with x: POSIXIndirect<T>, _ y: U) throws -> POSIXResultCode where T: Trivial {
    let rawValue = try x.withConstructedValue { value in
        try f(value, y).throwingAsPOSIXErrorIfNecessary()
    }

    return POSIXResultCode(rawValue: rawValue)!
}
