//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@freestanding(declaration, names: arbitrary)
public macro codesection(_: () -> Void) = #externalMacro(
    module: "SwallowMacros",
    type: "_CodesectionMacro"
)
