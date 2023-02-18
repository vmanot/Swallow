//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that represents a static construct.
///
/// For e.g. `StaticString`.
public protocol _StaticType {
    
}

public protocol _StaticValue: _StaticType {
    associatedtype Value
    
    static var value: Value { get }
}

public protocol _StaticBoolean: _StaticValue where Value == Bool {
    
}

public protocol _StaticInteger: _StaticValue where Value == Int {
    
}
