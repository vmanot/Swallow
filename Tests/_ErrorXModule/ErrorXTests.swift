//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import Testing

@testable import ErrorX

@Suite
struct ErrorXTests {
  @Test
  func explicitIdentityIsPayloadIndependent() {
    let first = PaymentError.declined(processorCode: "do-not-log")
    let second = PaymentError.declined(processorCode: "different")

    #expect(ErrorIdentity(first) == ErrorIdentity(second))
    #expect(ErrorIdentity(first)?.domain == "dev.vmanot.tests.payments")
    #expect(ErrorIdentity(first)?.code == "card.declined")
  }

  @Test
  func typeErasedContextKeysAreStringLiteralExpressible() {
    let key: ErrorContext.AnyKey = "attempt.index"

    #expect(key == ErrorContext.AnyKey("attempt.index"))
    #expect(key.description == "attempt.index")
  }

  @Test
  func erasedCodePreservesItsBaseAndComparesByIdentity() {
    let code = AnyErrorCode(PaymentError.Code.cardDeclined)

    #expect(code.base as? PaymentError.Code == .cardDeclined)
    #expect(code.identifier == "card.declined")
    #expect(code == AnyErrorCode(EquivalentPaymentCode.cardDeclined))
    #expect(Set([code, AnyErrorCode(EquivalentPaymentCode.cardDeclined)]).count == 1)
  }

  @Test
  func reportAggregatesIdentityPresentationContextAndObservation() {
    let error: PaymentError = .declined(processorCode: "42")
    let report: ErrorReport = ErrorReport(
      error,
      observation: .init(
        sourceLocation: .unavailable,
        context: [
          .init(key: TestContext.requestID, value: "req-1")
        ]
      )
    )

    #expect(report.error as? PaymentError == error)
    #expect(report.primaryIdentity?.code == "card.declined")
    #expect(report.identities.map(\.code) == ["card.declined"])
    #expect(report.presentation?.message == "Card declined")
    #expect(report.context.map(\.key.name).contains("processor.code"))
    #expect(report.context.map(\.key.name).contains("request.id"))
    #expect(report.context[PaymentDiagnostics.Context.processorCode] == "42")
    #expect(report.context[TestContext.requestID] == "req-1")
  }

  @Test
  func flattenedContextUsesTheSameFirstOccurrenceAsTypedLookup() throws {
    let report = ErrorReport(
      PaymentError.declined(processorCode: "error-value"),
      observation: .init(
        context: [
          .init(
            key: PaymentDiagnostics.Context.processorCode,
            value: "observation-value",
            privacy: .private
          )
        ]
      )
    )
    let nsError = NSError(
      report,
      contextProjection: .diagnostic
    )
    let exportedContext = try #require(
      nsError.userInfo[ErrorReport.UserInfoKey.context] as? [String: String]
    )

    #expect(report.context[PaymentDiagnostics.Context.processorCode] == "error-value")
    #expect(exportedContext[PaymentDiagnostics.Context.processorCode.name] == "error-value")
  }

  @Test
  func reportPreservesEveryExplicitIdentityInPrimaryChain() {
    let root: PaymentError = .timeout
    let wrapped: IdentityWrappingPaymentError = .init(cause: root)
    let report: ErrorReport = ErrorReport(wrapped)

    #expect(report.primaryIdentity == IdentityWrappingPaymentError.Code.wrapperFailed.identity)
    #expect(
      report.identities == [
        IdentityWrappingPaymentError.Code.wrapperFailed.identity,
        PaymentError.Code.networkTimeout.identity,
      ])
    #expect(report.causeIdentities == report.identities)
    #expect(
      report.identityOccurrences.map(\.relationPath) == [
        [],
        [.cause],
      ])
    #expect(report.contains(PaymentError.Code.networkTimeout.identity))
    #expect(report.firstError(of: PaymentError.self) == .timeout)
    #expect(report.contains(PaymentError.self))
  }

  @Test
  func transparentWrapperCyclesAreBounded() {
    let error = CyclicTransparentError()
    let report = ErrorReport(error)

    #expect(report.causeChain.count == 1)
    #expect(report.firstError(of: CyclicTransparentError.self) === error)
  }

  @Test
  func repeatedReferenceFailuresRemainDistinctOccurrences() {
    let failure = NSError(domain: "dev.vmanot.tests.repeated", code: 7)
    let report = ErrorReport(RepeatedReferenceFailure(failure: failure))

    #expect(
      report.identities.map(\.description) == [
        "dev.vmanot.tests.repeated.7",
        "dev.vmanot.tests.repeated.7",
      ])
    #expect(report.identityOccurrences.map(\.path) == [[0], [1]])
    #expect(report.errors(of: NSError.self).count == 2)
  }

  @Test
  func explicitErrorTreesAreNotSilentlyTruncated() throws {
    var tree = ErrorTree(PaymentError.timeout)

    for _ in 0..<80 {
      tree = ErrorTree(
        OpaqueUnderlyingError(),
        relations: [ErrorRelation(.cleanup, to: tree)]
      )
    }

    let report = ErrorReport(ExplicitErrorTreeError(errorTree: tree))
    let occurrence = try #require(report.identityOccurrences.first)

    #expect(occurrence.identity == PaymentError.Code.networkTimeout.identity)
    #expect(occurrence.relationPath.count == 80)
  }

  @Test
  func explicitCauseChainsAreNotSilentlyTruncated() throws {
    var tree = ErrorTree(PaymentError.timeout)

    for _ in 0..<80 {
      tree = ErrorTree(
        OpaqueUnderlyingError(),
        relations: [ErrorRelation(.cause, to: tree)]
      )
    }

    let error = ExplicitErrorTreeError(errorTree: tree)
    let report = ErrorReport(error)

    #expect(ErrorCauseChain(error).count == 81)
    #expect(report.causeChain.count == 81)

    var cocoaError = NSError(report)
    var cocoaCauseCount = 1

    while let cause = cocoaError.userInfo[NSUnderlyingErrorKey] as? NSError {
      cocoaCauseCount += 1
      cocoaError = cause
    }

    #expect(cocoaCauseCount == 81)
  }

  @Test
  func primaryIdentityComesFromThePrimaryCauseChain() {
    let primaryCause = PaymentError.timeout
    let secondaryComponent = PaymentError.declined(processorCode: "do-not-log")
    let intermediate = ErrorTree(
      OpaqueUnderlyingError(),
      relations: [
        ErrorRelation(.component, to: secondaryComponent),
        ErrorRelation(.cause, to: primaryCause),
      ]
    )
    let tree = ErrorTree(
      OpaqueUnderlyingError(),
      relations: [ErrorRelation(.cause, to: intermediate)]
    )
    let report = ErrorReport(ExplicitErrorTreeError(errorTree: tree))

    #expect(report.primaryIdentity == PaymentError.Code.networkTimeout.identity)
    #expect(report.identities.first == PaymentError.Code.cardDeclined.identity)
  }

  @Test
  func nsErrorStopsAtCauseCycles() throws {
    let first = CyclicCauseError()
    let second = CyclicCauseError()
    first.underlyingError = second
    second.underlyingError = first

    let nsError = NSError(first)
    let nested = try #require(nsError.userInfo[NSUnderlyingErrorKey] as? NSError)

    #expect(nested.userInfo[NSUnderlyingErrorKey] == nil)
  }

  @Test
  func reportPreservesComposedFailureStructureAndScenario() throws {
    let error = CheckoutSubmissionFailure.submitFailed(
      payment: .declined(processorCode: "do-not-log"),
      inventory: .reservationExpired,
      cleanup: .releaseHoldFailed
    )
    let report = ErrorReport(
      error,
      observation: .init(
        scenario: CheckoutScenarios.submitFailed
      )
    )

    #expect(report.observation.scenario?.identifier == "checkout.submit_failed")
    #expect(report.primaryIdentity == CheckoutSubmissionFailure.Code.submitFailed.identity)
    #expect(
      report.causeIdentities == [
        CheckoutSubmissionFailure.Code.submitFailed.identity,
        PaymentError.Code.cardDeclined.identity,
      ])
    #expect(
      report.identities == [
        CheckoutSubmissionFailure.Code.submitFailed.identity,
        PaymentError.Code.cardDeclined.identity,
        InventoryFailureError.Code.reservationExpired.identity,
        CleanupFailureError.Code.releaseHoldFailed.identity,
      ])
    #expect(
      report.identityOccurrences.map(\.relationPath) == [
        [],
        [.translatedFrom],
        [.concurrent],
        [.suppressed],
      ])
    #expect(report.context[TestCheckoutDiagnostics.Context.cleanupPhase] == "release-hold")
    #expect(report.contextOccurrences.map(\.entry.key.name).contains("cleanup.phase"))
    #expect(report.contains(InventoryFailureError.self))
    #expect(report.firstError(of: CleanupFailureError.self) == .releaseHoldFailed)
  }

  @Test
  func detailedDiagnosticDescriptionRendersFailureRelations() {
    let error = CheckoutSubmissionFailure.submitFailed(
      payment: .declined(processorCode: "do-not-log"),
      inventory: .reservationExpired,
      cleanup: .releaseHoldFailed
    )
    let description = error.diagnosticDescription(
      observation: .init(scenario: CheckoutScenarios.submitFailed),
      style: .detailed
    )

    #expect(description.contains("Scenario: checkout.submit_failed"))
    #expect(description.contains("Error tree:"))
    #expect(description.contains("- translated-from"))
    #expect(description.contains("- concurrent"))
    #expect(description.contains("- suppressed"))
  }

  @Test
  func nsErrorIncludesScenarioAndComposedIdentities() throws {
    let error = CheckoutSubmissionFailure.submitFailed(
      payment: .declined(processorCode: "do-not-log"),
      inventory: .reservationExpired,
      cleanup: .releaseHoldFailed
    )
    let nsError = NSError(
      error,
      observation: .init(scenario: CheckoutScenarios.submitFailed)
    )

    #expect(nsError.domain == "dev.vmanot.tests.checkout")
    #expect(
      nsError.userInfo[ErrorReport.UserInfoKey.scenario] as? String == "checkout.submit_failed")
    #expect(
      nsError.userInfo[ErrorReport.UserInfoKey.identities] as? [String] == [
        "dev.vmanot.tests.checkout.checkout.submit_failed",
        "dev.vmanot.tests.payments.card.declined",
        "dev.vmanot.tests.inventory.inventory.reservation_expired",
        "dev.vmanot.tests.cleanup.cleanup.release_hold_failed",
      ])

    let occurrences = try #require(
      nsError.userInfo[ErrorReport.UserInfoKey.identityOccurrences] as? [[String: Any]])

    #expect(occurrences.count == 4)
    #expect(occurrences[3]["relationPath"] as? [String] == ["suppressed"])
  }

  @Test
  func diagnosticDescriptionProvidesReportBackedCatchBoundaryText() {
    let error = PaymentError.declined(processorCode: "42")

    #expect(
      error.diagnosticDescription() == "[dev.vmanot.tests.payments.card.declined] Card declined"
    )
  }

  @Test
  func detailedDiagnosticDescriptionIncludesContextAndCauseChain() {
    let root = PaymentError.declined(processorCode: "42")
    let wrapped = WrappedPaymentError(cause: root)
    let description = wrapped.diagnosticDescription(
      observation: .init(
        context: [
          .init(key: TestContext.requestID, value: "req-1")
        ]
      ),
      style: .detailed,
      contextProjection: .diagnostic
    )

    #expect(description.contains("[dev.vmanot.tests.payments.card.declined] Card declined"))
    #expect(description.contains("Context:"))
    #expect(description.contains("- processor.code: 42"))
    #expect(description.contains("- request.id: req-1"))
    #expect(description.contains("Cause chain:"))
    #expect(description.contains("WrappedPaymentError"))
    #expect(description.contains("PaymentError"))
  }

  @Test
  func detailedDiagnosticDescriptionUsesPublicContextProjectionByDefault() {
    let error = PaymentError.declined(processorCode: "42")
    let description = error.diagnosticDescription(style: .detailed)

    #expect(!description.contains("processor.code"))
    #expect(!description.contains("42"))
  }

  @Test
  func nsErrorUsesPublicContextProjectionByDefault() {
    let error = PaymentError.declined(processorCode: "42")
    let nsError = NSError(error)

    #expect(nsError.userInfo[ErrorReport.UserInfoKey.context] == nil)
  }

  @Test
  func nsErrorRebuildsReservedUserInfoKeys() {
    let error = NSError(
      domain: "dev.vmanot.tests.reserved-keys",
      code: 9,
      userInfo: [
        ErrorReport.UserInfoKey.context: ["secret": "do-not-preserve"],
        ErrorReport.UserInfoKey.identities: ["spoofed.identity"],
      ]
    )
    let nsError = NSError(error)

    #expect(nsError.userInfo[ErrorReport.UserInfoKey.context] == nil)
    #expect(
      nsError.userInfo[ErrorReport.UserInfoKey.identities] as? [String]
        == ["dev.vmanot.tests.reserved-keys.9"]
    )
  }

  @Test
  func nsErrorPreservesModeledPrimaryCause() throws {
    let error = MacroWrappedPaymentError.boundary(
      underlying: .declined(processorCode: "42")
    )
    let nsError = NSError(error)
    let underlyingError = try #require(nsError.userInfo[NSUnderlyingErrorKey] as? NSError)

    #expect(underlyingError.domain == "dev.vmanot.tests.payments")
    #expect(underlyingError.userInfo[ErrorReport.UserInfoKey.code] as? String == "card.declined")
  }

  @Test
  func diagnosticProjectionStillDoesNotExposeSecrets() {
    let report = ErrorReport(
      PaymentError.timeout,
      observation: .init(
        context: [
          .init(key: "api.token", value: "secret-token", privacy: .secret),
          .init(key: "request.url", value: "https://example.com/private", privacy: .private),
          .init(key: "http.status", value: 401, privacy: .public),
        ]
      )
    )

    #expect(
      report.context.projected(using: .diagnostic).map(\.key.name) == [
        "request.url", "http.status",
      ])
    #expect(
      report.context.projected(using: .diagnostic).values(for: "request.url").first
        == .string("https://example.com/private"))
    #expect(report.context.projected().values(for: "http.status").first == .integer(401))
    #expect(report.context.projected(using: .diagnostic).values(for: "api.token").isEmpty)
    #expect(
      report.context.projected(
        using: .init(visibility: .diagnostic, redaction: .placeholder)
      ).map(\.value) == [
        .redacted(.secret),
        .string("https://example.com/private"),
        .integer(401),
      ]
    )
  }

  @Test
  func redactedPlaceholdersAreOptInAtEveryProjectionLevel() {
    let entry = ErrorContext.Entry(
      key: "access.token",
      value: "do-not-export",
      privacy: .sensitive
    )

    #expect(entry.projected(using: .includingPrivate) == nil)
    #expect(
      entry.projected(
        using: .init(visibility: .includingPrivate, redaction: .placeholder)
      )?.value == .redacted(.sensitive)
    )
  }

  @Test
  func primaryCauseChainTraversesExplicitUnderlyingErrors() {
    let root = PaymentError.timeout
    let wrapped = WrappedPaymentError(cause: root)

    #expect(
      ErrorCauseChain(wrapped).map { String(describing: Swift.type(of: $0)) } == [
        String(describing: WrappedPaymentError.self),
        String(describing: PaymentError.self),
      ])
    #expect(ErrorCauseChain(wrapped).count == 2)
  }

  @Test
  func nsErrorPreservesStringCodeWhenIntegerCodeIsUnavailable() {
    let nsError = NSError(UncatalogedPaymentError.timeout)

    #expect(nsError.domain == "dev.vmanot.tests.uncataloged-payments")
    #expect(nsError.code == 0)
    #expect(nsError.userInfo[ErrorReport.UserInfoKey.code] as? String == "network.timeout")
    #expect(nsError.userInfo[NSLocalizedDescriptionKey] as? String == "Network timeout")
  }

  @Test
  func nsErrorDoesNotInventIntegerCodesFromCatalogOrder() {
    let nsError = NSError(CatalogedPaymentError.timeout)
    let secondNSError = NSError(CatalogedRefundError.timeout)

    #expect(nsError.domain == "dev.vmanot.tests.cataloged-payments")
    #expect(nsError.code == 0)
    #expect(secondNSError.code == 0)
    #expect(nsError.userInfo[ErrorReport.UserInfoKey.code] as? String == "network.timeout")
  }

  @Test
  func macrosSynthesizeDomainCodeAndContextKeyIdentifiers() {
    #expect(MacroPaymentCode.domain == "dev.vmanot.tests.macro-payments")
    #expect(MacroPaymentCode.cardDeclined.identifier == "card.declined")
    #expect(MacroPaymentCode.cardDeclined.identity.domain == "dev.vmanot.tests.macro-payments")
    #expect(MacroPaymentContext.processorCode.name == "processor.code")
    #expect(MacroPaymentContext.processorCode.defaultPrivacy == .sensitive)
  }

  @Test
  func caseOnlyErrorCodeCatalogUsesCaseNamesAsStableIdentifiers() {
    #expect(
      CaseOnlyCatalogDiagnostics.Codes.unsupportedFileType.identifier == "unsupportedFileType")
    #expect(
      CaseOnlyCatalogDiagnostics.Codes.invalidRecord.identity.domain
        == "dev.vmanot.tests.case-only-catalog")
  }

  @Test
  func macrosPreserveEscapedLiteralsAndBacktickedCaseNames() {
    let error = EscapedSyntaxDiagnostics.Failure.`default`(value: "visible")
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.domain == #"dev.example."quoted"\path"#)
    #expect(report.primaryIdentity?.code == "default")
    #expect(report.presentation?.message == #"Summary "quoted" \ path"#)
    #expect(
      report.context[EscapedSyntaxDiagnostics.Context.`default`] == "visible"
    )
  }

  @Test
  func errorModelMacroSynthesizesPresentationRecoveryAndCauseDescriptors() {
    let error = MacroWrappedPaymentError.boundary(underlying: .timeout)
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.code == "macro.boundary_failed")
    #expect(
      report.identities.map(\.code) == [
        "macro.boundary_failed",
        "network.timeout",
      ])
    #expect(report.presentation?.message == "Macro boundary failed")
    #expect(
      report.presentation?.failureReason
        == "A typed boundary preserved the underlying payment failure.")
    #expect(report.presentation?.helpAnchor == "https://example.com/payments/help")
    #expect(
      report.recoveryOptions.map(\.title) == [
        "Retry the payment boundary."
      ])
    #expect(
      report.recoveryOptions.first?.explanation
        == "Use this when the processor failure is temporary.")
    #expect(error._resolvedErrorDescriptor?.underlyingError as? PaymentError == .timeout)
    #expect(ErrorCauseChain(error).count == 2)
  }

  @Test
  func authoredDescriptorRecoveryTakesPrecedenceOverManualFallback() {
    let report = ErrorReport(DescriptorRecoveryPrecedenceError.failed)

    #expect(report.recoveryOptions.map(\.title) == ["Descriptor recovery"])
  }

  @Test
  func blankDescriptorPresentationDoesNotBlockManualFallback() {
    let report = ErrorReport(BlankDescriptorPresentationError())

    #expect(report.presentation?.message == "Manual presentation")
  }

  @Test
  func causeRemainsInErrorTreeAlongsideRelatedFailures() {
    let error = PaymentBoundaryFailure.failed(
      cause: .timeout,
      suppressed: .declined(processorCode: "do-not-log")
    )
    let report = ErrorReport(error)

    #expect(
      report.identities.map(\.code) == [
        "boundary.failed",
        "network.timeout",
        "card.declined",
      ])
    #expect(
      report.identityOccurrences.map(\.relationPath) == [
        [],
        [.cause],
        [.suppressed],
      ])
    #expect(
      report.causeIdentities.map(\.code) == [
        "boundary.failed",
        "network.timeout",
      ])
  }

  @Test
  func errorModelDoesNotImposeHashableOnRuntimeErrors() {
    let error: RuntimePayloadError = .executionFailed(
      underlying: OpaqueUnderlyingError()
    )
    let report: ErrorReport = ErrorReport(error)

    #expect(report.primaryIdentity?.code == "runtime.execution_failed")
    #expect(report.presentation?.message == "Runtime execution failed")
  }

  @Test
  func errorContextCanIncludeReusableContents() {
    let snapshot: CommandLineInvocationSnapshot = .init(
      toolName: "swiftc",
      sourceKind: "modeledInvocation",
      commandLine: "swiftc -typecheck Sources/main.swift",
      exitStatus: 1
    )
    let error: CommandLineInvocationError = .invocationFailed(snapshot: snapshot)
    let report: ErrorReport = ErrorReport(error)

    #expect(report.context[CommandLineErrorDiagnostics.Context.toolName] == "swiftc")
    #expect(report.context[CommandLineErrorDiagnostics.Context.sourceKind] == "modeledInvocation")
    #expect(report.context[CommandLineErrorDiagnostics.Context.exitStatus] == 1)
    #expect(
      report.context[CommandLineErrorDiagnostics.Context.commandLine]
        == "swiftc -typecheck Sources/main.swift")
    #expect(report.context.projected()[CommandLineErrorDiagnostics.Context.commandLine] == nil)
  }

  @Test
  func reportPreservesItsObservationScenario() {
    let report = ErrorReport(
      PaymentError.timeout, observation: .init(scenario: MacroCheckoutScenarios.submitFailed))

    #expect(report.observation.scenario?.identifier == "macro.checkout.submit_failed")
    #expect(report.primaryIdentity?.code == "network.timeout")
  }

  @Test
  func literalCodeProvidesStableIdentity() {
    let report = ErrorReport(LiteralCodeError.failed)

    #expect(report.primaryIdentity?.domain == "dev.vmanot.tests.literal-code")
    #expect(report.primaryIdentity?.code == "literal.failed")
    #expect(
      LiteralCodeError.failed.diagnosticDescription()
        == "[dev.vmanot.tests.literal-code.literal.failed]")
  }

  @Test
  func typedContextKeysDefaultToPrivate() {
    let key = ErrorContext.Key<String>("request.url")

    #expect(key.defaultPrivacy == .private)
  }
}

@ErrorCodeCatalog(domain: "dev.vmanot.tests.macro-payments")
private enum MacroPaymentCode: String {
  case cardDeclined = "card.declined"
}

private enum MacroPaymentContext {
  static let processorCode = ErrorContext.Key<String>("processor.code", privacy: .sensitive)
}

private enum MacroCheckoutScenarios {
  static let submitFailed = ErrorScenario("macro.checkout.submit_failed")
}

private enum CaseOnlyCatalogDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.case-only-catalog")
  enum Codes {
    case unsupportedFileType
    case invalidRecord
  }
}

private enum EscapedSyntaxDiagnostics {
  @ErrorCodeCatalog(domain: #"dev.example."quoted"\path"#)
  enum Codes {
    case `default`
  }

  enum Context {
    static let `default` = ErrorContext.Key<String>(#"request."identifier"\path"#, privacy: .public)
  }

  @ErrorModel
  enum Failure {
    @ErrorCode(Codes.`default`, message: #"Summary "quoted" \ path"#)
    @ErrorContext(Context.`default`, from: "value")
    case `default`(value: String)
  }
}

@ErrorModel(domain: "dev.vmanot.tests.macro-wrapping")
private enum MacroWrappedPaymentError {
  @ErrorCode(
    "macro.boundary_failed",
    message: "Macro boundary failed",
    failureReason: "A typed boundary preserved the underlying payment failure.",
    helpAnchor: "https://example.com/payments/help"
  )
  @ErrorRecoveryOption(
    "Retry the payment boundary.",
    explanation: "Use this when the processor failure is temporary."
  )
  @ErrorCause("underlying")
  case boundary(underlying: PaymentError)
}

@ErrorModel(domain: "dev.vmanot.tests.cause-and-related")
private enum PaymentBoundaryFailure {
  @ErrorCode("boundary.failed")
  @ErrorCause("cause")
  @ErrorRelation(.suppressed, error: "suppressed")
  case failed(cause: PaymentError, suppressed: PaymentError)
}

@ErrorModel(domain: "dev.vmanot.tests.recovery-precedence")
private enum DescriptorRecoveryPrecedenceError: ErrorRecoveryProviding {
  @ErrorCode("failed")
  @ErrorRecoveryOption("Descriptor recovery")
  case failed

  var errorRecoveryOptions: [ErrorRecoveryOption] {
    [.init(title: "Manual recovery")]
  }
}

private struct BlankDescriptorPresentationError: Swift.Error, _ModeledError,
  ErrorPresentationProviding
{
  enum Code: String, ErrorCode {
    case failed

    static var domain: String {
      "dev.vmanot.tests.blank-presentation"
    }
  }

  static var _errorDescriptor: _ErrorDescriptor<Self> {
    _ErrorDescriptor { _ in
      _ResolvedErrorDescriptor(
        code: AnyErrorCode(Code.failed),
        presentation: .init(message: "")
      )
    }
  }

  var errorPresentation: ErrorPresentation {
    .init(message: "Manual presentation")
  }
}

@ErrorModel(domain: "dev.vmanot.tests.literal-code")
private enum LiteralCodeError {
  @ErrorCode("literal.failed")
  case failed
}

@ErrorModel(domain: "dev.vmanot.tests.runtime-payload")
private enum RuntimePayloadError {
  @ErrorCode("runtime.execution_failed", message: "Runtime execution failed")
  case executionFailed(underlying: any Swift.Error)
}

private struct OpaqueUnderlyingError: Swift.Error {

}

private final class CyclicTransparentError: Swift.Error, TransparentError, @unchecked Sendable {
  var wrappedError: any Swift.Error {
    self
  }
}

private final class CyclicCauseError: Swift.Error, ErrorCauseProviding, CustomReflectable,
  @unchecked Sendable
{
  var underlyingError: (any Swift.Error)?

  var customMirror: Mirror {
    Mirror(self, children: [:], displayStyle: .struct)
  }
}

private struct RepeatedReferenceFailure: Swift.Error, ErrorTreeProviding {
  var failure: NSError

  var errorTree: ErrorTree {
    ErrorTree(
      self,
      relations: [
        ErrorRelation(.concurrent, to: failure),
        ErrorRelation(.concurrent, to: failure),
      ]
    )
  }
}

private struct ExplicitErrorTreeError: Swift.Error, ErrorTreeProviding {
  let errorTree: ErrorTree
}

private enum CommandLineErrorDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.command-line")
  enum Codes: String {
    case invocationFailed = "command.invocation_failed"
  }

  enum Context {
    static let toolName = ErrorContext.Key<String>("tool.name", privacy: .public)

    static let sourceKind = ErrorContext.Key<String>("execution.source_kind", privacy: .public)

    static let commandLine = ErrorContext.Key<String>("command.line", privacy: .private)

    static let exitStatus = ErrorContext.Key<Int>("process.exit_status", privacy: .public)
  }
}

private struct CommandLineInvocationSnapshot: Hashable, Sendable, ErrorContextProviding {
  var toolName: String
  var sourceKind: String
  var commandLine: String
  var exitStatus: Int

  var errorContext: ErrorContext {
    [
      ErrorContext.Entry(key: CommandLineErrorDiagnostics.Context.toolName, value: toolName),
      ErrorContext.Entry(key: CommandLineErrorDiagnostics.Context.sourceKind, value: sourceKind),
      ErrorContext.Entry(key: CommandLineErrorDiagnostics.Context.commandLine, value: commandLine),
      ErrorContext.Entry(key: CommandLineErrorDiagnostics.Context.exitStatus, value: exitStatus),
    ]
  }
}

@ErrorModel
private enum CommandLineInvocationError {
  @ErrorCode(
    CommandLineErrorDiagnostics.Codes.invocationFailed, message: "Command invocation failed")
  @ErrorContext(contentsOf: "snapshot")
  case invocationFailed(snapshot: CommandLineInvocationSnapshot)
}

private enum PaymentDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.payments")
  enum Codes: String {
    case cardDeclined = "card.declined"
    case networkTimeout = "network.timeout"
  }

  enum Context {
    static let processorCode = ErrorContext.Key<String>("processor.code", privacy: .private)
  }

  @ErrorModel
  enum PaymentError: Equatable {
    @ErrorCode(Codes.cardDeclined, message: "Card declined")
    @ErrorContext(Context.processorCode)
    case declined(processorCode: String)

    @ErrorCode(Codes.networkTimeout, message: "Network timeout")
    case timeout
  }
}

private typealias PaymentError = PaymentDiagnostics.PaymentError

private enum EquivalentPaymentCode: String, ErrorCode {
  case cardDeclined = "card.declined"

  static let domain = "dev.vmanot.tests.payments"
}

private enum UncatalogedPaymentError: Hashable, Error, ErrorCodeProviding,
  ErrorPresentationProviding
{
  enum Code: String, ErrorCode {
    case networkTimeout = "network.timeout"

    static var domain: String {
      "dev.vmanot.tests.uncataloged-payments"
    }
  }

  case timeout

  var errorCode: Code {
    .networkTimeout
  }

  var errorPresentation: ErrorPresentation {
    .init(message: "Network timeout")
  }
}

private enum CheckoutScenarios {
  static let submitFailed = ErrorScenario("checkout.submit_failed")
}

private enum TestCheckoutDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.checkout")
  enum Codes: String {
    case submitFailed = "checkout.submit_failed"
  }

  enum Context {
    static let cleanupPhase = ErrorContext.Key<String>("cleanup.phase", privacy: .public)
  }

  @ErrorModel
  enum CheckoutSubmissionFailure: ErrorTreeProviding {
    @ErrorCode(Codes.submitFailed, message: "Checkout failed")
    case submitFailed(
      payment: PaymentError,
      inventory: InventoryFailureError,
      cleanup: CleanupFailureError
    )

    var errorTree: ErrorTree {
      switch self {
      case .submitFailed(let payment, let inventory, let cleanup):
        return ErrorTree(
          self,
          relations: [
            ErrorRelation(.translatedFrom, to: payment),
            ErrorRelation(.concurrent, to: inventory),
            ErrorRelation(
              .suppressed,
              to: cleanup,
              context: [
                .init(
                  key: Context.cleanupPhase,
                  value: "release-hold",
                  privacy: .public
                )
              ]
            ),
          ]
        )
      }
    }
  }
}

private typealias CheckoutSubmissionFailure = TestCheckoutDiagnostics.CheckoutSubmissionFailure

private enum TestInventoryDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.inventory")
  enum Codes: String {
    case reservationExpired = "inventory.reservation_expired"
  }

  @ErrorModel
  enum InventoryFailureError {
    @ErrorCode(Codes.reservationExpired)
    case reservationExpired
  }
}

private typealias InventoryFailureError = TestInventoryDiagnostics.InventoryFailureError

private enum TestCleanupDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.cleanup")
  enum Codes: String {
    case releaseHoldFailed = "cleanup.release_hold_failed"
  }

  @ErrorModel
  enum CleanupFailureError {
    @ErrorCode(Codes.releaseHoldFailed)
    case releaseHoldFailed
  }
}

private typealias CleanupFailureError = TestCleanupDiagnostics.CleanupFailureError

private enum CatalogedPaymentDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.cataloged-payments")
  enum Codes: String {
    case cardDeclined = "card.declined"
    case networkTimeout = "network.timeout"
  }

  @ErrorModel
  enum CatalogedPaymentError {
    @ErrorCode(Codes.cardDeclined)
    case declined

    @ErrorCode(Codes.networkTimeout)
    case timeout
  }

  @ErrorModel
  enum CatalogedRefundError {
    @ErrorCode(Codes.networkTimeout)
    case timeout
  }
}

private typealias CatalogedPaymentError = CatalogedPaymentDiagnostics.CatalogedPaymentError
private typealias CatalogedRefundError = CatalogedPaymentDiagnostics.CatalogedRefundError

private enum TestContext {
  static let attemptIndex = ErrorContext.Key<Int>("attempt.index")
  static let processorCode = ErrorContext.Key<String>("processor.code")
  static let requestID = ErrorContext.Key<String>("request.id")
}

private struct WrappedPaymentError: Error, ErrorCauseProviding {
  let cause: any Error

  var underlyingError: (any Error)? {
    cause
  }
}

private enum WrappingDiagnostics {
  @ErrorCodeCatalog(domain: "dev.vmanot.tests.wrapping")
  enum Codes: String {
    case wrapperFailed = "wrapper.failed"
  }
}

private struct IdentityWrappingPaymentError: Error, ErrorCauseProviding,
  ErrorCodeProviding
{
  typealias Code = WrappingDiagnostics.Codes

  let cause: any Error

  var errorCode: Code {
    .wrapperFailed
  }

  var underlyingError: (any Error)? {
    cause
  }

}
