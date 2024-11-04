//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(body)
public macro _DebugLogMethod() = #externalMacro(
    module: "SwallowMacros",
    type: "DebugLogMethodMacro"
)

@attached(memberAttribute)
public macro DebugLog() = #externalMacro(
    module: "SwallowMacros",
    type: "DebugLogMacro"
)
