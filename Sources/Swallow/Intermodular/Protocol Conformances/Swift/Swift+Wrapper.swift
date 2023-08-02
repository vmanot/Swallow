//
// Copyright (c) Vatsal Manot
//

import Swift

extension Character: MutableWrapper {
    public typealias Value = String.UnicodeScalarView
    
    public var value: Value {
        get {
            return String(self).unicodeScalars
        } set {
            self = Character(String(newValue))
        }
    }
    
    public init(_ value: Value) {
        self.init(String(value))
    }
}

extension CollectionOfOne: MutableWrapper {
    public typealias Value = Element
    
    @inlinable
    public var value: Value {
        get {
            self[0]
        } set {
            self[0] = newValue
        }
    }
}

@propertyWrapper
open class ReferenceBox<T>: Wrapper {
    public var value: T
    
    public var wrappedValue: T {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    public required init(_ value: T) {
        self.value = value
    }
    
    public convenience init(wrappedValue: T) {
        self.init(wrappedValue)
    }
}

public struct Pair<T, U>: MutableWrapper {
    public typealias Value = (T, U)
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init(_ value0: T, _ value1: U) {
        self.value = (value0, value1)
    }
}

extension Pair: Encodable where T: Encodable, U: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(value.0)
        try container.encode(value.1)
    }
}

extension Pair: Decodable where T: Decodable, U: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        let value0 = try container.decode(T.self)
        let value1 = try container.decode(U.self)
        
        self.init((value0, value1))
    }
}

extension Pair: Hashable where T: Hashable, U: Hashable {
    public func hash(into hasher: inout Hasher) {
        value.0.hash(into: &hasher)
        value.1.hash(into: &hasher)
    }
}

extension Pair: Equatable where T: Equatable, U: Equatable {
    public static func == (lhs: Pair<T, U>, rhs: Pair<T, U>) -> Bool {
        lhs.value == rhs.value
    }
}

extension Pair: Sendable where T: Sendable, U: Sendable {
    
}

public enum _StrongOrWeak<Value: AnyObject> {
    case strong(Value?)
    case weak(Weak<Value>)
    
    public var value: Value? {
        get {
            switch self {
                case .strong(let value):
                    return value
                case .weak(let valueWrapper):
                    return valueWrapper.wrappedValue
            }
        } set {
            switch self {
                case .strong:
                    self = .strong(newValue)
                case .weak:
                    self = .weak(.init(wrappedValue: newValue))
            }
        }
    }
}

extension UnicodeScalar: FailableWrapper {
    public typealias Value = UInt32
}

extension Unmanaged: MutableWrapper {
    public typealias Value = Instance
    
    public var value: Value {
        get {
            return takeUnretainedValue()
        } set {
            self = .init(newValue)
        }
    }
    
    public init(_ value: Value) {
        self = .passUnretained(value)
    }
}

public struct _UnownedObject<Value: AnyObject>: Wrapper {
    public unowned let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public struct _UnsafeWeak<Value: AnyObject>: Wrapper {
    public private(set) weak var _value: Value?
    
    public var value: Value {
        return _value!
    }
    
    public init(_ value: Value) {
        self._value = value
    }
}

/// A weakly held value.
@propertyWrapper
public struct Weak<Value>: PropertyWrapper {
    private weak var _weakWrappedValue: AnyObject?
    private var _strongWrappedValue: Value?
    
    public var wrappedValue: Value? {
        get {
            _weakWrappedValue.map({ $0 as! WrappedValue }) ?? _strongWrappedValue
        } set {
            if let newValue {
                if type(of: newValue) is AnyClass {
                    _weakWrappedValue = try! cast(newValue, to: AnyObject.self)
                } else {
                    _strongWrappedValue = newValue
                }
            } else {
                _weakWrappedValue = nil
                _strongWrappedValue = nil
            }
        }
    }
    
    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(_ value: Value?) {
        self.wrappedValue = value
    }
    
    public init() {
        self.init(wrappedValue: nil)
    }
}

// MARK: - Conformances

extension Pair: Initiable where T: Initiable, U: Initiable {
    public init() {
        self.init((.init(), .init()))
    }
}
