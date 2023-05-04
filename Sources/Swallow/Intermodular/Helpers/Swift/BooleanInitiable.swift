//
// Copyright (c) Vatsal Manot
//

import Darwin
import ObjectiveC
import Swift

public protocol BooleanInitiable {
    init(_: Bool)
    init(_: DarwinBoolean)
    init(_: ObjCBool)
}

extension BooleanInitiable {
    @inlinable
    public init(_ value: DarwinBoolean) {
        self.init(value.boolValue)
    }
    
    @inlinable
    public init(_ value: ObjCBool) {
        self.init(value.boolValue)
    }
}

// MARK: - Conformances

extension BooleanInitiable where Self: ExpressibleByIntegerLiteral {
    @inlinable
    public init(_ value: Bool) {
        self = (value == true) ? 1 : 0
    }
}

extension BooleanInitiable where Self: ExpressibleByBooleanLiteral {
    @inlinable
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}
