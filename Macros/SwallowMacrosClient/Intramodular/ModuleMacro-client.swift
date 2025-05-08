//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@freestanding(
    declaration,
    names: named(_module), named(_module_RuntimeTypeDiscovery)
)
public macro module(
    uniqueIdentifier: StaticString? = nil,
    _ body: () -> Void
) = #externalMacro(
    module: "SwallowMacros",
    type: "ModuleMacro"
)
