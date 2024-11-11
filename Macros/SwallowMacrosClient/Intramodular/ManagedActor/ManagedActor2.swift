//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(memberAttribute)
public macro ManagedActor2(_ options: _ManagedActorInitializationOptionName...) = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMacro2"
)

@attached(body)
public macro _ManagedActorMethod2() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro2"
)

@attached(body)
public macro ManagedActorMethod2() = #externalMacro(
    module: "SwallowMacros",
    type: "ManagedActorMethodMacro2"
)
