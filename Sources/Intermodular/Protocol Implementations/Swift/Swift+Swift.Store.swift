//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyMutableStore<T>: MutableStore {
    public var base: opaque_MutableStore
    
    public init<U: MutableStore>(_ base: U) where U.Storage == T {
        self.base = base
    }
    
    public var storage: T {
        get {
            return try! cast(base.opaque_Store_storage)
        } set {
            try! base.opaque_MutableStore_set(storage: newValue).unwrap()
        }
    }
    
    public init(storage: T) {
        self.init(SomeMutableStore(storage: storage))
    }
}

public struct AnyStore<T>: Store {
    public let base: opaque_Store

    public init<U: Store>(_ base: U) where U.Storage == T {
        self.base = base
    }

    public var storage: T {
        return try! cast(base.opaque_Store_storage)
    }

    public init(storage: T) {
        self.init(SomeStore(storage: storage))
    }
}

public final class HeapStore<T>: Store {
    public let storage: T
    
    public required init(storage: T) {
        self.storage = storage
    }
}

public final class MutableHeapStore<T>: MutableStore {
    public var storage: T
    
    public init(storage: T) {
        self.storage = storage
    }
}

public struct SomeMutableStore<T>: MutableStore {
    public var storage: T

    public init(storage: T) {
        self.storage = storage
    }
}

public struct SomeStore<T>: Store {
    public let storage: T
    
    public init(storage: T) {
        self.storage = storage
    }
}
