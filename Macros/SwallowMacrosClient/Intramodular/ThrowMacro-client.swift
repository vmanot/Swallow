//
// Copyright (c) Vatsal Manot
//

import Swallow

@freestanding(expression)
public macro `throw`() -> Never = #externalMacro(
    module: "SwallowMacros",
    type: "ThrowMacro"
)

@freestanding(expression)
public macro `throw`<T: Error>(_ error: T) -> Never = #externalMacro(
    module: "SwallowMacros",
    type: "ThrowMacro"
)

@freestanding(expression)
public macro assertionFailure() -> Never = #externalMacro(
    module: "SwallowMacros",
    type: "AssertionFailureMacro"
)
