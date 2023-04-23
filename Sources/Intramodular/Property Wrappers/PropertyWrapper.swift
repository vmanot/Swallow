//
// Copyright (c) Vatsal Manot
//

import Swift

/// A protocol formalizing a `@propertyWrapper`.
public protocol PropertyWrapper<WrappedValue>: CustomDebugStringConvertible {
    associatedtype WrappedValue
    
    var wrappedValue: WrappedValue { get }
}

public protocol ParameterlessPropertyWrapper: PropertyWrapper {
    init(wrappedValue: WrappedValue)
}

public protocol MutablePropertyWrapper: PropertyWrapper {
    var wrappedValue: WrappedValue { get set }
}

// MARK: - Extensions

extension ParameterlessPropertyWrapper {
    public static var _opaque_WrappedValue: Any.Type {
        WrappedValue.self
    }
    
    public init(_opaque_wrappedValue value: Any) throws {
        try self.init(wrappedValue: cast(value, to: WrappedValue.self))
    }
}

// MARK: - Implementation

extension PropertyWrapper {
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
    
    public init<Wrapper: MutablePropertyWrapper>(_ wrapper: Wrapper) where Wrapper.WrappedValue == Value {
        self.base = wrapper
    }
    
    public init<Wrapper: PropertyWrapper>(unsafelyAdapting wrapper: Wrapper) where Wrapper.WrappedValue == Value {
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
    private let getWrappedValue: (Self) -> WrappedValue
    private let setWrappedValue: (inout Self, WrappedValue) -> ()
    
    public var _opaque_wrappedValue: Any
    
    public var wrappedValue: WrappedValue {
        get {
            getWrappedValue(self)
        } set {
            setWrappedValue(&self, newValue)
        }
    }
    
    public init(wrappedValue: WrappedValue) {
        _opaque_wrappedValue = wrappedValue
        
        getWrappedValue = { _self in
            _self._opaque_wrappedValue as! WrappedValue
        }
        
        setWrappedValue = { _self, newValue in
            _self._opaque_wrappedValue = newValue
        }
    }
    
    public init<Wrapper: MutablePropertyWrapper>(_ wrapper: Wrapper) where Wrapper.WrappedValue == WrappedValue {
        _opaque_wrappedValue = wrapper
        
        getWrappedValue = { _self in
            (_self._opaque_wrappedValue as! Wrapper).wrappedValue
        }
        
        setWrappedValue = { _self, newValue in
            var wrappedValue = _self.wrappedValue as! Wrapper
            
            wrappedValue.wrappedValue = newValue
            
            _self._opaque_wrappedValue = newValue
        }
    }
    
    public init<T>(
        initial: T,
        get: @escaping (T) -> WrappedValue,
        set: @escaping (inout T, WrappedValue) -> ()
    )  {
        _opaque_wrappedValue = initial
        
        getWrappedValue = { _self in
            get(_self._opaque_wrappedValue as! T)
        }
        
        setWrappedValue = { _self, newValue in
            var initial = _self._opaque_wrappedValue as! T
            
            set(&initial, newValue)
            
            _self._opaque_wrappedValue = initial
        }
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
