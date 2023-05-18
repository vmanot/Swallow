//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadAttributes: POSIXIndirect<pthread_attr_t>, POSIXSynchronizationPrimitive {
    public override func construct() throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_attr_init(value) })
        }
    }

    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_attr_destroy(value) })
        }

        try super.destruct()
    }
}
