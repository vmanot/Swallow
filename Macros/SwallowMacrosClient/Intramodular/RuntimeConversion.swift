//
// Copyright (c) Vatsal Manot
//

@_exported import _SwallowMacrosRuntime
@_exported import Swallow

@attached(peer, names: suffixed(_RuntimeConversion))
public macro RuntimeConversion() = #externalMacro(
    module: "SwallowMacros",
    type: "RuntimeConversionMacro"
)
