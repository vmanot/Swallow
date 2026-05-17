//
// Copyright (c) Vatsal Manot
//

import Testing
@testable import _ErrorXModule

@ErrorDomain("com.example.billing.subscriptions")
private enum SubscriptionBillingDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case planUnavailable = "subscription.plan_unavailable"
        case paymentRequired = "subscription.payment_required"
        case activationFailed = "subscription.activation_failed"
    }

    enum Context {
        @ErrorContextKey("subscription.plan", privacy: .public)
        static var plan: _TypedErrorContextKey<String>

        @ErrorContextKey("billing.gateway", privacy: .private)
        static var gateway: _TypedErrorContextKey<String>

        @ErrorContextKey("billing.gateway_code", privacy: .public)
        static var gatewayCode: _TypedErrorContextKey<String>
    }

    @ErrorModel(domain: SubscriptionBillingDiagnostics.self)
    enum BillingError {
        @ErrorCase(Codes.planUnavailable, summary: "Subscription plan is unavailable")
        @ErrorContext(Context.plan, parameter: "planID")
        case planUnavailable(planID: String)

        @ErrorCase(Codes.paymentRequired, summary: "Subscription requires a payment update")
        @ErrorContext(Context.gateway, parameter: "processor")
        @ErrorContext(Context.gatewayCode, parameter: "responseCode")
        case paymentRequired(processor: String, responseCode: String)

        @ErrorCase("legacy.gateway_timeout", summary: "Billing gateway timed out")
        @ErrorContext(Context.gateway, parameter: "processor")
        case legacyGatewayTimeout(processor: String)
    }

    @ErrorModel(domain: SubscriptionBillingDiagnostics.self)
    enum ActivationFailure {
        @ErrorCase(Codes.activationFailed, summary: "Subscription activation failed")
        @ErrorPrimary(parameter: "primary")
        @ErrorFallbackAttempt(parameter: "legacyFallback")
        case activationFailed(primary: BillingError, legacyFallback: BillingError)
    }
}

private struct SubscriptionBillingService {
    private let catalog = PlanCatalog()
    private let gateway = BillingGateway(name: "stripe")

    func activate(
        _ request: SubscriptionRequest
    ) throws -> Subscription {
        guard catalog.contains(request.planID) else {
            throw SubscriptionBillingDiagnostics.BillingError.planUnavailable(
                planID: request.planID
            )
        }

        let result = gateway.authorize(customerID: request.customerID)

        guard result.isApproved else {
            throw SubscriptionBillingDiagnostics.BillingError.paymentRequired(
                processor: gateway.name,
                responseCode: result.responseCode
            )
        }

        return Subscription(id: "subscription_123", planID: request.planID)
    }

    func activateWithLegacyFallback(
        _ request: SubscriptionRequest
    ) throws -> Subscription {
        do {
            return try activate(request)
        } catch let error as SubscriptionBillingDiagnostics.BillingError {
            throw SubscriptionBillingDiagnostics.ActivationFailure.activationFailed(
                primary: error,
                legacyFallback: .legacyGatewayTimeout(processor: "legacy-gateway")
            )
        }
    }

    func refreshLegacyEntitlement(
        customerID: String
    ) throws {
        // During migration, this path still preserves its legacy literal code.
        throw SubscriptionBillingDiagnostics.BillingError.legacyGatewayTimeout(
            processor: gateway.name
        )
    }
}

private struct SubscriptionRequest: Hashable {
    var customerID: String
    var planID: String
}

private struct Subscription: Hashable {
    var id: String
    var planID: String
}

private struct PlanCatalog {
    func contains(
        _ planID: String
    ) -> Bool {
        planID == "pro"
    }
}

private struct BillingGateway {
    var name: String

    func authorize(
        customerID: String
    ) -> BillingGatewayResult {
        .init(isApproved: false, responseCode: "card_expired")
    }
}

private struct BillingGatewayResult: Hashable {
    var isApproved: Bool
    var responseCode: String
}

@Suite
struct SubscriptionBillingErrorModelExample {
    @Test
    func modeledErrorCanMixTypedAndLiteralCodeDeclarations() throws {
        let paymentRequired = try catchBillingError {
            _ = try SubscriptionBillingService().activate(
                .init(customerID: "customer_123", planID: "pro")
            )
        }
        let legacyTimeout = try catchBillingError {
            try SubscriptionBillingService().refreshLegacyEntitlement(
                customerID: "customer_123"
            )
        }

        #expect(paymentRequired._errorIdentity?.domain.rawValue == "com.example.billing.subscriptions")
        #expect(paymentRequired._errorIdentity?.code == "subscription.payment_required")
        #expect(_AnyErrorCodeCatalog(SubscriptionBillingDiagnostics.Codes.self).allErrorCodes.map(\.stableIdentifier) == [
            "subscription.plan_unavailable",
            "subscription.payment_required",
            "subscription.activation_failed"
        ])
        #expect(paymentRequired.errorContextBindings.map(\.key.rawValue) == ["billing.gateway", "billing.gateway_code"])
        #expect(paymentRequired.errorContextBindings.map(\.privacy) == [_ErrorContextPrivacy.private, .public])
        #expect(legacyTimeout._errorIdentity?.code == "legacy.gateway_timeout")
        #expect(legacyTimeout.errorContextBindings.map(\.key.rawValue) == ["billing.gateway"])
    }

    @Test
    func contextParameterCanUseAssociatedValueLocalName() throws {
        let error = try catchBillingError {
            _ = try SubscriptionBillingService().activate(
                .init(customerID: "customer_123", planID: "enterprise")
            )
        }

        #expect(error._errorIdentity?.code == "subscription.plan_unavailable")
        #expect(error.errorContextBindings.map(\.value) == [.string("enterprise")])
    }

    @Test
    func activationFailurePreservesFallbackAttemptRelation() throws {
        let error = try catchActivationFailure {
            _ = try SubscriptionBillingService().activateWithLegacyFallback(
                .init(customerID: "customer_123", planID: "pro")
            )
        }
        let report = _ErrorReporting.report(error)

        #expect(report.headlineIdentity?.code == "subscription.activation_failed")
        #expect(report.allIdentities.map(\.code) == [
            "subscription.activation_failed",
            "subscription.payment_required",
            "legacy.gateway_timeout"
        ])
        #expect(report.identities(in: .primary).map(\.code) == ["subscription.payment_required"])
        #expect(report.identities(in: .fallbackAttempt).map(\.code) == ["legacy.gateway_timeout"])
    }
}

private func catchBillingError(
    _ operation: () throws -> Void
) throws -> SubscriptionBillingDiagnostics.BillingError {
    do {
        try operation()
    } catch let error as SubscriptionBillingDiagnostics.BillingError {
        return error
    } catch {
        Issue.record("Unexpected error: \(error)")
    }

    throw SubscriptionBillingExampleFailure.expectedBillingError
}

private func catchActivationFailure(
    _ operation: () throws -> Void
) throws -> SubscriptionBillingDiagnostics.ActivationFailure {
    do {
        try operation()
    } catch let error as SubscriptionBillingDiagnostics.ActivationFailure {
        return error
    } catch {
        Issue.record("Unexpected error: \(error)")
    }

    throw SubscriptionBillingExampleFailure.expectedActivationFailure
}

private enum SubscriptionBillingExampleFailure: Error {
    case expectedBillingError
    case expectedActivationFailure
}
