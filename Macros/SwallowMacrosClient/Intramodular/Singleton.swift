//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@attached(member, names: named(init), named(shared))
public macro Singleton() = #externalMacro(
    module: "SwallowMacros",
    type: "SingletonMacro"
)
