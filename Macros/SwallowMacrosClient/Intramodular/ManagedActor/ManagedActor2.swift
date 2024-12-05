//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(memberAttribute)
@attached(extension, conformances: _ManagedActorProtocol2, names: arbitrary)
@attached(member, names: named(_managedActorDispatch))
public macro ManagedActor2(_ options: _ManagedActorInitializationOptionName...) = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro2"
)

@attached(memberAttribute)
public macro ManagedActorExtension2() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro2"
)

@attached(body)
public macro _ManagedActorMethod2() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro2"
)

@attached(body)
public macro ManagedActorMethod2() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro2"
)

public protocol _ManagedActorProtocol2: AnyObject {
    associatedtype _ManagedActorDispatchType2: _ManagedActorDispatch2<Self> = _ManagedActorDispatch2<Self>

    static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> { get }
    
    var _managedActorDispatch: _ManagedActorDispatchType2 { get }
    
    @inline(never)
    dynamic func _performOperation<R>(
        operation: @escaping () -> R
    ) -> R
    
    @inline(never)
    dynamic func _performThrowingOperation<R>(
        operation: @escaping () throws -> R
    ) rethrows -> R
    
    @inline(never)
    dynamic func _performAsyncOperation<R>(
        operation: @escaping () async -> R
    ) async -> R
    
    @inline(never)
    dynamic func _performThrowingAsyncOperation<R>(
        operation: @escaping () async throws -> R
    ) async throws -> R
}

// MARK: - Implementation

extension _ManagedActorProtocol2 {
    public typealias _ManagedActorSelfType = Self
}

extension _ManagedActorProtocol2 {
    @inline(never)
    public dynamic func _performOperation<R>(
        operation: @escaping () -> R
    ) -> R {
        _managedActorDispatch._performOperation {
            operation()
        }
    }
    
    @inline(never)
    public dynamic func _performThrowingOperation<R>(
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try _managedActorDispatch._performThrowingOperation {
            try operation()
        }
    }
    
    @inline(never)
    public dynamic func _performAsyncOperation<R>(
        operation: @escaping () async -> R
    ) async -> R {
        await _managedActorDispatch._performAsyncOperation {
            await operation()
        }
    }
    
    @inline(never)
    public dynamic func _performThrowingAsyncOperation<R>(
        operation: @escaping () async throws -> R
    ) async throws -> R {
        try await _managedActorDispatch._performThrowingAsyncOperation {
            try await operation()
        }
    }
}
