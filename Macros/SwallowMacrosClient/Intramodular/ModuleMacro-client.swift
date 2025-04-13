//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@freestanding(declaration, names: named(_module))
public macro module(_: () -> Void) = #externalMacro(
    module: "SwallowMacros",
    type: "ModuleMacro"
)
