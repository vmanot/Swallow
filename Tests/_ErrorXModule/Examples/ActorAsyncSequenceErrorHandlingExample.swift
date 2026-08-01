//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

private struct PipelineEvent: Sendable {
  let index: Int
}

private enum PipelineItemError: Error, ErrorCodeProviding, Sendable {
  enum Code: String, ErrorCode {
    static let domain = "com.example.event-pipeline.item"

    case malformed
    case rejected
  }

  case malformed
  case rejected

  var errorCode: Code {
    switch self {
    case .malformed:
      return .malformed
    case .rejected:
      return .rejected
    }
  }
}

private enum PipelineSourceError: Error, ErrorCodeProviding, Sendable {
  enum Code: String, ErrorCode {
    static let domain = "com.example.event-pipeline.source"

    case disconnected
  }

  case disconnected

  var errorCode: Code {
    .disconnected
  }
}

private struct EventPipelineFailure: Error, ErrorCodeProviding, ErrorPresentationProviding,
  ErrorTreeProviding
{
  struct Child: Sendable {
    let index: Int
    let traceID: String
    let error: any Error
  }

  enum Code: String, ErrorCode {
    static let domain = "com.example.event-pipeline"

    case failed
  }

  enum Context {
    static let eventIndex = ErrorContext.Key<Int>("event.index", privacy: .public)
    static let traceID = ErrorContext.Key<String>("trace.id", privacy: .public)
  }

  let sourceFailure: (any Error)?
  let children: [Child]

  var errorCode: Code {
    .failed
  }

  var errorPresentation: ErrorPresentation {
    ErrorPresentation(message: "The event pipeline failed.")
  }

  var errorTree: ErrorTree {
    var relations = children.map { child in
      ErrorRelation(
        .concurrent,
        to: child.error,
        context: [
          .init(key: Context.eventIndex, value: child.index),
          .init(key: Context.traceID, value: child.traceID),
        ]
      )
    }

    if let sourceFailure {
      relations.insert(ErrorRelation(.cause, to: sourceFailure), at: 0)
    }

    return ErrorTree(self, relations: relations)
  }
}

private actor EventPipeline {
  func consume(
    _ events: AsyncThrowingStream<PipelineEvent, any Error>
  ) async -> ErrorReport {
    var sourceFailure: (any Error)?

    let children = await withTaskGroup(
      of: EventPipelineFailure.Child?.self,
      returning: [EventPipelineFailure.Child].self
    ) { group in
      do {
        for try await event in events {
          group.addTask {
            await self.process(event)
          }
        }
      } catch is CancellationError {
        group.cancelAll()
      } catch {
        sourceFailure = error
      }

      var failures: [EventPipelineFailure.Child] = []

      for await failure in group {
        if let failure {
          failures.append(failure)
        }
      }

      return failures.sorted { $0.index < $1.index }
    }

    // The task-local observation reaches this actor call and is captured by
    // the report's default argument at the actual observation boundary.
    return ErrorReport(
      EventPipelineFailure(
        sourceFailure: sourceFailure,
        children: children
      )
    )
  }

  nonisolated private func process(
    _ event: PipelineEvent
  ) async -> EventPipelineFailure.Child? {
    await Task.yield()

    do {
      switch event.index {
      case 0:
        return nil
      case 1:
        throw PipelineItemError.malformed
      case 2:
        throw CancellationError()
      default:
        throw PipelineItemError.rejected
      }
    } catch {
      guard !ErrorReport(error).isCancellation else {
        return nil
      }

      return EventPipelineFailure.Child(
        index: event.index,
        traceID: ErrorObservation.current.context[EventPipelineFailure.Context.traceID]
          ?? "missing-task-local-trace",
        error: error
      )
    }
  }
}

@Suite
struct ActorAsyncSequenceErrorHandlingExample {
  @Test
  func taskLocalObservationFlowsThroughAnActorAndChildTasks() async throws {
    let stream = AsyncThrowingStream<PipelineEvent, any Error> { continuation in
      for index in 0..<4 {
        continuation.yield(PipelineEvent(index: index))
      }

      continuation.finish(throwing: PipelineSourceError.disconnected)
    }
    let observation = ErrorObservation(
      scenario: .init("event-pipeline.consume"),
      context: [
        .init(
          key: EventPipelineFailure.Context.traceID,
          value: "trace-42"
        )
      ]
    )
    let pipeline = EventPipeline()
    let report = await ErrorObservation.$current.withValue(observation) {
      await pipeline.consume(stream)
    }
    let relationTraceIDs = report.contextOccurrences.compactMap { occurrence -> String? in
      guard occurrence.owner == .relation,
        occurrence.entry.key == ErrorContext.AnyKey(EventPipelineFailure.Context.traceID)
      else {
        return nil
      }

      return String(errorContextValue: occurrence.entry.value)
    }

    #expect(report.observation == observation)
    #expect(report.causeIdentities.map(\.code) == ["failed", "disconnected"])
    #expect(report.identities(relatedBy: .concurrent).map(\.code) == ["malformed", "rejected"])
    #expect(relationTraceIDs == ["trace-42", "trace-42"])
    #expect(!report.identities.map(\.code).contains("CancellationError"))
  }

  @Test
  func detachedTasksRequireExplicitObservationForwarding() async {
    let observation = ErrorObservation(scenario: .init("detached-work"))
    let values = await ErrorObservation.$current.withValue(observation) {
      let inherited = Task {
        ErrorObservation.current.scenario
      }
      let detached = Task.detached {
        ErrorObservation.current.scenario
      }

      return await (inherited.value, detached.value)
    }

    #expect(values.0 == observation.scenario)
    #expect(values.1 == nil)
  }
}
