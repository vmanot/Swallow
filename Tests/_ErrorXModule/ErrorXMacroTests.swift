//
// Copyright (c) Vatsal Manot
//

import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import ErrorXMacros

final class ErrorXMacroTests: XCTestCase {
  func testInvalidCatalogDoesNotSynthesizeConformance() {
    assertMacroExpansion(
      """
      @ErrorCodeCatalog(domain: Domain.value)
      enum Codes {
          case failed
      }
      """,
      expandedSource: """
        enum Codes {
            case failed
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Expected 'domain:' to be a string literal.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorCodeCatalog": ErrorCodeCatalogMacro.self]
    )
  }

  func testLiteralDomainCannotSilentlyOverrideTypedCatalogCodes() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.override")
      enum Failure {
          @ErrorCode(Codes.failed)
          case failed
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode(Codes.failed)
            case failed
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message:
            "An @ErrorModel 'domain:' cannot be combined with catalog-backed @ErrorCode values. Omit 'domain:' to infer the catalog, or pass it with 'catalog:'.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testEmptyModelDomainIsRejected() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "")
      enum Failure {
          @ErrorCode("failed")
          case failed
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("failed")
            case failed
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "@ErrorModel domain cannot be empty.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testDuplicateModelCodesDoNotSynthesizeConformance() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.failure")
      enum Failure {
          @ErrorCode("same")
          case first

          @ErrorCode("same")
          case second
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("same")
            case first

            @ErrorCode("same")
            case second
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Duplicate stable error code 'same'.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testDuplicateCatalogReferencesAreRejected() {
    assertMacroExpansion(
      """
      @ErrorModel
      enum Failure {
          @ErrorCode(Codes.failed)
          case first

          @ErrorCode(Codes.failed)
          case second
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode(Codes.failed)
            case first

            @ErrorCode(Codes.failed)
            case second
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Duplicate error code reference 'Codes.failed'.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testCauseAttributeAndCauseRelationCannotConflict() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.failure")
      enum Failure {
          @ErrorCode("failed")
          @ErrorCause("directCause")
          @ErrorRelation(.cause, error: "relatedCause")
          case failed(directCause: SomeError, relatedCause: SomeError)
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("failed")
            @ErrorCause("directCause")
            @ErrorRelation(.cause, error: "relatedCause")
            case failed(directCause: SomeError, relatedCause: SomeError)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message:
            "A modeled error case cannot combine @ErrorCause with @ErrorRelation(.cause); both define the underlying error.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testErrorRelationRequiresOneAssociatedValueSelector() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.failure")
      enum Failure {
          @ErrorCode("failed")
          @ErrorRelation(.concurrent, error: "first", errors: "others")
          case failed(first: SomeError, others: [SomeError])
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("failed")
            @ErrorRelation(.concurrent, error: "first", errors: "others")
            case failed(first: SomeError, others: [SomeError])
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "@ErrorRelation requires exactly one of 'error:' or 'errors:'.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testErrorRelationRejectsMultipleDirectCauses() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.failure")
      enum Failure {
          @ErrorCode("failed")
          @ErrorRelation(.cause, errors: "causes")
          case failed(causes: [SomeError])
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("failed")
            @ErrorRelation(.cause, errors: "causes")
            case failed(causes: [SomeError])
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message:
            "The 'errors:' argument is not valid for .cause or .translatedFrom relations; each identifies one direct error.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testErrorRelationRejectsMultipleDirectTranslations() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.failure")
      enum Failure {
          @ErrorCode("failed")
          @ErrorRelation(.translatedFrom, error: "first")
          @ErrorRelation(.translatedFrom, error: "second")
          case failed(first: SomeError, second: SomeError)
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("failed")
            @ErrorRelation(.translatedFrom, error: "first")
            @ErrorRelation(.translatedFrom, error: "second")
            case failed(first: SomeError, second: SomeError)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message:
            "A modeled error case can declare at most one @ErrorRelation(.translatedFrom).",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testCauseAndTranslationRelationsCannotConflict() {
    assertMacroExpansion(
      """
      @ErrorModel(domain: "com.example.failure")
      enum Failure {
          @ErrorCode("failed")
          @ErrorRelation(.cause, error: "cause")
          @ErrorRelation(.translatedFrom, error: "source")
          case failed(cause: SomeError, source: SomeError)
      }
      """,
      expandedSource: """
        enum Failure {
            @ErrorCode("failed")
            @ErrorRelation(.cause, error: "cause")
            @ErrorRelation(.translatedFrom, error: "source")
            case failed(cause: SomeError, source: SomeError)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message:
            "A modeled error case cannot combine a cause with @ErrorRelation(.translatedFrom); both define its primary causal predecessor.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testInterpolatedMessageBindsEachCasesAssociatedValues() {
    assertMacroExpansion(
      #"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode(message: "Cannot copy sources for \(module).")
          case unavailableModuleSourceDirectory(module: String)

          @ErrorCode(message: "Cannot publish \(package): module \(module) was not built at \(xcFrameworkURL.path).")
          case unavailableBuiltArtifact(package: String, module: String, xcFrameworkURL: URL)
      }
      """#,
      expandedSource: #"""
        enum Failure {
            @ErrorCode(message: "Cannot copy sources for \(module).")
            case unavailableModuleSourceDirectory(module: String)

            @ErrorCode(message: "Cannot publish \(package): module \(module) was not built at \(xcFrameworkURL.path).")
            case unavailableBuiltArtifact(package: String, module: String, xcFrameworkURL: URL)

            enum Code: ErrorCode, CaseIterable {
                static var domain: String {
                    "com.example.publish"
                }
                case unavailableModuleSourceDirectory
                case unavailableBuiltArtifact

                var identifier: String {
                    switch self {
                        case .unavailableModuleSourceDirectory:
                            return "unavailableModuleSourceDirectory"
                        case .unavailableBuiltArtifact:
                            return "unavailableBuiltArtifact"
                    }
                }

                static var allCases: [Self] {
                    [
                        Self.unavailableModuleSourceDirectory,
                        Self.unavailableBuiltArtifact,
                    ]
                }
            }

            static var _errorDescriptor: _ErrorDescriptor<Self> {
                _ErrorDescriptor { error in
                    switch error {
                        case .unavailableModuleSourceDirectory(let _errorX_0_module):
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.unavailableModuleSourceDirectory),
                                            presentation: ErrorPresentation(message: "Cannot copy sources for \(_errorX_0_module).")
                                )
                        case .unavailableBuiltArtifact(let _errorX_0_package, let _errorX_1_module, let _errorX_2_xcFrameworkURL):
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.unavailableBuiltArtifact),
                                            presentation: ErrorPresentation(message: "Cannot publish \(_errorX_0_package): module \(_errorX_1_module) was not built at \(_errorX_2_xcFrameworkURL.path).")
                                )
                    }
                }
            }
        }

        extension Failure: Swift.Error, _ModeledError {

        }
        """#,
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testOmittedDomainAndCodeAreDerivedFromTheDeclaration() {
    assertMacroExpansion(
      #"""
      @ErrorModel
      enum Failure {
          @ErrorCode
          case nothingToPublish

          @ErrorCode(message: "Cannot copy sources for \(module).")
          case unavailableModuleSourceDirectory(module: String)
      }
      """#,
      expandedSource: #"""
        enum Failure {
            @ErrorCode
            case nothingToPublish

            @ErrorCode(message: "Cannot copy sources for \(module).")
            case unavailableModuleSourceDirectory(module: String)

            enum Code: ErrorCode, CaseIterable {
                static var domain: String {
                    "TestModule.test.Failure"
                }
                case nothingToPublish
                case unavailableModuleSourceDirectory

                var identifier: String {
                    switch self {
                        case .nothingToPublish:
                            return "nothingToPublish"
                        case .unavailableModuleSourceDirectory:
                            return "unavailableModuleSourceDirectory"
                    }
                }

                static var allCases: [Self] {
                    [
                        Self.nothingToPublish,
                        Self.unavailableModuleSourceDirectory,
                    ]
                }
            }

            static var _errorDescriptor: _ErrorDescriptor<Self> {
                _ErrorDescriptor { error in
                    switch error {
                        case .nothingToPublish:
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.nothingToPublish)
                                )
                        case .unavailableModuleSourceDirectory(let _errorX_0_module):
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.unavailableModuleSourceDirectory),
                                            presentation: ErrorPresentation(message: "Cannot copy sources for \(_errorX_0_module).")
                                )
                    }
                }
            }
        }

        extension Failure: Swift.Error, _ModeledError {

        }
        """#,
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testInertRawLiteralPlaceholdersMatchRealInterpolation() {
    // `#"...\(module)..."#` is the spelling adopters must use, because Swift
    // type-checks the attribute argument and `module` is not in scope there.
    assertMacroExpansion(
      ##"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode("sources.unavailable", message: #"Cannot copy sources for \(module)."#)
          case unavailableModuleSourceDirectory(module: String)
      }
      """##,
      expandedSource: ##"""
        enum Failure {
            @ErrorCode("sources.unavailable", message: #"Cannot copy sources for \(module)."#)
            case unavailableModuleSourceDirectory(module: String)

            enum Code: ErrorCode, CaseIterable {
                static var domain: String {
                    "com.example.publish"
                }
                case unavailableModuleSourceDirectory

                var identifier: String {
                    switch self {
                        case .unavailableModuleSourceDirectory:
                            return "sources.unavailable"
                    }
                }

                static var allCases: [Self] {
                    [
                        Self.unavailableModuleSourceDirectory,
                    ]
                }
            }

            static var _errorDescriptor: _ErrorDescriptor<Self> {
                _ErrorDescriptor { error in
                    switch error {
                        case .unavailableModuleSourceDirectory(let _errorX_0_module):
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.unavailableModuleSourceDirectory),
                                            presentation: ErrorPresentation(message: "Cannot copy sources for \(_errorX_0_module).")
                                )
                    }
                }
            }
        }

        extension Failure: Swift.Error, _ModeledError {

        }
        """##,
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testMessagePlaceholderMustNameAnAssociatedValue() {
    assertMacroExpansion(
      #"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode(message: "Cannot copy sources for \(moduleName).")
          case unavailableModuleSourceDirectory(module: String)
      }
      """#,
      expandedSource: #"""
        enum Failure {
            @ErrorCode(message: "Cannot copy sources for \(moduleName).")
            case unavailableModuleSourceDirectory(module: String)
        }
        """#,
      diagnostics: [
        DiagnosticSpec(
          message:
            "@ErrorCode 'message:' interpolates 'moduleName', which does not name exactly one associated value. Available associated values: module.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testUnterminatedMessagePlaceholderIsRejected() {
    assertMacroExpansion(
      ##"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode(message: #"Cannot copy sources for \(module."#)
          case unavailableModuleSourceDirectory(module: String)
      }
      """##,
      expandedSource: ##"""
        enum Failure {
            @ErrorCode(message: #"Cannot copy sources for \(module."#)
            case unavailableModuleSourceDirectory(module: String)
        }
        """##,
      diagnostics: [
        DiagnosticSpec(
          message: "@ErrorCode 'message:' has an unterminated '\\(' placeholder.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testBracePlaceholderInPlainLiteralMatchesRealInterpolation() {
    // `{module}` needs no raw literal: a plain literal carries it inertly.
    assertMacroExpansion(
      ##"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode("sources.unavailable", message: "Cannot copy sources for {module}.")
          case unavailableModuleSourceDirectory(module: String)
      }
      """##,
      expandedSource: ##"""
        enum Failure {
            @ErrorCode("sources.unavailable", message: "Cannot copy sources for {module}.")
            case unavailableModuleSourceDirectory(module: String)

            enum Code: ErrorCode, CaseIterable {
                static var domain: String {
                    "com.example.publish"
                }
                case unavailableModuleSourceDirectory

                var identifier: String {
                    switch self {
                        case .unavailableModuleSourceDirectory:
                            return "sources.unavailable"
                    }
                }

                static var allCases: [Self] {
                    [
                        Self.unavailableModuleSourceDirectory,
                    ]
                }
            }

            static var _errorDescriptor: _ErrorDescriptor<Self> {
                _ErrorDescriptor { error in
                    switch error {
                        case .unavailableModuleSourceDirectory(let _errorX_0_module):
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.unavailableModuleSourceDirectory),
                                            presentation: ErrorPresentation(message: "Cannot copy sources for \(_errorX_0_module).")
                                )
                    }
                }
            }
        }

        extension Failure: Swift.Error, _ModeledError {

        }
        """##,
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testBraceEscapePositionalIndexAndAccessorChain() {
    assertMacroExpansion(
      ##"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode("archive.failed", message: "Archive {{failed}} for {0} at {url.path}.")
          case archiveFailure(String, url: URL)
      }
      """##,
      expandedSource: ##"""
        enum Failure {
            @ErrorCode("archive.failed", message: "Archive {{failed}} for {0} at {url.path}.")
            case archiveFailure(String, url: URL)

            enum Code: ErrorCode, CaseIterable {
                static var domain: String {
                    "com.example.publish"
                }
                case archiveFailure

                var identifier: String {
                    switch self {
                        case .archiveFailure:
                            return "archive.failed"
                    }
                }

                static var allCases: [Self] {
                    [
                        Self.archiveFailure,
                    ]
                }
            }

            static var _errorDescriptor: _ErrorDescriptor<Self> {
                _ErrorDescriptor { error in
                    switch error {
                        case .archiveFailure(let _errorX_0_value0, let _errorX_1_url):
                                return _ResolvedErrorDescriptor(
                                    code: AnyErrorCode(Code.archiveFailure),
                                            presentation: ErrorPresentation(message: "Archive {failed} for \(_errorX_0_value0) at \(_errorX_1_url.path).")
                                )
                    }
                }
            }
        }

        extension Failure: Swift.Error, _ModeledError {

        }
        """##,
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

  func testUnterminatedBracePlaceholderIsRejected() {
    assertMacroExpansion(
      ##"""
      @ErrorModel(domain: "com.example.publish")
      enum Failure {
          @ErrorCode(message: "Cannot copy sources for {module.")
          case unavailableModuleSourceDirectory(module: String)
      }
      """##,
      expandedSource: ##"""
        enum Failure {
            @ErrorCode(message: "Cannot copy sources for {module.")
            case unavailableModuleSourceDirectory(module: String)
        }
        """##,
      diagnostics: [
        DiagnosticSpec(
          message:
            "@ErrorCode 'message:' has an unterminated '{' placeholder. Write '{{' for a literal brace.",
          line: 1,
          column: 1
        )
      ],
      macros: ["ErrorModel": ErrorModelMacro.self]
    )
  }

}
