//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be initialized with a value.
public protocol _ValueInitiable<Value> {
    associatedtype Value
    
    init(value: Value)
}

extension _ValueInitiable {
    public init?(_opaque_value value: Any) {
        guard let value = value as? Value else {
            return nil
        }
        
        self.init(value: value)
    }
}

/// A type that can be converted to and from an associated value.
public protocol FailableWrapper: ValueConvertible {
    init(uncheckedValue: Value)
    
    init?(_: Value)
}

/// A type that can be infallibly converted to and from an associated value.
public protocol Wrapper<Value>: FailableWrapper {
    init(_: Value)
}

public protocol MutableWrapper<Value>: Wrapper {
    var value: Value { get set }
}

// MARK: - Implementation

extension FailableWrapper {
    public init(uncheckedValue value: Value) {
        self = Self(value)!
    }
}
