//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing
@testable import _ErrorXModule

@Suite
struct ErrorXTests {
    @Test
    func explicitIdentityIsPayloadIndependent() {
        let first = PaymentError.declined(processorCode: "do-not-log")
        let second = PaymentError.declined(processorCode: "different")

        #expect(first._errorIdentity == second._errorIdentity)
        #expect(first._errorIdentity?.domain.rawValue == "dev.vmanot.tests.payments")
        #expect(first._errorIdentity?.code == "card.declined")
    }

    @Test
    func missingDomainIdentifierDoesNotProduceExportIdentity() {
        #expect(UnidentifiedError.broken._errorIdentity == nil)
    }

    @Test
    func traitsCanBeQueriedByConcreteType() {
        let traits: _ErrorTraits = [
            _ErrorIdentityTrait(.init(domain: "dev.vmanot.tests", code: "one")),
            _ErrorContextTrait([
                .init(key: TestErrorContextKey.attemptIndex, value: .int(2))
            ])
        ]

        #expect(traits.first(of: _ErrorIdentityTrait.self)?.identity.code == "one")
        #expect(traits.all(of: _ErrorContextTrait.self).first?.bindings.first?.key.rawValue == "attempt.index")
        #expect(traits.count == 2)
    }

    @Test
    func stringBackedIdentifiersUseSwallowRawAndStringProtocols() throws {
        let domain: _SubsystemDomainIdentifier = "dev.vmanot.tests"
        let key: _ErrorContextBinding.Key = "attempt.index"

        let domainFromString = try #require(_SubsystemDomainIdentifier(stringValue: "dev.vmanot.tests"))
        let keyFromString = try #require(_ErrorContextBinding.Key(stringValue: "attempt.index"))

        #expect(domain.rawValue == "dev.vmanot.tests")
        #expect(domain.stringValue == "dev.vmanot.tests")
        #expect(domainFromString == domain)
        #expect(key.rawValue == "attempt.index")
        #expect(key.stringValue == "attempt.index")
        #expect(keyFromString == key)
    }

    @Test
    func erasedCodeExposesBaseAsSwallowValueConvertible() {
        let code = _AnyErrorCode(PaymentError.Code.cardDeclined)

        #expect(code.value.stableIdentifier == "card.declined")
        #expect(code._unwrapBase().stableIdentifier == "card.declined")
    }

    @Test
    func erasedCodeParticipatesInSwallowTypeErasingCasts() throws {
        let code: _AnyErrorCode = try _castTypeErasingIfNeeded(
            PaymentError.Code.cardDeclined,
            to: _AnyErrorCode.self
        )

        #expect(code.stableIdentifier == "card.declined")
    }

    @Test
    func errorIdentityIsIdentifiableByItself() {
        let identity = _ErrorIdentity(domain: "dev.vmanot.tests", code: "one")

        #expect(identity.id == identity)
    }

    @Test
    func reportAggregatesIdentityPresentationContextAndObservation() {
        let error: PaymentError = .declined(processorCode: "42")
        let report: _ErrorReport = _ErrorReporting.report(
            error,
            observation: .init(
                sourceLocation: .unavailable,
                contextBindings: [
                    .init(key: TestErrorContextKey.requestID, value: .string("req-1"))
                ]
            )
        )

        #expect(report.root.base as? PaymentError == error)
        #expect(report.identity?.code == "card.declined")
        #expect(report.identities.map(\.code) == ["card.declined"])
        #expect(report.presentation?.summary == "Card declined")
        #expect(report.context.map(\.key.rawValue).contains("processor.code"))
        #expect(report.context.map(\.key.rawValue).contains("request.id"))
        #expect(report.contextValue(for: PaymentDiagnostics.Context.processorCode) == .string("42"))
        #expect(report.contextValue(for: TestErrorContextKey.requestID) == .string("req-1"))
        #expect(report.containsContextValue(.string("req-1"), for: TestErrorContextKey.requestID))
    }

    @Test
    func reportMirrorExposesSemanticReadModel() {
        let report = _ErrorReporting.report(PaymentError.declined(processorCode: "42"))
        let labels = Mirror(reflecting: report).children.compactMap(\.label)

        #expect(labels == [
            "root",
            "chain",
            "failureTree",
            "scenario",
            "identity",
            "headlineIdentity",
            "allIdentities",
            "identityOccurrences",
            "failureIdentityOccurrences",
            "failureContextOccurrences",
            "failureDiagnosticLabelOccurrences",
            "diagnosticLabels",
            "traits",
            "presentation",
            "recoverySuggestions",
            "context",
            "observation",
        ])
    }

    @Test
    func reportPreservesEveryExplicitIdentityInPrimaryChain() {
        let root: PaymentError = .timeout
        let wrapped: IdentityWrappingPaymentError = .init(wrapping: AnyError(erasing: root), context: .init())
        let report: _ErrorReport = _ErrorReporting.report(wrapped)

        #expect(report.identity == IdentityWrappingPaymentError.Code.wrapperFailed.identity)
        #expect(report.identities == [
            IdentityWrappingPaymentError.Code.wrapperFailed.identity,
            PaymentError.Code.networkTimeout.identity
        ])
        #expect(report.allIdentities == report.identities)
        #expect(report.identityOccurrences.map(\.chainIndex) == [0, 1])
        #expect(report.failureIdentityOccurrences.map(\.relationRoles) == [
            [.primary],
            [.primary]
        ])
        #expect(report.contains(identity: PaymentError.Code.networkTimeout.identity))
    }

    @Test
    func reportPreservesComposedFailureStructureAndScenario() throws {
        let error = CheckoutSubmissionFailure.submitFailed(
            payment: .declined(processorCode: "do-not-log"),
            inventory: .reservationExpired,
            cleanup: .releaseHoldFailed
        )
        let report = _ErrorReporting.report(
            error,
            observation: .init(
                scenario: .init(CheckoutReportScenario.submitFailed)
            )
        )

        #expect(report.scenario?.stableIdentifier == "checkout.submit_failed")
        #expect(report.headlineIdentity == CheckoutSubmissionFailure.Code.submitFailed.identity)
        #expect(report.identities == [CheckoutSubmissionFailure.Code.submitFailed.identity])
        #expect(report.allIdentities == [
            CheckoutSubmissionFailure.Code.submitFailed.identity,
            PaymentError.Code.cardDeclined.identity,
            InventoryFailureError.Code.reservationExpired.identity,
            CleanupFailureError.Code.releaseHoldFailed.identity
        ])
        #expect(report.failureIdentityOccurrences.map(\.relationRoles) == [
            [.contains],
            [.contains, .translatedFrom],
            [.contains, .parallel],
            [.contains, .suppressed]
        ])
        #expect(report.contextValue(for: TestCheckoutDiagnostics.Context.cleanupPhase) == .string("release-hold"))
        #expect(report.failureContextOccurrences.map(\.context.key.rawValue).contains("cleanup.phase"))
    }

    @Test
    func detailedDiagnosticDescriptionRendersFailureRelations() {
        let error = CheckoutSubmissionFailure.submitFailed(
            payment: .declined(processorCode: "do-not-log"),
            inventory: .reservationExpired,
            cleanup: .releaseHoldFailed
        )
        let description = error._diagnosticDescription(
            observation: .init(scenario: .init(CheckoutReportScenario.submitFailed)),
            detailLevel: .detailed
        )

        #expect(description.contains("Scenario: checkout.submit_failed"))
        #expect(description.contains("Failure tree:"))
        #expect(description.contains("- contains"))
        #expect(description.contains("- translated-from"))
        #expect(description.contains("- parallel"))
        #expect(description.contains("- suppressed"))
    }

    @Test
    func nserrorProjectionIncludesScenarioAndComposedIdentities() throws {
        let error = CheckoutSubmissionFailure.submitFailed(
            payment: .declined(processorCode: "do-not-log"),
            inventory: .reservationExpired,
            cleanup: .releaseHoldFailed
        )
        let representation = error._nsErrorExportRepresentation(
            observation: .init(scenario: .init(CheckoutReportScenario.submitFailed))
        )

        #expect(representation.domain == "dev.vmanot.tests.checkout")
        #expect(representation.userInfo[_NSErrorExportRepresentation.scenarioKey] as? String == "checkout.submit_failed")
        #expect(representation.userInfo[_NSErrorExportRepresentation.identitiesKey] as? [String] == [
            "dev.vmanot.tests.checkout.checkout.submit_failed",
            "dev.vmanot.tests.payments.card.declined",
            "dev.vmanot.tests.inventory.inventory.reservation_expired",
            "dev.vmanot.tests.cleanup.cleanup.release_hold_failed"
        ])

        let occurrences = try #require(representation.userInfo[_NSErrorExportRepresentation.failureIdentityOccurrencesKey] as? [[String: Any]])

        #expect(occurrences.count == 4)
        #expect(occurrences[3]["relationRoles"] as? [String] == ["contains", "suppressed"])
    }

    @Test
    func diagnosticDescriptionProvidesReportBackedCatchBoundaryText() {
        let error = PaymentError.declined(processorCode: "42")

        #expect(
            error._diagnosticDescription() == "[dev.vmanot.tests.payments.card.declined] Card declined"
        )
    }

    @Test
    func detailedDiagnosticDescriptionIncludesContextAndCauseChain() {
        let root = PaymentError.declined(processorCode: "42")
        let wrapped = WrappedPaymentError(wrapping: AnyError(erasing: root), context: .init())
        let description = wrapped._diagnosticDescription(
            observation: .init(
                contextBindings: [
                    .init(key: TestErrorContextKey.requestID, value: .string("req-1"))
                ]
            ),
            detailLevel: .detailed,
            contextProjectionPolicy: .allDiagnostic
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
        let description = error._diagnosticDescription(detailLevel: .detailed)

        #expect(!description.contains("processor.code"))
        #expect(!description.contains("42"))
    }

    @Test
    func nserrorProjectionUsesPublicContextProjectionByDefault() {
        let error = PaymentError.declined(processorCode: "42")
        let representation = error._nsErrorExportRepresentation()

        #expect(representation.userInfo[_NSErrorExportRepresentation.contextKey] == nil)
    }

    @Test
    func allDiagnosticProjectionStillDoesNotExposeSecrets() {
        let report = _ErrorReporting.report(
            PaymentError.timeout,
            observation: .init(
                contextBindings: [
                    .secretValue(key: "api.token", value: .string("secret-token")),
                    .privateValue(key: "request.url", value: .string("https://example.com/private")),
                    .publicValue(key: "http.status", value: .int(401))
                ]
            )
        )

        #expect(report.projectedContext(using: .allDiagnostic).map(\.key.rawValue) == ["request.url", "http.status"])
        #expect(report.projectedContextString(for: "request.url", using: .allDiagnostic) == "https://example.com/private")
        #expect(report.projectedContextInt(for: "http.status") == 401)
        #expect(report.projectedContextString(for: "api.token", using: .allDiagnostic) == nil)
        #expect(
            report.projectedContext(
                using: .allDiagnostic(includingRedactedPlaceholders: true)
            ).map(\.value) == [
                .description("<secret>"),
                .string("https://example.com/private"),
                .int(401)
            ]
        )
    }

    @Test
    func primaryCauseChainTraversesExplicitUnderlyingErrors() {
        let root = PaymentError.timeout
        let wrapped = WrappedPaymentError(wrapping: AnyError(erasing: root), context: .init())

        #expect(wrapped._errorChain.elements.map { String(describing: Swift.type(of: $0.base)) } == [
            String(describing: WrappedPaymentError.self),
            String(describing: PaymentError.self)
        ])
        #expect(wrapped._errorChain.count == 2)
    }

    @Test
    func nserrorProjectionPreservesStringCodeWhenIntegerCodeIsUnavailable() {
        let representation = UncataloguedPaymentError.timeout._nsErrorExportRepresentation()

        #expect(representation.domain == "dev.vmanot.tests.uncatalogued-payments")
        #expect(representation.code == 0)
        #expect(representation.userInfo[_NSErrorExportRepresentation.errorCodeStringKey] as? String == "network.timeout")
        #expect(representation.userInfo[NSLocalizedDescriptionKey] as? String == "Network timeout")
    }

    @Test
    func nserrorProjectionUsesDiscoveredErrorCodeCatalogForIntegerCode() throws {
        let representation = CataloguedPaymentError.timeout._nsErrorExportRepresentation()
        let secondModelRepresentation = CataloguedRefundError.timeout._nsErrorExportRepresentation()

        #expect(representation.domain == "dev.vmanot.tests.catalogued-payments")
        #expect(representation.code == 2)
        #expect(secondModelRepresentation.code == 2)
        #expect(representation.userInfo[_NSErrorExportRepresentation.errorCodeStringKey] as? String == "network.timeout")
        #expect(representation.userInfo[_NSErrorExportRepresentation.errorCodeIntegerKey] as? Int == 2)
        #expect(representation.userInfo[_NSErrorExportRepresentation.errorCodeCatalogKey] as? [String] == [
            "card.declined",
            "network.timeout"
        ])
        #expect(representation.userInfo[_NSErrorExportRepresentation.errorCodeCatalogIdentifierKey] as? String == String(reflecting: CataloguedPaymentError.Code.self))
        #expect(secondModelRepresentation.userInfo[_NSErrorExportRepresentation.errorCodeCatalogIdentifierKey] as? String == String(reflecting: CataloguedPaymentError.Code.self))

        let entries = try #require(representation.userInfo[_NSErrorExportRepresentation.errorCodeCatalogEntriesKey] as? [[String: Any]])

        #expect(entries.count == 2)
        #expect(entries[1]["stableIdentifier"] as? String == "network.timeout")
        #expect(entries[1]["integerCode"] as? Int == 2)
    }

    @Test
    func withErrorTypeUsesExplicitWrappingWhenAvailable() {
        do {
            try _withErrorType(WrappedPaymentError.self) {
                throw PaymentError.timeout
            }

            Issue.record("Expected _withErrorType to throw")
        } catch let error as WrappedPaymentError {
            #expect(error.underlyingError as? PaymentError == .timeout)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func withErrorTypePassesExplicitWrappingContext() {
        let location = SourceCodeLocation(fileID: "Tests/Checkout.swift", function: "submit()", line: 42)

        do {
            try _withErrorType(ContextCapturingPaymentError.self, location: location) {
                throw PaymentError.timeout
            }

            Issue.record("Expected _withErrorType to throw")
        } catch let error as ContextCapturingPaymentError {
            #expect(error.context.location == location)
            #expect(error.underlyingError as? PaymentError == .timeout)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func macrosSynthesizeDomainCodeAndContextKeyIdentifiers() {
        #expect(MacroPaymentDomain().subsystemDomainIdentifier.rawValue == "dev.vmanot.tests.macro-payments")
        #expect(MacroPaymentCode.cardDeclined.stableIdentifier == "card.declined")
        #expect(MacroPaymentCode.cardDeclined.identity.domain.rawValue == "dev.vmanot.tests.macro-payments")
        #expect(MacroPaymentContextKey.processorCode.stableIdentifier == "processor.code")
        #expect(MacroPaymentContextKey.processorCode.privacy == .redacted)
    }

    @Test
    func caseOnlyErrorCodeCatalogUsesCaseNamesAsStableIdentifiers() {
        #expect(CaseOnlyCatalogDiagnostics.Codes.unsupportedFileType.stableIdentifier == "unsupportedFileType")
        #expect(CaseOnlyCatalogDiagnostics.Codes.invalidRecord.identity.domain.rawValue == "dev.vmanot.tests.case-only-catalog")
        #expect(_AnyErrorCodeCatalog(CaseOnlyCatalogDiagnostics.Codes.self).allErrorCodes.map(\.stableIdentifier) == [
            "unsupportedFileType",
            "invalidRecord"
        ])
    }

    @Test
    func errorModelMacroSynthesizesPresentationRecoveryAndCauseDescriptors() {
        let error = MacroWrappedPaymentError.boundary(underlying: .timeout)
        let report = _ErrorReporting.report(error)

        #expect(report.identity?.code == "macro.boundary_failed")
        #expect(report.identities.map(\.code) == [
            "macro.boundary_failed",
            "network.timeout"
        ])
        #expect(report.presentation?.summary == "Macro boundary failed")
        #expect(report.presentation?.reason == "A typed boundary preserved the underlying payment failure.")
        #expect(report.presentation?.helpAnchor == "https://example.com/payments/help")
        #expect(report.recoverySuggestions.map(\.title) == [
            "Retry the payment boundary."
        ])
        #expect(report.recoverySuggestions.first?.explanation == "Use this when the processor failure is temporary.")
        #expect(error._errorDescriptorCase?.underlyingError as? PaymentError == .timeout)
        #expect(error._errorChain.count == 2)
    }

    @Test
    func errorModelCanOptOutOfHashableSynthesisForRuntimeErrors() {
        let error: RuntimeBackedModeledError = .executionFailed(
            underlying: RuntimeBackedUnderlyingError()
        )
        let report: _ErrorReport = _ErrorReporting.report(error)

        #expect(report.identity?.code == "runtime.execution_failed")
        #expect(report.presentation?.summary == "Runtime execution failed")
    }

    @Test
    func errorContextPackSplicesReusableOccurrenceContext() {
        let snapshot: CommandLineInvocationSnapshot = .init(
            toolName: "swiftc",
            sourceKind: "modeledInvocation",
            commandLine: "swiftc -typecheck Sources/main.swift",
            exitStatus: 1
        )
        let error: CommandLineModeledError = .invocationFailed(snapshot: snapshot)
        let report: _ErrorReport = _ErrorReporting.report(error)

        #expect(report.contextValue(for: CommandLineErrorDiagnostics.Context.toolName) == .string("swiftc"))
        #expect(report.contextValue(for: CommandLineErrorDiagnostics.Context.sourceKind) == .string("modeledInvocation"))
        #expect(report.contextValue(for: CommandLineErrorDiagnostics.Context.exitStatus) == .int(1))
        #expect(report.contextValue(for: CommandLineErrorDiagnostics.Context.commandLine) == .string("swiftc -typecheck Sources/main.swift"))
        #expect(report.projectedContextValue(for: CommandLineErrorDiagnostics.Context.commandLine) == nil)
    }

    @Test
    func diagnosticLabelsArePreservedAndProjectedWithPrivacy() throws {
        let error: CommandLineModeledError = .invalidArguments(
            labelMessage: "missing value for -sdk"
        )
        let report: _ErrorReport = _ErrorReporting.report(error)
        let detailed: _ErrorDiagnosticDescription = report._diagnosticDescription(detailLevel: .detailed)
        let nsError: _NSErrorExportRepresentation = .init(report)

        #expect(report.diagnosticLabels.map(\.subject.description) == ["argument[1]"])
        #expect(report.diagnosticLabels(for: .commandLineArgument(index: 1)).map(\.message) == ["missing value for -sdk"])
        #expect(report.failureDiagnosticLabelOccurrences.first?.path == [])
        #expect(detailed.description.contains("Labels:"))
        #expect(detailed.description.contains("argument[1]: missing value for -sdk"))

        let exportedLabels: [[String: Any]] = try #require(
            nsError.userInfo[_NSErrorExportRepresentation.failureDiagnosticLabelOccurrencesKey] as? [[String: Any]]
        )

        #expect(exportedLabels.first?["subject"] as? String == "argument[1]")
        #expect(exportedLabels.first?["message"] as? String == "missing value for -sdk")
    }

    @Test
    func errorScenarioMacroWorksWithReportConvenience() {
        let report = PaymentError.timeout._errorReport(scenario: MacroCheckoutScenario.submitFailed)

        #expect(report.scenario?.stableIdentifier == "macro.checkout.submit_failed")
        #expect(report.identity?.code == "network.timeout")
    }

    @Test
    func legacyErrorCodeCaseMacroStillWorksWithErrorModel() {
        let report = _ErrorReporting.report(LegacyModeledError.failed)

        #expect(report.identity?.domain.rawValue == "dev.vmanot.tests.legacy-modeled-error")
        #expect(report.identity?.code == "legacy.failed")
    }

    @Test
    func typedContextKeysDefaultToPrivate() {
        let key = _TypedErrorContextKey<String>("request.url")

        #expect(key.defaultErrorContextPrivacy == .private)
    }
}

@_ErrorDomain("dev.vmanot.tests.macro-payments")
private struct MacroPaymentDomain {

}

private enum MacroPaymentCode {
    @_ErrorCode("card.declined")
    static var cardDeclined: _ErrorCodeIdentifier<MacroPaymentDomain>
}

private enum MacroPaymentContextKey {
    @_ErrorContextKey("processor.code", privacy: .redacted)
    static var processorCode: _TypedErrorContextKey<String>
}

private enum MacroCheckoutScenario {
    @ErrorScenario("macro.checkout.submit_failed")
    static var submitFailed: _ErrorReportScenarioIdentifier
}

@ErrorDomain("dev.vmanot.tests.case-only-catalog")
private enum CaseOnlyCatalogDiagnostics {
    @ErrorCodeCatalog
    enum Codes {
        case unsupportedFileType
        case invalidRecord
    }
}

@ErrorModel("dev.vmanot.tests.macro-wrapping")
private enum MacroWrappedPaymentError: Hashable, Swift.Error, _ErrorX {
    @ErrorCase("macro.boundary_failed")
    @ErrorSummary("Macro boundary failed")
    @ErrorReason("A typed boundary preserved the underlying payment failure.")
    @ErrorHelp("https://example.com/payments/help")
    @ErrorRecovery(
        "Retry the payment boundary.",
        explanation: "Use this when the processor failure is temporary."
    )
    @ErrorCause(parameter: "underlying")
    case boundary(underlying: PaymentError)
}

@ErrorModel("dev.vmanot.tests.legacy-modeled-error")
private enum LegacyModeledError: Hashable, Swift.Error, _ErrorX {
    @ErrorCode("legacy.failed")
    case failed
}

@ErrorModel("dev.vmanot.tests.runtime-backed", hashable: false)
private enum RuntimeBackedModeledError {
    @ErrorCase("runtime.execution_failed", summary: "Runtime execution failed")
    case executionFailed(underlying: any Swift.Error)
}

private struct RuntimeBackedUnderlyingError: Swift.Error {

}

@ErrorDomain("dev.vmanot.tests.command-line")
private enum CommandLineErrorDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case invocationFailed = "command.invocation_failed"
        case invalidArguments = "command.invalid_arguments"
    }

    enum Context {
        @ErrorContextKey("tool.name", privacy: .public)
        static var toolName: _TypedErrorContextKey<String>

        @ErrorContextKey("execution.source_kind", privacy: .public)
        static var sourceKind: _TypedErrorContextKey<String>

        @ErrorContextKey("command.line", privacy: .private)
        static var commandLine: _TypedErrorContextKey<String>

        @ErrorContextKey("process.exit_status", privacy: .public)
        static var exitStatus: _TypedErrorContextKey<Int>
    }
}

private struct CommandLineInvocationSnapshot: Hashable, Sendable, _ErrorOccurrenceContextRepresentable {
    var toolName: String
    var sourceKind: String
    var commandLine: String
    var exitStatus: Int

    var errorOccurrenceContextBindings: [_ErrorContextBinding] {
        [
            _ErrorContextBinding(key: CommandLineErrorDiagnostics.Context.toolName, value: toolName),
            _ErrorContextBinding(key: CommandLineErrorDiagnostics.Context.sourceKind, value: sourceKind),
            _ErrorContextBinding(key: CommandLineErrorDiagnostics.Context.commandLine, value: commandLine),
            _ErrorContextBinding(key: CommandLineErrorDiagnostics.Context.exitStatus, value: exitStatus)
        ]
    }
}

@ErrorModel(domain: CommandLineErrorDiagnostics.self)
private enum CommandLineModeledError: Hashable, Swift.Error, _ErrorX, _ErrorDiagnosticLabelsRepresentable {
    @ErrorCase(CommandLineErrorDiagnostics.Codes.invocationFailed, summary: "Command invocation failed")
    @ErrorContextPack(parameter: "snapshot")
    case invocationFailed(snapshot: CommandLineInvocationSnapshot)

    @ErrorCase(CommandLineErrorDiagnostics.Codes.invalidArguments, summary: "Command arguments are invalid")
    case invalidArguments(labelMessage: String)

    var errorDiagnosticLabels: [_ErrorDiagnosticLabel] {
        switch self {
            case .invalidArguments(let labelMessage):
                return [
                    _ErrorDiagnosticLabel(
                        subject: .commandLineArgument(index: 1),
                        message: labelMessage
                    )
                ]
            case .invocationFailed:
                return []
        }
    }
}

@ErrorDomain("dev.vmanot.tests.payments")
private enum PaymentDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case cardDeclined = "card.declined"
        case networkTimeout = "network.timeout"
    }

    enum Context {
        @ErrorContextKey("processor.code", privacy: .private)
        static var processorCode: _TypedErrorContextKey<String>
    }

    @ErrorModel(domain: PaymentDiagnostics.self)
    enum PaymentError: Hashable, Swift.Error, _ErrorX {
        @ErrorCase(Codes.cardDeclined, summary: "Card declined")
        @ErrorContext(Context.processorCode)
        case declined(processorCode: String)

        @ErrorCase(Codes.networkTimeout, summary: "Network timeout")
        case timeout
    }
}

private typealias PaymentError = PaymentDiagnostics.PaymentError

@ErrorDomain("dev.vmanot.tests.uncatalogued-payments")
private enum UncataloguedPaymentDomain {

}

private enum UncataloguedPaymentError: Hashable, _ErrorX, _ErrorCodeRepresentable, _ErrorPresentationRepresentable {
    enum Code: String, _ErrorCode {
        case networkTimeout = "network.timeout"

        typealias Domain = UncataloguedPaymentDomain
    }

    case timeout

    var errorCode: Code {
        .networkTimeout
    }

    var errorPresentation: _ErrorPresentation {
        .init(summary: "Network timeout")
    }
}

private enum CheckoutReportScenario: String, _ErrorReportScenario {
    case submitFailed = "checkout.submit_failed"
}

@ErrorDomain("dev.vmanot.tests.checkout")
private enum TestCheckoutDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case submitFailed = "checkout.submit_failed"
    }

    enum Context {
        @ErrorContextKey("cleanup.phase", privacy: .public)
        static var cleanupPhase: _TypedErrorContextKey<String>
    }

    @ErrorModel(domain: TestCheckoutDiagnostics.self)
    enum CheckoutSubmissionFailure: Hashable, Swift.Error, _ErrorX, _ErrorFailureTreeRepresentable {
        @ErrorCase(Codes.submitFailed, summary: "Checkout failed")
        case submitFailed(
            payment: PaymentError,
            inventory: InventoryFailureError,
            cleanup: CleanupFailureError
        )

        var errorFailureTree: _ErrorFailureTree {
            switch self {
                case .submitFailed(let payment, let inventory, let cleanup):
                    return .contains(
                        self,
                        related: [
                            .translatedFrom(.failure(payment)),
                            .parallel([.failure(inventory)]),
                            .suppressed(
                                .failure(cleanup),
                                context: [
                                    .init(
                                        key: Context.cleanupPhase,
                                        value: .string("release-hold"),
                                        privacy: .public
                                    )
                                ]
                            )
                        ]
                    )
            }
        }
    }
}

private typealias CheckoutSubmissionFailure = TestCheckoutDiagnostics.CheckoutSubmissionFailure

@ErrorDomain("dev.vmanot.tests.inventory")
private enum TestInventoryDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case reservationExpired = "inventory.reservation_expired"
    }

    @ErrorModel(domain: TestInventoryDiagnostics.self)
    enum InventoryFailureError: Hashable, Swift.Error, _ErrorX {
        @ErrorCase(Codes.reservationExpired)
        case reservationExpired
    }
}

private typealias InventoryFailureError = TestInventoryDiagnostics.InventoryFailureError

@ErrorDomain("dev.vmanot.tests.cleanup")
private enum TestCleanupDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case releaseHoldFailed = "cleanup.release_hold_failed"
    }

    @ErrorModel(domain: TestCleanupDiagnostics.self)
    enum CleanupFailureError: Hashable, Swift.Error, _ErrorX {
        @ErrorCase(Codes.releaseHoldFailed)
        case releaseHoldFailed
    }
}

private typealias CleanupFailureError = TestCleanupDiagnostics.CleanupFailureError

@ErrorDomain("dev.vmanot.tests.catalogued-payments")
private enum CataloguedPaymentDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case cardDeclined = "card.declined"
        case networkTimeout = "network.timeout"
    }

    @ErrorModel(domain: CataloguedPaymentDiagnostics.self)
    enum CataloguedPaymentError: Hashable, Swift.Error, _ErrorX {
        @ErrorCase(Codes.cardDeclined)
        case declined

        @ErrorCase(Codes.networkTimeout)
        case timeout
    }

    @ErrorModel(domain: CataloguedPaymentDiagnostics.self)
    enum CataloguedRefundError: Hashable, Swift.Error, _ErrorX {
        @ErrorCase(Codes.networkTimeout)
        case timeout
    }
}

private typealias CataloguedPaymentError = CataloguedPaymentDiagnostics.CataloguedPaymentError
private typealias CataloguedRefundError = CataloguedPaymentDiagnostics.CataloguedRefundError

private enum TestErrorContextKey: String, _ErrorOccurrenceContextKey {
    case attemptIndex = "attempt.index"
    case processorCode = "processor.code"
    case requestID = "request.id"
}

private enum UnidentifiedError: Hashable, _ErrorX, _ErrorCodeRepresentable {
    struct Domain: _SubsystemDomain, Initiable {
        init() {

        }
    }

    enum Code: String, _ErrorCode {
        case broken

        typealias Domain = UnidentifiedError.Domain
    }

    case broken

    var errorCode: Code {
        .broken
    }
}

private struct WrappedPaymentError: Hashable, _ErrorWrappingRepresentable {
    let cause: AnyError

    var underlyingError: (any Error)? {
        cause.base
    }

    init(wrapping error: AnyError, context: _ErrorWrappingContext) {
        self.cause = error
    }
}

@ErrorDomain("dev.vmanot.tests.wrapping")
private enum WrappingDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case wrapperFailed = "wrapper.failed"
    }
}

private struct IdentityWrappingPaymentError: Hashable, _ErrorWrappingRepresentable, _ErrorCodeRepresentable {
    typealias Code = WrappingDiagnostics.Codes

    let cause: AnyError

    var errorCode: Code {
        .wrapperFailed
    }

    var underlyingError: (any Error)? {
        cause.base
    }

    init(wrapping error: AnyError, context: _ErrorWrappingContext) {
        self.cause = error
    }
}

private struct ContextCapturingPaymentError: Hashable, _ErrorWrappingRepresentable {
    let cause: AnyError
    let context: _ErrorWrappingContext

    var underlyingError: (any Error)? {
        cause.base
    }

    init(wrapping error: AnyError, context: _ErrorWrappingContext) {
        self.cause = error
        self.context = context
    }
}

private extension _ErrorCode {
    var identity: _ErrorIdentity {
        _AnyErrorCode(self).identity!
    }
}
