//
// Copyright (c) Vatsal Manot
//

import Swallow

@freestanding(declaration)
public macro scope<Scope: Swallow.module.DeclarationScopeType, Void>(
    _ scope: Scope,
    _: () -> Void
) = #externalMacro(
    module: "SwallowMacros",
    type: "ScopeDeclarationMacro"
)
