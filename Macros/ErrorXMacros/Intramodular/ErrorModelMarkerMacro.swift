//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

/// Marker attributes interpreted by `@ErrorModel`.
public struct ErrorModelMarkerMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.is(EnumCaseDeclSyntax.self) else {
      throw ErrorXMacroDiagnostic.error(
        .invalidDeclaration,
        "Error modeling attributes can only be attached to enum cases."
      )
    }

    return []
  }
}
