//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
 
/// A memoized value.
///
/// This type is a work-in-progress. Do not use this type directly in your code.
@propertyWrapper
public final class _MemoizedValue<EnclosingSelf, Value>: PropertyWrapper {
    public let computeBaseHash: @Sendable (EnclosingSelf) -> Int
    public let computeValue: @Sendable (EnclosingSelf) -> Value
    
    var baseHash: Int?
    var computedValue: Value?
    
    public var wrappedValue: Value {
        get {
            fatalError()
        } set {
            fatalError()
        }
    }
    
    public init(
        _ computeValue: @escaping @Sendable (EnclosingSelf) -> Value
    ) where EnclosingSelf: Hashable {
        self.computeBaseHash = { $0.hashValue }
        self.computeValue = computeValue
    }
        
    public init<T>(
        tracking keyPath: KeyPath<EnclosingSelf, T>,
        computeValue: @escaping (EnclosingSelf) -> Value
    ) {
        fatalError()
    }
    
    public init<T: Hashable>(
        _ keyPath: KeyPath<EnclosingSelf, T>,
        _ computeValue: @escaping @Sendable (T) -> Value
    ) {
        self.computeBaseHash = { $0[keyPath: keyPath].hashValue }
        self.computeValue = { computeValue($0[keyPath: keyPath]) }
    }
    
    public static subscript(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, _MemoizedValue>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].compute(for: instance)
        } set {
            fatalError("`set` is not allowed on a memoized value. This setter has been exposed to work around a compiler bug")
        }
    }
    
    private func compute(for instance: EnclosingSelf) -> Value {
        let newBaseHash = computeBaseHash(instance)
        
        if let computedValue = computedValue, baseHash == newBaseHash {
            return computedValue
        } else {
            let newValue = computeValue(instance)
            
            computedValue = newValue
            baseHash = newBaseHash
            
            return newValue
        }
    }
}

// MARK: - Conformances

extension _MemoizedValue: Equatable {
    public static func == (lhs: _MemoizedValue, rhs: _MemoizedValue) -> Bool {
        return true
    }
}

extension _MemoizedValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}

extension Hashable {
    public typealias _Memoized<Value> = Swallow._MemoizedValue<Self, Value>
}

extension ObservableObject {
    public typealias _MemoizedValueWithSelfParametrized<Value> = _MemoizedValue<Self, Value>
}
