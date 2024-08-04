//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct _ManagedActorDispatchState {
    
}

open class _ManagedActorDispatch<ActorType: _ManagedActorProtocol> {
    private weak var owner: ActorType?
    
    private lazy var taskQueue = _ManagedActorTaskQueue()

    private let _wantsSerializedExecution: Bool = ActorType._managedActorInitializationOptions.contains(.serializedExecution)
    
    public required init(owner: ActorType) {
        self.owner = owner
    }
    
    @inline(never)
    open dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<ActorType._ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try operation()
    }
    
    @inline(never)
    open dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<ActorType._ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () async -> R
    ) async -> R {
        let result: R
        
        if _wantsSerializedExecution {
            result = await taskQueue.perform {
                await operation()
            }
        } else {
            result = await operation()
        }
        
        return result
    }
    
    @inline(never)
    open dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<ActorType._ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R {
        let result: Result<R, Error>
        
        if _wantsSerializedExecution {
            result = await taskQueue.perform {
                await Result(catching: {
                    try await operation()
                })
            }
        } else {
            result = await Result(catching: {
                try await operation()
            })
        }
        
        return try result.get()
    }
    
    @inline(never)
    open dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<ActorType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try operation()
    }
    
    @inline(never)
    open dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<ActorType, M>,
        operation: @escaping () async -> R
    ) async -> R {
        let result: R
        
        if _wantsSerializedExecution {
            result = await taskQueue.perform {
                await operation()
            }
        } else {
            result = await operation()
        }
        
        return result
    }
    
    @inline(never)
    open dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<ActorType, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R {
        let result: Result<R, Error>
        
        if _wantsSerializedExecution {
            result = await taskQueue.perform {
                await Result(catching: {
                    try await operation()
                })
            }
        } else {
            result = await Result(catching: {
                try await operation()
            })
        }
        
        return try result.get()
    }
}
