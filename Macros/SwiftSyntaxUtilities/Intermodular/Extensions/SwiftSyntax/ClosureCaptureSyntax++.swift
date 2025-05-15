//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

#if compiler(>=6.1)
extension ClosureCaptureSyntax {
    public init(
        expression: some ExprSyntaxProtocol
    ) {
        let effectiveName: TokenSyntax = {
            if let declRef = expression.as(DeclReferenceExprSyntax.self) {
                return declRef.baseName
            }
            
            assertionFailure()
            
            return .identifier("_capture")
        }()
        
        self.init(
            leadingTrivia: nil,
            specifier: nil,
            name: effectiveName,
            initializer: nil,
            trailingComma: nil,
            trailingTrivia: nil
        )
    }
}
#endif
