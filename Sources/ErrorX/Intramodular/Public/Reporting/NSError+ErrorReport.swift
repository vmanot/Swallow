//
// Copyright (c) Vatsal Manot
//

import Foundation

extension ErrorReport {
  /// User-info keys written when an ``ErrorReport`` is bridged to `NSError`.
  public enum UserInfoKey {
    /// The report's stable string code.
    public static let code = "ErrorX.errorCode"

    /// The report's flattened, projected context.
    public static let context = "ErrorX.context"

    /// The scenario in which the error was observed.
    public static let scenario = "ErrorX.scenario"

    /// Every identity in depth-first error-tree order.
    public static let identities = "ErrorX.identities"

    /// Identity values paired with their error-tree paths.
    public static let identityOccurrences = "ErrorX.identityOccurrences"

    /// Context values paired with their error-tree paths.
    public static let contextOccurrences = "ErrorX.contextOccurrences"

    fileprivate static let all = [
      code,
      context,
      scenario,
      identities,
      identityOccurrences,
      contextOccurrences,
    ]
  }
}

extension NSError {
  /// Creates an `NSError` containing the information in `report`.
  public convenience init(
    _ report: ErrorReport,
    contextProjection: ErrorContext.Projection = .publicOnly
  ) {
    let projection = _NSErrorProjection(
      report,
      contextProjection: contextProjection
    )

    self.init(
      domain: projection.domain,
      code: projection.code,
      userInfo: projection.userInfo
    )
  }

  /// Observes `error` and creates its `NSError` representation.
  public convenience init(
    _ error: any Swift.Error,
    observation: ErrorObservation = .current,
    contextProjection: ErrorContext.Projection = .publicOnly
  ) {
    self.init(
      ErrorReport(error, observation: observation),
      contextProjection: contextProjection
    )
  }
}

private struct _NSErrorProjection {
  var domain: String
  var code: Int
  var userInfo: [String: Any]

  init(
    _ report: ErrorReport,
    contextProjection: ErrorContext.Projection
  ) {
    let error = report.error._errorXBase
    let nativeNSError = error._errorXNativeNSError
    let customNSError = error as? any CustomNSError

    if let identity = report.primaryIdentity {
      domain = identity.domain
      code = customNSError?.errorCode ?? nativeNSError?.code ?? 0
    } else if let nativeNSError {
      domain = nativeNSError.domain
      code = nativeNSError.code
    } else if let customNSError {
      domain = type(of: customNSError).errorDomain
      code = customNSError.errorCode
    } else {
      domain = String(reflecting: Swift.type(of: error))
      code = 0
    }

    userInfo = nativeNSError?.userInfo ?? customNSError?.errorUserInfo ?? [:]

    for key in ErrorReport.UserInfoKey.all {
      userInfo.removeValue(forKey: key)
    }

    // These keys describe the report's tree. Rebuild them rather than
    // preserving values supplied by a native or CustomNSError root that may
    // disagree with an explicit ErrorTreeProviding conformance.
    userInfo.removeValue(forKey: NSUnderlyingErrorKey)

    if #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *) {
      userInfo.removeValue(forKey: NSMultipleUnderlyingErrorsKey)
    }

    if let identity = report.primaryIdentity {
      userInfo[ErrorReport.UserInfoKey.code] = identity.code
    }

    if let scenario = report.observation.scenario {
      userInfo[ErrorReport.UserInfoKey.scenario] = scenario.identifier
    }

    if !report.identities.isEmpty {
      userInfo[ErrorReport.UserInfoKey.identities] = report.identities.map(\.description)
    }

    if !report.identityOccurrences.isEmpty {
      userInfo[ErrorReport.UserInfoKey.identityOccurrences] = report.identityOccurrences.map {
        occurrence in
        [
          "path": occurrence.path,
          "relationPath": occurrence.relationPath.map(\.description),
          "identity": occurrence.identity.description,
        ] as [String: Any]
      }
    }

    let contextOccurrences = report.contextOccurrences(projectedUsing: contextProjection)

    if !contextOccurrences.isEmpty {
      userInfo[ErrorReport.UserInfoKey.contextOccurrences] = contextOccurrences.map { occurrence in
        [
          "path": occurrence.path,
          "relationPath": occurrence.relationPath.map(\.description),
          "owner": occurrence.owner == .error ? "error" : "relation",
          "key": occurrence.entry.key.name,
          "value": occurrence.entry.value.description,
          "privacy": occurrence.entry.privacy.description,
        ] as [String: Any]
      }
    }

    if let presentation = report.presentation {
      if let message = presentation.message, !message.isEmpty {
        userInfo[NSLocalizedDescriptionKey] = message
      }

      if let failureReason = presentation.failureReason, !failureReason.isEmpty {
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
      }

      if let diagnosticDescription = presentation.diagnosticDescription,
        !diagnosticDescription.isEmpty
      {
        userInfo[NSDebugDescriptionErrorKey] = diagnosticDescription
      }

      if let helpAnchor = presentation.helpAnchor, !helpAnchor.isEmpty {
        userInfo[NSHelpAnchorErrorKey] = helpAnchor
      }
    }

    if !report.recoveryOptions.isEmpty {
      userInfo[NSLocalizedRecoveryOptionsErrorKey] = report.recoveryOptions.map(\.title)

      if let explanation = report.recoveryOptions.lazy.compactMap(\.explanation).first {
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = explanation
      }
    }

    let context = report.context.projected(using: contextProjection)

    if !context.isEmpty {
      userInfo[ErrorReport.UserInfoKey.context] = context.reduce(into: [String: String]()) {
        if $0[$1.key.name] == nil {
          $0[$1.key.name] = $1.value.description
        }
      }
    }

    let cause =
      report.errorTree.relations.first(where: { $0.kind == .cause })
      ?? report.errorTree.relations.first(where: { $0.kind == .translatedFrom })

    if let cause {
      userInfo[NSUnderlyingErrorKey] = Self._nsError(
        for: cause.subtree,
        contextProjection: contextProjection
      )
    }

    if #available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *) {
      let components = report.errorTree.relations.filter {
        $0.kind == .component || $0.kind == .concurrent
      }

      if !components.isEmpty {
        userInfo[NSMultipleUnderlyingErrorsKey] = components.map { relation in
          Self._nsError(
            for: relation.subtree,
            contextProjection: contextProjection
          )
        }
      }
    }
  }

  private static func _nsError(
    for tree: ErrorTree,
    contextProjection: ErrorContext.Projection
  ) -> NSError {
    let error = tree.root._errorXBase

    if tree.relations.isEmpty, let nativeNSError = error._errorXNativeNSError {
      return nativeNSError
    }

    let projection = Self(
      ErrorReport(error, observation: .init(), errorTree: tree),
      contextProjection: contextProjection
    )

    return NSError(
      domain: projection.domain,
      code: projection.code,
      userInfo: projection.userInfo
    )
  }
}
