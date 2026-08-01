//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

private struct TranslatedCancellationFailure: Error, ErrorTreeProviding {
  let source: any Error

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: [ErrorRelation(.translatedFrom, to: source)]
    )
  }
}

private struct CleanupDuringCancellationFailure: Error, ErrorTreeProviding {
  let cancellation: any Error

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: [ErrorRelation(.cause, to: cancellation)]
    )
  }
}

private struct MultipleTranslationFailure: Error, ErrorTreeProviding {
  let sources: [any Error]

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: sources.map { ErrorRelation(.translatedFrom, to: $0) }
    )
  }
}

@Suite
struct CancellationErrorHandlingExample {
  @Test
  func recognizesSwiftAndCocoaCancellationSignals() {
    #expect(ErrorReport(CancellationError()).isCancellation)
    #expect(ErrorReport(URLError(.cancelled)).isCancellation)
    #expect(ErrorReport(CocoaError(.userCancelled)).isCancellation)
    #expect(ErrorReport(POSIXError(.ECANCELED)).isCancellation)
    #expect(
      ErrorReport(
        NSError(
          domain: NSURLErrorDomain,
          code: URLError.Code.cancelled.rawValue
        )
      ).isCancellation
    )
  }

  @Test
  func translationsPreserveCancellationMeaning() {
    let report = ErrorReport(
      TranslatedCancellationFailure(source: CancellationError())
    )

    #expect(report.isCancellation)
    #expect(report.causeChain.count == 2)
  }

  @Test
  func cancellationClassificationExaminesEveryTranslationBranch() {
    let report = ErrorReport(
      MultipleTranslationFailure(
        sources: [
          CocoaError(.fileReadNoSuchFile),
          CancellationError(),
        ]
      )
    )

    #expect(report.isCancellation)
  }

  @Test
  func operationalFailuresAreNotHiddenBecauseCancellationCausedThem() {
    let report = ErrorReport(
      CleanupDuringCancellationFailure(cancellation: CancellationError())
    )

    #expect(!report.isCancellation)
    #expect(report.contains(CancellationError.self))
  }

  @Test
  func aCancelledTaskCanStillProduceAReportableOperationalFailure() async {
    let task = Task {
      while !Task.isCancelled {
        await Task.yield()
      }

      return ErrorReport(
        NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileWriteOutOfSpace.rawValue)
      )
    }

    task.cancel()

    let report = await task.value

    #expect(!report.isCancellation)
  }
}
