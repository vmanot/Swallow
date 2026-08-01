//
// Copyright (c) Vatsal Manot
//

import Foundation
import Testing

@testable import ErrorX

private enum GitHubAPIDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.github-api")
  enum Codes: String {
    case rateLimited = "github.rate_limited"
    case releaseUploadFailed = "github.release_upload_failed"
  }

  enum Context {
    static let statusCode = ErrorContext.Key<Int>("http.status_code", privacy: .public)

    static let remaining = ErrorContext.Key<Int>("github.rate_limit.remaining", privacy: .public)

    static let resetEpoch = ErrorContext.Key<Double>(
      "github.rate_limit.reset_epoch", privacy: .public)

    static let owner = ErrorContext.Key<String>("github.owner", privacy: .private)

    static let repository = ErrorContext.Key<String>("github.repository", privacy: .private)

    static let assetName = ErrorContext.Key<String>("github.release.asset_name", privacy: .private)

    static let assetByteCount = ErrorContext.Key<Int>(
      "github.release.asset_byte_count", privacy: .public)
  }

  @ErrorModel
  enum APIError {
    @ErrorCode(
      Codes.rateLimited,
      message: "GitHub API rate limit was exceeded",
      failureReason: "The upload cannot continue until the API rate limit resets."
    )
    @ErrorContext(Context.statusCode)
    @ErrorContext(Context.remaining)
    @ErrorContext(Context.resetEpoch)
    @ErrorRecoveryOption("Retry after the rate limit resets.")
    case rateLimited(statusCode: Int, remaining: Int, resetEpoch: Double)
  }

  @ErrorModel
  enum ReleaseUploadError {
    @ErrorCode(
      Codes.releaseUploadFailed,
      message: "Release asset upload failed"
    )
    @ErrorContext(Context.owner)
    @ErrorContext(Context.repository)
    @ErrorContext(Context.assetName)
    @ErrorContext(Context.assetByteCount)
    @ErrorCause("underlying")
    case uploadFailed(
      owner: String,
      repository: String,
      assetName: String,
      assetByteCount: Int,
      underlying: APIError
    )
  }
}

private enum GitHubAPIScenarios {
  static let releaseAssetUploadFailed = ErrorScenario("github.release_asset_upload_failed")
}

private struct GitHubReleaseClient {
  private let transport = GitHubTransport()

  func upload(
    _ asset: ReleaseAsset,
    to repository: Repository
  ) throws {
    do {
      try transport.upload(asset)
    } catch let error as GitHubAPIDiagnostics.APIError {
      // Credentials are deliberately not attached as diagnostic context.
      throw GitHubAPIDiagnostics.ReleaseUploadError.uploadFailed(
        owner: repository.owner,
        repository: repository.name,
        assetName: asset.name,
        assetByteCount: asset.byteCount,
        underlying: error
      )
    }
  }
}

private struct GitHubTransport {
  func upload(
    _ asset: ReleaseAsset
  ) throws {
    throw GitHubAPIDiagnostics.APIError.rateLimited(
      statusCode: 403,
      remaining: 0,
      resetEpoch: 1_800_000_000
    )
  }
}

private struct Repository: Hashable {
  var owner: String
  var name: String
}

private struct ReleaseAsset: Hashable {
  var name: String
  var byteCount: Int
}

@Suite
struct GitHubReleaseUploadErrorModelExample {
  @Test
  func sdkBoundaryPreservesCauseWhileExportingOnlySafeContext() throws {
    let repository = Repository(owner: "private-org", name: "internal-app")
    let asset = ReleaseAsset(name: "InternalApp.xcframework.zip", byteCount: 42_000_000)
    let error = try catchReleaseUploadError {
      try GitHubReleaseClient().upload(asset, to: repository)
    }
    let report = ErrorReport(
      error, observation: .init(scenario: GitHubAPIScenarios.releaseAssetUploadFailed))
    let diagnostic = report.diagnosticDescription(style: .detailed)
    let nsError = NSError(report)

    #expect(report.primaryIdentity?.code == "github.release_upload_failed")
    #expect(
      report.causeIdentities.map(\.code) == [
        "github.release_upload_failed",
        "github.rate_limited",
      ])
    #expect(report.firstError(of: GitHubAPIDiagnostics.APIError.self) != nil)
    #expect(report.observation.scenario == GitHubAPIScenarios.releaseAssetUploadFailed)

    #expect(report.context[GitHubAPIDiagnostics.Context.owner] == repository.owner)
    #expect(report.context.projected()[GitHubAPIDiagnostics.Context.owner] == nil)
    #expect(report.context.projected()[GitHubAPIDiagnostics.Context.statusCode] == 403)
    #expect(
      report.context.projected()[GitHubAPIDiagnostics.Context.assetByteCount] == asset.byteCount)
    #expect(!diagnostic.contains(repository.owner))
    #expect(!diagnostic.contains(repository.name))
    #expect(!diagnostic.contains(asset.name))
    #expect(diagnostic.contains("http.status_code: 403"))

    let exportedContext = try #require(
      nsError.userInfo[ErrorReport.UserInfoKey.context] as? [String: String]
    )

    #expect(exportedContext["http.status_code"] == "403")
    #expect(exportedContext["github.release.asset_byte_count"] == "42000000")
    #expect(exportedContext["github.owner"] == nil)
    #expect(nsError.userInfo[NSUnderlyingErrorKey] != nil)
  }
}

private func catchReleaseUploadError(
  _ operation: () throws -> Void
) throws -> GitHubAPIDiagnostics.ReleaseUploadError {
  do {
    try operation()
  } catch let error as GitHubAPIDiagnostics.ReleaseUploadError {
    return error
  } catch {
    Issue.record("Unexpected error: \(error)")
  }

  throw GitHubReleaseUploadExampleFailure.expectedReleaseUploadError
}

private enum GitHubReleaseUploadExampleFailure: Error {
  case expectedReleaseUploadError
}
