//
// Copyright (c) Vatsal Manot
//

import Swift

/// A value identified by its `hashValue`.
public struct HashIdentifiedValue<Value: Hashable>: Swift.Identifiable {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public var id: Int {
        return value.hashValue
    }
}
