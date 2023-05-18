//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadReadWriteLockAttributes: POSIXIndirect<pthread_rwlockattr_t>, POSIXSynchronizationPrimitive {
    public override func construct() throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_rwlockattr_init(value) })
        }
    }

    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_rwlockattr_destroy(value) })
        }

        try super.destruct()
    }
}
