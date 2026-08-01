//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

private struct ConcurrentOperationFailure: Error, ErrorCodeProviding, ErrorPresentationProviding,
  ErrorTreeProviding
{
  struct Child: Sendable {
    let index: Int
    let operation: String
    let error: any Error
  }

  enum Code: String, ErrorCode {
    static let domain = "com.example.concurrent-operation"

    case failed = "operation.failed"
  }

  enum Context {
    static let childIndex = ErrorContext.Key<Int>("task.index", privacy: .public)
    static let operation = ErrorContext.Key<String>("task.operation", privacy: .public)
  }

  let children: [Child]

  var errorCode: Code {
    .failed
  }

  var errorPresentation: ErrorPresentation {
    ErrorPresentation(
      message: "Some background operations failed.",
      failureReason: "Independent child tasks reported errors."
    )
  }

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: children.map { child in
        ErrorRelation(
          .concurrent,
          to: child.error,
          context: [
            .init(key: Context.childIndex, value: child.index),
            .init(key: Context.operation, value: child.operation),
          ]
        )
      }
    )
  }
}

private enum ChildOperationError: String, Error, ErrorCodeProviding, Sendable {
  enum Code: String, ErrorCode {
    static let domain = "com.example.child-operation"

    case unavailable
    case invalidResponse = "invalid-response"
  }

  case unavailable
  case invalidResponse

  var errorCode: Code {
    switch self {
    case .unavailable:
      return .unavailable
    case .invalidResponse:
      return .invalidResponse
    }
  }
}

private actor ErrorReportMailbox {
  private var report: ErrorReport?

  func store(_ report: ErrorReport) {
    self.report = report
  }

  func take() -> ErrorReport? {
    defer { report = nil }
    return report
  }
}

@Suite
struct SwiftConcurrencyErrorHandlingExample {
  @Test
  func taskGroupRetainsSiblingFailuresAcrossAnActorBoundary() async throws {
    let operations = ["profile", "cancelled-prefetch", "recommendations"]
    let children = await withTaskGroup(
      of: ConcurrentOperationFailure.Child?.self,
      returning: [ConcurrentOperationFailure.Child].self
    ) { group in
      for (index, operation) in operations.enumerated() {
        group.addTask {
          await captureFailure(index: index, operation: operation)
        }
      }

      var failures: [ConcurrentOperationFailure.Child] = []

      for await failure in group {
        if let failure {
          failures.append(failure)
        }
      }

      // Task-group results arrive in completion order. Sort by the input index
      // before constructing a report whose serialized order must be stable.
      return failures.sorted { $0.index < $1.index }
    }

    let report = ErrorReport(
      ConcurrentOperationFailure(children: children),
      observation: ErrorObservation(scenario: .init("dashboard.refresh"))
    )
    let mailbox = ErrorReportMailbox()

    await mailbox.store(report)

    let received = try #require(await mailbox.take())
    let relationContext = received.contextOccurrences.filter { $0.owner == .relation }

    #expect(received.primaryIdentity == ConcurrentOperationFailure.Code.failed.identity)
    #expect(
      received.identities(relatedBy: .concurrent).map(\.code) == [
        "unavailable",
        "invalid-response",
      ])
    #expect(
      received.identityOccurrences.map(\.relationPath) == [
        [],
        [.concurrent],
        [.concurrent],
      ])
    #expect(relationContext.map(\.path) == [[0], [0], [1], [1]])
    #expect(
      relationContext.compactMap { occurrence in
        Int(errorContextValue: occurrence.entry.value)
      } == [0, 2]
    )
  }
}

private func captureFailure(
  index: Int,
  operation: String
) async -> ConcurrentOperationFailure.Child? {
  await Task.yield()

  do {
    switch operation {
    case "profile":
      throw ChildOperationError.unavailable
    case "cancelled-prefetch":
      throw CancellationError()
    default:
      throw ChildOperationError.invalidResponse
    }
  } catch {
    // Cooperative cancellation is expected control flow. This also catches
    // cancellation surfaced by URLSession or another Cocoa API.
    guard !ErrorReport(error).isCancellation else {
      return nil
    }

    return ConcurrentOperationFailure.Child(
      index: index,
      operation: operation,
      error: error
    )
  }
}
