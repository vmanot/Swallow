//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXThreadKeyedValue<T: ExpressibleByNilLiteral>: Initiable, POSIXSynchronizationPrimitive {
    private var key: POSIXThreadKey
    
    public init() {
        self.key = .init()
    }
    
    public func construct() throws {
        try key.construct(with: { $0.assumingMemoryBound(to: (() -> Void).self).pointee() })
    }

    public func destruct() throws {
        try key.destruct()
    }
}

extension POSIXThreadKeyedValue {
    private struct Storage {
        public var destructor: (() -> Void)
        public var value: T
    }

    private var rawValue: UnsafeMutablePointer<Storage> {
        guard key.isAssociatedWithSpecificValue else {
            let value = UnsafeMutablePointer<Storage>.allocate(capacity: 1)

            try! POSIXThread.setSpecificValue(value, forKey: key)

            value.initialize(to:
                .init(destructor: { value.deinitializeFirst().deallocate() }, value: nil))

            return .init(value)
        }

        return try! POSIXThread
            .specificValue(forKey: key)!
            .assumingMemoryBound(to: Storage.self)
    }

    public var value: T {
        get {
            return rawValue.pointee.value
        } set {
            rawValue.pointee.value = newValue
        }
    }
}
