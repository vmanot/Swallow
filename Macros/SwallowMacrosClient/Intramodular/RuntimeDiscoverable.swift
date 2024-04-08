//
// Copyright (c) Vatsal Manot
//

@_exported import _SwallowMacrosRuntime
@_exported import Swallow

@attached(peer, names: suffixed(_RuntimeTypeDiscovery))
public macro RuntimeDiscoverable() = #externalMacro(
    module: "SwallowMacros",
    type: "RuntimeDiscoverableMacro"
)
