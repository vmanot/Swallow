//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(member, names: arbitrary)
@attached(extension, conformances: OptionSet)
public macro OptionSet<RawType>() = #externalMacro(
    module: "SwallowMacros",
    type: "OptionSetMacro"
)
