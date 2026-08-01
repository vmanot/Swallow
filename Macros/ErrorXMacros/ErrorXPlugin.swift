//
// Copyright (c) Vatsal Manot
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
public struct ErrorXPlugin: CompilerPlugin {
  public let providingMacros: [Macro.Type] = [
    ErrorCodeCatalogMacro.self,
    ErrorModelMarkerMacro.self,
    ErrorModelMacro.self,
  ]

  public init() {

  }
}
