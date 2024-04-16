//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(memberAttribute)
@attached(extension, conformances: _ManagedActorProtocol, names: arbitrary)
@attached(peer, names: prefixed(_ManagedActorMethodList_))
public macro ManagedActor() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro"
)

@attached(peer, names: prefixed(_ManagedActorMethod_))
public macro ManagedActorMethod() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro"
)

public protocol _StaticManagedActorMethodConfiguration {
    associatedtype Async: _StaticBoolean
    associatedtype Throws: _StaticBoolean
}

public protocol _ManagedActorMethodProtocol: Initiable {
    //associatedtype _StaticConfiguration: _StaticManagedActorMethodConfiguration
}

@dynamicMemberLookup
public protocol _ManagedActorProtocol {
    associatedtype _ManagedActorMethodListType: Initiable
    
    dynamic subscript<T: _ManagedActorMethodProtocol>(
        dynamicMember keyPath: KeyPath<_ManagedActorMethodListType, T>
    ) -> T { get }
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: () throws -> R
    ) rethrows -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: () async throws -> R
    ) async rethrows -> R
}

extension _ManagedActorProtocol {
    public dynamic subscript<T: _ManagedActorMethodProtocol>(
        dynamicMember keyPath: KeyPath<_ManagedActorMethodListType, T>
    ) -> T {
        _ManagedActorMethodListType()[keyPath: keyPath]
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: () throws -> R
    ) rethrows -> R {
        try operation()
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: () async throws -> R
    ) async rethrows -> R {
        try await operation()
    }
}
