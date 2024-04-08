//
// Copyright (c) Vatsal Manot
//

import Swift

@freestanding(declaration)
public macro once<T>(_ fn: () async throws -> T) = #externalMacro(
    module: "SwallowMacros",
    type: "OnceMacro"
)
