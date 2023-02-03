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
public protocol Wrapper: FailableWrapper {
    init(_: Value)
}

public protocol MutableWrapper: Wrapper {
    var value: Value { get set }
}

// MARK: - Implementation -

extension FailableWrapper {
    public init(uncheckedValue value: Value) {
        self = Self(value)!
    }
}
