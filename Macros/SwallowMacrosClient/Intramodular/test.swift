//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@freestanding(declaration)
public macro test<T>(_ fn: () async throws -> T) = #externalMacro(
    module: "SwallowMacros",
    type: "TestMacro"
)

@freestanding(declaration, names: named(InlineXCTestCases))
public macro InitializeInlineXCTestCases() = #externalMacro(
    module: "SwallowMacros",
    type: "InitializeInlineXCTestCasesMacro"
)
