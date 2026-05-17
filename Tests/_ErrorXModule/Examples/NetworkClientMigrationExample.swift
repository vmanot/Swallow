//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing
@testable import _ErrorXModule

private enum NetworkClientContext {
    @ErrorContextKey("url.input", privacy: .private)
    static var urlInput: _TypedErrorContextKey<String>

    @ErrorContextKey("http.status_code", privacy: .public)
    static var statusCode: _TypedErrorContextKey<Int>
}

@ErrorModel("com.example.network-client", allowUnmodeledCases: true)
private enum NetworkClientError: Swift.Error, LocalizedError {
    @ErrorCase("network.invalid_url", summary: "The URL is invalid.")
    @ErrorContext(NetworkClientContext.urlInput)
    case invalidURL(String)

    @ErrorCase("network.unacceptable_status_code", summary: "HTTP response status code is not acceptable.")
    @ErrorContext(NetworkClientContext.statusCode)
    case unacceptableStatusCode(statusCode: Int)

    case decoding(Error)

    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "The URL is invalid."
            case .unacceptableStatusCode(let statusCode):
                return "Unexpected HTTP status code: \(statusCode)"
            case .decoding(let error):
                return "Response decoding failed: \(error.localizedDescription)"
        }
    }
}

private struct NetworkClient {
    func fetch(
        urlString: String,
        statusCode: Int
    ) throws -> String {
        guard urlString.hasPrefix("https://") else {
            throw NetworkClientError.invalidURL(urlString)
        }

        guard (200..<300).contains(statusCode) else {
            throw NetworkClientError.unacceptableStatusCode(statusCode: statusCode)
        }

        // A real client would decode the response body here.
        return "ok"
    }
}

@Suite
struct NetworkClientMigrationExample {
    @Test
    func partialModelingAddsIdentityToModeledCases() throws {
        let error = try catchNetworkClientError {
            _ = try NetworkClient().fetch(
                urlString: "http://example.com/private-token",
                statusCode: 200
            )
        }
        let report = _ErrorReporting.report(error)

        #expect(report.identity?.domain.rawValue == "com.example.network-client")
        #expect(report.identity?.code == "network.invalid_url")
        #expect(report.presentation?.summary == "The URL is invalid.")
        #expect(report.contextValue(for: NetworkClientContext.urlInput) == .string("http://example.com/private-token"))
        #expect(report.projectedContextValue(for: NetworkClientContext.urlInput) == nil)
    }

    @Test
    func unmodeledCasesKeepLocalizedErrorFallbackWithoutFakeIdentity() {
        let error = NetworkClientError.decoding(NetworkClientDecodeFailure())
        let report = _ErrorReporting.report(error)

        #expect(report.identity == nil)
        #expect(report.presentation?.summary == "Response decoding failed: JSON body could not be decoded.")
        #expect(report.context.isEmpty)
    }
}

private func catchNetworkClientError(
    _ operation: () throws -> Void
) throws -> NetworkClientError {
    do {
        try operation()
    } catch let error as NetworkClientError {
        return error
    } catch {
        Issue.record("Unexpected error: \(error)")
    }

    throw NetworkClientMigrationExampleFailure.expectedNetworkClientError
}

private struct NetworkClientDecodeFailure: LocalizedError {
    var errorDescription: String? {
        "JSON body could not be decoded."
    }
}

private enum NetworkClientMigrationExampleFailure: Error {
    case expectedNetworkClientError
}
