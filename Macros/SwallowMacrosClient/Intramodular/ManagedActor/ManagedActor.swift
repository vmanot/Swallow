//
// Copyright (c) Vatsal Manot
//

import Swift

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
@attached(peer, names: prefixed(_ManagedActorMethodList_))
@attached(member, names: named(_managedActorScratchpad))
public macro ManagedActor(_ options: _ManagedActorInitializationOptionName...) = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro"
)

/// `extension` macro cannot be attached to extension...
///
///  (╯°□°）╯︵ ┻━┻
/*
 @attached(extension, names: arbitrary)
 public macro ManagedActorExtension() = #externalMacro(
 module: "SwallowMacros",
 type: "ManagedActorMacro"
 )
 */

@attached(peer, names: prefixed(_ManagedActorMethod_))
public macro ManagedActorMethod() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro"
)

public protocol _StaticManagedActorMethodConfiguration {
    associatedtype Async: _StaticBoolean
    associatedtype Throws: _StaticBoolean
}

open class _AnyManagedActorMethod {
    public var _caller: Any?
    
    public init() {
        
    }
}

@dynamicMemberLookup
public protocol _ManagedActorProtocol: AnyObject {
    associatedtype _ManagedActorMethodListType: Initiable
    
    static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> { get }
    
    var _managedActorScratchpad: _ManagedActorScratchpad<Self> { get }
    
    dynamic subscript<T: _ManagedActorMethodProtocol>(
        dynamicMember keyPath: KeyPath<_ManagedActorMethodListType, T>
    ) -> T { get }
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: @escaping () async -> R
    ) async -> R
    
    @inline(never)
    dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R
}

public protocol _ManagedActorMethodProtocol: _AnyManagedActorMethod, Initiable {
    associatedtype OwnerType: _ManagedActorProtocol
    
    typealias _OptionalOwnerType = Optional<OwnerType>
}

extension _ManagedActorMethodProtocol {
    public var caller: OwnerType {
        get {
            self._caller! as! OwnerType
        } set {
            self._caller = newValue
        }
    }
}

@dynamicMemberLookup
public struct _ManagedActorExplicitSelf<ActorType: _ManagedActorProtocol>: @unchecked Sendable {
    public let actor: ActorType
    
    public init(actor: ActorType) {
        self.actor = actor
    }
    
    public dynamic subscript<T: _ManagedActorMethodProtocol>(
        dynamicMember keyPath: KeyPath<ActorType._ManagedActorMethodListType, T>
    ) -> T {
        self.actor[dynamicMember: keyPath]
    }
}

extension _ManagedActorProtocol {
    public var __managed_self: _ManagedActorExplicitSelf<Self> {
        _ManagedActorExplicitSelf(actor: self)
    }
}

extension _ManagedActorProtocol {
    public dynamic subscript<T: _ManagedActorMethodProtocol>(
        dynamicMember keyPath: KeyPath<_ManagedActorMethodListType, T>
    ) -> T {
        let result = _ManagedActorMethodListType()[keyPath: keyPath]
        
        result._caller = self
        
        return result
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: @escaping () throws -> R
    ) rethrows -> R {
        try _managedActorScratchpad._performInnerBodyOfMethod(method) {
            try operation()
        }
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: @escaping () async -> R
    ) async -> R {
        await _managedActorScratchpad._performInnerBodyOfMethod(method) {
            await operation()
        }
    }
    
    @inline(never)
    public dynamic func _performInnerBodyOfMethod<M: _ManagedActorMethodProtocol, R>(
        _ method: KeyPath<_ManagedActorMethodListType, M>,
        operation: @escaping () async throws -> R
    ) async throws -> R {
        try await _managedActorScratchpad._performInnerBodyOfMethod(method) {
            try await operation()
        }
    }
}

