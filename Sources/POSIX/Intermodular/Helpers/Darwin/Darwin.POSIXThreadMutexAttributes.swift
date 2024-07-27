//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadMutexAttributes: POSIXIndirect<pthread_mutexattr_t>, POSIXSynchronizationPrimitive {
    public override func construct() throws {
        try super.construct()
        
        try withConstructedValue { value in
            try pthread_try({ pthread_mutexattr_init(value) })
        }
    }
    
    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_mutexattr_destroy(value) })
        }
        
        try super.destruct()
    }
}

extension POSIXThreadMutexAttributes {
    public var type: POSIXThreadMutexType {
        get {
            try! withConstructedValue { value in
                let type = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
                
                pthread_mutexattr_gettype(value, type)
                
                return POSIXThreadMutexType(rawValue: type.remove())!
            }
        } set {
            try! withConstructedValue { value in
                pthread_force_try({ pthread_mutexattr_settype(value, newValue.rawValue) })
            }
        }
    }
    
    public var priorityProtocol: POSIXThreadMutexPriorityProtocol {
        get {
            try! withConstructedValue { value in
                let ptcl = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
                
                pthread_mutexattr_getprotocol(value, ptcl)
                
                return try POSIXThreadMutexPriorityProtocol(rawValue: ptcl.remove()).forceUnwrap()
            }
        } set {
            try! withConstructedValue { value in
                pthread_force_try({ pthread_mutexattr_setprotocol(value, newValue.rawValue) })
            }
        }
    }
}
