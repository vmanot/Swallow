//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

private enum PaymentDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.payment")
  enum Codes: String {
    case cardDeclined = "payment.card_declined"
  }

  enum Context {
    static let processor = ErrorContext.Key<String>("payment.processor", privacy: .private)

    static let responseCode = ErrorContext.Key<String>("processor.response_code", privacy: .public)
  }

  @ErrorModel
  enum PaymentError {
    @ErrorCode(
      Codes.cardDeclined,
      message: "Card was declined",
      failureReason: "The payment processor rejected the card."
    )
    @ErrorContext(Context.processor)
    @ErrorContext(Context.responseCode)
    @ErrorRelation(.translatedFrom, error: "response")
    case cardDeclined(
      processor: String,
      responseCode: String,
      response: NetworkDiagnostics.HTTPError
    )
  }
}

private enum NetworkDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.network")
  enum Codes: String {
    case httpStatus = "http.status"
  }

  enum Context {
    static let statusCode = ErrorContext.Key<Int>("http.status_code", privacy: .public)
  }

  @ErrorModel
  enum HTTPError {
    @ErrorCode(Codes.httpStatus, message: "HTTP request failed")
    @ErrorContext(Context.statusCode)
    case status(statusCode: Int)
  }
}

private enum InventoryDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.inventory")
  enum Codes: String {
    case reservationExpired = "inventory.reservation_expired"
  }

  @ErrorModel
  enum InventoryError {
    @ErrorCode(
      Codes.reservationExpired,
      message: "Inventory reservation expired"
    )
    case reservationExpired
  }
}

private enum CheckoutDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.checkout")
  enum Codes: String {
    case submitFailed = "checkout.submit_failed"
    case cleanupReleaseHoldFailed = "checkout.cleanup.release_hold_failed"
  }

  enum Context {
    static let cartID = ErrorContext.Key<String>("checkout.cart_id", privacy: .private)

    static let cleanupPhase = ErrorContext.Key<String>("cleanup.phase", privacy: .public)
  }

  @ErrorModel
  enum CleanupError {
    @ErrorCode(
      Codes.cleanupReleaseHoldFailed,
      message: "Checkout cleanup failed"
    )
    @ErrorContext(Context.cleanupPhase, from: "phase")
    case releaseHoldFailed(phase: String)
  }

  @ErrorModel
  enum SubmissionFailure {
    @ErrorCode(
      Codes.submitFailed,
      message: "Checkout submission failed",
      failureReason: "Checkout could not complete after payment, inventory, and cleanup work."
    )
    @ErrorContext(Context.cartID)
    @ErrorRelation(.cause, error: "payment")
    @ErrorRelation(.concurrent, error: "inventory")
    @ErrorRelation(.suppressed, error: "cleanup")
    case submitFailed(
      cartID: String,
      payment: PaymentDiagnostics.PaymentError,
      inventory: InventoryDiagnostics.InventoryError,
      cleanup: CleanupError
    )
  }
}

private enum CheckoutScenarios {
  static let submitFailed = ErrorScenario("checkout.submit_failed")
}

private struct CheckoutService {
  private let inventory = InventoryService()
  private let payment = PaymentProcessor(name: "stripe")
  private let cleanup = CheckoutCleanupService()

  func submit(
    _ cart: Cart
  ) throws -> Receipt {
    do {
      try inventory.reserveItems(in: cart)

      let charge = payment.charge(cart)

      guard charge.isApproved else {
        throw PaymentDiagnostics.PaymentError.cardDeclined(
          processor: payment.name,
          responseCode: charge.responseCode,
          response: .status(statusCode: 402)
        )
      }

      return Receipt(id: "receipt_123")
    } catch let paymentError as PaymentDiagnostics.PaymentError {
      throw CheckoutDiagnostics.SubmissionFailure.submitFailed(
        cartID: cart.id,
        payment: paymentError,
        inventory: .reservationExpired,
        cleanup: cleanup.releaseHoldFailure()
      )
    }
  }
}

private struct Cart: Hashable {
  var id: String
  var customerID: String
  var items: [CartItem]
  var shippingAddress: ShippingAddress
}

private struct CartItem: Hashable {
  var sku: String
  var quantity: Int
  var unitPriceInCents: Int
}

private struct Receipt: Hashable {
  var id: String
}

private struct ShippingAddress: Hashable {
  var postalCode: String
  var countryCode: String
}

private struct InventoryService {
  func reserveItems(
    in cart: Cart
  ) throws {
    // A real checkout flow would reserve stock before charging the card.
  }
}

private struct CheckoutCleanupService {
  func releaseHoldFailure() -> CheckoutDiagnostics.CleanupError {
    .releaseHoldFailed(phase: "release-hold")
  }
}

private struct PaymentProcessor {
  var name: String

  func charge(
    _ cart: Cart
  ) -> PaymentResult {
    PaymentResult(isApproved: false, responseCode: "do_not_honor")
  }
}

private struct PaymentResult: Hashable {
  var isApproved: Bool
  var responseCode: String
}

@Suite
struct CheckoutErrorModelExample {
  @Test
  func checkoutSubmissionFailurePreservesComposedFailureStructure() throws {
    let error = try catchCheckoutSubmissionFailure {
      _ = try CheckoutService().submit(
        Cart(
          id: "cart_123",
          customerID: "customer_456",
          items: [
            .init(sku: "coffee-beans", quantity: 2, unitPriceInCents: 2100)
          ],
          shippingAddress: .init(postalCode: "10001", countryCode: "US")
        )
      )
    }
    let report = ErrorReport(error, observation: .init(scenario: CheckoutScenarios.submitFailed))

    #expect(report.primaryIdentity?.domain == "com.example.checkout")
    #expect(report.primaryIdentity?.code == "checkout.submit_failed")
    #expect(report.observation.scenario?.identifier == "checkout.submit_failed")
    #expect(
      report.identities.map(\.code) == [
        "checkout.submit_failed",
        "payment.card_declined",
        "http.status",
        "inventory.reservation_expired",
        "checkout.cleanup.release_hold_failed",
      ])
    #expect(
      report.causeIdentities.map(\.code) == [
        "checkout.submit_failed",
        "payment.card_declined",
        "http.status",
      ])
    #expect(report.identities(relatedBy: .translatedFrom).map(\.code) == ["http.status"])
    #expect(
      report.identities(relatedBy: .cause).map(\.code) == [
        "payment.card_declined",
        "http.status",
      ])
    #expect(
      report.identities(relatedBy: .concurrent).map(\.code) == [
        "inventory.reservation_expired"
      ])
    #expect(
      report.identities(relatedBy: .suppressed).map(\.code) == [
        "checkout.cleanup.release_hold_failed"
      ])
    #expect(report.errors(of: PaymentDiagnostics.PaymentError.self).count == 1)
    #expect(report.contextOccurrences.map(\.entry.key.name).contains("checkout.cart_id"))
    #expect(report.contextOccurrences.map(\.entry.key.name).contains("payment.processor"))
    #expect(report.contextOccurrences.map(\.entry.key.name).contains("processor.response_code"))
    #expect(report.contextOccurrences.map(\.entry.key.name).contains("http.status_code"))
    #expect(report.contextOccurrences.map(\.entry.key.name).contains("cleanup.phase"))
    #expect(
      report.contextOccurrences(relatedBy: .cause).map(\.entry.key.name) == [
        "payment.processor",
        "processor.response_code",
        "http.status_code",
      ])
    #expect(
      report.contextOccurrences(projectedUsing: .publicOnly).map(\.entry.key.name) == [
        "processor.response_code",
        "http.status_code",
        "cleanup.phase",
      ])
  }
}

private func catchCheckoutSubmissionFailure(
  _ operation: () throws -> Void
) throws -> CheckoutDiagnostics.SubmissionFailure {
  do {
    try operation()
  } catch let error as CheckoutDiagnostics.SubmissionFailure {
    return error
  } catch {
    Issue.record("Unexpected error: \(error)")
  }

  throw CheckoutExampleFailure.expectedSubmissionFailure
}

private enum CheckoutExampleFailure: Error {
  case expectedSubmissionFailure
}
