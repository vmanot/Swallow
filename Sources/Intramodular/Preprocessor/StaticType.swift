//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that represents a static construct.
///
/// For e.g. `StaticString`.
public protocol StaticType {
    
}

public protocol StaticValue: StaticType {
    associatedtype Value
    
    static var value: Value { get }
}

public protocol StaticInteger: StaticValue where Value == Int {
    
}
