//
// Copyright (c) Vatsal Manot
//

import Swift

/// An indirect, copy-on-write wrapper over a value.
@frozen
@propertyWrapper
public struct _UnsafeIndirect<Value>: ParameterlessPropertyWrapper {
    private var storage: UnsafeMutablePointer<Value>?
    
    public var wrappedValue: Value? {
        get {
            return storage?.pointee
        } set {
            storage!.pointee = newValue!
        }
    }
        
    public init(wrappedValue: Value?) {
        if let wrappedValue {
            self.storage = UnsafeMutablePointer.allocate(initializingTo: wrappedValue)
        } else {
            self.storage = nil
        }
    }
}

// MARK: - Conformances

extension _UnsafeIndirect: Encodable where Value: Encodable {
    
}

extension _UnsafeIndirect: Decodable where Value: Decodable {
    
}

extension _UnsafeIndirect: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        wrappedValue?.description ?? "<uninitialized>"
    }
}

extension _UnsafeIndirect: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension _UnsafeIndirect: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

extension _UnsafeIndirect: @unchecked Sendable where Value: Sendable {
    
}
