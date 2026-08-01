//
// Copyright (c) Vatsal Manot
//

import SwiftSyntaxUtilities

/// Diagnostics emitted by ErrorX authoring macros.
enum ErrorXMacroDiagnostic {
  enum ID: String {
    case invalidDeclaration
    case missingErrorCode
    case duplicateErrorCode
    case invalidErrorCode
    case duplicateStableCode
    case invalidDomain
    case missingDomain
    case mismatchedCatalog
    case invalidContextAssociatedValue
    case duplicateContext
    case invalidContextContents
    case invalidCauseAssociatedValue
    case invalidRelationAssociatedValue
    case duplicateRelation
    case duplicateAttribute
    case invalidStableIdentifier
    case invalidCatalog
  }

  static func error(
    _ id: ID,
    _ message: String
  ) -> MacroExpansionDiagnosticMessage {
    MacroExpansionDiagnosticMessage(
      message: message,
      domain: "com.vmanot.ErrorXMacros",
      id: id.rawValue
    )
  }
}
