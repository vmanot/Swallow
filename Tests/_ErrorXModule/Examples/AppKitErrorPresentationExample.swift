//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
  import AppKit
  import Testing

  @testable import ErrorX

  @ErrorModel(domain: "com.example.appkit-document")
  private enum AppKitDocumentFailure {
    @ErrorCode(
      "document.save-failed",
      message: "The document couldn’t be saved.",
      failureReason: "The destination volume is unavailable."
    )
    @ErrorRecoveryOption("Try Again", explanation: "Reconnect the volume and retry.")
    @ErrorRecoveryOption("Save a Copy")
    @ErrorCause
    case saveFailed(cause: any Error)
  }

  @MainActor
  private struct AppKitErrorPresenter {
    func makeAlert(for report: ErrorReport) -> NSAlert {
      // `NSError(report)` carries recovery-option titles and the underlying
      // Cocoa error. `LocalizedError` alone has no structured recovery list.
      NSAlert(error: NSError(report))
    }
  }

  @Suite
  struct AppKitErrorPresentationExample {
    @Test
    @MainActor
    func nsAlertConsumesTheCocoaProjectionOfAReport() throws {
      let cause = NSError(
        domain: NSCocoaErrorDomain,
        code: CocoaError.fileWriteNoPermission.rawValue
      )
      let report = ErrorReport(
        AppKitDocumentFailure.saveFailed(cause: cause),
        observation: ErrorObservation(scenario: .init("document.save"))
      )
      let cocoaError = NSError(report)
      let alert = AppKitErrorPresenter().makeAlert(for: report)
      let underlying = try #require(cocoaError.userInfo[NSUnderlyingErrorKey] as? NSError)

      #expect(alert.messageText == "The document couldn’t be saved.")
      #expect(alert.buttons.map(\.title).starts(with: ["Try Again", "Save a Copy"]))
      #expect(underlying === cause)
      #expect(cocoaError.userInfo[ErrorReport.UserInfoKey.scenario] as? String == "document.save")
    }
  }
#endif
