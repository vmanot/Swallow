//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

/// Implements the `@ErrorModel` attached macro.
public struct ErrorModelMacro: MemberMacro, ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
      throw ErrorXMacroDiagnostic.error(
        .invalidDeclaration, "@ErrorModel can only be attached to an enum.")
    }

    let access = enumDeclaration.modifiers.explicitDeclarationAccessLevelOrInternalFallback
      .protocolWitnessAccessModifierSource
    let model = try _validatedModel(from: node, enumDeclaration: enumDeclaration, in: context)
    let declarations: [DeclSyntax] = [
      DeclSyntax(stringLiteral: _codeDeclaration(access: access, definition: model.codeDefinition)),
      DeclSyntax(
        stringLiteral: _errorDescriptorDeclaration(
          access: access,
          cases: model.cases,
          includesDefault: !model.isExhaustive
        )
      ),
    ]

    return declarations
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
      _ = try _validatedModel(from: node, enumDeclaration: enumDeclaration, in: context)
    } catch {
      // The member role owns diagnostics. Avoid emitting a conformance
      // extension when member synthesis has already failed.
      return []
    }

    var conformances: [String] = []

    // Xcode 26.4.1 / Swift 6.3.1, Swift 6 mode: an attached extension
    // cannot reliably satisfy its advertised Error conformance through a
    // source-written protocol such as CustomNSError that inherits Error.
    if !declaration.inheritsAnyDirectType(named: [["Error"], ["Swift", "Error"]]) {
      conformances.append("Swift.Error")
    }

    if !declaration.inheritsType(withTerminalName: "_ModeledError") {
      conformances.append("_ModeledError")
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

  private static func _validatedModel(
    from node: AttributeSyntax,
    enumDeclaration: EnumDeclSyntax,
    in context: some MacroExpansionContext
  ) throws -> ModelDefinition {
    let options = try node._errorModelOptions()
    let modeledCases = try enumDeclaration._errorModelCases(
      allowsUnmodeledCases: options.allowsUnmodeledCases
    )

    return try .init(
      cases: modeledCases.cases,
      isExhaustive: modeledCases.isExhaustive,
      codeDefinition: CodeDefinition(
        cases: modeledCases.cases,
        domain: options.domain,
        derivedDomain: _derivedDomain(of: enumDeclaration, in: context)
      )
    )
  }

  /// The domain used when a model authors neither `domain:` nor `catalog:`.
  ///
  /// This qualifies the enum's declared name with its module and file base
  /// name, so several same-named nested error enums in one module — the common
  /// `private enum Error` shape — still occupy distinct domains. Pass `domain:`
  /// explicitly when the domain has to survive renaming the file.
  private static func _derivedDomain(
    of enumDeclaration: EnumDeclSyntax,
    in context: some MacroExpansionContext
  ) -> String {
    let typeName =
      enumDeclaration.name.identifierValue
      ?? enumDeclaration.name.trimmedDescription

    guard
      let fileID = context.location(of: enumDeclaration)?.file.representedStringLiteralValue
    else {
      return typeName
    }

    let pathComponents = fileID.split(separator: "/")

    guard let module = pathComponents.first, pathComponents.count > 1 else {
      return typeName
    }

    var result = [String(module)]

    if let fileBaseName = pathComponents[pathComponents.count - 1].split(separator: ".").first {
      result.append(String(fileBaseName))
    }

    result.append(typeName)

    return result.joined(separator: ".")
  }

  private static func _codeDeclaration(
    access: String,
    definition: CodeDefinition
  ) -> String {
    switch definition {
    case .catalog(let typeExpression):
      return "\(access)typealias Code = \(typeExpression)"
    case .synthesized(let domain, let cases):
      return _codeEnumDeclaration(access: access, domain: domain, cases: cases)
    }
  }

  private static func _codeEnumDeclaration(
    access: String,
    domain: String,
    cases: [ModeledCase]
  ) -> String {
    var result = """
      \(access)enum Code: ErrorCode, CaseIterable {
          \(access)static var domain: String {
              \(domain)
          }

      """

    for item in cases {
      result += "    case \(item.codeCaseName)\n"
    }

    result += """

          \(access)var identifier: String {
              switch self {
      """

    for item in cases {
      result +=
        "\n            case .\(item.codeCaseName):\n                return \(item.code.identifierExpression)"
    }

    result += """

              }
          }

          \(access)static var allCases: [Self] {
              [
      """

    for item in cases {
      result += "\n            Self.\(item.codeCaseName),"
    }

    result += """

              ]
          }
      }
      """

    return result
  }

  private static func _errorDescriptorDeclaration(
    access: String,
    cases: [ModeledCase],
    includesDefault: Bool
  ) -> String {
    var result = """
      \(access)static var _errorDescriptor: _ErrorDescriptor<Self> {
          _ErrorDescriptor { error in
              switch error {
      """

    for item in cases {
      result += "\n" + _errorCaseResolution(item)
    }

    if includesDefault {
      result += """

                default:
                    return nil
        """
    }

    result += """

              }
          }
      }
      """

    return result
  }

  private static func _errorCaseResolution(
    _ item: ModeledCase
  ) -> String {
    var arguments: [String] = [
      "code: AnyErrorCode(Code.\(item.codeCaseName))"
    ]
    var result = """
                  case \(item.boundPattern(binding: item.descriptorBindingNames)):
      """

    if !item.contexts.isEmpty || !item.contextSources.isEmpty {
      if item.contextSources.isEmpty {
        arguments.append(
          "context: [\(item.contexts.map(_contextEntryExpression).joined(separator: ", "))]")
      } else {
        result += """

                      var _errorX_context = ErrorContext([\(item.contexts.map(_contextEntryExpression).joined(separator: ", "))])
          """

        for source in item.contextSources {
          result += """

                    _errorX_context += \(source.boundName).errorContext
            """
        }

        arguments.append("context: _errorX_context")
      }
    }

    if let presentation = _presentationExpression(item.presentation) {
      arguments.append("presentation: \(presentation)")
    }

    if !item.recoveryOptions.isEmpty {
      arguments.append(
        "recoveryOptions: [\(item.recoveryOptions.map(_recoveryOptionExpression).joined(separator: ", "))]"
      )
    }

    if let cause = item.cause {
      arguments.append("underlyingError: \(cause.boundName)")
    }

    if !item.relations.isEmpty {
      var relationArrays = item.relations.map(\.arrayExpression)

      if let cause = item.cause {
        relationArrays.insert(
          "[ErrorRelation(.cause, to: \(cause.boundName))]",
          at: 0
        )
      }

      arguments.append(
        "errorTree: ErrorTree(error, relations: \(relationArrays.joined(separator: " + ")))"
      )
    }

    result += """

                          return _ResolvedErrorDescriptor(
                              \(arguments.joined(separator: ",\n                                "))
                          )
      """

    return result
  }

  private static func _contextEntryExpression(
    _ context: ContextAttribute
  ) -> String {
    var result = ".init(key: \(context.keyExpression), value: \(context.boundName)"

    if let privacyExpression = context.privacyExpression {
      result += ", privacy: \(privacyExpression)"
    }

    return result + ")"
  }

  private static func _presentationExpression(
    _ presentation: PresentationAttributes
  ) -> String? {
    let fields: [(String, ErrorPresentationTemplate?)] = [
      ("message", presentation.message),
      ("failureReason", presentation.failureReason),
      ("helpAnchor", presentation.helpAnchor),
    ]
    let arguments = fields.compactMap { name, template in
      template.map { "\(name): \($0.expressionSource)" }
    }

    guard !arguments.isEmpty else {
      return nil
    }

    return "ErrorPresentation(\(arguments.joined(separator: ", ")))"
  }

  private static func _recoveryOptionExpression(
    _ option: RecoveryOptionAttribute
  ) -> String {
    var result = "ErrorRecoveryOption(title: \(option.title.swiftStringLiteralSource)"

    if let explanation = option.explanation {
      result += ", explanation: \(explanation.swiftStringLiteralSource)"
    }

    return result + ")"
  }

}

private struct ModelDefinition {
  let cases: [ModeledCase]
  let isExhaustive: Bool
  let codeDefinition: CodeDefinition
}

private struct ModeledCases {
  let cases: [ModeledCase]
  let isExhaustive: Bool
}

private enum CodeDefinition {
  case synthesized(domain: String, cases: [ModeledCase])
  case catalog(typeExpression: String)

  init(
    cases: [ModeledCase],
    domain: DomainSpecification,
    derivedDomain: String
  ) throws {
    try Self.validateUniqueCodes(in: cases)

    let catalogCases = cases.compactMap { item -> CodeAttribute.CatalogCaseReference? in
      guard case .catalogCase(let reference) = item.code.source else {
        return nil
      }

      return reference
    }

    switch domain {
    case .inferred:
      if catalogCases.isEmpty {
        // No catalog to infer from, so derive a domain rather than requiring one.
        self = .synthesized(
          domain: derivedDomain.swiftStringLiteralSource,
          cases: cases
        )

        return
      }

      guard catalogCases.count == cases.count,
        let firstCatalog = catalogCases.first,
        catalogCases.allSatisfy({ $0.catalogNameComponents == firstCatalog.catalogNameComponents })
      else {
        throw ErrorXMacroDiagnostic.error(
          .missingDomain,
          "@ErrorModel requires a domain when its cases do not all use the same typed error-code catalog."
        )
      }

      self = .catalog(typeExpression: firstCatalog.catalogTypeExpression)
    case .literal(let domain):
      guard catalogCases.isEmpty else {
        throw ErrorXMacroDiagnostic.error(
          .invalidDomain,
          "An @ErrorModel 'domain:' cannot be combined with catalog-backed @ErrorCode values. Omit 'domain:' to infer the catalog, or pass it with 'catalog:'."
        )
      }

      self = .synthesized(
        domain: domain.swiftStringLiteralSource,
        cases: cases
      )
    case .catalog(let typeExpression, let nameComponents):
      if let mismatchedCatalog = catalogCases.first(where: {
        $0.catalogNameComponents != nameComponents
      }) {
        throw ErrorXMacroDiagnostic.error(
          .mismatchedCatalog,
          "@ErrorModel catalog '\(nameComponents.joined(separator: "."))' does not match @ErrorCode catalog '\(mismatchedCatalog.catalogNameComponents.joined(separator: "."))'."
        )
      }

      if catalogCases.count == cases.count {
        self = .catalog(typeExpression: typeExpression)
      } else {
        self = .synthesized(
          domain: "\(typeExpression).domain",
          cases: cases
        )
      }
    }
  }

  private static func validateUniqueCodes(
    in cases: [ModeledCase]
  ) throws {
    var catalogReferences: Set<String> = []
    var generatedCaseNames: Set<String> = []
    var literalStableIdentifiers: Set<String> = []

    for item in cases {
      switch item.code.source {
      case .catalogCase(let reference):
        let identity = (reference.catalogNameComponents + [reference.caseName]).joined(
          separator: ".")

        guard catalogReferences.insert(identity).inserted else {
          throw ErrorXMacroDiagnostic.error(
            .duplicateStableCode, "Duplicate error code reference '\(reference.expression)'.")
        }
      case .literal(let stableIdentifier):
        guard literalStableIdentifiers.insert(stableIdentifier).inserted else {
          throw ErrorXMacroDiagnostic.error(
            .duplicateStableCode, "Duplicate stable error code '\(stableIdentifier)'.")
        }
      }

      guard generatedCaseNames.insert(item.codeCaseName).inserted else {
        throw ErrorXMacroDiagnostic.error(
          .duplicateStableCode, "Duplicate generated error code case '\(item.codeCaseName)'.")
      }
    }
  }
}

private struct ModeledCase {
  let name: String
  let codeCaseName: String
  let code: CodeAttribute
  let associatedValues: [AssociatedValue]
  let contexts: [ContextAttribute]
  let contextSources: [ContextSource]
  let presentation: PresentationAttributes
  let recoveryOptions: [RecoveryOptionAttribute]
  let cause: CauseAttribute?
  let relations: [RelationAttribute]

  func boundPattern(
    binding boundNames: Set<String>
  ) -> String {
    guard !associatedValues.isEmpty else {
      return ".\(name)"
    }

    return ".\(name)" + "("
      + associatedValues.map { associatedValue in
        associatedValue.bindingPattern(isBound: boundNames.contains(associatedValue.bindingName))
      }.joined(separator: ", ") + ")"
  }

  var descriptorBindingNames: Set<String> {
    var result = Set(contexts.map(\.boundName) + contextSources.map(\.boundName))

    if let cause {
      result.insert(cause.boundName)
    }

    result.formUnion(relations.map(\.boundName))
    result.formUnion(presentation.referencedBindingNames)

    return result
  }
}

private enum DomainSpecification {
  case inferred
  case literal(String)
  case catalog(typeExpression: String, nameComponents: [String])
}

private struct ModelOptions {
  let domain: DomainSpecification
  let allowsUnmodeledCases: Bool
}

private struct AssociatedValue {
  let position: Int
  let label: String?
  let localName: String?
  let bindingName: String

  func bindingPattern(
    isBound: Bool
  ) -> String {
    isBound ? "let \(bindingName)" : "_"
  }

  func matches(_ name: String) -> Bool {
    label == name || localName == name
  }

  var diagnosticName: String {
    switch (label, localName) {
    case (let label?, let localName?) where label != localName:
      return "\(label) (local: \(localName))"
    case (let label?, _):
      return label
    case (_, let localName?):
      return localName
    case (nil, nil):
      return "<unlabeled #\(position + 1)>"
    }
  }
}

private struct CodeAttribute {
  struct CatalogCaseReference {
    let expression: String
    let catalogTypeExpression: String
    let catalogNameComponents: [String]
    let caseName: String
  }

  enum Source {
    case literal(String)
    case catalogCase(CatalogCaseReference)
  }

  let source: Source
  let presentation: PresentationAttributes

  var identifierExpression: String {
    switch source {
    case .literal(let value):
      return value.swiftStringLiteralSource
    case .catalogCase(let reference):
      return "\(reference.expression).identifier"
    }
  }

  var externalCatalogCaseName: String? {
    guard case .catalogCase(let reference) = source else {
      return nil
    }

    return reference.caseName
  }
}

private struct ContextAttribute {
  let keyExpression: String
  let privacyExpression: String?
  let boundName: String
}

private struct ContextSource {
  let boundName: String
}

private struct PresentationAttributes {
  let message: ErrorPresentationTemplate?
  let failureReason: ErrorPresentationTemplate?
  let helpAnchor: ErrorPresentationTemplate?

  /// The generated case bindings every authored template reads.
  var referencedBindingNames: Set<String> {
    [message, failureReason, helpAnchor]
      .compactMap { $0 }
      .reduce(into: Set<String>()) { result, template in
        result.formUnion(template.referencedBindingNames)
      }
  }
}

private struct RecoveryOptionAttribute {
  let title: String
  let explanation: String?
}

private struct CauseAttribute {
  let boundName: String
}

private struct RelationAttribute {
  enum Kind {
    case cause
    case translatedFrom
    case component
    case concurrent
    case suppressed
    case cleanup
    case fallback

    init?(
      expression: ExprSyntax
    ) {
      guard let member = expression.as(MemberAccessExprSyntax.self) else {
        return nil
      }

      switch member.declName.baseName.identifierValue {
      case "cause":
        self = .cause
      case "translatedFrom":
        self = .translatedFrom
      case "component":
        self = .component
      case "concurrent":
        self = .concurrent
      case "suppressed":
        self = .suppressed
      case "cleanup":
        self = .cleanup
      case "fallback":
        self = .fallback
      default:
        return nil
      }
    }

    var acceptsMultipleElements: Bool {
      switch self {
      case .cause, .translatedFrom:
        return false
      case .component, .concurrent, .suppressed, .cleanup, .fallback:
        return true
      }
    }
  }

  let kind: Kind
  let boundName: String
  let appliesToElements: Bool

  var isCause: Bool {
    if case .cause = kind {
      return true
    }

    return false
  }

  var isTranslation: Bool {
    if case .translatedFrom = kind {
      return true
    }

    return false
  }

  var arrayExpression: String {
    let kindExpression = ".\(kind.sourceName)"

    if appliesToElements {
      return "\(boundName).map { ErrorRelation(\(kindExpression), to: $0) }"
    }

    return "[ErrorRelation(\(kindExpression), to: \(boundName))]"
  }
}

extension RelationAttribute.Kind {
  fileprivate var sourceName: String {
    switch self {
    case .cause:
      return "cause"
    case .translatedFrom:
      return "translatedFrom"
    case .component:
      return "component"
    case .concurrent:
      return "concurrent"
    case .suppressed:
      return "suppressed"
    case .cleanup:
      return "cleanup"
    case .fallback:
      return "fallback"
    }
  }
}

extension EnumDeclSyntax {
  fileprivate func _errorModelCases(
    allowsUnmodeledCases: Bool
  ) throws -> ModeledCases {
    var modeledCases: [ModeledCase] = []
    var totalCaseCount = 0

    for member in memberBlock.members {
      guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self) else {
        continue
      }

      totalCaseCount += enumCase.elements.count

      guard enumCase.elements.count == 1 else {
        throw ErrorXMacroDiagnostic.error(
          .invalidDeclaration, "Error model cases must be declared one per line.")
      }

      let element = try enumCase.elements.first.unwrap()
      let name = element.name.trimmedDescription
      let associatedValues = element.parameterClause?._associatedValues() ?? []
      let code = try enumCase._errorCodeAttribute(
        caseName: name,
        associatedValues: associatedValues
      )

      guard let code else {
        guard allowsUnmodeledCases else {
          throw ErrorXMacroDiagnostic.error(
            .missingErrorCode, "Every modeled case requires exactly one @ErrorCode attribute.")
        }

        guard enumCase._errorXModelingAttributes().isEmpty else {
          throw ErrorXMacroDiagnostic.error(
            .missingErrorCode,
            "Unmodeled error cases cannot declare ErrorX context, presentation, recovery, cause, or relation attributes."
          )
        }

        continue
      }

      let contexts = try enumCase._errorContextAttributes(associatedValues: associatedValues)
      let contextSources = try enumCase._errorContextSourceAttributes(
        associatedValues: associatedValues)
      let recoveryOptions = try enumCase._errorRecoveryOptionAttributes()
      let cause = try enumCase._errorCauseAttribute(associatedValues: associatedValues)
      let relations = try enumCase._errorRelationAttributes(associatedValues: associatedValues)
      let causeRelations = relations.filter(\.isCause)
      let translationRelations = relations.filter(\.isTranslation)

      guard causeRelations.count <= 1 else {
        throw ErrorXMacroDiagnostic.error(
          .duplicateRelation,
          "A modeled error case can declare at most one @ErrorRelation(.cause)."
        )
      }

      guard translationRelations.count <= 1 else {
        throw ErrorXMacroDiagnostic.error(
          .duplicateRelation,
          "A modeled error case can declare at most one @ErrorRelation(.translatedFrom)."
        )
      }

      if cause != nil, !causeRelations.isEmpty {
        throw ErrorXMacroDiagnostic.error(
          .duplicateRelation,
          "A modeled error case cannot combine @ErrorCause with @ErrorRelation(.cause); both define the underlying error."
        )
      }

      if cause != nil || !causeRelations.isEmpty, !translationRelations.isEmpty {
        throw ErrorXMacroDiagnostic.error(
          .duplicateRelation,
          "A modeled error case cannot combine a cause with @ErrorRelation(.translatedFrom); both define its primary causal predecessor."
        )
      }

      if let cause, relations.contains(where: { $0.boundName == cause.boundName }) {
        throw ErrorXMacroDiagnostic.error(
          .duplicateRelation,
          "An associated value cannot be modeled as both @ErrorCause and a related error."
        )
      }

      modeledCases.append(
        ModeledCase(
          name: name,
          codeCaseName: code.externalCatalogCaseName ?? name,
          code: code,
          associatedValues: associatedValues,
          contexts: contexts,
          contextSources: contextSources,
          presentation: code.presentation,
          recoveryOptions: recoveryOptions,
          cause: cause,
          relations: relations
        )
      )
    }

    guard !modeledCases.isEmpty else {
      throw ErrorXMacroDiagnostic.error(
        .missingErrorCode, "@ErrorModel requires at least one modeled case.")
    }

    return .init(
      cases: modeledCases,
      isExhaustive: modeledCases.count == totalCaseCount
    )
  }
}

extension EnumCaseParameterClauseSyntax {
  fileprivate func _associatedValues() -> [AssociatedValue] {
    var result: [AssociatedValue] = []

    for (index, parameter) in parameters.enumerated() {
      let firstName = parameter.firstName?.identifierValue
      let secondName = parameter.secondName?.identifierValue
      let label = firstName == "_" ? nil : firstName
      let localName = secondName == "_" ? nil : (secondName ?? label)
      let bindingBaseName = localName ?? label ?? "value\(index)"

      result.append(
        AssociatedValue(
          position: index,
          label: label,
          localName: localName,
          bindingName: "_errorX_\(index)_\(bindingBaseName)"
        )
      )
    }

    return result
  }
}

extension EnumCaseDeclSyntax {
  fileprivate func _errorCodeAttribute(
    caseName: String,
    associatedValues: [AssociatedValue]
  ) throws -> CodeAttribute? {
    let errorCodeAttributes = attributes(withUnqualifiedName: "ErrorCode")

    guard errorCodeAttributes.count <= 1 else {
      throw ErrorXMacroDiagnostic.error(
        .duplicateErrorCode, "A modeled error case can only have one @ErrorCode attribute.")
    }

    guard let attribute = errorCodeAttributes.first else {
      return nil
    }

    try attribute.validateMacroArgumentShape(
      allowedLabels: ["message", "failureReason", "helpAnchor"],
      unlabeledArgumentCount: 0...1
    )

    let presentation = try attribute._errorCodePresentation(
      associatedValues: associatedValues
    )

    guard
      let expression = try attribute.ordinaryArgumentListOrEmpty().uniqueUnlabeledArgument()?
        .expression
    else {
      // An omitted identifier derives the code from the case name.
      return CodeAttribute(source: .literal(caseName), presentation: presentation)
    }

    if let literal = expression.representedStringLiteralValue {
      guard !literal.isEmpty else {
        throw ErrorXMacroDiagnostic.error(
          .invalidErrorCode, "@ErrorCode identifiers cannot be empty.")
      }

      return CodeAttribute(source: .literal(literal), presentation: presentation)
    }

    guard let member = expression.as(MemberAccessExprSyntax.self),
      member.declName.argumentNames == nil,
      let base = member.base,
      let catalogNameComponents = base.directDeclReferenceNameComponents
    else {
      throw ErrorXMacroDiagnostic.error(
        .invalidErrorCode,
        "@ErrorCode requires a string literal or a direct catalog case reference such as 'Codes.requestFailed'."
      )
    }

    return CodeAttribute(
      source: .catalogCase(
        .init(
          expression: expression.trimmedDescription,
          catalogTypeExpression: base.trimmedDescription,
          catalogNameComponents: catalogNameComponents,
          caseName: member.declName.baseName.trimmedDescription
        )
      ),
      presentation: presentation
    )
  }

  fileprivate func _errorContextAttributes(
    associatedValues: [AssociatedValue]
  ) throws -> [ContextAttribute] {
    let attributes = attributes(withUnqualifiedName: "ErrorContext").filter { attribute in
      !attribute._providesContextContents
    }
    var contextKeyIdentities: Set<String> = []

    return try attributes.map { attribute in
      try attribute.validateMacroArgumentShape(
        allowedLabels: ["from", "privacy"],
        unlabeledArgumentCount: 1...1
      )

      let key = try attribute.requiredUnlabeledArgument(
        diagnostic: "@ErrorContext requires one typed context key."
      )

      if key.representedStringLiteralValue?.isEmpty == true {
        throw ErrorXMacroDiagnostic.error(
          .invalidStableIdentifier, "@ErrorContext keys cannot be empty.")
      }

      let keyExpression = key.trimmedDescription
      let keyIdentity =
        key.representedStringLiteralValue.map { "literal:\($0)" }
        ?? key.directDeclReferenceNameComponents.map { "reference:\($0.joined(separator: "."))" }
        ?? "expression:\(keyExpression)"
      let associatedValue = try attribute.optionalStringLiteralValue(labeled: "from")
      let privacyExpression = try attribute.optionalArgument(labeled: "privacy")?.trimmedDescription

      guard contextKeyIdentities.insert(keyIdentity).inserted else {
        throw ErrorXMacroDiagnostic.error(
          .duplicateContext,
          "Duplicate @ErrorContext key '\(keyExpression)' on the same error case.")
      }

      let selectedValue = try associatedValues._resolveAssociatedValue(
        named: associatedValue,
        inferredName: key.terminalDeclReferenceName,
        allowingSoleValueInference: true,
        macroName: "ErrorContext",
        diagnosticID: .invalidContextAssociatedValue,
        missingValueDiagnostic:
          "@ErrorContext requires 'from:' when a case has zero or multiple associated values."
      )

      return ContextAttribute(
        keyExpression: keyExpression,
        privacyExpression: privacyExpression,
        boundName: selectedValue.bindingName
      )
    }
  }

  fileprivate func _errorContextSourceAttributes(
    associatedValues: [AssociatedValue]
  ) throws -> [ContextSource] {
    let attributes = attributes(withUnqualifiedName: "ErrorContext").filter(
      \._providesContextContents)
    var contextSourceValues: Set<String> = []

    return try attributes.map { attribute in
      try attribute.validateMacroArgumentShape(
        allowedLabels: ["contentsOf"],
        unlabeledArgumentCount: 0...0
      )

      let associatedValue = try attribute.optionalStringLiteralValue(labeled: "contentsOf")

      guard let associatedValue else {
        throw ErrorXMacroDiagnostic.error(
          .invalidContextContents,
          "@ErrorContext(contentsOf:) requires an associated-value name."
        )
      }

      let selectedValue = try associatedValues._resolveAssociatedValue(
        named: associatedValue,
        allowingSoleValueInference: false,
        macroName: "ErrorContext",
        diagnosticID: .invalidContextContents,
        missingValueDiagnostic: "@ErrorContext(contentsOf:) requires an associated-value name."
      )

      guard contextSourceValues.insert(selectedValue.bindingName).inserted else {
        throw ErrorXMacroDiagnostic.error(
          .duplicateContext,
          "Associated value '\(selectedValue.diagnosticName)' is already used as @ErrorContext contents on this error case."
        )
      }

      return ContextSource(
        boundName: selectedValue.bindingName
      )
    }
  }

  fileprivate func _errorRecoveryOptionAttributes() throws -> [RecoveryOptionAttribute] {
    try attributes(withUnqualifiedName: "ErrorRecoveryOption").map { attribute in
      try attribute.validateMacroArgumentShape(
        allowedLabels: ["explanation"],
        unlabeledArgumentCount: 1...1
      )

      return try RecoveryOptionAttribute(
        title: attribute.requiredUnlabeledStringLiteralValue(
          diagnostic: "Expected @ErrorRecoveryOption title to be a string literal."
        ),
        explanation: attribute.optionalStringLiteralValue(labeled: "explanation")
      )
    }
  }

  fileprivate func _errorCauseAttribute(
    associatedValues: [AssociatedValue]
  ) throws -> CauseAttribute? {
    let attributes = attributes(withUnqualifiedName: "ErrorCause")

    guard attributes.count <= 1 else {
      throw ErrorXMacroDiagnostic.error(
        .duplicateAttribute, "A modeled error case can only have one @ErrorCause attribute.")
    }

    guard let attribute = attributes.first else {
      return nil
    }

    try attribute.validateMacroArgumentShape(
      allowedLabels: [],
      unlabeledArgumentCount: 0...1
    )

    let associatedValueExpression = try attribute.argumentList?.uniqueUnlabeledArgument()?
      .expression
    let associatedValue: String?

    if let associatedValueExpression {
      guard let value = associatedValueExpression.representedStringLiteralValue else {
        throw ErrorXMacroDiagnostic.error(
          .invalidCauseAssociatedValue,
          "@ErrorCause expects an associated-value name as a string literal."
        )
      }

      associatedValue = value
    } else {
      associatedValue = nil
    }

    let selectedValue = try associatedValues._resolveAssociatedValue(
      named: associatedValue,
      allowingSoleValueInference: true,
      macroName: "ErrorCause",
      diagnosticID: .invalidCauseAssociatedValue,
      missingValueDiagnostic:
        "@ErrorCause requires an associated-value name when a case has zero or multiple associated values."
    )

    return .init(boundName: selectedValue.bindingName)
  }

  fileprivate func _errorRelationAttributes(
    associatedValues: [AssociatedValue]
  ) throws -> [RelationAttribute] {
    var result: [RelationAttribute] = []
    var relatedValues: Set<String> = []

    for attributeElement in attributes {
      guard case .attribute(let attribute) = attributeElement,
        attribute.unqualifiedName == "ErrorRelation"
      else {
        continue
      }

      try attribute.validateMacroArgumentShape(
        allowedLabels: ["error", "errors"],
        unlabeledArgumentCount: 1...1
      )

      let kindExpression = try attribute.requiredUnlabeledArgument(
        diagnostic: "@ErrorRelation requires a relation kind."
      )

      guard let kind = RelationAttribute.Kind(expression: kindExpression) else {
        throw ErrorXMacroDiagnostic.error(
          .invalidRelationAssociatedValue,
          "@ErrorRelation requires a direct ErrorRelation.Kind value."
        )
      }

      let associatedValue = try attribute.optionalStringLiteralValue(labeled: "error")
      let elementsOf = try attribute.optionalStringLiteralValue(labeled: "errors")

      guard (associatedValue == nil) != (elementsOf == nil) else {
        throw ErrorXMacroDiagnostic.error(
          .invalidRelationAssociatedValue,
          "@ErrorRelation requires exactly one of 'error:' or 'errors:'."
        )
      }

      guard elementsOf == nil || kind.acceptsMultipleElements else {
        throw ErrorXMacroDiagnostic.error(
          .invalidRelationAssociatedValue,
          "The 'errors:' argument is not valid for .cause or .translatedFrom relations; each identifies one direct error."
        )
      }

      let associatedValueName = associatedValue ?? elementsOf
      let match = try associatedValues._resolveAssociatedValue(
        named: associatedValueName,
        allowingSoleValueInference: false,
        macroName: "ErrorRelation",
        diagnosticID: .invalidRelationAssociatedValue,
        missingValueDiagnostic: "@ErrorRelation requires an associated-value name."
      )

      guard relatedValues.insert(match.bindingName).inserted else {
        throw ErrorXMacroDiagnostic.error(
          .duplicateRelation,
          "Associated value '\(associatedValueName ?? match.diagnosticName)' is already modeled as a related error on this error case."
        )
      }

      result.append(
        .init(
          kind: kind,
          boundName: match.bindingName,
          appliesToElements: elementsOf != nil
        )
      )
    }

    return result
  }

  fileprivate func _errorXModelingAttributes() -> [AttributeSyntax] {
    let names: Set<String> = [
      "ErrorContext",
      "ErrorRecoveryOption",
      "ErrorCause",
      "ErrorRelation",
    ]

    return attributes.compactMap { attribute -> AttributeSyntax? in
      guard case .attribute(let attribute) = attribute,
        let name = attribute.unqualifiedName,
        names.contains(name)
      else {
        return nil
      }

      return attribute
    }
  }
}

extension AttributeSyntax {
  fileprivate var _providesContextContents: Bool {
    argumentList?.contains { argument in
      argument.label?.identifierValue == "contentsOf"
    } == true
  }

  fileprivate func _errorCodePresentation(
    associatedValues: [AssociatedValue]
  ) throws -> PresentationAttributes {
    func template(
      labeled label: String
    ) throws -> ErrorPresentationTemplate? {
      guard let expression = try optionalArgument(labeled: label), !expression.isNilLiteral else {
        return nil
      }

      return try ErrorPresentationTemplate(
        expression: expression,
        label: label
      ) { name in
        // Resolved by position when the placeholder is an index, so that associated values with no
        // label remain reachable. Deliberately kept out of `AssociatedValue.matches(_:)`, which
        // also drives `@ErrorContext`, `@ErrorCause`, and `@ErrorRelation`.
        if let position = Int(name) {
          guard let associatedValue = associatedValues.first(where: { $0.position == position }) else {
            throw ErrorXMacroDiagnostic.error(
              .invalidPresentationPlaceholder,
              "@ErrorCode '\(label):' interpolates position \(position), but the case has \(associatedValues.count) associated value(s)."
            )
          }

          return associatedValue.bindingName
        }

        guard let associatedValue = associatedValues.uniqueAssociatedValue(named: name) else {
          throw ErrorXMacroDiagnostic.error(
            .invalidPresentationPlaceholder,
            "@ErrorCode '\(label):' interpolates '\(name)', which does not name exactly one associated value. Available associated values: \(associatedValues._availableAssociatedValuesDescription)."
          )
        }

        return associatedValue.bindingName
      }
    }

    return .init(
      message: try template(labeled: "message"),
      failureReason: try template(labeled: "failureReason"),
      helpAnchor: try template(labeled: "helpAnchor")
    )
  }

  fileprivate func _errorModelOptions() throws -> ModelOptions {
    try validateMacroArgumentShape(
      allowedLabels: ["domain", "catalog", "allowingUnmodeledCases"],
      unlabeledArgumentCount: 0...0
    )

    let literalDomain = try optionalStringLiteralValue(labeled: "domain")
    let catalogExpression = try optionalArgument(labeled: "catalog")
    let allowsUnmodeledCases =
      try optionalBooleanLiteralValue(
        labeled: "allowingUnmodeledCases"
      ) ?? false
    let domain: DomainSpecification

    guard literalDomain == nil || catalogExpression == nil else {
      throw ErrorXMacroDiagnostic.error(
        .invalidDomain,
        "@ErrorModel accepts either 'domain:' or 'catalog:', not both."
      )
    }

    if let literalDomain {
      guard !literalDomain.isEmpty else {
        throw ErrorXMacroDiagnostic.error(.invalidDomain, "@ErrorModel domain cannot be empty.")
      }

      domain = .literal(literalDomain)
    } else if let catalogExpression {
      guard let base = catalogExpression.postfixSelfExpressionBase,
        let nameComponents = base.directDeclReferenceNameComponents
      else {
        throw ErrorXMacroDiagnostic.error(
          .invalidDomain,
          "@ErrorModel 'catalog:' must be a direct error-code catalog metatype such as 'CheckoutDiagnostics.Codes.self'."
        )
      }

      domain = .catalog(
        typeExpression: base.trimmedDescription,
        nameComponents: nameComponents
      )
    } else {
      domain = .inferred
    }

    return .init(
      domain: domain,
      allowsUnmodeledCases: allowsUnmodeledCases
    )
  }
}

extension Array where Element == AssociatedValue {
  fileprivate var _availableAssociatedValuesDescription: String {
    isEmpty ? "none" : map(\.diagnosticName).joined(separator: ", ")
  }

  fileprivate func uniqueAssociatedValue(
    named name: String
  ) -> AssociatedValue? {
    let matches = filter { $0.matches(name) }

    guard matches.count == 1 else {
      return nil
    }

    return matches[0]
  }

  fileprivate func _resolveAssociatedValue(
    named explicitName: String?,
    inferredName: String? = nil,
    allowingSoleValueInference: Bool,
    macroName: String,
    diagnosticID: ErrorXMacroDiagnostic.ID,
    missingValueDiagnostic: String
  ) throws -> AssociatedValue {
    if allowingSoleValueInference, count == 1, explicitName == nil {
      return self[0]
    }

    guard let name = explicitName ?? inferredName else {
      throw ErrorXMacroDiagnostic.error(diagnosticID, missingValueDiagnostic)
    }

    guard let value = uniqueAssociatedValue(named: name) else {
      throw ErrorXMacroDiagnostic.error(
        diagnosticID,
        "@\(macroName) associated value '\(name)' does not match exactly one label or local name. Available associated values: \(_availableAssociatedValuesDescription)."
      )
    }

    return value
  }
}
