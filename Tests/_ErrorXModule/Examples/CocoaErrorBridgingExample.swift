//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

private struct CocoaAggregateFailure: Error, ErrorCodeProviding, ErrorPresentationProviding,
  ErrorTreeProviding
{
  enum Code: String, ErrorCode {
    static let domain = "com.example.cocoa-aggregate"

    case failed = "batch.failed"
  }

  let components: [NSError]

  var errorCode: Code {
    .failed
  }

  var errorPresentation: ErrorPresentation {
    ErrorPresentation(message: "The batch operation failed.")
  }

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: components.map { ErrorRelation(.component, to: $0) }
    )
  }
}

private struct CocoaCauseTreeFailure: Error, ErrorCodeProviding, ErrorTreeProviding {
  enum Code: String, ErrorCode {
    static let domain = "com.example.cocoa-cause-tree"

    case failed
  }

  let cause: NSError

  var errorCode: Code {
    .failed
  }

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: [ErrorRelation(.cause, to: cause)]
    )
  }
}

private struct CocoaConflictingCauseFailure: CustomNSError, ErrorTreeProviding {
  static let errorDomain = "com.example.conflicting-cocoa-cause"

  let staleCause: NSError
  let actualCause: NSError

  var errorCode: Int {
    1
  }

  var errorUserInfo: [String: Any] {
    [NSUnderlyingErrorKey: staleCause]
  }

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: [ErrorRelation(.cause, to: actualCause)]
    )
  }
}

private final class CyclicCocoaAggregateError: CustomNSError, @unchecked Sendable {
  static let errorDomain = "com.example.cyclic-cocoa-aggregate"

  var errorCode: Int {
    1
  }

  var errorUserInfo: [String: Any] {
    guard #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *) else {
      return [:]
    }

    return [NSMultipleUnderlyingErrorsKey: [self]]
  }
}

@Suite
struct CocoaErrorBridgingExample {
  @Test
  func aggregateComponentsRoundTripThroughNSMultipleUnderlyingErrorsKey() throws {
    guard #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *) else {
      return
    }

    let database = NSError(domain: "NSPersistentStoreErrorDomain", code: 134_030)
    let file = NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileWriteOutOfSpace.rawValue)
    let report = ErrorReport(CocoaAggregateFailure(components: [database, file]))
    let exported = NSError(report)
    let components = try #require(
      exported.userInfo[NSMultipleUnderlyingErrorsKey] as? [NSError]
    )

    #expect(
      report.identityOccurrences.map(\.relationPath) == [
        [],
        [.component],
        [.component],
      ])
    #expect(components.count == 2)
    #expect(components[0] === database)
    #expect(components[1] === file)
    #expect(exported.userInfo[ErrorReport.UserInfoKey.code] as? String == "batch.failed")
  }

  @Test
  func explicitCauseEdgesBridgeToNSUnderlyingErrorKey() throws {
    let cause = NSError(
      domain: NSURLErrorDomain,
      code: NSURLErrorNotConnectedToInternet
    )
    let report = ErrorReport(CocoaCauseTreeFailure(cause: cause))
    let exported = NSError(report)
    let underlying = try #require(exported.userInfo[NSUnderlyingErrorKey] as? NSError)

    #expect(report.causeChain.count == 2)
    #expect(ErrorCauseChain(CocoaCauseTreeFailure(cause: cause)).count == 2)
    #expect(underlying === cause)
  }

  @Test
  func explicitErrorTreeReplacesConflictingCocoaCausality() throws {
    let stale = NSError(domain: "com.example.stale", code: 1)
    let actual = NSError(domain: "com.example.actual", code: 2)
    let exported = NSError(
      CocoaConflictingCauseFailure(
        staleCause: stale,
        actualCause: actual
      )
    )
    let underlying = try #require(exported.userInfo[NSUnderlyingErrorKey] as? NSError)

    #expect(underlying === actual)
  }

  @Test
  func nativeNSErrorQueriesDoNotCountBridgedSwiftRoots() {
    let first = NSError(domain: "com.example.first", code: 1)
    let second = NSError(domain: "com.example.second", code: 2)
    let report = ErrorReport(CocoaAggregateFailure(components: [first, second]))

    #expect(report.errors(of: NSError.self).count == 2)
  }

  @Test
  func cyclicCocoaAggregatesStopAtTheRepeatedOccurrence() throws {
    guard #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *) else {
      return
    }

    let report = ErrorReport(CyclicCocoaAggregateError())
    let component = try #require(report.errorTree.relations.first)

    #expect(component.kind == .component)
    #expect(component.subtree.relations.isEmpty)
    #expect(report.identityOccurrences.map(\.path) == [[], [0]])
  }
}
