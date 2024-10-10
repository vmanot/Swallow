//
// Copyright (c) Vatsal Manot
//

#if canImport(SwiftCompilerPlugin) && canImport(SwiftSyntaxMacros)

import SwiftCompilerPlugin
import SwiftSyntaxMacros

FAILS

public protocol MacrosProviding: CompilerPlugin {}

#endif
