//
// Copyright (c) Vatsal Manot
//

import Testing
@testable import _ErrorXModule

@ErrorDomain("com.example.payment")
private enum PaymentDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case cardDeclined = "payment.card_declined"
    }

    enum Context {
        @ErrorContextKey("payment.processor", privacy: .private)
        static var processor: _TypedErrorContextKey<String>

        @ErrorContextKey("processor.response_code", privacy: .public)
        static var responseCode: _TypedErrorContextKey<String>
    }

    @ErrorModel(domain: PaymentDiagnostics.self)
    enum PaymentError {
        @ErrorCase(
            Codes.cardDeclined,
            summary: "Card was declined",
            reason: "The payment processor rejected the card."
        )
        @ErrorContext(Context.processor)
        @ErrorContext(Context.responseCode)
        case cardDeclined(processor: String, responseCode: String)
    }
}

@ErrorDomain("com.example.network")
private enum NetworkDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case httpStatus = "http.status"
    }

    enum Context {
        @ErrorContextKey("http.status_code", privacy: .public)
        static var statusCode: _TypedErrorContextKey<Int>
    }

    @ErrorModel(domain: NetworkDiagnostics.self)
    enum HTTPError {
        @ErrorCase(Codes.httpStatus, summary: "HTTP request failed")
        @ErrorContext(Context.statusCode)
        case status(statusCode: Int)
    }
}

@ErrorDomain("com.example.inventory")
private enum InventoryDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case reservationExpired = "inventory.reservation_expired"
    }

    @ErrorModel(domain: InventoryDiagnostics.self)
    enum InventoryError {
        @ErrorCase(
            Codes.reservationExpired,
            summary: "Inventory reservation expired"
        )
        case reservationExpired
    }
}

@ErrorDomain("com.example.checkout")
private enum CheckoutDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case submitFailed = "checkout.submit_failed"
        case cleanupReleaseHoldFailed = "checkout.cleanup.release_hold_failed"
    }

    enum Context {
        @ErrorContextKey("checkout.cart_id", privacy: .private)
        static var cartID: _TypedErrorContextKey<String>

        @ErrorContextKey("cleanup.phase", privacy: .public)
        static var cleanupPhase: _TypedErrorContextKey<String>
    }

    @ErrorModel(domain: CheckoutDiagnostics.self)
    enum CleanupError {
        @ErrorCase(
            Codes.cleanupReleaseHoldFailed,
            summary: "Checkout cleanup failed"
        )
        @ErrorContext(Context.cleanupPhase, parameter: "phase")
        case releaseHoldFailed(phase: String)
    }

    @ErrorModel(domain: CheckoutDiagnostics.self)
    enum SubmissionFailure {
        @ErrorCase(
            Codes.submitFailed,
            summary: "Checkout submission failed",
            reason: "Checkout could not complete after payment, inventory, and cleanup work."
        )
        @ErrorContext(Context.cartID)
        @ErrorTranslatedFrom(parameter: "payment")
        @ErrorPrimary(parameter: "transport")
        @ErrorParallel(parameter: "inventory")
        @ErrorSuppressed(parameter: "cleanup")
        case submitFailed(
            cartID: String,
            payment: PaymentDiagnostics.PaymentError,
            transport: NetworkDiagnostics.HTTPError,
            inventory: InventoryDiagnostics.InventoryError,
            cleanup: CleanupError
        )
    }
}

private enum CheckoutScenarios {
    @ErrorScenario("checkout.submit_failed")
    static var submitFailed: _ErrorReportScenarioIdentifier
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
                    responseCode: charge.responseCode
                )
            }

            return Receipt(id: "receipt_123")
        } catch let paymentError as PaymentDiagnostics.PaymentError {
            throw CheckoutDiagnostics.SubmissionFailure.submitFailed(
                cartID: cart.id,
                payment: paymentError,
                transport: .status(statusCode: 402),
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
        let report = error._errorReport(scenario: CheckoutScenarios.submitFailed)

        #expect(report.headlineIdentity?.domain.rawValue == "com.example.checkout")
        #expect(report.headlineIdentity?.code == "checkout.submit_failed")
        #expect(report.scenario?.stableIdentifier == "checkout.submit_failed")
        #expect(report.allIdentities.map(\.code) == [
            "checkout.submit_failed",
            "payment.card_declined",
            "http.status",
            "inventory.reservation_expired",
            "checkout.cleanup.release_hold_failed"
        ])
        #expect(report.identities(in: .translatedFrom).map(\.code) == ["payment.card_declined"])
        #expect(report.identities(in: .primary).map(\.code) == ["http.status"])
        #expect(report.identities(in: .parallel).map(\.code) == ["inventory.reservation_expired"])
        #expect(report.identities(in: .suppressed).map(\.code) == ["checkout.cleanup.release_hold_failed"])
        #expect(report.failures(of: PaymentDiagnostics.PaymentError.self).count == 1)
        #expect(report.failureContextOccurrences.map(\.context.key.rawValue).contains("checkout.cart_id"))
        #expect(report.failureContextOccurrences.map(\.context.key.rawValue).contains("payment.processor"))
        #expect(report.failureContextOccurrences.map(\.context.key.rawValue).contains("processor.response_code"))
        #expect(report.failureContextOccurrences.map(\.context.key.rawValue).contains("http.status_code"))
        #expect(report.failureContextOccurrences.map(\.context.key.rawValue).contains("cleanup.phase"))
        #expect(report.failureContextOccurrences(in: .primary).map(\.context.key.rawValue) == ["http.status_code"])
        #expect(report.projectedFailureContextOccurrences().map(\.context.key.rawValue) == [
            "processor.response_code",
            "http.status_code",
            "cleanup.phase"
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
