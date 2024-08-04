//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@attached(peer)
public macro RuntimeConversion() = #externalMacro(
    module: "SwallowMacros",
    type: "RuntimeConversionMacro"
)
