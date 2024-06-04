//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@attached(peer, names: arbitrary)
@attached(accessor)
public macro AssociatedObject(
    _ policy: Policy
) = #externalMacro(
    module: "SwallowMacros",
    type: "AssociatedObjectMacro"
)

@attached(peer, names: arbitrary)
@attached(accessor)
public macro AssociatedObject(
    _ policy: Policy,
    key: Any
) = #externalMacro(
    module: "SwallowMacros",
    type: "AssociatedObjectMacro"
)

@attached(accessor)
public macro _AssociatedObject(
    _ policy: Policy
) = #externalMacro(
    module: "SwallowMacros",
    type: "AssociatedObjectMacro"
)

