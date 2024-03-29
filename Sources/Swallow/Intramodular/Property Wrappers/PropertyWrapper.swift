//
// Copyright (c) Vatsal Manot
//

import Swift

/// A protocol formalizing a `@propertyWrapper`.
public protocol PropertyWrapper<WrappedValue> {
    associatedtype WrappedValue
    
    var wrappedValue: WrappedValue { get }
}

public protocol ParameterlessPropertyWrapper<WrappedValue>: PropertyWrapper {
    init(wrappedValue: WrappedValue)
}

public protocol MutablePropertyWrapper<WrappedValue>: PropertyWrapper {
    var wrappedValue: WrappedValue { get set }
}

// MARK: - Extensions

extension PropertyWrapper {
    public static var _opaque_WrappedValue: Any.Type {
        WrappedValue.self
    }
}

extension ParameterlessPropertyWrapper {
    public init(_opaque_wrappedValue value: Any) throws {
        try self.init(wrappedValue: cast(value, to: WrappedValue.self))
    }
}

// MARK: - Implementation

extension PropertyWrapper where Self: CustomDebugStringConvertible {
    public var debugDescription: String {
        String(describing: wrappedValue)
    }
}

extension ParameterlessPropertyWrapper where WrappedValue: CustomStringConvertible, Self: CustomStringConvertible {
    public var description: String {
        wrappedValue.description
    }
}

extension ParameterlessPropertyWrapper where WrappedValue: Decodable, Self: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try WrappedValue.init(from: decoder))
    }
}

extension ParameterlessPropertyWrapper where WrappedValue: Encodable, Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension ParameterlessPropertyWrapper where WrappedValue: Equatable, Self: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension ParameterlessPropertyWrapper where WrappedValue: Hashable, Self: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

// MARK: - API

public struct AnyMutablePropertyWrapper<Value>: MutablePropertyWrapper {
    private var base: any MutablePropertyWrapper
    
    public var wrappedValue: Value {
        get {
            base.wrappedValue as! Value
        } set {
            try! base._opaque_setWrappedValue(newValue)
        }
    }
    
    public init<Wrapper: MutablePropertyWrapper>(
        _ wrapper: Wrapper
    ) where Wrapper.WrappedValue == Value {
        self.base = wrapper
    }
    
    public init<Wrapper: PropertyWrapper>(
        unsafelyAdapting wrapper: Wrapper
    ) where Wrapper.WrappedValue == Value {
        if let wrapper = wrapper as? any MutablePropertyWrapper {
            self.base = wrapper
        } else {
            self.base = _PropertyWrapperMutabilityAdaptor(wrapper)
        }
    }
}

extension MutablePropertyWrapper {
    fileprivate mutating func _opaque_setWrappedValue(_ newValue: Any) throws {
        self.wrappedValue = try cast(newValue, to: WrappedValue.self)
    }
}

/// A type capable of either storing a direct value or flattening a property wrapper.
///
/// Use it while building your own protocol wrapper composition.
@propertyWrapper
public struct MutableValueBox<WrappedValue>: MutablePropertyWrapper {
    struct Binding {
        let get: (MutableValueBox) -> WrappedValue
        let set: (inout MutableValueBox, WrappedValue) -> ()
    }
    
    private let binding: Binding
    public var _opaque_wrappedValue: Any
    
    public var wrappedValue: WrappedValue {
        get {
            binding.get(self)
        } set {
            binding.set(&self, newValue)
        }
    }
    
    public init(
        wrappedValue: WrappedValue
    ) {
        _opaque_wrappedValue = wrappedValue
        
        binding = .init(
            get: { _self in
                _self._opaque_wrappedValue as! WrappedValue
            },
            set: { _self, newValue in
                _self._opaque_wrappedValue = newValue
            }
        )
    }
    
    public init<Wrapper: MutablePropertyWrapper>(
        _ wrapper: Wrapper
    ) where Wrapper.WrappedValue == WrappedValue {
        _opaque_wrappedValue = wrapper
        
        if isAnyObject(wrapper) {
            binding = .init(
                get: { _ in
                    wrapper.wrappedValue
                },
                set: { _, newValue in
                    var wrapper = wrapper
                    
                    wrapper.wrappedValue = newValue
                }
            )
        } else {
            binding = .init(
                get: { _self in
                    (_self._opaque_wrappedValue as! Wrapper).wrappedValue
                },
                set: { _self, newValue in
                    do {
                        var mutableWrapper = try cast(_self._opaque_wrappedValue, to: Wrapper.self)
                        
                        mutableWrapper.wrappedValue = newValue
                        
                        _self._opaque_wrappedValue = mutableWrapper
                    } catch {
                        assertionFailure(error)
                    }
                }
            )
        }
    }
    
    public init<T>(
        initial: T,
        get: @escaping (T) -> WrappedValue,
        set: @escaping (inout T, WrappedValue) -> ()
    )  {
        _opaque_wrappedValue = initial
        
        binding = .init(
            get: { _self in
                get(_self._opaque_wrappedValue as! T)
            },
            set: { _self, newValue in
                var initial = _self._opaque_wrappedValue as! T
                
                set(&initial, newValue)
                
                _self._opaque_wrappedValue = initial
            }
        )
    }
}

extension MutableValueBox: Equatable where WrappedValue: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension MutableValueBox: Hashable where WrappedValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

// MARK: - Implemented Conformances

public final class _IndirectMutablePropertyWrapper<P: MutablePropertyWrapper>: MutablePropertyWrapper {
    public typealias WrappedValue = P.WrappedValue
    
    private var initialValue: P.WrappedValue?
    private var base: P?
    
    public var wrappedValue: P.WrappedValue {
        get {
            base?.wrappedValue ?? initialValue!
        } set {
            if var base = base {
                base.wrappedValue = newValue
            } else {
                initialValue = newValue
            }
        }
    }
    
    public func setBase(_ base: P) {
        self.initialValue = nil
        self.base = base
    }
    
    public init(initialValue: P.WrappedValue) {
        self.initialValue = initialValue
    }
    
    public init(base: P) {
        self.base = base
    }
}

public struct _PropertyWrapperMutabilityAdaptor<Wrapper: PropertyWrapper>: MutablePropertyWrapper {
    public typealias WrappedValue = Wrapper.WrappedValue
    
    private var base: Either<Wrapper, WrappedValue>
    
    public var wrappedValue: WrappedValue {
        get {
            base.reduce({ $0.wrappedValue }, { $0 })
        } set {
            base = .right(newValue)
        }
    }
    
    public init(_ wrapper: Wrapper) {
        self.base = .left(wrapper)
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension Binding: MutablePropertyWrapper {
    
}

extension ObservedObject: PropertyWrapper {
    
}

extension State: PropertyWrapper {
    
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension StateObject: PropertyWrapper {
    
}
#endif
