//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct ErrorCodeCatalogMacro: MemberMacro, ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
      throw ErrorXMacroDiagnostic.error(
        .invalidCatalog, "@ErrorCodeCatalog can only be attached to an enum.")
    }

    let access = enumDeclaration.modifiers.explicitDeclarationAccessLevelOrInternalFallback
      .protocolWitnessAccessModifierSource
    let catalog = try _validatedCatalog(from: node, enumDeclaration: enumDeclaration)
    let domainExpression = catalog.domain.swiftStringLiteralSource

    return [
      """
      \(raw: access)static var domain: String {
          \(raw: domainExpression)
      }
      """,
      DeclSyntax(
        stringLiteral: _identifierDeclaration(
          access: access,
          cases: catalog.cases,
          usesRawValue: enumDeclaration._catalogKind == .rawValueEnum
        )
      ),
      DeclSyntax(
        stringLiteral: _allCasesDeclaration(
          access: access,
          expressions: catalog.cases.map { "Self.\($0.sourceName)" }
        )
      ),
    ]
  }

  private static func _identifierDeclaration(
    access: String,
    cases: [CatalogCase],
    usesRawValue: Bool
  ) -> String {
    if usesRawValue {
      return """
        \(access)var identifier: String {
            rawValue
        }
        """
    }

    var result = """
      \(access)var identifier: String {
          switch self {
      """

    for item in cases {
      result += """

                case .\(item.sourceName):
                    return \(item.stableIdentifier.swiftStringLiteralSource)
        """
    }

    result += """

          }
      }
      """

    return result
  }

  private static func _allCasesDeclaration(
    access: String,
    expressions: [String]
  ) -> String {
    var result = """
      \(access)static var allCases: [Self] {
          [
      """

    for expression in expressions {
      result += "\n            \(expression),"
    }

    result += """

          ]
      }
      """

    return result
  }

  private static func _validatedCatalog(
    from node: AttributeSyntax,
    enumDeclaration: EnumDeclSyntax
  ) throws -> CatalogDefinition {
    try node.validateMacroArgumentShape(
      allowedLabels: ["domain"],
      unlabeledArgumentCount: 0...0
    )

    guard let domain = try node.optionalStringLiteralValue(labeled: "domain") else {
      throw ErrorXMacroDiagnostic.error(
        .invalidCatalog,
        "@ErrorCodeCatalog requires a string-literal 'domain:'."
      )
    }

    guard !domain.isEmpty else {
      throw ErrorXMacroDiagnostic.error(
        .invalidCatalog, "@ErrorCodeCatalog domain cannot be empty.")
    }

    let cases = try enumDeclaration._catalogCases()

    guard !cases.isEmpty else {
      throw ErrorXMacroDiagnostic.error(
        .invalidCatalog, "@ErrorCodeCatalog requires at least one enum case.")
    }

    return .init(domain: domain, cases: cases)
  }

  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
      return []
    }

    do {
      _ = try _validatedCatalog(from: node, enumDeclaration: enumDeclaration)
    } catch {
      // The member role owns diagnostics. Avoid emitting a conformance
      // extension when member synthesis has already failed.
      return []
    }

    var conformances: [String] = []

    if !enumDeclaration.inheritsType(withTerminalName: "ErrorCode") {
      conformances.append("ErrorCode")
    }

    if !enumDeclaration.inheritsType(withTerminalName: "CaseIterable") {
      conformances.append("CaseIterable")
    }

    guard !conformances.isEmpty else {
      return []
    }

    return [
      try ExtensionDeclSyntax(
        """
        extension \(type.trimmed): \(raw: conformances.joined(separator: ", ")) {

        }
        """
      )
    ]
  }
}

private struct CatalogDefinition {
  let domain: String
  let cases: [CatalogCase]
}

private enum CatalogKind: Equatable {
  case empty
  case rawValueEnum
  case caseNamespace
}

private struct CatalogCase {
  let sourceName: String
  let stableIdentifier: String
}

extension EnumDeclSyntax {
  fileprivate var _catalogKind: CatalogKind {
    let hasCases = memberBlock.members.contains { member in
      member.decl.is(EnumCaseDeclSyntax.self)
    }

    guard hasCases else {
      return .empty
    }

    if _usesStringRawValues {
      return .rawValueEnum
    } else {
      return .caseNamespace
    }
  }

  fileprivate func _catalogCases() throws -> [CatalogCase] {
    let isRawValueEnum = _usesStringRawValues

    return try memberBlock.members.flatMap { member -> [CatalogCase] in
      guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self) else {
        return []
      }

      return try enumCase.elements.map { element in
        guard element.parameterClause == nil else {
          throw ErrorXMacroDiagnostic.error(
            .invalidCatalog,
            "@ErrorCodeCatalog cases cannot declare associated values."
          )
        }

        if isRawValueEnum {
          guard let rawValue = element.rawValue else {
            throw ErrorXMacroDiagnostic.error(
              .invalidCatalog,
              "Raw-value @ErrorCodeCatalog enum cases must use explicit string raw values.")
          }

          if rawValue.value.representedStringLiteralValue?.isEmpty == true {
            throw ErrorXMacroDiagnostic.error(
              .invalidCatalog, "@ErrorCodeCatalog stable identifiers cannot be empty.")
          }
        } else {
          guard element.rawValue == nil else {
            throw ErrorXMacroDiagnostic.error(
              .invalidCatalog, "Case-only @ErrorCodeCatalog enums cannot declare raw values.")
          }
        }

        guard let stableIdentifier = element.name.identifierValue else {
          throw ErrorXMacroDiagnostic.error(
            .invalidCatalog,
            "@ErrorCodeCatalog cases must have identifier names."
          )
        }

        return CatalogCase(
          sourceName: element.name.trimmedDescription,
          stableIdentifier: stableIdentifier
        )
      }
    }
  }

  fileprivate var _usesStringRawValues: Bool {
    inheritsAnyDirectType(named: [["String"], ["Swift", "String"]])
  }
}
