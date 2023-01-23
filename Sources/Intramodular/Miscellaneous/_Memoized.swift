//
// Copyright (c) Vatsal Manot
//

import Swift

/// This type is a work-in-progress, **do not use it in production**.
@propertyWrapper
public final class _Memoized<EnclosingSelf: AnyObject, Value>: PropertyWrapper {
    public var computeBaseHash: (EnclosingSelf) -> Int
    public var computeValue: (EnclosingSelf) -> Value
    
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
        _ computeValue: @escaping (EnclosingSelf) -> Value
    ) where EnclosingSelf: Hashable {
        self.computeBaseHash = { $0.hashValue }
        self.computeValue = computeValue
    }
    
    public init<T: Hashable>(
        _ keyPath: KeyPath<EnclosingSelf, T>,
        _ computeValue: @escaping (T) -> Value
    ) {
        self.computeBaseHash = { $0[keyPath: keyPath].hashValue }
        self.computeValue = { computeValue($0[keyPath: keyPath]) }
    }
    
    public static subscript(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, _Memoized>
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

extension _Memoized: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: _Memoized, rhs: _Memoized) -> Bool {
        return true
    }
}
