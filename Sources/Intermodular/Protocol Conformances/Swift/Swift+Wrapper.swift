//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyFunction<T, U>: MutableFunctionWrapper {
    public typealias Value = ((T) -> U)
    
    public var value: Value
    
    public init(_ value: (@escaping Value)) {
        self.value = value
    }
    
    public var functionView: AnyFunction {
        get {
            return self
        } set {
            self = newValue
        }
    }
    
    public func input(_ value: T) -> U {
        return self.value(value)
    }
}

public struct AnyThrowingFunction<T, U>: MutableThrowingFunctionWrapper {
    public typealias Value = ((T) throws -> U)
    
    public var value: Value
    
    public init(_ value: (@escaping Value)) {
        self.value = value
    }
    
    public var functionView: AnyFunction<T, Result<U, AnyError>> {
        get {
            return AnyFunction(input)
        } set {
            self = .init({ try newValue.input($0).unwrap() })
        }
    }
    
    public func input(_ value: T) throws -> U {
        return try self.value(value)
    }
    
    public func input(_ value: T) -> Result<U, AnyError> {
        return Result(try self.value(value)).mapFailure({ AnyError($0 )})
    }
}

public struct AnyWrapper<T>: CustomDebugStringConvertible, Wrapper {
    private var base: _opaque_Wrapper
    
    public var value: T {
        return try! cast(base._opaque_Wrapper_value)
    }
    
    public init(_ value: T) {
        self.init(SomeWrapper(value))
    }
    
    public init<U: Wrapper>(_ base: U) where U.Value == T {
        self.base = base
    }
    
    public init<U: ValueConvertible>(_ valueConvertible: U) where U.Value == T {
        self.init(AnyValueConvertibleToWrapper(valueConvertible))
    }
}

public struct AnyMutableWrapper<T>: CustomDebugStringConvertible, MutableWrapper {
    private var base: _opaque_MutableWrapper
    
    public init<U: MutableWrapper>(_ base: U) where U.Value == T {
        self.base = base
    }
    
    public var value: T {
        get {
            return try! cast(base._opaque_Wrapper_value)
        } set {
            base._opaque_MutableWrapper_set(value: newValue).forceUnwrap()
        }
    }
    
    public init(_ value: T) {
        self.init(SomeMutableWrapper(value))
    }
}

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
            return self[0]
        } set {
            self[0] = newValue
        }
    }
}

public final class HeapWrapper<T>: MutableWrapperBase<T> {
    public required init(_ value: T) {
        super.init(value)
    }
}

extension IteratorOnly: Wrapper {
    
}

@propertyWrapper
public final class ReferenceBox<T>: MutableWrapperBase<T> {
    public var wrappedValue: T {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    public required init(_ value: T) {
        super.init(value)
    }
    
    public required init(wrappedValue: T) {
        super.init(wrappedValue)
    }
}

public struct MutableUnowned<Value: AnyObject>: MutableWrapper {
    public unowned var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public struct MutableWeak<Value: AnyObject>: MutableWrapper {
    public weak var value: Value?
    
    public init(_ value: Value?) {
        self.value = value
    }
}

open class MutableWrapperBase<Value>: CustomDebugStringConvertible, MutableWrapper {
    open var value: Value
    
    public required init(_ value: Value) {
        self.value = value
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

public struct SomeBidirectionalIndex<C: BidirectionalCollection>: Wrapper, Strideable2 {
    public typealias Stride = Int
    public typealias Value = (C, C.Index)
    
    public private(set) var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func advanced(by distance: Int) -> SomeBidirectionalIndex {
        return .init((value.0, value.0.index(value.1, offsetBy: distance)))
    }
    
    public func distance(to other: SomeBidirectionalIndex) -> Int {
        return value.0.distance(from: value.1, to: other.value.1)
    }
}

public struct SomeMutableWrapper<Value>: CustomDebugStringConvertible, MutableWrapper {
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public struct SomeWrapper<Value>: CustomDebugStringConvertible, Wrapper {
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public enum StrongOrWeak<Value: AnyObject> {
    case strong(Value?)
    case weak(Weak<Value>)
    
    public var value: Value? {
        get {
            switch self {
                case .strong(let value):
                    return value
                case .weak(let valueWrapper):
                    return valueWrapper.value
            }
        } set {
            switch self {
                case .strong:
                    self = .strong(newValue)
                case .weak:
                    self = .weak(.init(newValue))
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

public struct Unowned<Value: AnyObject>: Wrapper {
    public unowned let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public struct UnsafeWeak<Value: AnyObject>: Wrapper {
    public private(set) weak var _value: Value?
    
    public var value: Value {
        return _value!
    }
    
    public init(_ value: Value) {
        self._value = value
    }
}

public struct Weak<Value: AnyObject>: Wrapper {
    public private(set) weak var value: Value?
    
    public init(_ value: Value?) {
        self.value = value
    }
}

open class WrapperBase<Value>: CustomDebugStringConvertible, Wrapper {
    public let value: Value
    
    public required init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances -

extension Pair: Initiable where T: Initiable, U: Initiable {
    public init() {
        self.init((.init(), .init()))
    }
}

// MARK: - Helpers -

fileprivate struct AnyValueConvertibleToWrapper<Value>: Wrapper {
    var valueImpl: (() -> Value)
    
    var value: Value {
        return valueImpl()
    }
    
    init<T: ValueConvertible>(_ x: T) where T.Value == Value {
        self.valueImpl = { x.value }
    }
    
    init(_ value: Value) {
        self.init(AnyWrapper(value))
    }
}
