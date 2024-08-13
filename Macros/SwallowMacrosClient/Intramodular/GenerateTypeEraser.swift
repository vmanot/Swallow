//
// Copyright (c) Vatsal Manot
//

#if canImport(Distributed)
import Distributed
#endif
import Swift

@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any), prefixed(`$`))
@attached(member, names: prefixed(eraseToAny), prefixed(__distributed_eraseToAny))
public macro GenerateTypeEraser() = #externalMacro(module: "SwallowMacros", type: "GenerateTypeEraserMacro")

@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any), prefixed(`$`))
@attached(member, names: prefixed(eraseToAny))
public macro _GenerateTypeEraser2() = #externalMacro(module: "SwallowMacros", type: "GenerateTypeEraserMacro2")

#if canImport(Distributed)
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public protocol _DistributedTypeErasable {
    static func __distributedTypeEraserSwiftType<ActorSystem: DistributedActorSystem>(
        forActorSystem actorSystem: ActorSystem
    ) throws -> Any.Type
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public protocol _DistributedTypeEraser {
    associatedtype BaseType
    associatedtype ActorSystem: DistributedActorSystem
    
    init(_ base: BaseType, actorSystem: ActorSystem) async throws
}
#endif
