//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ManagedActorExecutor {
    
}

@frozen
public enum _ManagedActorInitializationOption: Hashable, Sendable {
    case serializedExecution
}

/// Because OF COURSE `ManagedActor(_: <literally any enum type>)` causes a fucking compiler crash.
///
///  (╯°□°）╯︵ ┻━┻
public struct _ManagedActorInitializationOptionName: Hashable, Sendable {
    public static let serializedExecution = Self()
}

@attached(memberAttribute)
@attached(extension, conformances: _ManagedActorProtocol, names: arbitrary)
@attached(peer, names: prefixed(_ManagedActorMethodTrampolineList_))
@attached(member, names: named(_managedActorDispatch))
public macro ManagedActor(_ options: _ManagedActorInitializationOptionName...) = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro"
)

/// `extension` macro cannot be attached to extension...
///
///  (╯°□°）╯︵ ┻━┻
@attached(peer, names: prefixed(_ManagedActorMethodTrampolineList_))
@attached(member, names: arbitrary, named(_managedActorDispatch))
public macro ManagedActorExtension() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro"
)

@attached(peer, names: prefixed(_ManagedActorMethod_))
public macro _ManagedActorMethod() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro"
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

@dynamicMemberLookup
public protocol _ManagedActorProtocol: AnyObject {
    associatedtype _ManagedActorMethodTrampolineListType: _ManagedActorMethodTrampolineList
    associatedtype _ManagedActorDispatchType: _ManagedActorDispatch<Self> = _ManagedActorDispatch<Self>

    static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> { get }
    
    var _managedActorDispatch: _ManagedActorDispatchType { get }
    
    dynamic subscript<T: _ManagedActorMethodTrampolineProtocol>(
        dynamicMember keyPath: KeyPath<_ManagedActorMethodTrampolineListType, T>
    ) -> T { get }
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () async -> R
    ) async -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<Self, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<Self, M>,
        operation: @escaping () async -> R
    ) async -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<Self, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R
}

// MARK: - Implementation

extension _ManagedActorProtocol {
    public typealias _ManagedActorSelfType = Self
}

extension _ManagedActorProtocol {
    public dynamic subscript<T: _ManagedActorMethodTrampolineProtocol>(
        dynamicMember keyPath: KeyPath<_ManagedActorMethodTrampolineListType, T>
    ) -> T {
        let result = _ManagedActorMethodTrampolineListType()[keyPath: keyPath]
        
        result._caller = self
        
        return result
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try _managedActorDispatch._performInnerBodyOfMethod(method) {
            try operation()
        }
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () async -> R
    ) async -> R {
        await _managedActorDispatch._performInnerBodyOfMethod(method) {
            await operation()
        }
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodTrampolineListType, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R {
        try await _managedActorDispatch._performInnerBodyOfMethod(method) {
            try await operation()
        }
    }
}

extension _ManagedActorProtocol {
    @_disfavoredOverload
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<Self, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try _managedActorDispatch._performInnerBodyOfMethod(method) {
            try operation()
        }
    }
    
    @_disfavoredOverload
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<Self, M>,
        operation: @escaping () async -> R
    ) async -> R {
        await _managedActorDispatch._performInnerBodyOfMethod(method) {
            await operation()
        }
    }
    
    @_disfavoredOverload
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodTrampolineProtocol, R>(
        _ method: KeyPath<Self, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R {
        try await _managedActorDispatch._performInnerBodyOfMethod(method) {
            try await operation()
        }
    }
}

// MARK: - Auxiliary

@dynamicMemberLookup
public struct _ManagedActorExplicitSelf<ActorType: _ManagedActorProtocol>: @unchecked Sendable {
    public let actor: ActorType
    
    public init(actor: ActorType) {
        self.actor = actor
    }
    
    public dynamic subscript<T: _ManagedActorMethodTrampolineProtocol>(
        dynamicMember keyPath: KeyPath<ActorType._ManagedActorMethodTrampolineListType, T>
    ) -> T {
        self.actor[dynamicMember: keyPath]
    }
}

extension _ManagedActorProtocol {
    public var __managed_self: _ManagedActorExplicitSelf<Self> {
        _ManagedActorExplicitSelf(actor: self)
    }
}
