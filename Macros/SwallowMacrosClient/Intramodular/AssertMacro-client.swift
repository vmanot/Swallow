//
// Copyright (c) Vatsal Manot
//

import Swift

@freestanding(expression)
public macro assert(_ condition: Bool) -> Void = #externalMacro(
    module: "SwallowMacros",
    type: "AssertMacro"
)
