//
// Copyright (c) Vatsal Manot
//

import Swallow

@freestanding(declaration)
public macro _InternalTestMacro() = #externalMacro(
    module: "SwallowMacros",
    type: "_InternalTestMacro"
)
