//
// Copyright (c) Vatsal Manot
//

import Swift

@freestanding(expression)
public macro log<T: Error>(_ error: T) -> Never = #externalMacro(
    module: "SwallowMacros",
    type: "LogMacro"
)
