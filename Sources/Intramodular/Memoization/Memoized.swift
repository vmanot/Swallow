//
// Copyright (c) Vatsal Manot
//

import Swift
#if canImport(SwiftUI)
import SwiftUI
#endif

@propertyWrapper
public struct _Memoized<EnclosingSelf: AnyObject & Hashable, Value>: Hashable {
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
    
    public func compute(for instance: EnclosingSelf) -> Value {
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
    
    public static subscript(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].compute(for: instance)
        } set {
            fatalError()
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return true
    }
}

@propertyWrapper
public struct _MemoizedComputation<EnclosingSelf: Hashable, Value>: Hashable {
    private let computeValue: (EnclosingSelf) -> Value
    
    @Indirect var hashValueOfEnclosingSelf: Int?
    @Indirect var computedValue: Value?
    
    public var wrappedValue: Self {
        self
    }
    
    public init(_ computeValue: @escaping (EnclosingSelf) -> Value) {
        self.computeValue = computeValue
    }
    
    public func callAsFunction(_ instance: EnclosingSelf) -> Value {
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
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return true
    }
}

#if canImport(SwiftUI)

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

#endif

extension Hashable {
    public typealias Memoized<Value> = Swallow._Memoized<Self, Value> where Self: AnyObject
    public typealias MemoizedComputation<Value> = Swallow._MemoizedComputation<Self, Value>
}

#if canImport(SwiftUI)

extension View where Self: Hashable {
    public typealias MemoizedStateComputation<Value> = Swallow._MemoizedStateComputation<Self, Value>
}

#endif
