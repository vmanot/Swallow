//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXThreadMutexProtectedWrapper<T>: MutableWrapper {
    public typealias Value = T
    
    private var rawValue: Value
    private var protector: POSIXManagedSynchronizationPrimitive<POSIXThreadMutex>
    
    public var value: Value {
        get {
            return try! protector.value.withCriticalScope({ rawValue })
        } set {
            try! protector.value.withCriticalScope({ rawValue = newValue })
        }
    }
    
    public init(_ value: Value) {
        rawValue = value
        protector = .init(.init())
    }
}
