//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension FunctionDeclSyntax {
    public var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }
    
    public var isThrowing: Bool {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil
    }

    public var throwsKeyword: TokenSyntax? {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier
    }

    public var parameterList: FunctionParameterListSyntax {
        signature.parameterClause.parameters
    }
    
    public var explicitReturnType: TypeSyntax? {
        signature.returnClause?.type
    }
}
