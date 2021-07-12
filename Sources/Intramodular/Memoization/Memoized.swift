//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public final class _Memoized<EnclosingSelf: AnyObject & Hashable, Value>: PropertyWrapper, Hashable {
    public var computeValue: (EnclosingSelf) -> Value
    
    @Indirect var hashValueOfEnclosingSelf: Int?
    @Indirect var computedValue: Value?
    
    public var wrappedValue: Value {
        get {
            fatalError()
        } set {
            fatalError()
        }
    }
    
    public init(_ computeValue: @escaping (EnclosingSelf) -> Value) {
        self.computeValue = computeValue
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
        let instanceHashValue = instance.hashValue
        
        if let computedValue = computedValue, hashValueOfEnclosingSelf == instanceHashValue {
            return computedValue
        } else {
            let newValue = computeValue(instance)
            
            $computedValue.unsafelyUnwrapped = newValue
            $hashValueOfEnclosingSelf.unsafelyUnwrapped = instanceHashValue
            
            return newValue
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: _Memoized, rhs: _Memoized) -> Bool {
        return true
    }
}

extension Hashable {
    public typealias Memoized<Value> = Swallow._Memoized<Self, Value> where Self: AnyObject
}

#if canImport(SwiftUI)

import SwiftUI

@propertyWrapper
public struct _MemoizedStateComputation<EnclosingSelf: Hashable, Value>: Hashable {
    private let computeValue: (EnclosingSelf) -> Value
    
    @State var hashValueOfEnclosingSelf = ReferenceBox<Int?>(nil)
    @State var computedValue = ReferenceBox<Value?>(nil)
    
    public var wrappedValue: Self {
        self
    }
    
    public init(_ computeValue: @escaping (EnclosingSelf) -> Value) {
        self.computeValue = computeValue
    }
    
    public func callAsFunction(_ instance: EnclosingSelf) -> Value {
        let instanceHashValue = instance.hashValue
        
        if let computedValue = computedValue.wrappedValue, hashValueOfEnclosingSelf.wrappedValue == instanceHashValue {
            return computedValue
        } else {
            let newValue = computeValue(instance)
            
            computedValue.wrappedValue = newValue
            hashValueOfEnclosingSelf.wrappedValue = instanceHashValue
            
            return newValue
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return true
    }
}

extension View where Self: Hashable {
    public typealias MemoizedStateComputation<Value> = Swallow._MemoizedStateComputation<Self, Value>
}

#endif
