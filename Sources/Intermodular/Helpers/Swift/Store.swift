//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Store: _opaque_Store {
    associatedtype Storage
    
    var storage: Storage { get }
    
    init(storage: Storage)
}

public protocol MutableStore: _opaque_MutableStore, Store {
    var storage: Storage { get set }
}

// MARK: - Helpers -

public func store<T: Store>(_ storage: T.Storage) -> T {
    return .init(storage: storage)
}
