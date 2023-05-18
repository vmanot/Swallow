//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXThreadKey: POSIXIndirect<pthread_key_t>, POSIXSynchronizationPrimitive {
    public override func construct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_key_create(value, nil) })
        }
    }

    public func construct(with destructor: (@escaping @convention(c) (UnsafeMutableRawPointer) -> Void)) throws {
        try super.construct()

        try withConstructedValue { value in
            try pthread_try({ pthread_key_create(value, destructor) })
        }
    }
    
    public override func destruct() throws {
        try withConstructedValue { value in
            try pthread_try({ pthread_key_delete(value.pointee) })
        }

        try super.destruct()
    }
}

extension POSIXThreadKey {
    public var isAssociatedWithSpecificValue: Bool {
        return try! POSIXThread.specificValue(forKey: self) != nil
    }
}

// MARK: - Helpers

extension POSIXThread {
    public static func specificValue(forKey key: POSIXThreadKey) throws -> UnsafeMutableRawPointer? {
        return try key.withConstructedValue { value in
            return pthread_getspecific(value.pointee)
        }
    }
    
    public static func setSpecificValue(_ newValue: UnsafeMutableRawPointer?, forKey key: POSIXThreadKey) throws {
        try key.withConstructedValue { (value: UnsafeMutablePointer<pthread_key_t>) in
            return pthread_setspecific(value.pointee, newValue)
        }.toPOSIXResultCode()?.throwIfNecessary()
    }
}
