//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

private enum SubscriptionBillingDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.billing.subscriptions")
  enum Codes: String {
    case planUnavailable = "subscription.plan_unavailable"
    case paymentRequired = "subscription.payment_required"
    case activationFailed = "subscription.activation_failed"
  }

  enum Context {
    static let plan = ErrorContext.Key<String>("subscription.plan", privacy: .public)

    static let gateway = ErrorContext.Key<String>("billing.gateway", privacy: .private)

    static let gatewayCode = ErrorContext.Key<String>("billing.gateway_code", privacy: .public)
  }

  @ErrorModel(catalog: Codes.self)
  enum BillingError {
    @ErrorCode(Codes.planUnavailable, message: "Subscription plan is unavailable")
    @ErrorContext(Context.plan, from: "planID")
    case planUnavailable(planID: String)

    @ErrorCode(Codes.paymentRequired, message: "Subscription requires a payment update")
    @ErrorContext(Context.gateway, from: "processor")
    @ErrorContext(Context.gatewayCode, from: "responseCode")
    case paymentRequired(processor: String, responseCode: String)

    @ErrorCode("legacy.gateway_timeout", message: "Billing gateway timed out")
    @ErrorContext(Context.gateway, from: "processor")
    case legacyGatewayTimeout(processor: String)
  }

  @ErrorModel
  enum ActivationFailure {
    @ErrorCode(Codes.activationFailed, message: "Subscription activation failed")
    @ErrorRelation(.cause, error: "cause")
    @ErrorRelation(.fallback, error: "fallback")
    case activationFailed(cause: BillingError, fallback: BillingError)
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
        cause: error,
        fallback: .legacyGatewayTimeout(processor: "legacy-gateway")
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
    let paymentReport = ErrorReport(paymentRequired)
    let legacyReport = ErrorReport(legacyTimeout)

    #expect(ErrorIdentity(paymentRequired)?.domain == "com.example.billing.subscriptions")
    #expect(ErrorIdentity(paymentRequired)?.code == "subscription.payment_required")
    #expect(
      paymentReport.context.map(\.key.name) == ["billing.gateway", "billing.gateway_code"])
    #expect(paymentReport.context.map(\.privacy) == [ErrorContext.Privacy.private, .public])
    #expect(ErrorIdentity(legacyTimeout)?.code == "legacy.gateway_timeout")
    #expect(legacyReport.context.map(\.key.name) == ["billing.gateway"])
  }

  @Test
  func contextCanUseAssociatedValueLocalName() throws {
    let error = try catchBillingError {
      _ = try SubscriptionBillingService().activate(
        .init(customerID: "customer_123", planID: "enterprise")
      )
    }

    #expect(ErrorIdentity(error)?.code == "subscription.plan_unavailable")
    #expect(ErrorReport(error).context.map(\.value) == [.string("enterprise")])
  }

  @Test
  func activationFailurePreservesFallbackRelation() throws {
    let error = try catchActivationFailure {
      _ = try SubscriptionBillingService().activateWithLegacyFallback(
        .init(customerID: "customer_123", planID: "pro")
      )
    }
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.code == "subscription.activation_failed")
    #expect(
      report.identities.map(\.code) == [
        "subscription.activation_failed",
        "subscription.payment_required",
        "legacy.gateway_timeout",
      ])
    #expect(report.identities(relatedBy: .cause).map(\.code) == ["subscription.payment_required"])
    #expect(
      report.identities(relatedBy: .fallback).map(\.code) == ["legacy.gateway_timeout"])
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
