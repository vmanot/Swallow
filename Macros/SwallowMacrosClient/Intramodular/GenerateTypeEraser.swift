//
// Copyright (c) Vatsal Manot
//

#if canImport(Distributed)
import Distributed
#endif
import Swift

@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any), prefixed(__dollar__))
@attached(member, names: arbitrary, prefixed(eraseToAny), prefixed(__distributed_eraseToAny))
public macro GenerateTypeEraser() = #externalMacro(
    module: "SwallowMacros",
    type: "GenerateTypeEraserMacro"
)

@attached(extension, names: arbitrary)
@attached(peer, names: arbitrary, prefixed(Any), prefixed(`$`))
@attached(member, names: prefixed(eraseToAny))
public macro GenerateDistributedTypeEraser() = #externalMacro(
    module: "SwallowMacros",
    type: "GenerateDistributedTypeEraser"
)

#if canImport(Distributed)
@_alwaysEmitConformanceMetadata
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public protocol _DistributedTypeErasable {
    /// The protocol type being erased.
    static var _erasedProtocolType: Any.Type { get }
    
    static func __distributedTypeEraserSwiftType<ActorSystem: DistributedActorSystem>(
        forActorSystem actorSystem: ActorSystem
    ) throws -> Any.Type
}

@_alwaysEmitConformanceMetadata
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public protocol _DistributedTypeEraser<ActorSystem>: DistributedActor {
    associatedtype BaseType
    
    init(_ base: BaseType?, actorSystem: ActorSystem) async throws
}

@_alwaysEmitConformanceMetadata
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public protocol _ConcreteDistributedTypeEraser<ActorSystem>: _DistributedTypeEraser {
    
}
#endif
