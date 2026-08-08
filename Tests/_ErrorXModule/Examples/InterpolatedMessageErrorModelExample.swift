//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

// The shape this replaces is a hand-written `LocalizedError` enum whose
// `errorDescription` is one `switch` interpolating each case's associated
// values. `@ErrorModel` reproduces it without a domain, without per-case code
// strings, and without the `switch`.
@ErrorModel
private enum PublishError {
  @ErrorCode(
    message: #"Cannot copy sources for \(module): its source directory is absent from the resolved package graph."#
  )
  case unavailableModuleSourceDirectory(module: String)

  @ErrorCode(
    message:
      #"Cannot publish \(package): module \(module) was not built at \(xcFrameworkURL.path)."#
  )
  case unavailableBuiltArtifact(package: String, module: String, xcFrameworkURL: URL)

  @ErrorCode(message: #"Nothing to publish."#)
  case nothingToPublish
}

@Suite
struct InterpolatedMessageErrorModelExample {
  /// Substitution has to reach both surfaces: the report a presenter reads, and the
  /// `LocalizedError` members a `catch` site reads.
  @Test
  func anInterpolatedMessageReachesBothTheReportAndLocalizedError() {
    let error = PublishError.unavailableModuleSourceDirectory(module: "ScipioKit")
    let expected =
      "Cannot copy sources for ScipioKit: its source directory is absent from the resolved package graph."

    #expect(ErrorReport(error).presentation?.message == expected)
    #expect(error.errorDescription == expected)
    #expect(error.localizedDescription == expected)
  }

  @Test
  func aPlaceholderCanReachThroughAnAssociatedValue() {
    let error = PublishError.unavailableBuiltArtifact(
      package: "Scipio",
      module: "ScipioKit",
      xcFrameworkURL: URL(fileURLWithPath: "/tmp/build/ScipioKit.xcframework")
    )

    #expect(
      error.errorDescription
        == "Cannot publish Scipio: module ScipioKit was not built at /tmp/build/ScipioKit.xcframework."
    )
  }

  @Test
  func aCaseWithoutAssociatedValuesKeepsItsPlainMessage() {
    #expect(PublishError.nothingToPublish.errorDescription == "Nothing to publish.")
  }

  @Test
  func everyCaseKeepsItsOwnMessageAndCode() {
    let errors: [PublishError] = [
      .unavailableModuleSourceDirectory(module: "A"),
      .unavailableBuiltArtifact(
        package: "B",
        module: "C",
        xcFrameworkURL: URL(fileURLWithPath: "/tmp/C.xcframework")
      ),
      .nothingToPublish,
    ]

    #expect(
      errors.map { ErrorIdentity($0)?.code } == [
        "unavailableModuleSourceDirectory",
        "unavailableBuiltArtifact",
        "nothingToPublish",
      ]
    )
    #expect(errors.compactMap(\.errorDescription).count == 3)
    #expect(Set(errors.compactMap(\.errorDescription)).count == 3)
  }

  @Test
  func anOmittedDomainIsDerivedFromTheDeclarationSite() {
    #expect(
      PublishError.Code.domain
        == "ErrorXTests.InterpolatedMessageErrorModelExample.PublishError"
    )
    #expect(
      ErrorIdentity(PublishError.nothingToPublish)?.description
        == "ErrorXTests.InterpolatedMessageErrorModelExample.PublishError.nothingToPublish"
    )
  }

}

// An associated value with no label has no name to interpolate, so it is reached by position.
// Hand-written error enums use this shape constantly — `case invalidSourceRepository(String)`.
@ErrorModel
private enum PositionalError {
  @ErrorCode(message: #"Cannot derive a GitHub repository identity from '\(0)'."#)
  case invalidSourceRepository(String)

  @ErrorCode(message: #"Expected \(1) at '\(0)'."#)
  case unexpectedContents(String, String)
}

@Suite
struct PositionalPlaceholderExample {
  @Test
  func positionalPlaceholdersResolveUnlabeledAssociatedValues() {
    #expect(
      PositionalError.invalidSourceRepository("not/a/repo").errorDescription
        == "Cannot derive a GitHub repository identity from 'not/a/repo'."
    )
    #expect(
      PositionalError.unexpectedContents("/tmp/x", "a manifest").errorDescription
        == "Expected a manifest at '/tmp/x'."
    )
  }
}

// Every `@ErrorCode` argument is optional, so a case can be marked as modeled
// and nothing else. Its code is then the case name and it has no presentation.
@ErrorModel
private enum MinimalError {
  @ErrorCode
  case cancelled

  @ErrorCode
  case timedOut(afterSeconds: Int)
}

@Suite
struct OmittedErrorCodeArgumentsExample {
  @Test
  func aBareErrorCodeStillModelsTheCase() {
    #expect(ErrorIdentity(MinimalError.cancelled)?.code == "cancelled")
    #expect(ErrorIdentity(MinimalError.timedOut(afterSeconds: 30))?.code == "timedOut")
    #expect(MinimalError.Code.allCases.map(\.identifier) == ["cancelled", "timedOut"])
  }

  @Test
  func anUnauthoredMessageLeavesErrorDescriptionAbsent() {
    #expect(MinimalError.cancelled.errorDescription == nil)
    #expect(ErrorReport(MinimalError.cancelled).presentation == nil)
  }
}

// A message can also carry a failure reason and a help anchor with placeholders,
// and a code identifier may still be authored explicitly alongside them.
@ErrorModel(domain: "dev.vmanot.tests.interpolated-presentation")
private enum ArchiveError {
  @ErrorCode(
    "archive.unreadable",
    message: #"Cannot read \(url.lastPathComponent)."#,
    failureReason: #"The archive at \(url.path) reported status \(status)."#,
    helpAnchor: #"https://example.com/help/archive/\(status)"#
  )
  case unreadable(url: URL, status: Int)
}

@Suite
struct InterpolatedPresentationFieldsExample {
  @Test
  func everyPresentationFieldResolvesItsPlaceholders() {
    let error = ArchiveError.unreadable(
      url: URL(fileURLWithPath: "/tmp/archives/Sources.zip"),
      status: 66
    )

    #expect(error.errorDescription == "Cannot read Sources.zip.")
    #expect(error.failureReason == "The archive at /tmp/archives/Sources.zip reported status 66.")
    #expect(error.helpAnchor == "https://example.com/help/archive/66")
    #expect(ErrorIdentity(error)?.code == "archive.unreadable")
  }
}
