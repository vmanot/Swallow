//
// Copyright (c) Vatsal Manot
//

import Swallow

public final class _ManagedActorScratchpad<ActorType: _ManagedActorProtocol> {
    private lazy var taskQueue = _ManagedActorTaskQueue()
    private weak var owner: ActorType?
    
    private let _wantsSerializedExecution: Bool = ActorType._managedActorInitializationOptions.contains(.serializedExecution)
    
    public init(_owner owner: ActorType) {
        self.owner = owner
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<ActorType._ManagedActorMethodListType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try operation()
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<ActorType._ManagedActorMethodListType, M>,
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
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<ActorType._ManagedActorMethodListType, M>,
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

