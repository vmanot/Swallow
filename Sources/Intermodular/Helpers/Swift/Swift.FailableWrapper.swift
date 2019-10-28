//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be converted to and from an associated value.
public protocol FailableWrapper: ValueConvertible {
    init(uncheckedValue: Value)
    init?(_: Value)
}

/// A type that can be infallibly converted to and from an associated value.
public protocol Wrapper: opaque_Wrapper, FailableWrapper {
    init(_: Value)
}

public protocol MutableWrapper: opaque_MutableWrapper, Wrapper {
    var value: Value { get set }
}

public protocol WrapperWrapper: Wrapper {
    associatedtype ValueWrapper: Wrapper where ValueWrapper.Value == Value
    var valueWrapper: ValueWrapper { get }
    init(_: ValueWrapper)
}

public protocol MutableWrapperWrapper: MutableWrapper, WrapperWrapper where ValueWrapper: MutableWrapper {
    var valueWrapper: ValueWrapper { get set }
}

public protocol MutableWrapperWrapperClass: MutableWrapperWrapper {
    var valueWrapper: ValueWrapper { get nonmutating set }
    var value: Value { get nonmutating set }
}

// MARK: - Implementation -

extension FailableWrapper {
    public init(uncheckedValue value: Value) {
        self = Self(value)!
    }
}

extension Wrapper {
    @inlinable
    public init?(nilIfNil value: Value?) {
        guard let value = value else {
            return nil
        }

        self.init(value)
    }
}

extension WrapperWrapper {
    public var value: Value {
        return valueWrapper.value
    }

    public init(_ value: Value) {
        self.init(ValueWrapper(value))
    }
}

extension MutableWrapperWrapper {
    public var value: Value {
        get {
            return valueWrapper.value
        } set {
            valueWrapper.value = newValue
        }
    }
}

extension MutableWrapperWrapperClass where Self: AnyObject {
    public var value: Value {
        get {
            return valueWrapper.value
        } nonmutating set {
            valueWrapper.value = newValue
        }
    }
}
