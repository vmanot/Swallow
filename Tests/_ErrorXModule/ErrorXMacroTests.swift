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

}
