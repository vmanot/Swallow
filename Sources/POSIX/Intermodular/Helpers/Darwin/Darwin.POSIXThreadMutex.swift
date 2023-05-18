//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadMutex: POSIXIndirect<pthread_mutex_t>, POSIXSynchronizationPrimitive {
    public func construct(with attributes: POSIXThreadMutexAttributes) throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_mutex_init(value, attributes.value) })
        }
    }
    
    public override func construct() throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_mutex_init(value, nil) })
        }
    }
    
    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_mutex_destroy(value) })
        }

        try super.destruct()
    }
}

extension POSIXThreadMutex: POSIXThreadMutexProtocol {
    public func acquireOrBlock() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_mutex_lock(value) })
        }
    }

    public func acquireOrFail() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_mutex_trylock(value) })
        }
    }

    public func relinquish() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_mutex_unlock(value) })
        }
    }
}
