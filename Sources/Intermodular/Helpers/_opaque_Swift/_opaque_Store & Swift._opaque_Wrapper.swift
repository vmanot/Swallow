//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_Store: AnyProtocol {
    var _opaque_Store_storage: Any { get }
    
    static func _opaque_Store_init(storage: Any) -> _opaque_Store?
}

public protocol _opaque_MutableStore: _opaque_Store {
    mutating func _opaque_MutableStore_set(storage: Any) -> Void?
}

public protocol _opaque_Wrapper: AnyProtocol {
    var _opaque_Wrapper_value: Any { get }
    
    static func _opaque_Wrapper_init(_: Any) -> _opaque_Wrapper?
}

public protocol _opaque_MutableWrapper: _opaque_Wrapper {
    mutating func _opaque_MutableWrapper_set(value _: Any) -> Void?
}

// MARK: - Implementation -

extension _opaque_Store where Self: Store {
    public var _opaque_Store_storage: Any {
        return storage
    }
    
    public static func _opaque_Store_init(storage: Any) -> _opaque_Store? {
        return (-?>storage).map(Self.init(storage:))
    }
}

extension _opaque_MutableStore where Self: MutableStore {
    public mutating func _opaque_MutableStore_set(storage: Any) -> Void? {
        return (storage as? Storage).map({ self.storage = $0 })
    }
}

// MARK: -

extension _opaque_Wrapper where Self: Wrapper {
    public var _opaque_Wrapper_value: Any {
        return value
    }
    
    public static func _opaque_Wrapper_init(_ value: Any) -> _opaque_Wrapper? {
        return (-?>value).map({ self.init($0) })
    }
}

extension _opaque_MutableWrapper where Self: MutableWrapper {
    public mutating func _opaque_MutableWrapper_set(value newValue: Any) -> Void? {
        return (-?>newValue).map({ self.value = $0 })
    }
}
