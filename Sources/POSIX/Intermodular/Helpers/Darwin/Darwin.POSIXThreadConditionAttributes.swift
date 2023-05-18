//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadConditionAttributes: POSIXIndirect<pthread_condattr_t>, POSIXSynchronizationPrimitive {
    public override func construct() throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_condattr_init(value) })
        }
    }
    
    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_condattr_destroy(value) })
        }

        try super.destruct()
    }
}
