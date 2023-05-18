//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadReadWriteLock: POSIXIndirect<pthread_rwlock_t>, POSIXSynchronizationPrimitive {
    public func construct(with attributes: POSIXThreadReadWriteLockAttributes) throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_init(value, attributes.value) })
        }
    }

    public override func construct() throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_init(value, nil) })
        }
    }

    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_destroy(value) })
        }

        try super.destruct()
    }
}

extension POSIXThreadReadWriteLock {
    public func acquireOrBlockForReading() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_rdlock(value) })
        }
    }

    public func acquireOrFailForReading() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_tryrdlock(value) })
        }
    }

    public func acquireOrBlockForWriting() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_wrlock(value) })
        }
    }

    public func acquireOrFailForWriting() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_trywrlock(value) })
        }
    }

    public func relinquish() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlock_unlock(value) })
        }
    }
}
