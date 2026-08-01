//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

private struct LegacyConfigurationError: LocalizedError, RecoverableError {
  let path: String

  var errorDescription: String? {
    "Configuration could not be loaded."
  }

  var failureReason: String? {
    "The configuration file does not exist."
  }

  var recoverySuggestion: String? {
    "Create the default configuration or choose another file."
  }

  var recoveryOptions: [String] {
    ["Create Default Configuration", "Cancel"]
  }

  func attemptRecovery(
    optionIndex recoveryOptionIndex: Int
  ) -> Bool {
    recoveryOptionIndex == 0
  }
}

private struct LegacyConfigurationLoader {
  func load(
    from path: String
  ) throws -> String {
    throw LegacyConfigurationError(path: path)
  }
}

private enum PlainLegacyError: Error {
  case rejectedCredential(String)
}

private struct UnmodeledCustomNSError: CustomNSError {
  static let errorDomain = "com.example.legacy-database"

  let errorCode: Int

  var errorUserInfo: [String: Any] {
    [NSLocalizedDescriptionKey: "The legacy database request failed."]
  }
}

@ErrorModel(domain: "com.example.legacy-service")
private enum LegacyServiceError: CustomNSError {
  @ErrorCode("service.unavailable", message: "The legacy service is unavailable.")
  case unavailable

  static var errorDomain: String {
    "com.example.legacy-service"
  }

  var errorCode: Int {
    4107
  }

  var errorUserInfo: [String: Any] {
    ["legacy.request-id": "request-123"]
  }
}

@Suite
struct ExistingSwiftErrorInteropExample {
  @Test
  func plainLocalizedAndRecoverableErrorsNeedNoErrorXConformance() throws {
    let path = "/Users/example/.example-app/config.yml"
    let error = try catchLegacyConfigurationError {
      _ = try LegacyConfigurationLoader().load(from: path)
    }
    let report = ErrorReport(
      error,
      observation: .init(context: [
        .init(key: "configuration.format", value: "yaml", privacy: .public),
        .init(key: "configuration.path", value: path, privacy: .private),
      ])
    )
    let diagnostic = report.diagnosticDescription(style: .detailed)

    #expect(report.primaryIdentity == nil)
    #expect(report.presentation?.message == "Configuration could not be loaded.")
    #expect(report.presentation?.failureReason == "The configuration file does not exist.")
    #expect(report.recoveryOptions.map(\.title) == ["Create Default Configuration", "Cancel"])
    #expect(
      report.recoveryOptions.allSatisfy {
        $0.explanation == "Create the default configuration or choose another file."
      })
    #expect(diagnostic.contains("configuration.format: yaml"))
    #expect(!diagnostic.contains(path))
  }

  @Test
  func unmodeledCustomNSErrorKeepsItsExplicitCocoaIdentity() {
    let error = UnmodeledCustomNSError(errorCode: 73)
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.domain == UnmodeledCustomNSError.errorDomain)
    #expect(report.primaryIdentity?.code == "73")
    #expect(report.presentation?.message == "The legacy database request failed.")
  }

  @Test
  func nativeNSErrorKeepsIdentityPresentationRecoveryAndCause() {
    let root = NSError(
      domain: NSPOSIXErrorDomain,
      code: 2,
      userInfo: [NSLocalizedDescriptionKey: "Configuration file was not found."]
    )
    let error = NSError(
      domain: "com.example.configuration",
      code: 17,
      userInfo: [
        NSUnderlyingErrorKey: root,
        NSLocalizedDescriptionKey: "Configuration could not be loaded.",
        NSLocalizedFailureReasonErrorKey: "The file lookup failed.",
        NSLocalizedRecoveryOptionsErrorKey: ["Retry", "Cancel"],
        NSLocalizedRecoverySuggestionErrorKey: "Check the selected path and retry.",
      ]
    )
    let report = ErrorReport(error)
    let nsError = NSError(error)

    #expect(report.primaryIdentity?.domain == "com.example.configuration")
    #expect(report.primaryIdentity?.code == "17")
    #expect(report.causeChain.count == 2)
    #expect(report.presentation?.message == "Configuration could not be loaded.")
    #expect(report.recoveryOptions.map(\.title) == ["Retry", "Cancel"])
    #expect(nsError.domain == "com.example.configuration")
    #expect(nsError.code == 17)
    #expect(nsError.userInfo[NSUnderlyingErrorKey] as? NSError === root)
  }

  @Test
  func nativeNSErrorAggregateParticipatesInTheErrorTree() {
    guard #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *) else {
      return
    }

    let lookup = NSError(domain: "com.example.lookup", code: 11)
    let cache = NSError(domain: "com.example.cache", code: 12)
    let error = NSError(
      domain: "com.example.configuration",
      code: 18,
      userInfo: [NSMultipleUnderlyingErrorsKey: [lookup, cache]]
    )
    let report = ErrorReport(error)

    #expect(
      report.identities.map(\.description) == [
        "com.example.configuration.18",
        "com.example.lookup.11",
        "com.example.cache.12",
      ])
    #expect(report.identities(relatedBy: .component).count == 2)
  }

  @Test
  func completeCustomNSErrorModelKeepsItsExistingIntegerCode() {
    let error = LegacyServiceError.unavailable
    let report = ErrorReport(error)
    let nsError = NSError(error)

    #expect(report.primaryIdentity?.code == "service.unavailable")
    #expect(report.presentation?.message == "The legacy service is unavailable.")
    #expect(nsError.domain == LegacyServiceError.errorDomain)
    #expect(nsError.code == 4107)
    #expect(nsError.userInfo["legacy.request-id"] as? String == "request-123")
  }

  @Test
  func plainErrorPayloadRequiresExplicitDiagnosticVisibility() {
    let secret = "token-123"
    let error = PlainLegacyError.rejectedCredential(secret)

    #expect(!error.diagnosticDescription().contains(secret))
    #expect(error.diagnosticDescription(contextProjection: .diagnostic).contains(secret))
  }
}

private func catchLegacyConfigurationError(
  _ operation: () throws -> Void
) throws -> LegacyConfigurationError {
  do {
    try operation()
  } catch let error as LegacyConfigurationError {
    return error
  } catch {
    Issue.record("Unexpected error: \(error)")
  }

  throw ExistingSwiftErrorInteropExampleFailure.expectedLegacyConfigurationError
}

private enum ExistingSwiftErrorInteropExampleFailure: Error {
  case expectedLegacyConfigurationError
}
