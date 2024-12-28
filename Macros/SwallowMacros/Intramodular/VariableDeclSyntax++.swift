//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension VariableDeclSyntax {
    public var names: [TokenSyntax] {
        bindings.map {
            $0.pattern.as(IdentifierPatternSyntax.self)?.identifier ?? "_"
        }
    }
    
    public var explicitlyDeclaredTypes: [TypeSyntax] {
        bindings.map {
            $0.typeAnnotation?.type ?? "_"
        }
    }
}
