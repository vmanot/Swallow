//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(member, names: named(hash), named(==))
@attached(extension, conformances: Hashable)
public macro Hashable() = #externalMacro(
    module: "SwallowMacros",
    type: "HashableMacro"
)
