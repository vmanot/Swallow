//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxUtilities

/// Compile-only coverage for source spellings retained for existing macro clients.
@available(*, deprecated, message: "Exercises SwiftSyntaxUtilities source compatibility.")
private func _compileDeprecatedSwiftSyntaxUtilitiesSurface(
    declaration: StructDeclSyntax,
    function: FunctionDeclSyntax,
    variable: VariableDeclSyntax,
    expression: ExprSyntax
) throws {
    let _: any AccessLevelSyntax = declaration
    let _: any DeclSyntaxWithMemberBlock = declaration
    let _: any WithMemberBlockSyntax = declaration
    let _: any WithNameSyntax = declaration
    let _: any _NamedDeclSyntax = declaration
    let _: AnyDiagnosticMessage = AnyDiagnosticMessage(message: "Compatibility diagnostic")
    let _: [MacroProtoype.Type] = [RuntimeDiscoverableMacroPrototype.self]

    _ = declaration.accessLevel
    _ = declaration.declAccessLevel
    _ = declaration.concreteTypeName
    _ = function.isAsync
    _ = function.isThrowing
    _ = function.parameterList
    _ = variable.hasSingleBinding
    _ = variable.variableName
    _ = expression.isNil
}
