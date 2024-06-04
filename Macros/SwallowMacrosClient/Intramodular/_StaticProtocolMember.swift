//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow
@_exported import Swallow

@attached(member, names: arbitrary)
// @attached(extension, names: arbitrary)
public macro _StaticProtocolMember<T>(
    named: String,
    type: T.Type
) = #externalMacro(
    module: "SwallowMacros",
    type: "_StaticProtocolMember"
)
