//
// Copyright (c) Vatsal Manot
//

@_exported import _SwallowMacrosRuntime
@_exported import Swallow

@attached(member, names: arbitrary)
public macro AddCaseBoolean() = #externalMacro(
    module: "SwallowMacros",
    type: "AddCaseBooleanMacro"
)

@attached(peer, names: arbitrary)
public macro duplicate(as: String) = #externalMacro(
    module: "SwallowMacros",
    type: "GenerateDuplicateMacro"
)

@attached(member, names: named(hash), named(==))
@attached(extension, conformances: Hashable)
public macro Hashable() = #externalMacro(
    module: "SwallowMacros",
    type: "HashableMacro"
)

@freestanding(declaration)
public macro once<T>(_ fn: () async throws -> T) = #externalMacro(
    module: "SwallowMacros",
    type: "OnceMacro"
)

@attached(member, names: arbitrary)
@attached(extension, conformances: OptionSet)
public macro OptionSet<RawType>() = #externalMacro(
    module: "SwallowMacros",
    type: "OptionSetMacro"
)

@attached(peer, names: suffixed(_RuntimeConversion))
public macro RuntimeConversion() = #externalMacro(
    module: "SwallowMacros",
    type: "RuntimeConversionMacro"
)

@attached(peer, names: suffixed(_RuntimeTypeDiscovery))
public macro RuntimeDiscoverable() = #externalMacro(
    module: "SwallowMacros",
    type: "RuntimeDiscoverableMacro"
)

@attached(member, names: named(init), named(shared))
public macro Singleton() = #externalMacro(
    module: "SwallowMacros",
    type: "SingletonMacro"
)

@attached(member, names: arbitrary)
// @attached(extension, names: arbitrary)
public macro _StaticProtocolMember<T>(
    named: String,
    type: T.Type
) = #externalMacro(
    module: "SwallowMacros",
    type: "_StaticProtocolMember"
)
