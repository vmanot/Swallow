//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(body)
public macro _DebugLogMethod() = #externalMacro(
    module: "SwallowMacros",
    type: "DebugLogMethodMacro"
)

