//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _SyncOrAsyncFunction_Type: Sendable {
    associatedtype Input
    associatedtype Output
    
    func callAsFunction(_ input: Input) throws -> _SyncOrAsyncValue<Output>
}

public enum _SyncOrAsyncFunction<Input, Output>: _SyncOrAsyncFunction_Type, @unchecked Sendable {
    case synchronous((Input) throws -> Output)
    case asynchronous((Input) async throws -> Output)
        
    public init(_ fn: @escaping (Input) throws -> Output) {
        self = .synchronous(fn)
    }
    
    @_disfavoredOverload
    public init(_ fn: @escaping (Input) async throws -> Output) {
        self = .asynchronous(fn)
    }
    
    
    public static func _asyncTrampoline(
        _ action: @escaping () -> _SyncOrAsyncFunction<Input, Output>
    ) -> Self {
        Self.init({
           try await action().callAsFunction($0).value
        })
    }
    
    public func callAsFunction(_ input: Input) -> _SyncOrAsyncValue<Output> {
        switch self {
            case .synchronous(let fn):
                return .synchronous(try fn(input))
            case .asynchronous(let fn):
                return _SyncOrAsyncValue.asynchronous(_AsyncPromise {
                    try await fn(input)
                })
        }
    }
    
    public func callAsFunction() -> _SyncOrAsyncValue<Output> where Input == Void {
        callAsFunction(())
    }
    
    @_disfavoredOverload
    public func callAsFunction() async throws -> Output where Input == Void {
        try await (callAsFunction(()) as _SyncOrAsyncValue).value
    }
}

extension _SyncOrAsyncFunction {
    public func map<T>(
        _ transform: @escaping (Output) -> T
    ) -> _SyncOrAsyncFunction<Input, T> {
        switch self {
            case .synchronous(let fn):
                return .synchronous({ try transform(fn($0)) })
            case .asynchronous(let fn):
                return .asynchronous({ try await transform(fn($0)) })
        }
    }
}
