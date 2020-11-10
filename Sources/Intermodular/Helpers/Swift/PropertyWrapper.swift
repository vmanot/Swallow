//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased shadow protocol for `PropertyWrapper`.
public protocol _opaque_PropertyWrapper {
    var _opaque_wrappedValue: Any { get }
}

extension _opaque_PropertyWrapper where Self: PropertyWrapper {
    public var _opaque_wrappedValue: Any {
        wrappedValue
    }
}

/// A protocol formalizing a `@propertyWrapper`.
public protocol PropertyWrapper: _opaque_PropertyWrapper {
    associatedtype WrappedValue
    
    var wrappedValue: WrappedValue { get }
}

public protocol ParameterlessPropertyWrapper: PropertyWrapper {
    init(wrappedValue: WrappedValue)
}

public protocol MutablePropertyWrapper: PropertyWrapper {
    var wrappedValue: WrappedValue { get set }
}

// MARK: - Implementation -

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

// MARK: - API -

/// A type capable of either storing a direct value or flattening a property wrapper.
///
/// Use it while building your own protocol wrapper composition.
@propertyWrapper
public struct MutableValueBox<WrappedValue>: MutablePropertyWrapper {
    private let getWrappedValue: (Self) -> WrappedValue
    private let setWrappedValue: (inout Self, WrappedValue) -> ()
    
    private var _wrappedValue: Any
    
    public var wrappedValue: WrappedValue {
        get {
            getWrappedValue(self)
        } set {
            setWrappedValue(&self, newValue)
        }
    }
    
    public init(wrappedValue: WrappedValue) {
        _wrappedValue = wrappedValue
        
        getWrappedValue = { _self in
            _self._wrappedValue as! WrappedValue
        }
        
        setWrappedValue = { _self, newValue in
            _self._wrappedValue = newValue
        }
    }
    
    public init<Wrapper: MutablePropertyWrapper>(wrappedValue: Wrapper) where Wrapper.WrappedValue == WrappedValue {
        _wrappedValue = wrappedValue
        
        getWrappedValue = { _self in
            (_self._wrappedValue as! Wrapper).wrappedValue
        }
        
        setWrappedValue = { _self, newValue in
            var wrappedValue = _self.wrappedValue as! Wrapper
            
            wrappedValue.wrappedValue = newValue
            
            _self._wrappedValue = newValue
        }
    }
}
