//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXThreadLocal<T> {
    private var storage: POSIXManagedSynchronizationPrimitive<POSIXThreadKeyedValue<T?>>
    private let generator: (() -> T)
    
    public init(initial: T, generator: (@escaping () -> T)) {
        self.storage = .init()
        self.storage.value.value = initial
        self.generator = generator
    }
    
    public init(_ value: (@escaping @autoclosure () -> T)) {
        self.init(initial: value(), generator: value)
    }
    
    public var value: T {
        get {
            return self.storage.value.value ?? generator()
        } set {
            if isKnownUniquelyReferenced(&storage) {
                self.storage.value.value = newValue
            }
                
            else {
                self = .init(initial: newValue, generator: generator)
            }
        }
    }
}
