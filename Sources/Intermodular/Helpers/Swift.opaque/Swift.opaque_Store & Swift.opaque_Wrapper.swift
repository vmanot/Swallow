//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_Store: AnyProtocol {
    var opaque_Store_storage: Any { get }
    
    static func opaque_Store_init(storage: Any) -> opaque_Store?
}

public protocol opaque_MutableStore: opaque_Store {
    mutating func opaque_MutableStore_set(storage: Any) -> Void?
}

public protocol opaque_Wrapper: AnyProtocol {
    var opaque_Wrapper_value: Any { get }
    
    static func opaque_Wrapper_init(_: Any) -> opaque_Wrapper?
}

public protocol opaque_MutableWrapper: opaque_Wrapper {
    mutating func opaque_MutableWrapper_set(value _: Any) -> Void?
}

// MARK: - Implementation -

extension opaque_Store where Self: Store {
    public var opaque_Store_storage: Any {
        return storage
    }
    
    public static func opaque_Store_init(storage: Any) -> opaque_Store? {
        return (-?>storage).map(Self.init(storage:))
    }
}

extension opaque_MutableStore where Self: MutableStore {
    public mutating func opaque_MutableStore_set(storage: Any) -> Void? {
        return (storage as? Storage).map({ self.storage = $0 })
    }
}

// MARK: -

extension opaque_Wrapper where Self: Wrapper {
    public var opaque_Wrapper_value: Any {
        return value
    }
    
    public static func opaque_Wrapper_init(_ value: Any) -> opaque_Wrapper? {
        return (-?>value).map({ self.init($0) })
    }
}

extension opaque_MutableWrapper where Self: MutableWrapper {
    public mutating func opaque_MutableWrapper_set(value newValue: Any) -> Void? {
        return (-?>newValue).map({ self.value = $0 })
    }
}
