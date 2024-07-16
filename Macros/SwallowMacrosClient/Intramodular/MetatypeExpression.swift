//
// Copyright (c) Vatsal Manot
//

import Swallow

@freestanding(expression)
public macro metatype<_Protocol, ExistentialType>(_: _Protocol.Type) -> _StaticSwift._ProtocolAndExistentialTypePair<_Protocol.Type, ExistentialType> = #externalMacro(
    module: "SwallowMacros",
    type: "MetatypeExpressionMacro"
)


/*@freestanding(declaration, names: named(type))
public macro metatypeDeclaration<_Protocol>(_: _Protocol.Type) = #externalMacro(
    module: "SwallowMacros",
    type: "MetatypeExpressionMacro"
)*/
