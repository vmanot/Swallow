//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

extension FunctionDeclSyntax {
    
}

struct GenerateDuplicateMacro: PeerMacro {
    private struct MacroArguments: Codable {
        enum CodingKeys: String, CodingKey {
            case name = "as"
        }
        
        let name: String
    }
    
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard var funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AnyDiagnosticMessage("@duplicate only works on functions")
        }
        
        funcDecl.attributes.removeAll(where: {
            $0.as(AttributeSyntax.self)?.attributeName.description == "duplicate"
        })
        
        let macroArguments = try node.labeledArguments!.decode(MacroArguments.self)
        let newFunctionName = macroArguments.name
        
        funcDecl = try funcDecl.makeDuplicate(named: newFunctionName)
        
        return [DeclSyntax(funcDecl)]
    }
}

extension TokenSyntax {
    /// The text of this instance with all backticks removed.
    ///
    /// - Bug: This property works around the presence of backticks in `text.`
    ///   ([swift-syntax-#1936](https://github.com/apple/swift-syntax/issues/1936))
    var textWithoutBackticks: String {
        text.filter { $0 != "`" }
    }
}

extension TypeSyntaxProtocol {
    /// Whether or not this type is an optional type (`T?`, `Optional<T>`, etc.)
    var isOptional: Bool {
        if `is`(OptionalTypeSyntax.self) {
            return true
        } else if `is`(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return true
        }
        return isNamed("Optional", inModuleNamed: "Swift")
    }
    
    /// Whether or not this type is equivalent to `Void`.
    var isVoid: Bool {
        if let tuple = `as`(TupleTypeSyntax.self) {
            return tuple.elements.isEmpty
        }
        return isNamed("Void", inModuleNamed: "Swift")
    }
    
    /// Whether or not this type is `some T` or a type derived from such a type.
    var isSome: Bool {
        tokens(viewMode: .fixedUp).lazy
            .map(\.tokenKind)
            .contains(.keyword(.some))
    }
    
    /// Check whether or not this type is named with the specified name and
    /// module.
    ///
    /// The type name is checked both without and with the specified module name
    /// as a prefix to allow for either syntax. When comparing the type name,
    /// generic type parameters are ignored.
    ///
    /// - Parameters:
    ///   - name: The `"."`-separated type name to compare against.
    ///   - moduleName: The module the specified type is declared in.
    ///
    /// - Returns: Whether or not this type has the given name.
    func isNamed(_ name: String, inModuleNamed moduleName: String) -> Bool {
        // Form a string of the fixed-up tokens representing the type name,
        // omitting any generic type parameters.
        let nameWithoutGenericParameters = tokens(viewMode: .fixedUp)
            .prefix { $0.tokenKind != .leftAngle }
            .filter { $0.tokenKind != .period }
            .map(\.textWithoutBackticks)
            .joined(separator: ".")
        
        return nameWithoutGenericParameters == name || nameWithoutGenericParameters == "\(moduleName).\(name)"
    }
}

extension FunctionDeclSyntax {
    public var _nameHasTrailingDollarSymbol: Bool {
        name.trimmedDescription.hasSuffix("$")
    }

    public var _hasTrailingEmptyVoidFlagParameter: Bool {
        guard let last: FunctionParameterListSyntax.Element = signature.parameterClause.parameters.last else {
            return false
        }
        
        if last.firstName.text == "_" && last.type.isVoid && last.secondName == nil {
            return true
        }
        
        return false
    }
    
    public func _makeRawCallArgumentListTuple() -> ExprSyntax {
        let newParameterList: FunctionParameterListSyntax = signature.parameterClause.parameters
        
        let callArguments: [String] = newParameterList.map { param in
            let argName = param.secondName ?? param.firstName
            
            let paramName = param.firstName
            
            if paramName.text != "_" {
                return "\(paramName.text): \(argName.text)"
            }
            
            return "\(argName.text)"
        }
        
        return "(\(raw: callArguments.joined(separator: ", ")))"
    }
    
    public var makeCallExpressionEffectSpecifiersPrefix: ExprSyntax {
        var result = ExprSyntax("")
        
        if signature.effectSpecifiers?.asyncSpecifier != nil {
            result.prepend("await", separator: " ")
        }
        
        if signature.effectSpecifiers?.throwsSpecifier != nil {
            result.prepend("try", separator: " ")
        }
        
        return result
    }
    
    public func makeDuplicate(
        named name: String?,
        caller: ExprSyntax? = nil
    ) throws -> FunctionDeclSyntax {
        var result = self
        
        var newBody: ExprSyntax =
        """
        \(raw: result.name)\(_makeRawCallArgumentListTuple())
        """
        
        if var caller {
            if !caller.trimmedDescription.hasSuffix(".") {
                caller = "\(caller)."
            }
            
            newBody.prepend(caller, separator: "")
        }
        
        if result.signature.effectSpecifiers?.asyncSpecifier != nil {
            newBody.prepend("await", separator: " ")
        }
        
        if result.signature.effectSpecifiers?.throwsSpecifier != nil {
            newBody.prepend("try", separator: " ")
        }
        
        result.name = .init(stringLiteral: name ?? result.name.trimmedDescription)
        result.body = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space),
            statements: CodeBlockItemListSyntax(
                [CodeBlockItemSyntax(item: .expr(newBody))]
            ),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        return result
    }
}

extension FunctionDeclSyntax {
    public func mappingBody(
        _ transform: (CodeBlockItemListSyntax) -> CodeBlockItemListSyntax
    ) throws -> Self {
        var result = self
        
        var body = try result.body.unwrap()
        
        body.statements = transform(try result.body.unwrap().statements)
        
        result.body = body
        
        return result
    }
}
