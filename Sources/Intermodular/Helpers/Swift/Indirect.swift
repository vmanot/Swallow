//
// Copyright (c) Vatsal Manot
//

import Swift

/// An indirect, copy-on-write wrapper over a value.
@propertyWrapper
public struct Indirect<Value>: ParameterlessPropertyWrapper {
    private var storage: ReferenceBox<Value>
    
    public var wrappedValue: Value {
        get {
            return storage.value
        } set {
            if isKnownUniquelyReferenced(&storage) {
                storage.value = newValue
            } else {
                storage = .init(newValue)
            }
        }
    }
    
    public init(wrappedValue: Value) {
        self.storage = .init(wrappedValue)
    }
}

// MARK: - Conformances -

extension Indirect: Encodable where Value: Encodable {
    
}

extension Indirect: Decodable where Value: Decodable {
    
}

extension Indirect: CustomStringConvertible where Value: CustomStringConvertible {
    
}

extension Indirect: Equatable where Value: Equatable {
    
}

extension Indirect: Hashable where Value: Hashable {
    
}
