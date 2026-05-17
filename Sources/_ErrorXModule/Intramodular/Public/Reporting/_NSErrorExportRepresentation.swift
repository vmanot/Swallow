//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// NSError-compatible projection of an `_ErrorReport`.
public struct _NSErrorExportRepresentation {
    public var domain: String
    public var code: Int
    public var userInfo: [String: Any]

    public init(
        domain: String,
        code: Int,
        userInfo: [String: Any]
    ) {
        self.domain = domain
        self.code = code
        self.userInfo = userInfo
    }

    public init(
        _ report: _ErrorReport,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) {
        let error = report.root.base._errorXBase
        let customNSError = error as? CustomNSError
        let errorCode = report._primaryErrorCode
        let projectedCode = errorCode?._nsErrorIntegerCode

        if let identity = report.identity {
            self.domain = identity.domain.rawValue
            self.code = projectedCode ?? customNSError?.errorCode ?? 0
        } else if let customNSError {
            self.domain = type(of: customNSError).errorDomain
            self.code = customNSError.errorCode
        } else {
            self.domain = String(reflecting: Swift.type(of: error))
            self.code = 0
        }

        self.userInfo = customNSError?.errorUserInfo ?? [:]

        if let identity = report.identity {
            userInfo[_NSErrorExportRepresentation.errorCodeStringKey] = identity.code
        }

        if let scenario = report.scenario {
            userInfo[_NSErrorExportRepresentation.scenarioKey] = scenario.stableIdentifier
        }

        if !report.allIdentities.isEmpty {
            userInfo[_NSErrorExportRepresentation.identitiesKey] = report.allIdentities.map(\.description)
        }

        if !report.failureIdentityOccurrences.isEmpty {
            userInfo[_NSErrorExportRepresentation.failureIdentityOccurrencesKey] = report.failureIdentityOccurrences.map { occurrence in
                [
                    "path": occurrence.path,
                    "relationRoles": occurrence.relationRoles.map(\.description),
                    "identity": occurrence.identity.description
                ] as [String: Any]
            }
        }

        let projectedFailureContextOccurrences = report.projectedFailureContextOccurrences(using: contextProjectionPolicy)

        if !projectedFailureContextOccurrences.isEmpty {
            userInfo[_NSErrorExportRepresentation.failureContextOccurrencesKey] = projectedFailureContextOccurrences.map { occurrence in
                [
                    "path": occurrence.path,
                    "relationRoles": occurrence.relationRoles.map(\.description),
                    "key": occurrence.context.key.rawValue,
                    "value": occurrence.context.value.description,
                    "privacy": "\(occurrence.context.privacy)"
                ] as [String: Any]
            }
        }

        if let projectedCode {
            userInfo[_NSErrorExportRepresentation.errorCodeIntegerKey] = projectedCode
        }

        if let catalog = errorCode?._discoveredCatalog {
            userInfo[_NSErrorExportRepresentation.errorCodeCatalogKey] = catalog.allErrorCodes.map(\.stableIdentifier)
            userInfo[_NSErrorExportRepresentation.errorCodeCatalogIdentifierKey] = catalog.descriptor.catalogIdentifier
            userInfo[_NSErrorExportRepresentation.errorCodeCatalogEntriesKey] = catalog.descriptor.entries.map { entry in
                [
                    "stableIdentifier": entry.stableIdentifier,
                    "integerCode": entry.integerCode,
                    "identity": entry.identity?.description as Any
                ]
            }
        }

        if let presentation = report.presentation {
            if let summary = presentation.summary {
                userInfo[NSLocalizedDescriptionKey] = summary
            }

            if let reason = presentation.reason {
                userInfo[NSLocalizedFailureReasonErrorKey] = reason
            }

            if let debugDescription = presentation.debugDescription {
                userInfo[NSDebugDescriptionErrorKey] = debugDescription
            }

            if let helpAnchor = presentation.helpAnchor {
                userInfo[NSHelpAnchorErrorKey] = helpAnchor
            }
        }

        if !report.recoverySuggestions.isEmpty {
            userInfo[NSLocalizedRecoveryOptionsErrorKey] = report.recoverySuggestions.map(\.title)

            if let explanation = report.recoverySuggestions.lazy.compactMap(\.explanation).first {
                userInfo[NSLocalizedRecoverySuggestionErrorKey] = explanation
            }
        }

        let projectedContext = report.projectedContext(using: contextProjectionPolicy)

        if !projectedContext.isEmpty {
            userInfo[_NSErrorExportRepresentation.contextKey] = projectedContext.reduce(into: [String: String]()) {
                $0[$1.key.rawValue] = $1.value.description
            }
        }
    }
}

extension _NSErrorExportRepresentation {
    public static let errorCodeStringKey = "_ErrorX.errorCode"
    public static let errorCodeIntegerKey = "_ErrorX.errorCodeInteger"
    public static let errorCodeCatalogKey = "_ErrorX.errorCodeCatalog"
    public static let errorCodeCatalogIdentifierKey = "_ErrorX.errorCodeCatalogIdentifier"
    public static let errorCodeCatalogEntriesKey = "_ErrorX.errorCodeCatalogEntries"
    public static let contextKey = "_ErrorX.context"
    public static let scenarioKey = "_ErrorX.scenario"
    public static let identitiesKey = "_ErrorX.identities"
    public static let failureIdentityOccurrencesKey = "_ErrorX.failureIdentityOccurrences"
    public static let failureContextOccurrencesKey = "_ErrorX.failureContextOccurrences"

    public var nsError: NSError {
        NSError(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
    }
}

extension _ErrorReport {
    fileprivate var _primaryErrorCode: _AnyErrorCode? {
        chain.elements.lazy.compactMap {
            $0.base._errorCode
        }.first
    }
}

extension _AnyErrorCode {
    fileprivate var _discoveredCatalog: _AnyErrorCodeCatalog? {
        guard let catalog = Swift.type(of: base) as? any _ErrorCodeCatalogProtocol.Type else {
            return nil
        }

        return _AnyErrorCodeCatalog(catalog)
    }

    fileprivate var _nsErrorIntegerCode: Int? {
        _discoveredCatalog?.integerCode(for: self)
    }
}

extension Error {
    public func _nsErrorExportRepresentation(
        scenario: some _ErrorReportScenario,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> _NSErrorExportRepresentation {
        _NSErrorExportRepresentation(
            _ErrorReporting.report(self as any Swift.Error, scenario: scenario),
            contextProjectionPolicy: contextProjectionPolicy
        )
    }

    public func _nsErrorExportRepresentation(
        observation: _ErrorObservationContext = .init(),
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> _NSErrorExportRepresentation {
        _NSErrorExportRepresentation(
            _ErrorReporting.report(self as any Swift.Error, observation: observation),
            contextProjectionPolicy: contextProjectionPolicy
        )
    }
}
