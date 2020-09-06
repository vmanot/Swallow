//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol FunctionInitiable: AnyProtocol {
    associatedtype InitiatingFunctionParameters
    associatedtype InitiatingFunctionResult
    
    init(_: (@escaping (InitiatingFunctionParameters) -> InitiatingFunctionResult))
}

public protocol ThrowingFunctionInitiable: FunctionInitiable {    
    init(_: (@escaping (InitiatingFunctionParameters) throws -> InitiatingFunctionResult))
}

public protocol FunctionWrapper: FunctionInitiable, Wrapper {
    associatedtype ValueParameters = InitiatingFunctionParameters
    associatedtype ValueResult = InitiatingFunctionResult
    
    var value: ((ValueParameters) -> ValueResult) { get }
    
    init(_ value: (@escaping (ValueParameters) -> ValueResult))
}

public protocol ThrowingFunctionWrapper: ThrowingFunctionInitiable, Wrapper {
    associatedtype ValueParameters = InitiatingFunctionParameters
    associatedtype ValueResult = InitiatingFunctionResult
    
    var value: ((ValueParameters) throws -> ValueResult) { get }
    
    init(_ value: (@escaping (ValueParameters) throws -> ValueResult))
}

public protocol MutableFunctionWrapper: FunctionWrapper, MutableWrapper {
    var value: ((ValueParameters) -> ValueResult) { get set }
}

public protocol MutableThrowingFunctionWrapper: ThrowingFunctionWrapper, MutableWrapper {
    var value: ((ValueParameters) throws -> ValueResult) { get set }
}

// MARK: - Implementation

extension FunctionInitiable where Self: ThrowingFunctionInitiable {
    public init(_ function: (@escaping (InitiatingFunctionParameters) -> InitiatingFunctionResult)) {
        self.init({ function($0) } as ((InitiatingFunctionParameters) throws -> InitiatingFunctionResult))
    }
}

// MARK: - Extensions -

extension FunctionInitiable {
    public init(lazy function: @autoclosure @escaping () -> InitiatingFunctionResult) {
        self.init({ _ in function() })
    }
}

extension FunctionInitiable where InitiatingFunctionParameters == Void {
    public init(lazy function: @autoclosure @escaping () -> InitiatingFunctionResult) {
        self.init({ _ in function() })
    }
}

extension FunctionWrapper {
    public func call(with parameters: ValueParameters) -> ValueResult {
        return value(parameters)
    }
}

extension ThrowingFunctionWrapper {
    public func call(with parameters: ValueParameters) throws -> ValueResult {
        return try value(parameters)
    }
}

// MARK: - Concrete Implementations -

public struct NonMutatingGetter<T, U>: FunctionWrapper {
    public typealias Value = ((T) -> U)
    public var value: Value
    public init(_ value: @escaping (Value)) {
        self.value = value
    }
}

public struct MutatingGetter<T, U>: FunctionWrapper {
    public typealias Value = ((Inout<T>) -> U)
    public var value: Value
    public init(_ value: @escaping (Value)) {
        self.value = value
    }
}

public struct MutatingSetter<T, U>: FunctionWrapper {
    public typealias Value = (((Inout<T>, U)) -> ())
    public var value: Value
    public init(_ value: @escaping (Value)) {
        self.value = value
    }
}

public struct NonMutatingSetter<T, U>: FunctionWrapper {
    public typealias Value = (((T, U)) -> ())
    public var value: Value
    public init(_ value: @escaping (Value)) {
        self.value = value
    }
}
