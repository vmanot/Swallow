//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol FunctionInitiable {
    associatedtype InitiatingFunctionParameters
    associatedtype InitiatingFunctionResult
    
    init(_: (@escaping (InitiatingFunctionParameters) -> InitiatingFunctionResult))
}

public protocol ThrowingFunctionInitiable: FunctionInitiable {
    init(_: (@escaping (InitiatingFunctionParameters) throws -> InitiatingFunctionResult))
}

// MARK: - Implementation

extension FunctionInitiable where Self: ThrowingFunctionInitiable {
    public init(_ function: (@escaping (InitiatingFunctionParameters) -> InitiatingFunctionResult)) {
        self.init({ function($0) } as ((InitiatingFunctionParameters) throws -> InitiatingFunctionResult))
    }
}
