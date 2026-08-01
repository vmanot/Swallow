//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

@ErrorModel(domain: "com.example.network-client", allowingUnmodeledCases: true)
private enum NetworkClientError: Swift.Error, LocalizedError {
  @ErrorCode("network.invalid_url", message: "The URL is invalid.")
  @ErrorContext("url.input", privacy: .private)
  case invalidURL(String)

  @ErrorCode(
    "network.unacceptable_status_code", message: "HTTP response status code is not acceptable.")
  @ErrorContext("http.status_code", privacy: .public)
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
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.domain == "com.example.network-client")
    #expect(report.primaryIdentity?.code == "network.invalid_url")
    #expect(report.presentation?.message == "The URL is invalid.")
    #expect(
      report.context.values(for: "url.input").first == .string("http://example.com/private-token"))
    #expect(report.context.projected().values(for: "url.input").isEmpty)
  }

  @Test
  func unmodeledCasesKeepLocalizedErrorFallbackWithoutFakeIdentity() {
    let error = NetworkClientError.decoding(NetworkClientDecodeFailure())
    let report = ErrorReport(error)

    #expect(report.primaryIdentity == nil)
    #expect(
      report.presentation?.message == "Response decoding failed: JSON body could not be decoded.")
    #expect(report.context.isEmpty)
    #expect(
      error.diagnosticDescription() == "Response decoding failed: JSON body could not be decoded.")
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
