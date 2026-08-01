//
// Copyright (c) Vatsal Manot
//

#if canImport(SwiftUI)
  import Foundation
  import SwiftUI
  import Testing

  @testable import ErrorX

  @ErrorModel(domain: "com.example.document-ui")
  private enum DocumentUIFailure {
    @ErrorCode(
      "document.open-failed",
      message: "The document couldn’t be opened.",
      failureReason: "The document service returned an error."
    )
    @ErrorRecoveryOption("Try Again", explanation: "Check the connection and retry.")
    @ErrorCause
    case openFailed(cause: any Error)
  }

  @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
  @MainActor
  private struct DocumentErrorView: View {
    @State private var report: ErrorReport?

    let openDocument: @Sendable () async throws -> Void

    var body: some View {
      Button("Open Document") {
        Task {
          await performOpen()
        }
      }
      .alert(
        isPresented: isPresentingReport,
        error: report
      ) { _ in
        Button(report?.recoveryOptions.first?.title ?? "Try Again") {
          Task {
            await performOpen()
          }
        }
        Button("Cancel", role: .cancel) {
          report = nil
        }
      } message: { report in
        Text(report.failureReason ?? report.recoverySuggestion ?? "")
      }
    }

    private var isPresentingReport: Binding<Bool> {
      Binding(
        get: { report != nil },
        set: { isPresented in
          if !isPresented {
            report = nil
          }
        }
      )
    }

    private func performOpen() async {
      do {
        try await openDocument()
        report = nil
      } catch {
        let sourceReport = ErrorReport(error)

        // Dismissing the view, cancelling URLSession, or receiving a translated
        // cancellation should not raise a stale alert.
        guard !sourceReport.isCancellation else {
          report = nil
          return
        }

        report = ErrorReport(
          DocumentUIFailure.openFailed(cause: error),
          observation: ErrorObservation(scenario: .init("document.open"))
        )
      }
    }
  }

  @Suite
  struct SwiftUIErrorPresentationExample {
    @Test
    @MainActor
    func localizedReportCanDriveSwiftUIErrorPresentation() {
      let report = ErrorReport(
        DocumentUIFailure.openFailed(
          cause: CocoaError(.fileReadNoSuchFile)
        )
      )
      let view = DocumentErrorView {
        throw CancellationError()
      }

      #expect(report.errorDescription == "The document couldn’t be opened.")
      #expect(report.failureReason == "The document service returned an error.")
      #expect(report.recoverySuggestion == "Check the connection and retry.")

      // Type-check the real `View.alert(isPresented:error:actions:message:)`
      // composition instead of testing a separate presentation adapter.
      _ = view.body
    }
  }
#endif
