//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased shadow protocol for `PropertyWrapper`.
public protocol _opaque_PropertyWrapper {
    var _opaque_wrappedValue: Any { get }
}

extension _opaque_PropertyWrapper where Self: PropertyWrapper {
    public var _opaque_wrappedValue: Any {
        wrappedValue
    }
}

/// A protocol formalizing a `@propertyWrapper`.
public protocol PropertyWrapper: _opaque_PropertyWrapper {
    associatedtype WrappedValue
    
    var wrappedValue: WrappedValue { get }
}

public protocol MutablePropertyWrapper: PropertyWrapper {
    var wrappedValue: WrappedValue { get set }
}
