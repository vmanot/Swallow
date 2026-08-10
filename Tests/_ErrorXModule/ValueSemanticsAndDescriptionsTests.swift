//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

private enum DescriptionTestCode: String, ErrorCode {
  static let domain = "com.example.description-tests"

  case failed
}

private struct DescriptionTestError: Error, ErrorCodeProviding, ErrorTreeProviding {
  let cause: NSError

  var errorCode: DescriptionTestCode {
    .failed
  }

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: [ErrorRelation(.cause, to: cause)]
    )
  }
}

@Suite
struct ValueSemanticsAndDescriptionsTests {
  @Test
  func contextDescriptionsPreservePrivacy() {
    let context: ErrorContext = [
      .init(key: "http.status", value: 503, privacy: .public),
      .init(key: "request.url", value: "https://example.com/private", privacy: .private),
      .init(key: "account.email", value: "person@example.com", privacy: .sensitive),
      .init(key: "access.token", value: "secret-token", privacy: .secret),
    ]

    #expect(context.description == "[http.status=503]")
    #expect(context.debugDescription.contains("http.status"))
    #expect(context.debugDescription.contains(".redacted(.private)"))
    #expect(context.debugDescription.contains(".redacted(.sensitive)"))
    #expect(context.debugDescription.contains(".redacted(.secret)"))
    #expect(!context.debugDescription.contains("https://example.com/private"))
    #expect(!context.debugDescription.contains("person@example.com"))
    #expect(!context.debugDescription.contains("secret-token"))

    let relation = ErrorRelation(
      .cause,
      to: NSError(domain: "com.example", code: 1),
      context: context
    )

    #expect(!relation.debugDescription.contains("https://example.com/private"))
    #expect(!relation.debugDescription.contains("person@example.com"))
    #expect(!relation.debugDescription.contains("secret-token"))
  }

  @Test
  func descriptionsDistinguishPresentationPayloadFromStructuralDebugText() {
    let presentation = ErrorPresentation(
      message: "Upload failed",
      failureReason: "The server rejected the request.",
      diagnosticDescription: "HTTP response was not successful.",
      helpAnchor: "https://example.com/help"
    )

    #expect(presentation.description == "Upload failed")
    #expect(presentation.debugDescription.contains("diagnosticDescription"))
    #expect(presentation.debugDescription.contains("HTTP response was not successful."))
    #expect(ErrorRecoveryOption(title: "Retry").description == "Retry")
    #expect(ErrorScenario("upload.release").debugDescription == #"ErrorScenario("upload.release")"#)
    #expect(ErrorRelation.Kind.translatedFrom.debugDescription == ".translatedFrom")

    let native = NSError(
      domain: "com.example.native",
      code: 1,
      userInfo: [NSDebugDescriptionErrorKey: "Native diagnostic detail"]
    )

    #expect(ErrorReport(native).presentation?.diagnosticDescription == "Native diagnostic detail")
  }

  @Test
  func causalityAndReportDescriptionsUseIdentityWithoutLeakingPrivateContext() {
    let cause = NSError(domain: "com.example.transport", code: 503)
    let error = DescriptionTestError(cause: cause)
    let report = ErrorReport(
      error,
      observation: .init(
        context: [
          .init(key: "request.id", value: "public-request", privacy: .public),
          .init(key: "access.token", value: "secret-token", privacy: .secret),
        ]
      )
    )

    #expect(report.errorTree.description == "com.example.description-tests.failed")
    #expect(report.causeChain.description.contains("com.example.description-tests.failed"))
    #expect(report.causeChain.description.contains("com.example.transport.503"))
    #expect(report.debugDescription.contains("request.id"))
    #expect(report.debugDescription.contains("public-request"))
    #expect(!report.debugDescription.contains("access.token"))
    #expect(!report.debugDescription.contains("secret-token"))
  }
}
