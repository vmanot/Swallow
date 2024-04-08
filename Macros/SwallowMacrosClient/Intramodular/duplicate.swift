//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(peer, names: arbitrary)
public macro duplicate(as: String) = #externalMacro(
    module: "SwallowMacros",
    type: "GenerateDuplicateMacro"
)
