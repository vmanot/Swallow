//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXManagedSynchronizationPrimitive<T: POSIXSynchronizationPrimitive>: MutableWrapper {
    public typealias Value = T
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
        
        try? self.value.construct()
    }
    
    deinit {
        try? value.destruct()
    }
}

extension POSIXManagedSynchronizationPrimitive where T: Initiable {
    public convenience init() {
        self.init(.init())
    }
}
