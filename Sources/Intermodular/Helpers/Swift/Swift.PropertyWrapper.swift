//
// Copyright (c) Vatsal Manot
//

import Swift

/// A protocol formalizing a `@propertyWrapper`.
public protocol PropertyWrapper {
    associatedtype WrappedValue
    
    var wrappedValue: WrappedValue { get }
}

public protocol MutablePropertyWrapper: PropertyWrapper {
    var wrappedValue: WrappedValue { get set }
}
