//
// Copyright (c) Vatsal Manot
//

import Foundation

/// A struct that mirrors the properties of `Wrapped`, making each of the types optional.
@dynamicMemberLookup
public struct KeyedValuesOf<Wrapped>: Initiable  {
    private var base: Wrapped?
    /// The values that have been set.
    private var values: [PartialKeyPath<Wrapped>: Any] = [:]
    
    public var isEmpty: Bool {
        base == nil && values.isEmpty
    }
    
    /// Create an empty `Partial`.
    public init() {
        
    }
    
    public init(from base: Wrapped?) {
        self.base = base
    }
    
    /// Returns the value of the given key path, or throws an error if the value has not been set.
    ///
    /// - Parameter keyPath: A keyPath path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value.
    public func value<Value>(
        for keyPath: KeyPath<Wrapped, Value>
    ) throws -> Value {
        if let base = base {
            return base[keyPath: keyPath]
        } else {
            guard let value = values[keyPath] else {
                throw Error.keyPathNotSet(keyPath)
            }
            
            if let value = value as? Value {
                return value
            }
            
            preconditionFailure("Type mismatch \(Value.self): \(value)")
        }
    }
        
    /// Updates the stored value for the given key path.
    ///
    /// - Parameter value: The value to store against `keyPath`.
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    public mutating func setValue<Value>(
        _ value: Value,
        for keyPath: WritableKeyPath<Wrapped, Value>
    ) {
        if base != nil {
            base![keyPath: keyPath] = value
        } else {
            values[keyPath] = value
        }
    }
    
    /// Removes the stored value for the given key path.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    public mutating func removeValue<Value>(for keyPath: WritableKeyPath<Wrapped, Value>) {
        if base != nil {
            fatalError(.unimplemented)
        } else {
            _ = values.removeValue(forKey: keyPath)
        }
    }
}

extension KeyedValuesOf {
    /// Retrieve or set a value for the given key path. Returns `nil` if the value has not been set. If the value is set
    /// to nil it will remove the value.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value, or `nil` if a value has not been set.
    public subscript<Value>(keyPath: WritableKeyPath<Wrapped, Value>) -> Value? {
        get {
            return try? value(for: keyPath)
        } set {
            if let newValue = newValue {
                setValue(newValue, for: keyPath)
            } else {
                removeValue(for: keyPath)
            }
        }
    }
    
    /// Retrieve or set a value for the given key path. Returns `nil` if the value has not been set. If the value is set to nil it will remove the value.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value, or `nil` if a value has not been set.
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Wrapped, Value>) -> Value? {
        get {
            return try? self.value(for: keyPath)
        } set {
            if let newValue = newValue {
                setValue(newValue, for: keyPath)
            } else {
                removeValue(for: keyPath)
            }
        }
    }
    
    /// Retrieve or set a value for the given key path. Returns `nil` if the value has not been set. If the value is set to nil it will remove the value.
    ///
    /// - Parameter keyPath: A key path from `Wrapped` to a property of type `Value`.
    /// - Returns: The stored value, or `nil` if a value has not been set.
    public subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<Wrapped, Value?>
    ) -> Value?? {
        get {
            return try? self.value(for: keyPath)
        } set {
            if let newValue = newValue {
                setValue(newValue, for: keyPath)
            } else {
                setValue(Optional<Value>.none, for: keyPath)
            }
        }
    }
}

extension KeyedValuesOf {
    public func apply(to root: inout Wrapped) throws {
        var _root = root as Any
        
        for (keyPath, value) in values {
            let keyPath = try cast(keyPath, to: _KeyPathMutating.self)
            
            try keyPath.apply(value, to: &_root)
        }
        
        root = _root as! Wrapped
    }
}

// MARK: - Conformances

extension KeyedValuesOf: CustomStringConvertible {
    public var description: String {
        "\(type(of: self))(values: \(String(describing: values)))"
    }
}

extension KeyedValuesOf: Diffable {
    public struct Difference: _DiffableDifferenceType {
        let source: KeyedValuesOf<Wrapped>
        let destination: KeyedValuesOf<Wrapped>
        
        public var isEmpty: Bool {
            source.isEmpty && destination.isEmpty
        }
        
        public func contains<T>(_ keyPath: WritableKeyPath<Wrapped, T>) -> Bool {
            let lhs = try? source.value(for: keyPath)
            let rhs = try? destination.value(for: keyPath)

            return AnyEquatable.equate(lhs, rhs)
        }
    }
    
    public func difference(from source: KeyedValuesOf<Wrapped>) -> Difference {
        Difference(source: source, destination: self)
    }
    
    public func applying(_ difference: Difference) -> Self? {
        fatalError(.unimplemented)
    }
    
    public static func diff(_ lhs: Wrapped, _ rhs: Wrapped) -> Difference {
        Difference(source: .init(from: lhs), destination: .init(from: rhs))
    }
}

extension KeyedValuesOf: @unchecked Sendable where Wrapped: Sendable {
    
}

// MARK: - Auxiliary

extension KeyedValuesOf {
    /// An error that can be thrown by the `value(for:)` function.
    public enum Error<Value>: Swift.Error {
        /// The key path has not been set.
        case keyPathNotSet(KeyPath<Wrapped, Value>)
    }
}

fileprivate protocol _KeyPathMutating {
    func apply(_ value: Any, to root: inout Any) throws
}

extension WritableKeyPath: _KeyPathMutating {
    fileprivate func apply(_ value: Any, to root: inout Any) throws {
        var _root = try cast(root, to: Root.self)
        
        _root[keyPath: self] = try cast(value, to: Value.self)
        
        root = _root
    }
}

public protocol KeyedValuesOfConstructible {
    init(from values: KeyedValuesOf<Self>) throws
}

// MARK: - SwiftUI Additions

#if canImport(SwiftUI)
import SwiftUI

extension Binding {
    /// Constructs a `Binding` that provides a key-path keyed container over a given `Binding.`
    public static func keyedValues<T: KeyedValuesOfConstructible>(
        of base: Binding<T?>
    ) -> Binding<KeyedValuesOf<T>> where Value == KeyedValuesOf<T> {
        Binding(
            get: {
                .init(from: base.wrappedValue)
            },
            set: {
                base.wrappedValue = try? .init(from: $0)
            }
        )
    }
    
    /// Constructs a `Binding` that provides a key-path keyed container over a given `Binding.`
    public static func keyedValues<T: KeyedValuesOfConstructible>(
        of base: Binding<T>
    ) -> Binding<KeyedValuesOf<T>> where Value == KeyedValuesOf<T> {
        Binding(
            get: {
                .init(from: base.wrappedValue)
            },
            set: { newValue in
                if let updatedValue = try? T(from: newValue) {
                    base.wrappedValue = updatedValue
                } else {
                    try! newValue.apply(to: &base.wrappedValue)
                }
            }
        )
    }
}
#endif
