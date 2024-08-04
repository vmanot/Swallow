//
// Copyright (c) Vatsal Manot
//

import Swift

@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any), prefixed(`$`))
@attached(member, names: prefixed(eraseToAny))
public macro GenerateTypeEraser() = #externalMacro(module: "SwallowMacros", type: "GenerateTypeEraserMacro")
