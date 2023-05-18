//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadCondition: POSIXIndirect<pthread_cond_t>, POSIXSynchronizationPrimitive {
    public func construct(with attributes: POSIXThreadConditionAttributes) throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_cond_init(value, attributes.value) })
        }
    }
    
    public override func construct() throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_cond_init(value, nil) })
        }
    }
    
    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_cond_destroy(value) })
        }

        try super.destruct()
    }
}

extension POSIXThreadCondition {
    public func broadcast() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_cond_broadcast(value) })
        }
    }
    
    public func signal() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_cond_signal(value) })
        }
    }
    
    public func wait(with mutex: POSIXThreadMutex) throws {
        try withConstructedValue { value in
            try mutex.withConstructedValue { mutexValue in
                try pthread_try({ pthread_cond_wait(value, mutexValue) })
            }
        }
    }
    
    public func wait(with mutex: POSIXThreadMutex, while predicate: @autoclosure () -> Bool) throws {
        while predicate() {
            try wait(with: mutex)
        }
    }
}
