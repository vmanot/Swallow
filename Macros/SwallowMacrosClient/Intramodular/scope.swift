//
// Copyright (c) Vatsal Manot
//

import Swallow

@freestanding(declaration)
public macro scope<Scope: _StaticSwift.DeclarationScopeType, Void>(
    _ scope: Scope,
    _: () -> Void
) = #externalMacro(
    module: "SwallowMacros",
    type: "DeclarationScopeMacro"
)
